/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "botinventory.h"

#include "botutils.h"

#include "common/logging.h"
#include "common/settings.h"

#include "entities/char_entity.h"
#include "item_container.h"
#include "items/item_equipment.h"
#include "items/item_weapon.h"
#include "items/transactions/item_claim.h"
#include "lua/luautils.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "spell.h"
#include "utils/charutils.h"
#include "utils/squadutils.h"
#include "utils/zoneutils.h"
#include "entities/npc_entity.h"
#include "enums/item_flag.h"
#include "zone.h"
#include "zone_entities.h"
#include "common/utils.h"

#include <algorithm>
#include <array>
#include <fstream>
#include <iterator>
#include <unordered_map>
#include <unordered_set>

namespace botutils
{

namespace
{

constexpr float kVendorReachYalms = 6.0f;

// Containers a character can equip from.
constexpr std::array<uint8, 9> kEquipContainers = {
    LOC_INVENTORY, LOC_WARDROBE, LOC_WARDROBE2, LOC_WARDROBE3, LOC_WARDROBE4,
    LOC_WARDROBE5, LOC_WARDROBE6, LOC_WARDROBE7, LOC_WARDROBE8,
};

// Slots managed here, in the order they're filled (main before sub, so a
// two-handed main weapon correctly rules out a shield). Ranged/ammo are left
// for combat logic.
constexpr std::array<SLOTTYPE, 14> kManagedSlots = {
    SLOT_MAIN, SLOT_SUB, SLOT_HEAD, SLOT_BODY, SLOT_HANDS, SLOT_LEGS, SLOT_FEET,
    SLOT_NECK, SLOT_WAIST, SLOT_EAR1, SLOT_EAR2, SLOT_RING1, SLOT_RING2, SLOT_BACK,
};

auto liveBot(uint32 charId) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        return nullptr;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar || session->PChar->loc.zone == nullptr)
    {
        return nullptr;
    }

    return session->PChar.get();
}

// Same requirements charutils::EquipArmor enforces - checked up front so we
// only try items that will actually go on.
auto canWear(CCharEntity* PChar, CItemEquipment* PItem) -> bool
{
    const auto job      = static_cast<uint8>(PChar->GetMJob());
    const auto jobLevel = settings::get<bool>("map.DISABLE_GEAR_SCALING") ? PChar->GetMLevel() : PChar->jobs.job[job];

    return (PItem->getJobs() & (1 << (job - 1))) != 0 &&
           PItem->getReqLvl() <= jobLevel &&
           PItem->getSuperiorLevel() <= PChar->getMod(xi::Mod::SUPERIOR_LEVEL) &&
           PItem->isEquippableByRace(PChar->look.race);
}

// First-pass "how good is this item" - a generic stat sum, not job-tuned yet.
// Weapons are dominated by damage per delay; armour by DEF and stats. Item
// level breaks ties so newer gear wins over equivalent older gear.
auto scoreItem(CItemEquipment* PItem) -> float
{
    using xi::Mod;

    float score = PItem->getModifier(Mod::DEF) +
                  0.1f * (PItem->getModifier(Mod::HP) + PItem->getModifier(Mod::MP)) +
                  1.5f * (PItem->getModifier(Mod::STR) + PItem->getModifier(Mod::DEX) + PItem->getModifier(Mod::VIT) +
                          PItem->getModifier(Mod::AGI) + PItem->getModifier(Mod::INT) + PItem->getModifier(Mod::MND) +
                          PItem->getModifier(Mod::CHR)) +
                  0.5f * (PItem->getModifier(Mod::ACC) + PItem->getModifier(Mod::ATT) + PItem->getModifier(Mod::EVA)) +
                  0.25f * PItem->getReqLvl();

    if (auto* PWeapon = dynamic_cast<CItemWeapon*>(PItem))
    {
        const float delay = std::max<float>(PWeapon->getDelay(), 1.0f);
        score += 4.0f * PWeapon->getDamage() * 240.0f / delay;
    }

    return score;
}

