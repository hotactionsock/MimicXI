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
#include <string>
#include <vector>

#include "common/cbasetypes.h"

namespace squadutils
{

// Number of mimic-trust squad slots per account.
inline constexpr uint8 SquadSlots = 5;

struct AccountChar
{
    uint32      charId{};
    std::string name;
    uint8       mainJob{};
    uint8       mainLvl{};
    bool        online{};   // has a live accounts_sessions row
    bool        locked{};   // currently out as someone's mimic trust (char_mimic_active)
};

// Returns slot -> charid for the account (index 0 == slot 1). 0 means the slot is empty.
auto GetSquad(uint32 accId) -> std::array<uint32, SquadSlots>;

// Writes one slot. charId 0 clears the slot. slot is 1..SquadSlots.
void SetSquadSlot(uint32 accId, uint8 slot, uint32 charId);

// Every character on the account (charid ascending), for roster pickers.
auto ListAccountChars(uint32 accId) -> std::vector<AccountChar>;

// True if charId belongs to accId (an owned alt).
auto IsOwnedByAccount(uint32 accId, uint32 charId) -> bool;

}; // namespace squadutils
