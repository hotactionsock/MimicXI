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

#include "botwatch.h"
#include "botlog.h"
#include "botutils.h"

#include "common/database.h"
#include "common/earth_time.h"
#include "common/tracy.h"

#include "ai/ai_container.h"
#include "entities/char_entity.h"
#include "entities/mob_entity.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "party.h"
#include "status_effect_container.h"
#include "zone.h"
#include "zone_entities.h"

#include <algorithm>
#include <format>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace botutils
{

namespace
{

constexpr uint32 kMaxWatched     = 50;    // bots snapshotted per update, at most
constexpr float  kMobRadius      = 60.0f; // yalms
constexpr float  kCharRadius     = 80.0f;
constexpr size_t kMaxMobs        = 60;
constexpr size_t kMaxChars       = 40;
constexpr float  kMovingYalms    = 0.3f;  // moved this far since the last snapshot = walking

std::unordered_map<uint32, position_t> g_lastPos; // per watched bot, for "moving"

auto liveBot(uint32 charId) -> CCharEntity*
{
    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar || session->PChar->loc.zone == nullptr)
    {
        return nullptr;
    }

    return session->PChar.get();
}

// "x":1.2,"z":3.4 - positions to one decimal (yalms).
auto pos(const position_t& p) -> std::string
{
    return std::format(R"("x":{:.1f},"y":{:.1f},"z":{:.1f})", p.x, p.y, p.z);
}

auto snapshot(CCharEntity* PChar) -> std::string
{
    auto* PZone = PChar->loc.zone;

    // Party members, for "claimed by my party".
    std::unordered_set<uint32> party;
    if (PChar->PParty != nullptr)
    {
        for (auto* PMember : PChar->PParty->members)
        {
            party.insert(PMember->id);
        }
    }

    // What it's doing.
    std::string state = "idle";
    if (PChar->isDead())
    {
        state = "dead";
    }
    else if (PChar->PAI->IsEngaged())
    {
        state = "fighting";
    }
    else if (PChar->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Healing))
    {
        state = "resting";
    }
    else if (const auto it = g_lastPos.find(PChar->id); it != g_lastPos.end() && distance(it->second, PChar->loc.p) >= kMovingYalms)
    {
        state = "moving";
    }

    g_lastPos[PChar->id] = PChar->loc.p;

    std::string target = "null";
    if (auto* PTarget = PChar->GetBattleTarget(); PTarget != nullptr && !PTarget->isDead())
    {
        target = std::format(R"({{"id":{},"name":"{}","hpp":{},{}}})", PTarget->id, JsonEscape(HumanName(PTarget->getName())), PTarget->GetHPP(),
                             pos(PTarget->loc.p));
    }

    // Mobs around it, nearest first.
    struct Near
    {
        float       dist;
        std::string json;
    };

    std::vector<Near> mobs;
    // clang-format off
    PZone->GetZoneEntities()->ForEachMob([&](CMobEntity* PMob)
    {
        if (PMob->isDead() || PMob->status == xi::Status::Disappear || PMob->PMaster != nullptr || PMob->allegiance != xi::Allegiance::Mob)
        {
            return;
        }

        const float d = distance(PChar->loc.p, PMob->loc.p);
        if (d > kMobRadius)
        {
            return;
        }

        std::string claim = "none";
        if (PMob->m_OwnerID.isSet())
        {
            const auto owner = PMob->m_OwnerID.UniqueNo;
            claim            = owner == PChar->id ? "mine" : (party.contains(owner) ? "party" : "other");
        }

        mobs.push_back(Near{ d, std::format(R"({{"id":{},"name":"{}","level":{},"hpp":{},{},"claim":"{}","aggro":{},"nm":{},"engaged":{}}})",
                                            PMob->id, JsonEscape(HumanName(PMob->getName())), PMob->GetMLevel(), PMob->GetHPP(), pos(PMob->loc.p), claim,
                                            PMob->m_Aggro ? "true" : "false",
                                            (PMob->m_Type & xi::MobType::Notorious) != xi::MobType::Normal ? "true" : "false",
                                            PMob->PAI->IsEngaged() ? "true" : "false") });
    });

    std::vector<Near> chars;
    PZone->ForEachChar([&](CCharEntity* POther)
    {
        if (POther == PChar || POther->status == xi::Status::Disappear)
        {
            return;
        }

        const float d = distance(PChar->loc.p, POther->loc.p);
        if (d > kCharRadius)
        {
            return;
        }

        chars.push_back(Near{ d, std::format(R"({{"id":{},"name":"{}","bot":{},"party":{},"level":{},{}}})", POther->id,
                                             JsonEscape(POther->getName()), IsBotEntity(POther) ? "true" : "false",
                                             party.contains(POther->id) ? "true" : "false", POther->GetMLevel(), pos(POther->loc.p)) });
    });
    // clang-format on

    const auto join = [](std::vector<Near>& list, size_t max)
    {
        std::sort(list.begin(), list.end(),
                  [](const Near& a, const Near& b)
                  {
                      return a.dist < b.dist;
                  });

        std::string out;
        for (size_t i = 0; i < list.size() && i < max; ++i)
        {
            out += (i ? "," : "") + list[i].json;
        }

        return out;
    };

    std::string lines;
    for (const auto& line : GetBotZoneLines(static_cast<xi::ZoneId>(PChar->getZone())))
    {
        lines += std::format(R"({}{{"to":{},{}}})", lines.empty() ? "" : ",", line.destinationZoneId, pos(line.origin));
    }

    return std::format(R"({{"online":true,"zone_id":{},{},"rot":{},"level":{},"job":{},"hp":{},"max_hp":{},"mp":{},"max_mp":{},"tp":{},)"
                       R"("state":"{}","target":{},"mobs":[{}],"chars":[{}],"lines":[{}]}})",
                       static_cast<uint16>(PChar->getZone()), pos(PChar->loc.p), PChar->loc.p.rotation, PChar->GetMLevel(),
                       static_cast<uint8>(PChar->GetMJob()), PChar->health.hp, PChar->GetMaxHP(), PChar->health.mp, PChar->GetMaxMP(),
                       PChar->health.tp, state, target, join(mobs, kMaxMobs), join(chars, kMaxChars), lines);
}

} // namespace

void UpdateBotWatch()
{
    TracyZoneScoped;

    if (g_PMapEngine == nullptr)
    {
        return;
    }

    const uint32 now = earth_time::timestamp();

    std::vector<uint32> watched;
    {
        const auto rset = db::preparedStmt("SELECT charid FROM world_bot_watch WHERE until_ts >= ? LIMIT ?", now, kMaxWatched);
        FOR_DB_MULTIPLE_RESULTS(rset)
        {
            watched.push_back(rset->get<uint32>("charid"));
        }
    }

    std::unordered_set<uint32> stillWatched;
    for (const auto charId : watched)
    {
        // Only bots this map process hosts (another process writes its own).
        auto* PChar = liveBot(charId);
        if (PChar == nullptr)
        {
            continue;
        }

        stillWatched.insert(charId);
        db::preparedStmt("INSERT INTO world_bot_live (charid, ts, zone_id, data) VALUES (?, ?, ?, ?) "
                         "ON DUPLICATE KEY UPDATE ts = VALUES(ts), zone_id = VALUES(zone_id), data = VALUES(data)",
                         charId, now, static_cast<uint16>(PChar->getZone()), snapshot(PChar));
    }

    std::erase_if(g_lastPos,
                  [&](const auto& entry)
                  {
                      return !stillWatched.contains(entry.first);
                  });
}

} // namespace botutils
