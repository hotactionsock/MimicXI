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
#include <utility>
#include <vector>

// The Auction House for world bots (Phase 6b-AH). Every listing, cancel and
// purchase goes through the real AH packet handler (GP_CLI_COMMAND_AUC ->
// auctionutils), so fees, the 7-listing limit, the AH-zone check and "the
// cheapest listing sells first" are exactly as for players. What to sell,
// at what price, and what to buy is xi.worldbots.ah policy
// (scripts/globals/worldbots_ah.lua).
//
// Bots carry the gil cap for vendors, so AH money is kept apart: each bot has
// an AH purse (world_bots.ah_purse), credited only by its AH sales and its
// vendor sales of loot, and AH purchases must fit in it. That closes the loop -
// bots can only put back into the market the gil the market (and their loot)
// gave them.
namespace botutils
{

// The market for one item (singles or stacks), from auction_house.
struct BotAuctionMarket
{
    uint32 lowest{ 0 };        // cheapest active listing (0 = none)
    bool   lowestIsMine{ false };
    uint32 listings{ 0 };      // active listings
    uint32 botListings{ 0 };   // ...of which by world bots
    uint32 mine{ 0 };          // ...of which by this bot
    uint32 sales7d{ 0 };       // sold in the last 7 days
    uint32 median{ 0 };        // median sale price over the last 30 days (0 = no history)
    uint32 historyCount{ 0 };  // sales that median is from
    uint32 vendorPrice{ 0 };   // what a vendor pays for one (or a stack)
};

auto GetBotAuctionMarket(uint32 charId, uint16 itemId, bool stack) -> BotAuctionMarket;

struct BotAuctionListing
{
    uint16      itemId;
    bool        stack;
    uint32      price;
    uint32      listedAt;
    std::string name;
};

// The bot's active listings.
auto GetBotAuctionListings(uint32 charId) -> std::vector<BotAuctionListing>;

// Lists the item at (location, slot) - moved into its inventory first if it's
// in a bag (the real item-move handler) - for price, as a stack or a single.
// The bot must be in a zone with an Auction House. True if it went up.
auto ListBotAuctionItem(uint32 charId, uint8 location, uint8 slot, uint32 price, bool stack) -> bool;

// Takes one of its listings down (the item comes back to its inventory).
auto CancelBotAuction(uint32 charId, uint16 itemId, bool stack, uint32 price) -> bool;

struct BotAuctionUpgrade
{
    uint16      itemId;
    uint32      price; // cheapest listing by someone else
    float       gain;  // EvaluateBotGearItem
    std::string name;
};

// Gear on sale now that would be an upgrade for the bot's main job at its
// level (by its gear-set stat weights), cheapest listing at most maxPrice -
// best gain first, at most 5.
auto FindBotAuctionUpgrades(uint32 charId, uint32 maxPrice) -> std::vector<BotAuctionUpgrade>;

// Buys the cheapest listing of the item by someone else, if it costs at most
// maxPrice. Returns the price paid (0 = nothing bought).
auto BuyBotAuctionItem(uint32 charId, uint16 itemId, bool stack, uint32 maxPrice) -> uint32;

struct BotDeliveries
{
    uint32                                gil{ 0 };
    std::vector<std::pair<uint16, uint32>> sold;     // item id, price
    std::vector<uint16>                   returned; // expired listings handed back
};

// Collects what the AH sent the bot (delivery box 1, from AH-Jeuno): sale
// gil and expired listings coming back (into its inventory while there's room).
auto CollectBotDeliveries(uint32 charId) -> BotDeliveries;

// The bot's AH purse. AddBotAuctionPurse clamps to [0, cap] and returns it.
auto GetBotAuctionPurse(uint32 charId) -> uint32;
auto AddBotAuctionPurse(uint32 charId, int32 delta, uint32 cap) -> uint32;

// Items that went unsold, per bot: how many times and when last.
struct BotAuctionFail
{
    uint16 itemId;
    uint8  fails;
    uint32 lastFail;
};

auto GetBotAuctionFails(uint32 charId) -> std::vector<BotAuctionFail>;
void NoteBotAuctionFail(uint32 charId, uint16 itemId);
void ClearBotAuctionFail(uint32 charId, uint16 itemId);

// ---- Starting prices ----------------------------------------------------------
//
// What an item is worth before the market has spoken (no sales history yet),
// or what the server owner says it's worth:
//   manual  - world_bot_ah_prices (set with !worldbot ahprice, or imported
//             from an ffxiahbot-format CSV): always wins, and can also forbid
//             bots from listing an item at all
//   level   - gear: by its level and how many jobs can wear it (a curve:
//             level 10 ~2k, 30 ~13k, 50 ~31k, 75 ~61k for all-job gear) - or
//             what farming it takes, if more (an NM's gear)
//   drops   - anything else an ordinary mob drops: from the cheapest way to
//             farm it (drop chance and mob level, mob_droplist). Drops known
//             only from NMs are ignored for non-gear
//   vendor  - anything else: a multiple of the vendor price
// Market sale history takes over from the estimate once there is some
// (worldbots_ah.lua); a manual price beats both.
struct BotAuctionPrice
{
    uint32      single{ 0 };
    uint32      stacks{ 0 };
    bool        manualSingle{ false };
    bool        manualStacks{ false };
    bool        allow{ true };   // false = bots never list it (manual)
    bool        commonDrop{ false }; // farmed easily: an ordinary mob, 10%+ chance
    std::string source;          // "manual", "level", "drops" or "vendor"
};

auto GetBotAuctionStartPrice(uint16 itemId) -> BotAuctionPrice;

// Manual prices (0 = no override for that kind - use the estimate).
void SetBotAuctionPrice(uint16 itemId, uint32 single, uint32 stacks, bool allow);
void ClearBotAuctionPrice(uint16 itemId);

// Everything AH for a bot that's being deleted (or a new bot reusing its
// charid): its unsold listings, fail counts and given-up items.
void DeleteBotAuctionData(uint32 charId);

} // namespace botutils
