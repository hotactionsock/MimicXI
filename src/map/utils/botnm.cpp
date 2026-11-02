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

#include "botnm.h"

#include "botinventory.h"
#include "botlog.h"
#include "botutils.h"

#include "common/logging.h"

#include "ai/ai_container.h"
#include "entities/char_entity.h"
#include "entities/mob_entity.h"
#include "entities/npc_entity.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "packet_system.h"
#include "party.h"
#include "packets/basic.h"
#include "packets/c2s/0x036_item_transfer.h"
#include "spawn_handler.h"
#include "utils/charutils.h"
#include "utils/itemutils.h"
#include "utils/zoneutils.h"
#include "zone.h"
#include "zone_entities.h"

#include <algorithm>
#include <fstream>
#include <iterator>
#include <regex>
#include <unordered_map>
#include <unordered_set>

namespace botutils
{

namespace
{

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

auto isCandidateNM(CMobEntity* PMob) -> bool
{
    return PMob != nullptr && (PMob->m_Type & xi::MobType::Notorious) != xi::MobType::Normal &&
           (PMob->m_Type & xi::MobType::Event) == xi::MobType::Normal && PMob->PBattlefield == nullptr && PMob->PMaster == nullptr &&
           PMob->dropList() != nullptr;
}

// Every item the mob can drop (plain drops and grouped drops).
auto dropItems(CMobEntity* PMob) -> std::vector<uint16>
{
    std::vector<uint16> items;
    if (const auto* PDrops = PMob->dropList())
    {
        for (const auto& item : PDrops->Items)
        {
            items.push_back(item.ItemID);
        }

        for (const auto& group : PDrops->Groups)
        {
            for (const auto& item : group.Items)
            {
                items.push_back(item.ItemID);
            }
        }
    }

    return items;
}

std::unordered_map<uint16, std::vector<BotForcedPop>> g_forcedPops;

} // namespace

auto GetBotNMTargets(uint32 charId, uint8 maxHops) -> std::vector<BotNM>
{
    std::vector<BotNM> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return result;
    }

    const uint8 level = PChar->GetMLevel();

    for (const auto& [zoneId, hops] : GetBotReachableZones(PChar->getZone(), maxHops))
    {
        auto* PZone = zoneutils::GetZone(static_cast<xi::ZoneId>(zoneId));
        if (PZone == nullptr)
        {
            continue;
        }

        // clang-format off
        PZone->GetZoneEntities()->ForEachMob([&](CMobEntity* PMob)
        {
            if (!isCandidateNM(PMob))
            {
                return;
            }

            // Its most useful drop for this bot.
            float       bestGain = 0.0f;
            uint16      bestItem = 0;
            for (const auto itemId : dropItems(PMob))
            {
                float gain = EvaluateBotGearItem(charId, itemId);
                if (gain <= 0.0f && IsUsefulBotScroll(charId, itemId))
                {
                    gain = 10.0f;
                }

                if (gain > bestGain)
                {
                    bestGain = gain;
                    bestItem = itemId;
                }
            }

            if (bestItem == 0)
            {
                return;
            }

            BotNM nm{};
            nm.mobId      = PMob->id;
            nm.name       = HumanName(PMob->getName());
            nm.zoneId     = zoneId;
            nm.hops       = hops;
            nm.minLevel   = PMob->m_minLevel;
            nm.maxLevel   = PMob->m_maxLevel;
            nm.con        = static_cast<uint8>(charutils::CheckMobLevel(level, PMob->m_maxLevel));
            nm.lottery    = (PMob->m_SpawnType & xi::SpawnType::Lottery) != xi::SpawnType::Normal;
            nm.windowed   = (PMob->m_SpawnType & xi::SpawnType::Windowed) != xi::SpawnType::Normal;
            nm.scripted   = (PMob->m_SpawnType & xi::SpawnType::Scripted) != xi::SpawnType::Normal;
            nm.spawned    = PMob->PAI->IsSpawned() && PMob->isAlive();
            nm.claimed    = nm.spawned && PMob->m_OwnerID.isSet();
            nm.respawnSec = -1;
            if (!nm.spawned)
            {
                if (const auto left = PZone->spawnHandler().getRemainingRespawnTime(PMob))
                {
                    nm.respawnSec = static_cast<int32>(std::chrono::duration_cast<std::chrono::seconds>(*left).count());
                }
            }

            nm.pos      = nm.spawned ? PMob->loc.p : PMob->m_SpawnPoint;
            nm.bestGain = bestGain;
            nm.bestItemId = bestItem;
            if (const auto* PItem = xi::items::lookup(bestItem))
            {
                nm.bestItemName = HumanName(PItem->getName());
            }

            result.push_back(nm);
        });
        // clang-format on
    }

    std::sort(result.begin(), result.end(),
              [](const BotNM& a, const BotNM& b)
              {
                  return a.bestGain != b.bestGain ? a.bestGain > b.bestGain : a.hops < b.hops;
              });

    if (result.size() > 10)
    {
        result.resize(10);
    }

    return result;
}

