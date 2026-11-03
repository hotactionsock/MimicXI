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
#include "botlog.h"
#include "trade_container.h"
#include "utils/itemutils.h"
#include "packets/c2s/0x083_shop_buy.h"
#include "packets/basic.h"
#include "packet_system.h"

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
#include <cmath>
#include <format>
#include <array>
#include <fstream>
#include <iterator>
#include <limits>
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

template <typename Slots, typename Scorer>
auto equipBest(CCharEntity* PChar, const Slots& slots, Scorer&& scoreItem) -> uint8
{
    uint8 changed = 0;

    for (const auto slot : slots)
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

                const auto name = HumanName(PCandidate->getName());
                LogBotEvent(PChar->id, BotLogLevel::Notable, "gear", "equipped", std::format("{} equipped {}", PChar->getName(), name),
                            std::format(R"({{"item_id":{},"item":"{}","slot":{}}})", PCandidate->getID(), JsonEscape(name), static_cast<uint8>(slot)));
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

auto equipBestGear(CCharEntity* PChar) -> uint8
{
    return equipBest(PChar, kManagedSlots, scoreItem);
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

            if (auto* PSpell = spell::GetSpell(static_cast<SpellID>(spellId)))
            {
                const auto name = HumanName(PSpell->getName());
                LogBotEvent(PChar->id, BotLogLevel::Notable, "magic", "learned_spell", std::format("{} learned {}", PChar->getName(), name),
                            std::format(R"({{"spell_id":{},"spell":"{}"}})", spellId, JsonEscape(name)));
            }
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

// A public place in the zone to judge reachability from: the zone line or
// city landmark (home point, Mog House exit, auction house) nearest `around`.
auto publicReference(CZone* PZone, const position_t& around) -> Maybe<position_t>
{
    Maybe<position_t> best;
    float             bestDist = std::numeric_limits<float>::max();
    const auto        consider = [&](const position_t& pos)
    {
        const float d = distance(pos, around, true);
        if (d < bestDist)
        {
            bestDist = d;
            best     = pos;
        }
    };

    for (const auto& line : GetBotZoneLines(PZone->GetID()))
    {
        consider(line.origin);
    }

    for (const auto& spot : GetBotSocialSpots(PZone->GetID()))
    {
        consider(spot.pos);
    }

    if (best)
    {
        if (const auto floor = PZone->navMesh()->findClosestValidPoint(*best))
        {
            return floor;
        }
    }

    return best;
}

// Where a customer stands to talk to a shop NPC. Shopkeepers stand behind
// their counters, and the navmesh often covers the counter top (and joins it to
// the floor behind) - walking to the NPC's own position ends with the bot on
// the counter. Instead: a walkable floor point a few yalms from the NPC, at its
// own floor height, that can be walked to from the public part of the zone
// without climbing over anything (pathPeak) - i.e. the customer side, not the
// shopkeeper's side. Tried from the way the NPC faces outward, around both
// sides. Falls back to the NPC position.
auto customerSpot(CZone* PZone, const CBaseEntity* PNpc) -> position_t
{
    const position_t& npc = PNpc->loc.p;
    if (PZone == nullptr || PZone->navMesh() == nullptr)
    {
        return npc;
    }

    constexpr float kMaxClimb = 0.5f; // a path rising this far above both its ends is climbing something

    const auto reference = publicReference(PZone, npc);
    const auto walkable  = [&](const position_t& spot) -> bool
    {
        if (!reference)
        {
            return true; // nothing to judge by - trust the height check alone
        }

        const auto peak = PZone->navMesh()->pathPeak(*reference, spot);
        return peak && *peak >= std::min(reference->y, spot.y) - kMaxClimb;
    };

    constexpr std::array<float, 3> kDistances  = { 2.5f, 3.5f, 4.0f }; // + walk slack, inside the 6y shop reach
    constexpr std::array<int, 9>   kTurns      = { 0, 16, -16, 32, -32, 64, -64, 96, -96 }; // rotation units (256 = full turn)
    constexpr float                kMaxSnap    = 1.0f;                                       // the floor must be right there
    constexpr float                kMaxHeight  = 0.6f;                                       // same floor as the NPC

    for (const int turn : kTurns)
    {
        const auto  rotation = static_cast<uint8>(npc.rotation + turn);
        const float radians  = 2.0f * static_cast<float>(M_PI) - rotationToRadian(rotation);

        for (const float dist : kDistances)
        {
            position_t probe = npc;
            probe.x += cosf(radians) * dist;
            probe.z += sinf(radians) * dist;

            const auto floor = PZone->navMesh()->findClosestValidPoint(probe);
            if (!floor)
            {
                continue;
            }

            if (distance(*floor, probe, true) <= kMaxSnap && std::abs(floor->y - npc.y) <= kMaxHeight && walkable(*floor))
            {
                position_t spot = *floor;
                spot.rotation   = worldAngle(spot, npc); // facing the shopkeeper
                return spot;
            }
        }
    }

    return npc;
}

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
        if (PItem == nullptr)
        {
            continue;
        }

        const auto itemId   = PItem->getID();
        const auto quantity = PItem->getQuantity();
        const auto name     = HumanName(PItem->getName());
        if (tx && tx->take(LOC_INVENTORY, slot, quantity) && tx->commit())
        {
            ++tossed;
            LogBotEvent(PChar->id, BotLogLevel::Detail, "item", "tossed", std::format("{} threw away {} x{}", PChar->getName(), name, quantity),
                        std::format(R"({{"item_id":{},"item":"{}","quantity":{}}})", itemId, JsonEscape(name), quantity));
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

    if (result.sold > 0)
    {
        LogBotEvent(PChar->id, BotLogLevel::Notable, "item", "sold",
                    std::format("{} sold {} stack{} of loot to a vendor for {} gil", PChar->getName(), result.sold, result.sold == 1 ? "" : "s", result.gil),
                    std::format(R"({{"stacks":{},"gil":{}}})", result.sold, result.gil));
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
                vendors.push_back(customerSpot(PZone, PNpc));
            }
        });
        // clang-format on
    }

    g_vendors[zoneId] = vendors;
    return vendors;
}

