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

#include <array>

class CCharEntity;

// Quests, missions and crafting for world bots - tracked ahead of the bots
// doing them. Hooked into the engine's own paths (CLuaBaseEntity
// addQuest/completeQuest/addMission/completeMission/setSkillRank and
// synthutils::sendSynthDone), so whatever later drives a bot through them -
// its AI or a GM - lands in the activity log the same way. Only bots are
// logged; players are untouched.
namespace botutils
{

// The crafts, by skill id (xi::SkillType: Woodworking 49 .. Cooking 56).
constexpr uint8 kFirstCraftSkill = 49;
constexpr uint8 kLastCraftSkill  = 56;
using CraftSkills                = std::array<uint16, kLastCraftSkill - kFirstCraftSkill + 1>;

// A quest or mission changed for a bot: event is "quest_started",
// "quest_completed", "mission_started" or "mission_completed". The Lua side
// (xi.worldbots.log.progress) names it and writes the log line.
void OnBotQuestOrMission(CCharEntity* PChar, const char* event, uint8 logId, uint16 id);

// Craft skills (x10, as stored) before a synth, to log level-ups after it.
auto BotCraftSkills(CCharEntity* PChar) -> CraftSkills;

// A synth just finished (after its skill-ups): logs the result and any craft
// that rose a whole level.
void LogBotSynth(CCharEntity* PChar, const CraftSkills& before);

// A guild rank changed (setSkillRank).
void LogBotCraftRank(CCharEntity* PChar, uint8 skillId, uint8 rank);

} // namespace botutils
