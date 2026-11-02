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

#include <string>

// Activity log for world bots: every bot records what it does - created,
// levelled, changed jobs, learned a spell, obtained or sold items, joined a
// party, died... - as rows in `world_bot_log`, so a website can show each
// bot's life story. Each row carries a ready-to-show sentence ("Testbot
// learned Cure") plus the same facts as JSON for linking/filtering.
//
// Rows are queued in memory and written in one transaction every few seconds
// (FlushBotLog), so thousands of bots don't hammer the database. How much is
// recorded is set by map.WORLDBOTS_LOG_LEVEL; old rows are pruned after
// map.WORLDBOTS_LOG_RETENTION_DAYS.
namespace botutils
{

enum class BotLogLevel : uint8
{
    Milestone = 1, // creation, level-ups, job changes and unlocks, deaths, retirement
    Notable   = 2, // gear and spells gained, items obtained/sold, travel, parties, hunt summaries
    Detail    = 3, // the small stuff: junk tossed, items used, skillchains, magic bursts
};

// True if events at this level are being recorded.
auto BotLogEnabled(BotLogLevel level) -> bool;

// Queues one event. category groups events ("lifecycle", "level", "job",
// "gear", "item", "magic", "travel", "party", "combat", "death"); event is a
// stable key the website can switch on ("level_up", "obtained", ...);
// message is the sentence to show; dataJson a JSON object of the facts.
void LogBotEvent(uint32 charId, BotLogLevel level, const std::string& category, const std::string& event, const std::string& message,
                 const std::string& dataJson = "{}");

// Writes queued events (every few seconds from the map engine).
void FlushBotLog();

// Deletes rows older than the retention setting (at startup, then every few hours).
void PruneBotLog();

// "Goblin_Thug" -> "Goblin Thug", "bat_wing" -> "Bat Wing": engine internal
// names as a person would write them.
auto HumanName(const std::string& internalName) -> std::string;

// A job's full name ("Paladin"), or "" for none.
auto JobFullName(uint8 job) -> std::string;

// Escapes a string for embedding in JSON.
auto JsonEscape(const std::string& text) -> std::string;

// Hunt progress since the last Take: EXP from kills is noted by the engine
// (charutils::AddExperiencePoints); xi.worldbots turns it into a summary line.
void NoteBotHunt(uint32 charId, uint32 exp, bool kill);

struct BotHuntProgress
{
    uint32 kills{};
    uint32 exp{};
};

auto TakeBotHuntProgress(uint32 charId) -> BotHuntProgress;

} // namespace botutils
