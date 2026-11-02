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

#include "botmemory.h"

#include "common/database.h"
#include "common/earth_time.h"
#include "common/logging.h"
#include "common/tracy.h"

#include <set>
#include <stdexcept>
#include <tuple>
#include <unordered_map>

namespace botutils
{

namespace
{

using MemoryKey = std::pair<uint8, uint32>; // kind, ref

struct KeyHash
{
    auto operator()(const MemoryKey& key) const -> std::size_t
    {
        return (static_cast<std::size_t>(key.first) << 32) ^ key.second;
    }
};

struct BotMemories
{
    std::unordered_map<MemoryKey, BotMemory, KeyHash> entries;
    std::set<MemoryKey>                               dirty;
};

std::unordered_map<uint32, BotMemories> g_memories;

// A bot's memories, loaded from the database the first time they're needed.
auto memoriesOf(uint32 charId) -> BotMemories&
{
    if (const auto it = g_memories.find(charId); it != g_memories.end())
    {
        return it->second;
    }

    auto&      memories = g_memories[charId];
    const auto rset     = db::preparedStmt("SELECT kind, ref, deaths, successes, exp, last_death, last_success, death_level FROM world_bot_memory WHERE charid = ?",
                                           charId);
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        BotMemory memory;
        memory.deaths        = rset->get<uint16>("deaths");
        memory.successes     = rset->get<uint16>("successes");
        memory.exp           = rset->get<uint32>("exp");
        memory.lastDeathTs   = rset->get<uint32>("last_death");
        memory.lastSuccessTs = rset->get<uint32>("last_success");
        memory.deathLevel    = rset->get<uint8>("death_level");
        memories.entries[{ rset->get<uint8>("kind"), rset->get<uint32>("ref") }] = memory;
    }

    return memories;
}

} // namespace

auto GetBotMemory(uint32 charId, BotMemoryKind kind, uint32 ref) -> BotMemory
{
    auto&      memories = memoriesOf(charId);
    const auto it       = memories.entries.find({ static_cast<uint8>(kind), ref });
    return it != memories.entries.end() ? it->second : BotMemory{};
}

void RecordBotDeath(uint32 charId, BotMemoryKind kind, uint32 ref, uint8 level)
{
    auto&           memories = memoriesOf(charId);
    const MemoryKey key{ static_cast<uint8>(kind), ref };
    auto&           memory = memories.entries[key];

    memory.deaths      = static_cast<uint16>(std::min<uint32>(memory.deaths + 1, 65535));
    memory.lastDeathTs = earth_time::timestamp();
    memory.deathLevel  = level;
    memories.dirty.insert(key);
}

void RecordBotSuccess(uint32 charId, BotMemoryKind kind, uint32 ref, uint32 exp)
{
    auto&           memories = memoriesOf(charId);
    const MemoryKey key{ static_cast<uint8>(kind), ref };
    auto&           memory = memories.entries[key];

    memory.successes     = static_cast<uint16>(std::min<uint32>(memory.successes + 1, 65535));
    memory.exp          += exp;
    memory.lastSuccessTs = earth_time::timestamp();
    memories.dirty.insert(key);
}

void FlushBotMemory()
{
    TracyZoneScoped;

    for (auto& [charId, memories] : g_memories)
    {
        if (memories.dirty.empty())
        {
            continue;
        }

        const bool ok = db::transaction(
            [&]()
            {
                for (const auto& key : memories.dirty)
                {
                    const auto& m = memories.entries[key];
                    if (!db::preparedStmt("INSERT INTO world_bot_memory (charid, kind, ref, deaths, successes, exp, last_death, last_success, death_level) "
                                          "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) "
                                          "ON DUPLICATE KEY UPDATE deaths = VALUES(deaths), successes = VALUES(successes), exp = VALUES(exp), "
                                          "last_death = VALUES(last_death), last_success = VALUES(last_success), death_level = VALUES(death_level)",
                                          charId, key.first, key.second, m.deaths, m.successes, m.exp, m.lastDeathTs, m.lastSuccessTs, m.deathLevel))
                    {
                        throw std::runtime_error("world_bot_memory write failed");
                    }
                }
            });

        if (ok)
        {
            memories.dirty.clear();
        }
        else
        {
            ShowError("botutils::FlushBotMemory: could not save memories for charid %u; will retry", charId);
        }
    }
}

void DeleteBotMemory(uint32 charId)
{
    g_memories.erase(charId);
    db::preparedStmt("DELETE FROM world_bot_memory WHERE charid = ?", charId);
}

} // namespace botutils
