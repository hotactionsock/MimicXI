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

#pragma once

#include "common/cbasetypes.h"

// What a world bot has learned from experience, kept in `world_bot_memory`
// so it survives restarts: deaths and successes per place or thing it tried.
// The AI (xi.worldbots) records outcomes and weighs them when choosing where
// to level, which camp to use and which NMs to hunt - so a bot that keeps
// dying on the way to a camp stops going there and tries something else.
//
// Writes are batched: kept in memory and flushed with the activity log
// (FlushBotMemory, every few seconds and on shutdown).
namespace botutils
{

enum class BotMemoryKind : uint8
{
    Zone  = 1, // died / did well while in this zone (ref = zone id)
    Route = 2, // died on the way to this zone, before getting there / arrived fine (ref = destination zone id)
    Camp  = 3, // died / did well at this camp (ref = zone id << 16 | 40-yalm grid cell)
    NM    = 4, // died fighting / defeated this NM (ref = mob id)
};

struct BotMemory
{
    uint16 deaths{};
    uint16 successes{};
    uint32 exp{};          // EXP earned there (zones and camps)
    uint32 lastDeathTs{};  // Unix time of the last death (0 = never)
    uint32 lastSuccessTs{};
    uint8  deathLevel{};   // the bot's level at its last death there
};

auto GetBotMemory(uint32 charId, BotMemoryKind kind, uint32 ref) -> BotMemory;
void RecordBotDeath(uint32 charId, BotMemoryKind kind, uint32 ref, uint8 level);
void RecordBotSuccess(uint32 charId, BotMemoryKind kind, uint32 ref, uint32 exp);

// Writes changed memories (with the activity log flush).
void FlushBotMemory();

// Forgets a bot entirely (it was deleted).
void DeleteBotMemory(uint32 charId);

} // namespace botutils