namespace
{

constexpr std::array<SLOTTYPE, 2> kWeaponSlots = { SLOT_MAIN, SLOT_SUB };

// Armour/accessory slots a gear set swaps (weapons, ranged and ammo excluded).
constexpr std::array<SLOTTYPE, 12> kSetSlots = {
    SLOT_HEAD, SLOT_BODY, SLOT_HANDS, SLOT_LEGS, SLOT_FEET, SLOT_NECK,
    SLOT_WAIST, SLOT_EAR1, SLOT_EAR2, SLOT_RING1, SLOT_RING2, SLOT_BACK,
};

struct PlannedItem
{
    uint8  container{};
    uint8  slot{}; // 0 = nothing planned for this equip slot
    uint16 itemId{};
};

using GearSetPlan = std::array<PlannedItem, SLOT_BACK + 1>;

std::unordered_map<uint32, std::unordered_map<std::string, GearSetPlan>> g_gearPlans;

// The weights each bot's plans were made with (for judging shop items).
std::unordered_map<uint32, std::vector<std::pair<std::string, BotGearWeights>>> g_gearWeights;
std::unordered_map<uint32, std::string>                                         g_gearWeaponSet;

auto weightedScore(CItemEquipment* PItem, const BotGearWeights& weights) -> float
{
    float score = 0.0f;
    for (const auto& [mod, weight] : weights.mods)
    {
        score += weight * PItem->getModifier(static_cast<xi::Mod>(mod));
    }

    if (auto* PWeapon = dynamic_cast<CItemWeapon*>(PItem); PWeapon && weights.weaponDps != 0.0f)
    {
        const float delay = std::max<float>(PWeapon->getDelay(), 1.0f);
        score += weights.weaponDps * PWeapon->getDamage() * 240.0f / delay;
    }

    // Tie-break: newer gear over equivalent older gear.
    return score + 0.01f * PItem->getReqLvl();
}

auto planSet(CCharEntity* PChar, const BotGearWeights& weights) -> GearSetPlan
{
    GearSetPlan             plan{};
    std::unordered_set<CItem*> used;

    for (const auto slot : kSetSlots)
    {
        float       bestScore = -std::numeric_limits<float>::infinity();
        PlannedItem best{};
        CItem*      bestItem = nullptr;

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
                if (PItem == nullptr || used.contains(PItem) || (PItem->getEquipSlotId() & (1 << slot)) == 0 || !canWear(PChar, PItem))
                {
                    continue;
                }

                const float score = weightedScore(PItem, weights);
                if (score > bestScore)
                {
                    bestScore = score;
                    best      = { containerId, i, PItem->getID() };
                    bestItem  = PItem;
                }
            }
        }

