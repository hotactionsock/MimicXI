/*
===========================================================================

  Copyright (c) 2024 LandSandBoat Dev Teams

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

#include <array>
#include <optional>
#include <string>
#include <utility>
#include <vector>

#include "common/cbasetypes.h"

namespace squadutils
{

// Number of mimic-trust squad slots per account.
inline constexpr uint8 SquadSlots = 5;

// char_jobs / char_exp / char_stats column name for job id 1..22 (WAR..RUN),
// nullptr for anything out of range.
auto JobColumn(uint8 jobId) -> const char*;

struct AccountChar
{
    uint32                charId{};
    std::string           name;
    uint8                 mainJob{};
    uint8                 mainLvl{};
    uint8                 subJob{};
    uint8                 subLvl{};
    bool                  online{};   // has a live accounts_sessions row
    bool                  locked{};   // currently out as someone's mimic trust (char_mimic_active)
    uint32                unlocked{}; // char_jobs.unlocked bitmask, bit jobId
    std::array<uint8, 23> levels{};   // levels[jobId], 1..22
};

enum class SetJobResult : uint8
{
    Ok,       // char_stats updated; the caller resummons if appropriate
    NotFound, // not one of this account's characters
    Online,   // the character is logged in
    JobLocked,// main or sub job is not unlocked
    BadJob,   // job id out of range
};

// Sets an offline alt's active main/sub job (writes char_stats mjob/sjob/mlvl/slvl,
// mlvl/slvl from char_jobs). sjob 0 = no sub.
auto SetAltJob(uint32 accId, uint32 charId, uint8 mjob, uint8 sjob) -> SetJobResult;

// --- job presets (account_jobpreset) ---
struct JobPresetEntry
{
    uint32 charId{};
    uint8  mjob{};
    uint8  sjob{};
};

void SaveJobPreset(uint32 accId, const std::string& name, const std::vector<JobPresetEntry>& entries);
auto LoadJobPreset(uint32 accId, const std::string& name) -> std::vector<JobPresetEntry>;
auto ListJobPresets(uint32 accId) -> std::vector<std::pair<std::string, uint32>>; // name, entry count
void DeleteJobPreset(uint32 accId, const std::string& name);

// Returns slot -> charid for the account (index 0 == slot 1). 0 means the slot is empty.
auto GetSquad(uint32 accId) -> std::array<uint32, SquadSlots>;

// Writes one slot. charId 0 clears the slot. slot is 1..SquadSlots.
void SetSquadSlot(uint32 accId, uint8 slot, uint32 charId);

// Every character on the account (charid ascending), for roster pickers.
auto ListAccountChars(uint32 accId) -> std::vector<AccountChar>;

// True if charId belongs to accId (an owned alt).
auto IsOwnedByAccount(uint32 accId, uint32 charId) -> bool;

}; // namespace squadutils