auto equippedItems(CCharEntity* PChar) -> std::unordered_set<CItem*>
{
    std::unordered_set<CItem*> result;
    for (uint8 slot = SLOT_MAIN; slot <= SLOT_BACK; ++slot)
    {
        if (auto* PItem = PChar->getEquip(static_cast<SLOTTYPE>(slot)))
        {
            result.insert(PItem);
        }
    }
    return result;
}

auto equipBestGear(CCharEntity* PChar) -> uint8
{
    uint8 changed = 0;

    for (const auto slot : kManagedSlots)
    {
        // A two-handed main weapon blocks the sub slot.
        if (slot == SLOT_SUB)
        {
            if (auto* PMain = dynamic_cast<CItemWeapon*>(PChar->getEquip(SLOT_MAIN)); PMain && PMain->isTwoHanded())
            {
                continue;
            }
        }

        const auto  equipped     = equippedItems(PChar);
        auto*       PCurrent     = PChar->getEquip(slot);
        float       bestScore    = PCurrent ? scoreItem(PCurrent) : -1.0f;
        uint8       bestContainer = 0;
        uint8       bestSlot      = 0;

        for (const auto containerId : kEquipContainers)
        {
            auto* PContainer = PChar->getStorage(containerId);
            if (PContainer == nullptr)
            {
                continue;
            }

            for (uint8 i = 1; i <= PContainer->GetSize(); ++i)
            {
                auto* PItem = dynamic_cast<CItemEquipment*>(PContainer->GetItem(i));
                if (PItem == nullptr || equipped.contains(PItem) || (PItem->getEquipSlotId() & (1 << slot)) == 0)
                {
                    continue;
                }

                // Off-hand weapons need dual wield and their own rules - only
                // shields/grips go in the sub slot for now.
                if (slot == SLOT_SUB && dynamic_cast<CItemWeapon*>(PItem) != nullptr)
                {
                    continue;
                }

                if (!canWear(PChar, PItem))
                {
                    continue;
                }

                const float score = scoreItem(PItem);
                if (score > bestScore)
                {
                    bestScore     = score;
                    bestContainer = containerId;
                    bestSlot      = i;
                }
            }
        }

        if (bestSlot != 0)
        {
            auto* PCandidate = PChar->getStorage(bestContainer)->GetItem(bestSlot);
            charutils::EquipItem(PChar, bestSlot, slot, bestContainer);

            if (PChar->getEquip(slot) == PCandidate)
            {
                ++changed;
            }
        }
    }

    if (changed > 0)
    {
        // Same follow-up the real client's equip packet gets (GP_CLI_COMMAND_EQUIP_SET).
        luautils::CheckForGearSet(PChar);
        PChar->UpdateHealth();
        PChar->retriggerLatents = true;
    }

    return changed;
}

// item id -> spell it teaches (0 = not a spell scroll); static data, cached.
std::unordered_map<uint16, uint16> g_scrollSpells;

auto scrollSpell(uint16 itemId) -> uint16
{
    if (const auto it = g_scrollSpells.find(itemId); it != g_scrollSpells.end())
    {
        return it->second;
    }

    const auto spellId      = squadutils::ScrollSpellId(itemId);
    g_scrollSpells[itemId] = spellId;
    return spellId;
}

// A player can learn a scroll if any of their jobs is high enough to use it.
auto canLearn(CCharEntity* PChar, uint16 spellId) -> bool
{
    for (uint8 job = 1; job < MAX_JOBTYPE; ++job)
    {
        if (spell::CanUseSpellWith(static_cast<SpellID>(spellId), static_cast<xi::Job>(job), PChar->jobs.job[job]))
        {
            return true;
        }
    }

    return false;
}

