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

#include <string>
#include <vector>

// NM camping for world bots (Phase 6a): which notorious monsters are worth a
// bot's time (they drop an upgrade for it), how each one spawns, and the
// pieces needed to camp them like a player - who else is around, and trading
// a pop item to a ??? spot. Which NM to camp, and how, is xi.worldbots policy
// (scripts/globals/worldbots_nm.lua).
namespace botutils
{

struct BotNM
{
    uint32      mobId;
    std::string name;      // as a person writes it ("Valkurm Emperor")
    uint16      zoneId;
    uint8       hops;      // zone hops from the bot
    uint8       minLevel;
    uint8       maxLevel;
    uint8       con;       // EMobDifficulty of its top level for the bot (0 too weak .. 7 incredibly tough)
    bool        lottery;   // pops from a placeholder (spawn type lottery)
    bool        windowed;  // timed respawn window
    bool        scripted;  // forced pop (??? + item) or other scripted spawn
    bool        spawned;   // up right now
    bool        claimed;   // someone is fighting it
    int32       respawnSec; // seconds until it may respawn (-1 = unknown / not waiting)
    position_t  pos;       // where it is (spawned) or its spawn point
    float       bestGain;  // the best upgrade among its drops, for this bot
    uint16      bestItemId;
    std::string bestItemName;
};

// NMs within maxHops whose drops include an upgrade for the bot (gear by its
// set weights, or a scroll it can use) - best upgrade first, at most 10.
// Event and battlefield NMs are left out.
auto GetBotNMTargets(uint32 charId, uint8 maxHops) -> std::vector<BotNM>;

struct BotMobStatus
{
    bool       found;
    bool       alive;    // spawned and alive
    bool       claimed;  // someone has claim
    bool       ours;     // claimed by the bot or its party
    position_t pos;
    float      distance; // from the bot (same zone)
};

// A mob in the bot's zone, as the bot sees it.
auto GetBotMobStatus(uint32 charId, uint32 mobId) -> BotMobStatus;

// True if a real player (not a bot) is within radius of the mob - for giving
// players a fair chance at a claim.
auto IsRealPlayerNearMob(uint32 mobId, uint16 zoneId, float radius) -> bool;

struct BotForcedPop
{
    uint32                   npcId;
    position_t               pos;
    std::vector<std::string> mobKeys;  // ID.mob.<KEY> names popFromQM refers to
    std::vector<std::string> itemKeys; // xi.item.<KEY> names its onTrade checks
};

// ??? spots in a zone that pop NMs when traded an item (NPC scripts calling
// npcUtil.popFromQM). The names are resolved in Lua (zones[...].mob, xi.item).
auto GetBotForcedPops(uint16 zoneId) -> std::vector<BotForcedPop>;

// Trades quantity of itemId from the bot's inventory to npcId (within reach)
// through the real NPC trade handler (GP_CLI_COMMAND_ITEM_TRANSFER). True if
// the item left the bot's bags (the NPC took it).
auto TradeBotItemToNpc(uint32 charId, uint32 npcId, uint16 itemId, uint32 quantity) -> bool;

} // namespace botutils
