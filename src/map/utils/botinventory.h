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

// Inventory management for world bots (see botutils.h). A bot is a real
// CCharEntity with a real inventory, so everything here goes through the same
// engine paths a real client's actions do (charutils::EquipItem's job/level/race
// checks, ItemClaimTransaction for consuming items, charutils::addSpell) - bots
// can't do anything a player couldn't.
namespace botutils
{

struct BotInventoryResult
{
    uint8 equipped{}; // slots changed to a better item
    uint8 learned{};  // spell scrolls used
};

// One pass of "what a sensible player would do with their bags": equip the best
// item it can wear in each slot (main, sub, armour, accessories - ranged/ammo
// are left for combat), and use any spell scroll it can learn but doesn't know.
// Cheap enough to run on spawn, after receiving items, and every few minutes.
auto ManageBotInventory(uint32 charId) -> BotInventoryResult;

struct BotItemInfo
{
    uint8       container;
    uint8       slot;
    uint16      itemId;
    std::string name;
    uint32      quantity;
    int8        equipSlot; // SLOTTYPE it's equipped in, or -1
};

// Everything in the bot's inventory and wardrobes, for the !worldbot inv command.
auto GetBotItems(uint32 charId) -> std::vector<BotItemInfo>;

// ---- Bag space -------------------------------------------------------------
// "Keepers" are never tossed or sold: gil, anything equipped, gear the bot can
// wear now or later (its job, its race), and spell scrolls its jobs can use.
// Everything else is "loot" - valued at its vendor price x quantity.

// Free inventory slots (0 if the bot isn't live).
auto GetBotFreeSlots(uint32 charId) -> uint8;

// Tosses loot worth less than maxValue gil, cheapest first (unsellable loot
// counts as worth 0), until `wantFree` slots are free. Returns how many stacks
// were tossed.
auto TossBotJunk(uint32 charId, uint32 maxValue, uint8 wantFree) -> uint8;

// Total vendor value of the bot's sellable loot.
auto GetBotSellableValue(uint32 charId) -> uint32;

struct BotSaleResult
{
    uint8  sold{};
    uint32 gil{};
};

// Sells all sellable loot - only works within reach of a vendor NPC (see
// GetBotVendors), as a player has to be at a shop.
auto SellBotItems(uint32 charId) -> BotSaleResult;

// Vendor NPCs (general shops) in a zone: NPCs whose script opens xi.shop.general.
auto GetBotVendors(uint16 zoneId) -> std::vector<position_t>;

} // namespace botutils
