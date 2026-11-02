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
#include <unordered_map>
#include <utility>
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
// Once a bot has gear sets planned (PlanBotGear), equipping is left to those
// and this only learns scrolls.
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

// ---- Gear sets (Phase 3) ---------------------------------------------------
// A player swaps gear for what they're doing: an idle set, a set for meleeing,
// one for weapon skills, others for nuking or curing. Bots do the same. The
// stat weights come from Lua (worldbots_gear.lua, per job) so they can be tuned
// without a rebuild. Weapons are chosen once, by one set's weights, and never
// swapped by a set change - in FFXI changing weapons costs your TP.

struct BotGearWeights
{
    std::unordered_map<uint16, float> mods;      // xi::Mod id -> weight per point
    float                             weaponDps{}; // weight on weapon damage x 240 / delay
};

// Works out each set's best armour from what the bot carries, and equips the
// best weapons by weaponSet's weights. Run during inventory upkeep (out of
// combat). Returns the number of weapon slots changed.
auto PlanBotGear(uint32 charId, const std::vector<std::pair<std::string, BotGearWeights>>& sets, const std::string& weaponSet) -> uint8;

// Puts on a planned set's armour (weapons untouched). Items that have moved or
// gone since planning are skipped. Returns the number of slots changed.
auto EquipBotGearSet(uint32 charId, const std::string& name) -> uint8;

// Drops a bot's gear plans (despawn).
void ForgetBotGear(uint32 charId);

} // namespace botutils