auto learnScrolls(CCharEntity* PChar) -> uint8
{
    uint8 learned = 0;

    auto* PInventory = PChar->getStorage(LOC_INVENTORY);
    if (PInventory == nullptr)
    {
        return 0;
    }

    for (uint8 i = 1; i <= PInventory->GetSize(); ++i)
    {
        auto* PItem = PInventory->GetItem(i);
        if (PItem == nullptr)
        {
            continue;
        }

        const auto spellId = scrollSpell(PItem->getID());
        if (spellId == 0 || charutils::hasSpell(PChar, spellId) || !canLearn(PChar, spellId))
        {
            continue;
        }

        auto tx = ItemClaimTransaction::start(PChar);
        if (!tx || !tx->take(LOC_INVENTORY, i, 1) || !tx->commit())
        {
            continue;
        }

        if (charutils::addSpell(PChar, spellId))
        {
            charutils::SaveSpell(PChar, spellId);
            ++learned;
        }
    }

    return learned;
}

// ---- keepers vs loot ----

auto isKeeper(CCharEntity* PChar, CItem* PItem, const std::unordered_set<CItem*>& equipped) -> bool
{
    if (equipped.contains(PItem))
    {
        return true;
    }

    // Gear it can wear now or once it levels (job + race match).
    if (auto* PEquip = dynamic_cast<CItemEquipment*>(PItem))
    {
        const auto job = static_cast<uint8>(PChar->GetMJob());
        if ((PEquip->getJobs() & (1 << (job - 1))) != 0 && PEquip->isEquippableByRace(PChar->look.race))
        {
            return true;
        }
    }

    // Spell scrolls any of its jobs will be able to learn.
    if (const auto spellId = scrollSpell(PItem->getID()); spellId != 0)
    {
        for (uint8 job = 1; job < MAX_JOBTYPE; ++job)
        {
            if (spell::CanUseSpellWith(static_cast<SpellID>(spellId), static_cast<xi::Job>(job), 99))
            {
                return true;
            }
        }
    }

    return false;
}

auto isSellable(CItem* PItem) -> bool
{
    return !PItem->hasFlag(ItemFlag::NoSale) && PItem->getBasePrice() > 0;
}

auto lootValue(CItem* PItem) -> uint32
{
    return isSellable(PItem) ? PItem->getBasePrice() * PItem->getQuantity() : 0;
}

// ---- vendors ----

std::unordered_map<uint16, std::vector<position_t>> g_vendors;

auto withinVendorReach(CCharEntity* PChar) -> bool
{
    for (const auto& pos : GetBotVendors(static_cast<uint16>(PChar->getZone())))
    {
        if (distance(PChar->loc.p, pos) <= kVendorReachYalms)
        {
            return true;
        }
    }

    return false;
}

} // namespace

auto GetBotFreeSlots(uint32 charId) -> uint8
{
    auto* PChar = liveBot(charId);
    return PChar ? PChar->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() : 0;
}

auto TossBotJunk(uint32 charId, uint32 maxValue, uint8 wantFree) -> uint8
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return 0;
    }

    auto*      PInventory = PChar->getStorage(LOC_INVENTORY);
    const auto equipped   = equippedItems(PChar);

    std::vector<std::pair<uint32, uint8>> junk; // value, slot
    for (uint8 i = 1; i <= PInventory->GetSize(); ++i)
    {
        auto* PItem = PInventory->GetItem(i);
        if (PItem != nullptr && !isKeeper(PChar, PItem, equipped) && lootValue(PItem) < maxValue)
        {
            junk.emplace_back(lootValue(PItem), i);
        }
    }

    std::sort(junk.begin(), junk.end());

    uint8 tossed = 0;
    for (const auto& [value, slot] : junk)
    {
        if (PInventory->GetFreeSlotsCount() >= wantFree)
        {
            break;
        }

        auto tx = ItemClaimTransaction::start(PChar);
        auto* PItem = PInventory->GetItem(slot);
        if (tx && PItem && tx->take(LOC_INVENTORY, slot, PItem->getQuantity()) && tx->commit())
        {
            ++tossed;
        }
    }

    return tossed;
}