auto GetBotMobStatus(uint32 charId, uint32 mobId) -> BotMobStatus
{
    BotMobStatus status{};

    auto* PChar = liveBot(charId);
    auto* PMob  = PChar ? dynamic_cast<CMobEntity*>(PChar->loc.zone->GetEntity(static_cast<uint16>(mobId & 0xFFF), TYPE_MOB)) : nullptr;
    if (PMob == nullptr || PMob->id != mobId)
    {
        return status;
    }

    status.found    = true;
    status.alive    = PMob->PAI->IsSpawned() && PMob->isAlive();
    status.claimed  = status.alive && PMob->m_OwnerID.isSet();
    status.pos      = PMob->loc.p;
    status.distance = distance(PChar->loc.p, PMob->loc.p);

    if (status.claimed)
    {
        const uint32 owner = PMob->m_OwnerID.UniqueNo;
        status.ours        = owner == PChar->id;
        if (!status.ours && PChar->PParty != nullptr)
        {
            for (auto* PMember : PChar->PParty->members)
            {
                if (PMember != nullptr && PMember->id == owner)
                {
                    status.ours = true;
                    break;
                }
            }
        }
    }

    return status;
}

auto IsRealPlayerNearMob(uint32 mobId, uint16 zoneId, float radius) -> bool
{
    auto* PZone = zoneutils::GetZone(static_cast<xi::ZoneId>(zoneId));
    auto* PMob  = PZone ? dynamic_cast<CMobEntity*>(PZone->GetEntity(static_cast<uint16>(mobId & 0xFFF), TYPE_MOB)) : nullptr;
    if (PMob == nullptr || PMob->id != mobId)
    {
        return false;
    }

    bool playerNear = false;
    PZone->ForEachChar(
        [&](CCharEntity* PChar)
        {
            if (!playerNear && !IsBotEntity(PChar) && !PChar->isDead() && distance(PChar->loc.p, PMob->loc.p) <= radius)
            {
                playerNear = true;
            }
        });

    return playerNear;
}

auto GetBotForcedPops(uint16 zoneId) -> std::vector<BotForcedPop>
{
    if (const auto it = g_forcedPops.find(zoneId); it != g_forcedPops.end())
    {
        return it->second;
    }

    std::vector<BotForcedPop> pops;

    if (auto* PZone = zoneutils::GetZone(static_cast<xi::ZoneId>(zoneId)))
    {
        const auto       zoneName = PZone->getName();
        const std::regex mobPattern(R"(popFromQM\([^,]+,[^,]+,\s*ID\.mob\.([A-Z0-9_]+))");
        const std::regex itemPattern(R"(xi\.item\.([A-Z0-9_]+))");

        // clang-format off
        PZone->GetZoneEntities()->ForEachNpc([&](CNpcEntity* PNpc)
        {
            std::ifstream file(fmt::format("./scripts/zones/{}/npcs/{}.lua", zoneName, PNpc->getName()));
            if (!file)
            {
                return;
            }

            const std::string script((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
            if (script.find("popFromQM") == std::string::npos)
            {
                return;
            }

            BotForcedPop pop{ PNpc->id, PNpc->loc.p, {}, {} };

            for (auto it = std::sregex_iterator(script.begin(), script.end(), mobPattern); it != std::sregex_iterator(); ++it)
            {
                pop.mobKeys.push_back((*it)[1].str());
            }

            // Items only from the onTrade part (onTrigger mentions don't count).
            const auto tradeStart = script.find("onTrade");
            const auto tradeEnd   = script.find("onTrigger", tradeStart == std::string::npos ? 0 : tradeStart);
            if (tradeStart != std::string::npos)
            {
                const std::string trade = script.substr(tradeStart, tradeEnd == std::string::npos ? std::string::npos : tradeEnd - tradeStart);
                std::unordered_set<std::string> seen;
                for (auto it = std::sregex_iterator(trade.begin(), trade.end(), itemPattern); it != std::sregex_iterator(); ++it)
                {
                    if (seen.insert((*it)[1].str()).second)
                    {
                        pop.itemKeys.push_back((*it)[1].str());
                    }
                }
            }

            if (!pop.mobKeys.empty() && !pop.itemKeys.empty())
            {
                pops.push_back(std::move(pop));
            }
        });
        // clang-format on
    }

    g_forcedPops[zoneId] = pops;
    return pops;
}

auto TradeBotItemToNpc(uint32 charId, uint32 npcId, uint16 itemId, uint32 quantity) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead() || quantity == 0)
    {
        return false;
    }

    auto* PNpc = PChar->loc.zone->GetEntity(static_cast<uint16>(npcId & 0xFFF), TYPE_NPC);
    if (PNpc == nullptr || PNpc->id != npcId)
    {
        return false;
    }

    auto* PInventory = PChar->getStorage(LOC_INVENTORY);
    uint8 slot       = 0;
    for (uint8 i = 1; i <= PInventory->GetSize(); ++i)
    {
        auto* PItem = PInventory->GetItem(i);
        if (PItem != nullptr && PItem->getID() == itemId && PItem->getQuantity() >= quantity && !PItem->isBusy())
        {
            slot = i;
            break;
        }
    }

    if (slot == 0)
    {
        return false;
    }

    const auto before = charutils::getItemCount(PChar, itemId);

    CBasicPacket packet;
    packet.setType(static_cast<uint16>(GP_CLI_COMMAND_ITEM_TRANSFER::packetId));
    packet.setSize(sizeof(GP_CLI_COMMAND_ITEM_TRANSFER));
    packet.setSequence(0);
    auto* data                    = packet.as<GP_CLI_COMMAND_ITEM_TRANSFER>();
    data->UniqueNo                = PNpc->id;
    data->ItemNumTbl[0]           = quantity;
    data->PropertyItemIndexTbl[0] = slot;
    data->ActIndex                = PNpc->targid;
    data->ItemNum                 = 1;

    g_PMapEngine->networking().packetSystem().dispatch(packet.getType(), PChar->PSession, PChar, packet);

    if (PChar->isInEvent())
    {
        PChar->endCurrentEvent();
    }

    return charutils::getItemCount(PChar, itemId) < before;
}

} // namespace botutils
