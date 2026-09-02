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

#include "base.h"
#include <cstdint>
#include <vector>

class CCharEntity;

namespace bankutils
{
struct BankItem;
}

// Non-retail, MimicXI-specific packet (see PacketS2C::GP_SERV_COMMAND_BANK_LIST).
// Pushes the contents of a player's account-wide bank (see utils/bankutils.h) to the
// client so the companion Ashita v4 addon (tools/ashita-addons/mimicxi_bank) can render
// them in its UI. The retail client has no handler for this opcode -- the addon's
// packet_in hook MUST intercept and block it before the game engine sees it.
//
// Total packet size is capped by the 7-bit size field in GP_SERV_HEADER (max ~254 bytes
// including the 4-byte header), so only MAX_ENTRIES distinct items are sent at a time;
// `truncated` is set if the bank holds more than that. Fine for v1's scope of plain
// stackable materials -- a bank holding more than MAX_ENTRIES distinct item types would
// need this extended to page across multiple packets.
class GP_SERV_COMMAND_BANK_LIST final : public GP_SERV_PACKET<PacketS2C::GP_SERV_COMMAND_BANK_LIST, GP_SERV_COMMAND_BANK_LIST>
{
public:
    static constexpr std::size_t MAX_ENTRIES = 24;

    struct Entry
    {
        uint16_t itemId;
        uint8_t  category;  // see "Categories" in CLAUDE.md, "Account Bank System"
        uint8_t  padding00;
        uint32_t quantity;
    };

    struct PacketData
    {
        uint8_t truncated; // 1 if the bank holds more distinct items than fit here
        uint8_t padding00[3];
        Entry   entries[MAX_ENTRIES];
    };

    GP_SERV_COMMAND_BANK_LIST(CCharEntity* PChar, const std::vector<bankutils::BankItem>& items);
};