auto GetBotSellableValue(uint32 charId) -> uint32
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return 0;
    }

    auto*      PInventory = PChar->getStorage(LOC_INVENTORY);
    const auto equipped   = equippedItems(PChar);

    uint32 total = 0;
    for (uint8 i = 1; i <= PInventory->GetSize(); ++i)
    {
        auto* PItem = PInventory->GetItem(i);
        if (PItem != nullptr && !isKeeper(PChar, PItem, equipped))
        {
            total += lootValue(PItem);
        }
    }

    return total;
}

auto SellBotItems(uint32 charId) -> BotSaleResult
{
    BotSaleResult result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr || !withinVendorReach(PChar))
    {
        return result;
    }

    auto*      PInventory = PChar->getStorage(LOC_INVENTORY);
    const auto equipped   = equippedItems(PChar);

    for (uint8 i = 1; i <= PInventory->GetSize(); ++i)
    {
        auto* PItem = PInventory->GetItem(i);
        if (PItem == nullptr || isKeeper(PChar, PItem, equipped) || !isSellable(PItem))
        {
            continue;
        }

        // Same transaction shape as GP_CLI_COMMAND_SHOP_SELL_SET, at base price.
        const uint32 quantity = PItem->getQuantity();
        const uint32 gil      = PItem->getBasePrice() * quantity;

        auto tx = ItemClaimTransaction::start(PChar);
        if (tx && tx->take(LOC_INVENTORY, i, quantity) && tx->earn(gil) && tx->commit())
        {
            ++result.sold;
            result.gil += gil;
        }
    }

    return result;
}

auto GetBotVendors(uint16 zoneId) -> std::vector<position_t>
{
    if (const auto it = g_vendors.find(zoneId); it != g_vendors.end())
    {
        return it->second;
    }

    std::vector<position_t> vendors;

    if (auto* PZone = zoneutils::GetZone(static_cast<xi::ZoneId>(zoneId)))
    {
        const auto zoneName = PZone->getName();

        // clang-format off
        PZone->GetZoneEntities()->ForEachNpc([&](CNpcEntity* PNpc)
        {
            if (PNpc->status != xi::Status::Normal)
            {
                return;
            }

            std::ifstream file(fmt::format("./scripts/zones/{}/npcs/{}.lua", zoneName, PNpc->getName()));
            if (!file)
            {
                return;
            }

            const std::string script((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
            if (script.find("xi.shop.general") != std::string::npos)
            {
                vendors.push_back(PNpc->loc.p);
            }
        });
        // clang-format on
    }

    g_vendors[zoneId] = vendors;
    return vendors;
}

auto ManageBotInventory(uint32 charId) -> BotInventoryResult
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return {};
    }

    BotInventoryResult result;
    result.learned  = learnScrolls(PChar);
    result.equipped = equipBestGear(PChar);

    return result;
}

auto GetBotItems(uint32 charId) -> std::vector<BotItemInfo>
{
    std::vector<BotItemInfo> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return result;
    }

    std::unordered_map<CItem*, int8> equippedSlot;
    for (uint8 slot = SLOT_MAIN; slot <= SLOT_BACK; ++slot)
    {
        if (auto* PItem = PChar->getEquip(static_cast<SLOTTYPE>(slot)))
        {
            equippedSlot[PItem] = static_cast<int8>(slot);
        }
    }

    for (const auto containerId : kEquipContainers)
    {
        auto* PContainer = PChar->getStorage(containerId);
        if (PContainer == nullptr)
        {
            continue;
        }

        for (uint8 i = 1; i <= PContainer->GetSize(); ++i)
        {
            if (auto* PItem = PContainer->GetItem(i))
            {
                const auto it = equippedSlot.find(PItem);
                result.push_back({ containerId, i, PItem->getID(), PItem->getName(), PItem->getQuantity(),
                                   it != equippedSlot.end() ? it->second : static_cast<int8>(-1) });
            }
        }
    }

    return result;
}

} // namespace botutils