        if (bestItem != nullptr)
        {
            plan[slot] = best;
            used.insert(bestItem);
        }
    }

    return plan;
}

// The other half of a paired slot (ears, rings), or the slot itself.
auto pairedSlot(SLOTTYPE slot) -> SLOTTYPE
{
    switch (slot)
    {
        case SLOT_EAR1:
            return SLOT_EAR2;
        case SLOT_EAR2:
            return SLOT_EAR1;
        case SLOT_RING1:
            return SLOT_RING2;
        case SLOT_RING2:
            return SLOT_RING1;
        default:
            return slot;
    }
}

} // namespace

auto PlanBotGear(uint32 charId, const std::vector<std::pair<std::string, BotGearWeights>>& sets, const std::string& weaponSet) -> uint8
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return 0;
    }

    uint8 changed = 0;
    auto& plans   = g_gearPlans[charId];

    g_gearWeights[charId]   = sets;
    g_gearWeaponSet[charId] = weaponSet;

    // Items already in some set, to log only genuinely new gear afterwards.
    const bool                 hadPlans = !plans.empty();
    std::unordered_set<uint16> before;
    for (const auto& [name, plan] : plans)
    {
        for (const auto& item : plan)
        {
            if (item.slot != 0)
            {
                before.insert(item.itemId);
            }
        }
    }

    plans.clear();

    for (const auto& [name, weights] : sets)
    {
        if (name == weaponSet)
        {
            changed = equipBest(PChar, kWeaponSlots,
                                [&weights](CItemEquipment* PItem)
                                {
                                    return weightedScore(PItem, weights);
                                });
        }
    }

    for (const auto& [name, weights] : sets)
    {
        plans[name] = planSet(PChar, weights);
    }

    if (hadPlans)
    {
        std::unordered_set<uint16> logged;
        for (const auto& [setName, plan] : plans)
        {
            for (const auto& item : plan)
            {
                if (item.slot == 0 || before.contains(item.itemId) || logged.contains(item.itemId))
                {
                    continue;
                }

                logged.insert(item.itemId);
                if (auto* PItem = PChar->getStorage(item.container)->GetItem(item.slot))
                {
                    const auto itemName = HumanName(PItem->getName());
                    LogBotEvent(PChar->id, BotLogLevel::Notable, "gear", "new_gear",
                                std::format("{} added {} to their {} gear", PChar->getName(), itemName, setName),
                                std::format(R"({{"item_id":{},"item":"{}","set":"{}"}})", item.itemId, JsonEscape(itemName), JsonEscape(setName)));
                }
            }
        }
    }

    return changed;
}

auto EquipBotGearSet(uint32 charId, const std::string& name) -> uint8
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return 0;
    }

    const auto botIt = g_gearPlans.find(charId);
    if (botIt == g_gearPlans.end())
    {
        return 0;
    }

    const auto setIt = botIt->second.find(name);
    if (setIt == botIt->second.end())
    {
        return 0;
    }

    uint8 changed = 0;
    for (const auto slot : kSetSlots)
    {
        const auto& planned = setIt->second[slot];
        if (planned.slot == 0)
        {
            continue;
        }

        auto* PContainer = PChar->getStorage(planned.container);
        auto* PItem      = PContainer ? PContainer->GetItem(planned.slot) : nullptr;
        if (PItem == nullptr || PItem->getID() != planned.itemId || PChar->getEquip(slot) == PItem)
        {
            continue; // moved/gone since planning, or already on
        }

        // An earring/ring worn in the paired slot has to come off there first
        // (the engine won't equip one item into two slots).
        const auto other = pairedSlot(slot);
        if (other != slot && PChar->getEquip(other) == PItem)
        {
            charutils::UnequipItem(PChar, other, Recalculate::No);
        }

        charutils::EquipItem(PChar, planned.slot, slot, planned.container);
        if (PChar->getEquip(slot) == PItem)
        {
            ++changed;
        }
    }

    if (changed > 0)
    {
        luautils::CheckForGearSet(PChar);
        PChar->UpdateHealth();
        PChar->retriggerLatents = true;
    }

    return changed;
}

