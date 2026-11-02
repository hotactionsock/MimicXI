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
#include "common/types/position.h"

#include <optional>
#include <string>
#include <vector>

// Parties for world bots (see botutils.h). Bots form real engine parties
// (CParty, as the invite handler builds them), so party EXP, treasure pools,
// party buffs and level sync all work exactly as for players. Who partners
// with whom, and how a party plays, is xi.worldbots policy
// (scripts/globals/worldbots_party.lua). Bots never invite players.
class CCharEntity;

namespace botutils
{

// Puts the given bots in a party led by leaderId (creating it if needed).
// Bots already in another party are skipped, and the party is never filled
// past 6. Returns how many joined (not counting the leader).
auto FormBotParty(uint32 leaderId, const std::vector<uint32>& memberIds) -> uint8;

// Takes a bot out of its party (the engine disbands a party left with one).
void LeaveBotParty(uint32 charId);

struct BotPartyMember
{
    uint32     charId;
    bool       isBot;
    bool       isLeader;
    uint8      mainJob;
    uint8      subJob;
    uint8      level;
    uint8      hpp;
    uint8      mpp;
    uint16     tp;
    uint16     zoneId;
    position_t pos;
    bool       dead;
    bool       engaged;
    uint32     targetId; // battle target's id (0 = none)
};

// The bot's party (itself included), or nullopt if it isn't in one. Members
// on other map processes are left out.
auto GetBotParty(uint32 charId) -> std::optional<std::vector<BotPartyMember>>;

// ---- Hired by players (Phase 5) ----------------------------------------------

// Called by the invite handler (GP_CLI_COMMAND_GROUP_SOLICIT_REQ) when a real
// player invites a bot: a bot in a bots-only party leaves it so it can accept
// - players come first. No-op for anyone else.
void FreeBotForPlayerInvite(CCharEntity* PInvitee);

// The charid of whoever has a party invite pending for this bot (0 = none),
// and whether that inviter is itself a bot.
struct BotInvite
{
    uint32 inviterId{};
    bool   inviterIsBot{};
};

auto GetBotPendingInvite(uint32 charId) -> BotInvite;

// Answers the pending invite through the real response handler
// (GP_CLI_COMMAND_GROUP_SOLICIT_RES). True if the bot ended up in a party.
auto AnswerBotInvite(uint32 charId, bool accept) -> bool;

// Level sync for a hired bot: caps its level at `level` with the Level
// Restriction effect (EXP is then earned for the capped level, as with level
// sync). 0 removes the cap. Only ever touches a cap it set itself.
void SetBotLevelSync(uint32 charId, uint8 level);

// The bot's real main-job level (not capped by level sync).
auto GetBotTrueLevel(uint32 charId) -> uint8;

// Shows the bot in /sea as seeking a party (the /invite flag) with an
// "EXP party: seeking party" comment, or clears both.
void SetBotSeekingParty(uint32 charId, bool seeking, const std::string& comment);

} // namespace botutils
