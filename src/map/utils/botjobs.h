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
#include <optional>

// Jobs for world bots (see botutils.h): what a bot has levelled and unlocked,
// unlocking jobs, and changing jobs. Which jobs to play, and when, is
// xi.worldbots policy (scripts/globals/worldbots_jobs.lua).
namespace botutils
{

struct BotJobInfo
{
    uint8                 mainJob{};
    uint8                 subJob{};
    bool                  subjobUnlocked{};
    std::array<uint8, 32> levels{};   // [job id] -> level (0 = never played)
    std::array<bool, 32>  unlocked{}; // [job id] -> unlocked
};

auto GetBotJobInfo(uint32 charId) -> std::optional<BotJobInfo>;

// Unlocks a job (or, for job 0, the ability to set a subjob) - the same change
// the unlock quests make (CLuaBaseEntity::unlockJob). A stand-in for bots doing
// those quests themselves, which comes in a later phase.
auto UnlockBotJob(uint32 charId, uint8 job) -> bool;

// Changes main and/or sub job (0 = leave unchanged) through the real job-change
// handler (GP_CLI_COMMAND_MYROOM_JOB), so equipment, stats, traits, abilities and
// recasts all update exactly as for a player. Like a player in their Mog House,
// the bot must be standing at a Mog House entrance. Returns false if not.
auto ChangeBotJobs(uint32 charId, uint8 mainJob, uint8 subJob) -> bool;

// The bot's lifetime main job (world_bots.career_job; 0 = not chosen yet).
auto GetBotCareerJob(uint32 charId) -> uint8;
void SetBotCareerJob(uint32 charId, uint8 job);

} // namespace botutils