void ForgetBotGear(uint32 charId)
{
    g_gearPlans.erase(charId);
    g_gearWeights.erase(charId);
    g_gearWeaponSet.erase(charId);
}

// ---- Shopping ---------------------------------------------------------------

namespace
{

constexpr float kShopReachYalms = 6.0f;

std::unordered_map<uint16, std::vector<BotShop>> g_shops;

} // namespace

auto GetBotShops(uint16 zoneId) -> std::vector<BotShop>
{
    if (const auto it = g_shops.find(zoneId); it != g_shops.end())
    {
        return it->second;
    }

    std::vector<BotShop> shops;

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
            if (script.find("xi.shop.general(") != std::string::npos || script.find("xi.shop.nation(") != std::string::npos)
            {
                shops.push_back({ PNpc->id, customerSpot(PZone, PNpc) });
            }
        });
        // clang-format on
    }

    g_shops[zoneId] = shops;
    return shops;
}

auto BrowseBotShop(uint32 charId, uint32 npcId) -> std::vector<BotShopItem>
{
    std::vector<BotShopItem> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead() || PChar->isInEvent())
    {
        return result;
    }

    auto* PNpc = PChar->loc.zone->GetEntity(EntityTargId(npcId), TYPE_NPC);
    if (PNpc == nullptr || PNpc->id != npcId || distance(PChar->loc.p, PNpc->loc.p) > kShopReachYalms)
    {
        return result;
    }

    // Talk to it, as a player clicking the NPC would.
    PChar->Container->Clean();
    luautils::OnTrigger(PChar, PNpc);

    // A script that started a cutscene or menu event instead: close it.
    if (PChar->isInEvent())
    {
        PChar->endCurrentEvent();
    }

    if (PChar->Container->getShopVendorId() != npcId)
    {
        return result; // not a shop after all
    }

    for (uint8 i = 0; i < PChar->Container->getExSize(); ++i)
    {
        const uint16 itemId = PChar->Container->getItemID(i);
        const auto*  PItem  = xi::items::lookup(itemId);
        if (itemId == 0 || PItem == nullptr)
        {
            continue;
        }

        result.push_back({ i, itemId, PChar->Container->getQuantity(i), HumanName(PItem->getName()) });
    }

    return result;
}

auto BuyBotShopItem(uint32 charId, uint8 index, uint32 quantity) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || quantity == 0 || index >= PChar->Container->getExSize())
    {
        return false;
    }

    const uint16 itemId    = PChar->Container->getItemID(index);
    const uint32 price     = PChar->Container->getQuantity(index);
    auto*        PGilBefore = PChar->getStorage(LOC_INVENTORY)->GetItem(0); // slot 0 = gil
    const uint32 gilBefore  = PGilBefore ? PGilBefore->getQuantity() : 0;

    CBasicPacket packet;
    packet.setType(static_cast<uint16>(GP_CLI_COMMAND_SHOP_BUY::packetId));
    packet.setSize(sizeof(GP_CLI_COMMAND_SHOP_BUY));
    packet.setSequence(0);
    packet.as<GP_CLI_COMMAND_SHOP_BUY>()->ItemNum           = quantity;
    packet.as<GP_CLI_COMMAND_SHOP_BUY>()->ShopNo            = 0;
    packet.as<GP_CLI_COMMAND_SHOP_BUY>()->ShopItemIndex     = index;
    packet.as<GP_CLI_COMMAND_SHOP_BUY>()->PropertyItemIndex = 0;

    g_PMapEngine->networking().packetSystem().dispatch(packet.getType(), PChar->PSession, PChar, packet);

    auto*      PGil     = PChar->getStorage(LOC_INVENTORY)->GetItem(0);
    const uint32 gilAfter = PGil ? PGil->getQuantity() : 0;
    if (gilAfter >= gilBefore)
    {
        return false; // nothing was bought (no gil, no space, stack limits...)
    }

    const auto* PItem = xi::items::lookup(itemId);
    const auto  name  = PItem ? HumanName(PItem->getName()) : std::to_string(itemId);
    const auto  spent = gilBefore - gilAfter;
    LogBotEvent(PChar->id, BotLogLevel::Notable, "item", "bought",
                quantity > 1 ? std::format("{} bought {} x{} for {} gil", PChar->getName(), name, quantity, spent)
                             : std::format("{} bought {} for {} gil", PChar->getName(), name, spent),
                std::format(R"({{"item_id":{},"item":"{}","quantity":{},"gil":{},"price":{}}})", itemId, JsonEscape(name), quantity, spent, price));
    return true;
}

auto EvaluateBotGearItem(uint32 charId, uint16 itemId) -> float
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return 0.0f;
    }

    const auto weightsIt = g_gearWeights.find(charId);
    const auto plansIt   = g_gearPlans.find(charId);
    if (weightsIt == g_gearWeights.end() || plansIt == g_gearPlans.end())
    {
        return 0.0f;
    }

    auto* PItem = const_cast<CItemEquipment*>(dynamic_cast<const CItemEquipment*>(xi::items::lookup(itemId)));
    if (PItem == nullptr || !canWear(PChar, PItem))
    {
        return 0.0f;
    }

    float best = 0.0f;

    // Armour and accessories: against what each set plans for the slot.
    for (const auto& [setName, weights] : weightsIt->second)
    {
        const auto planIt = plansIt->second.find(setName);
        if (planIt == plansIt->second.end())
        {
            continue;
        }

        for (const auto slot : kSetSlots)
        {
            if ((PItem->getEquipSlotId() & (1 << slot)) == 0)
            {
                continue;
            }

            float current = 0.0f;
            const auto& planned = planIt->second[slot];
            if (planned.slot != 0)
            {
                if (auto* PCurrent = dynamic_cast<CItemEquipment*>(PChar->getStorage(planned.container)->GetItem(planned.slot)))
                {
                    current = weightedScore(PCurrent, weights);
                }
            }

            best = std::max(best, weightedScore(PItem, weights) - current);
        }
    }

    // Weapons: against what's equipped, by the weapon set's weights.
    if (dynamic_cast<CItemWeapon*>(PItem) != nullptr && (PItem->getEquipSlotId() & (1 << SLOT_MAIN)) != 0)
    {
        const auto& weaponSet = g_gearWeaponSet[charId];
        for (const auto& [setName, weights] : weightsIt->second)
        {
            if (setName != weaponSet)
            {
                continue;
            }

            auto* PCurrent = PChar->getEquip(SLOT_MAIN);
            best           = std::max(best, weightedScore(PItem, weights) - (PCurrent ? weightedScore(PCurrent, weights) : 0.0f));
        }
    }

    return best;
}

auto IsUsefulBotScroll(uint32 charId, uint16 itemId) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return false;
    }

    const auto spellId = scrollSpell(itemId);
    if (spellId == 0 || charutils::hasSpell(PChar, spellId))
    {
        return false;
    }

    return spell::CanUseSpellWith(static_cast<SpellID>(spellId), PChar->GetMJob(), PChar->GetMLevel()) ||
           (PChar->GetSJob() != xi::Job::NONE && spell::CanUseSpellWith(static_cast<SpellID>(spellId), PChar->GetSJob(), PChar->GetSLevel()));
}

auto IsBotKeeperLoot(CCharEntity* PChar, uint16 itemId) -> bool
{
    auto* PItem = const_cast<CItem*>(xi::items::lookup(itemId));
    return PChar != nullptr && PItem != nullptr && isKeeper(PChar, PItem, {});
}

auto IsGearOrScroll(uint16 itemId) -> bool
{
    const auto* PItem = xi::items::lookup(itemId);
    return PItem != nullptr && (dynamic_cast<const CItemEquipment*>(PItem) != nullptr || scrollSpell(itemId) != 0);
}

auto ManageBotInventory(uint32 charId) -> BotInventoryResult
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return {};
    }

    BotInventoryResult result;
    result.learned = learnScrolls(PChar);

    // Bots with planned gear sets equip through those (PlanBotGear).
    if (!g_gearPlans.contains(charId))
    {
        result.equipped = equipBestGear(PChar);
    }

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
