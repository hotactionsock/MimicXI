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

#include "botauction.h"
#include "botinventory.h"
#include "botlog.h"

#include "common/database.h"
#include "common/earth_time.h"
#include "common/logging.h"

#include "entities/char_entity.h"
#include "item_container.h"
#include "items.h"
#include "items/item_equipment.h"
#include "items/transactions/item_claim.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "packet_system.h"
#include "packets/basic.h"
#include "packets/c2s/0x029_item_move.h"
#include "packets/c2s/0x04e_auc.h"
#include "utils/itemutils.h"

#include <algorithm>
#include <format>

namespace botutils
{

namespace
{

constexpr uint16 kGilItemId    = 0xFFFF; // delivery box: an AH sale's gil
constexpr uint32 kWeekSec      = 7 * 24 * 60 * 60;
constexpr uint32 kMonthSec     = 30 * 24 * 60 * 60;
constexpr uint8  kUpgradeRange = 12; // look at gear up to this many levels below the bot

auto liveBot(uint32 charId) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        return nullptr;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar || session->PChar->loc.zone == nullptr)
    {
        return nullptr;
    }

    return session->PChar.get();
}

auto itemName(uint16 itemId) -> std::string
{
    const auto* PItem = xi::items::lookup(itemId);
    return PItem ? HumanName(PItem->getName()) : std::to_string(itemId);
}

auto activeListingCount(uint32 charId) -> uint32
{
    const auto rset = db::preparedStmt("SELECT COUNT(*) AS n FROM auction_house WHERE seller = ? AND sale = 0", charId);
    FOR_DB_SINGLE_RESULT(rset)
    {
        return rset->get<uint32>("n");
    }

    return 0;
}

auto countInInventory(CCharEntity* PChar, uint16 itemId) -> uint32
{
    uint32 total = 0;
    auto*  PInv  = PChar->getStorage(LOC_INVENTORY);
    for (uint8 slot = 1; slot <= PInv->GetSize(); ++slot)
    {
        if (auto* PItem = PInv->GetItem(slot); PItem != nullptr && PItem->getID() == itemId)
        {
            total += PItem->getQuantity();
        }
    }

    return total;
}

// One AH command through the real handler (validation included: AH zone, not
// in an event, parameter ranges).
void sendAuction(CCharEntity* PChar, GP_CLI_COMMAND_AUC_COMMAND command, int8 workIndex, const auto& fill)
{
    CBasicPacket packet;
    packet.setType(static_cast<uint16>(GP_CLI_COMMAND_AUC::packetId));
    packet.setSize(sizeof(GP_CLI_COMMAND_AUC));
    packet.setSequence(0);

    auto* auc         = packet.as<GP_CLI_COMMAND_AUC>();
    auc->Command      = command;
    auc->AucWorkIndex = workIndex;
    auc->Result       = 0;
    auc->ResultStatus = 0;
    fill(auc->Param);

    g_PMapEngine->networking().packetSystem().dispatch(packet.getType(), PChar->PSession, PChar, packet);
}

// Brings an item from a bag into the inventory (the real item-move handler).
// Returns its inventory slot, or 0.
auto toInventory(CCharEntity* PChar, uint8 location, uint8 slot) -> uint8
{
    auto* PItem = PChar->getStorage(location)->GetItem(slot);
    if (PItem == nullptr)
    {
        return 0;
    }

    if (location == LOC_INVENTORY)
    {
        return slot;
    }

    auto* PInv = PChar->getStorage(LOC_INVENTORY);
    if (PInv->GetFreeSlotsCount() == 0)
    {
        return 0;
    }

    CBasicPacket packet;
    packet.setType(static_cast<uint16>(GP_CLI_COMMAND_ITEM_MOVE::packetId));
    packet.setSize(sizeof(GP_CLI_COMMAND_ITEM_MOVE));
    auto* move       = packet.as<GP_CLI_COMMAND_ITEM_MOVE>();
    move->ItemNum    = PItem->getQuantity();
    move->Category1  = location;
    move->Category2  = LOC_INVENTORY;
    move->ItemIndex1 = slot;
    move->ItemIndex2 = 0xFF; // any free slot
    g_PMapEngine->networking().packetSystem().dispatch(packet.getType(), PChar->PSession, PChar, packet);

    if (PChar->getStorage(location)->GetItem(slot) == PItem)
    {
        return 0; // not moved
    }

    for (uint8 i = 1; i <= PInv->GetSize(); ++i)
    {
        if (PInv->GetItem(i) == PItem)
        {
            return i;
        }
    }

    return 0;
}

} // namespace

auto GetBotAuctionMarket(uint32 charId, uint16 itemId, bool stack) -> BotAuctionMarket
{
    BotAuctionMarket market;
    const uint32     now = earth_time::timestamp();

    {
        const auto rset = db::preparedStmt("SELECT a.price, a.seller, (w.charid IS NOT NULL) AS bot FROM auction_house a "
                                           "LEFT JOIN world_bots w ON w.charid = a.seller "
                                           "WHERE a.itemid = ? AND a.stack = ? AND a.sale = 0 ORDER BY a.price ASC",
                                           itemId, stack);
        FOR_DB_MULTIPLE_RESULTS(rset)
        {
            const auto price  = rset->get<uint32>("price");
            const auto seller = rset->get<uint32>("seller");
            if (market.listings == 0)
            {
                market.lowest       = price;
                market.lowestIsMine = seller == charId;
            }

            ++market.listings;
            market.botListings += rset->get<uint32>("bot") != 0 ? 1 : 0;
            market.mine += seller == charId ? 1 : 0;
        }
    }

    {
        std::vector<uint32> prices;
        const auto rset = db::preparedStmt("SELECT sale, sell_date FROM auction_house WHERE itemid = ? AND stack = ? AND sale > 0 AND sell_date >= ? "
                                           "ORDER BY sell_date DESC LIMIT 25",
                                           itemId, stack, now - kMonthSec);
        FOR_DB_MULTIPLE_RESULTS(rset)
        {
            prices.push_back(rset->get<uint32>("sale"));
            market.sales7d += rset->get<uint32>("sell_date") >= now - kWeekSec ? 1 : 0;
        }

        if (!prices.empty())
        {
            std::sort(prices.begin(), prices.end());
            market.median       = prices[prices.size() / 2];
            market.historyCount = static_cast<uint32>(prices.size());
        }
    }

    if (const auto* PItem = xi::items::lookup(itemId); PItem != nullptr && !PItem->hasFlag(ItemFlag::NoSale))
    {
        market.vendorPrice = PItem->getBasePrice() * (stack ? PItem->getStackSize() : 1);
    }

    return market;
}

auto GetBotAuctionListings(uint32 charId) -> std::vector<BotAuctionListing>
{
    std::vector<BotAuctionListing> result;

    const auto rset = db::preparedStmt("SELECT itemid, stack, price, date FROM auction_house WHERE seller = ? AND sale = 0 ORDER BY id ASC", charId);
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        const auto itemId = rset->get<uint16>("itemid");
        result.push_back(BotAuctionListing{
            .itemId   = itemId,
            .stack    = rset->get<uint8>("stack") != 0,
            .price    = rset->get<uint32>("price"),
            .listedAt = rset->get<uint32>("date"),
            .name     = itemName(itemId),
        });
    }

    return result;
}

auto ListBotAuctionItem(uint32 charId, uint8 location, uint8 slot, uint32 price, bool stack) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || price == 0 || location >= CONTAINER_ID::MAX_CONTAINER_ID)
    {
        return false;
    }

    auto* PItem = PChar->getStorage(location)->GetItem(slot);
    if (PItem == nullptr)
    {
        return false;
    }

    const auto itemId   = PItem->getID();
    const auto quantity = PItem->getQuantity();

    const uint8 invSlot = toInventory(PChar, location, slot);
    if (invSlot == 0)
    {
        return false;
    }

    const auto before = activeListingCount(charId);
    if (before >= 7)
    {
        return false;
    }

    sendAuction(PChar, GP_CLI_COMMAND_AUC_COMMAND::LotIn, static_cast<int8>(before),
                [&](GP_AUC_PARAM& param)
                {
                    param.LotIn.LimitPrice    = price;
                    param.LotIn.ItemWorkIndex = invSlot;
                    param.LotIn.ItemStacks    = stack ? 0 : 1;
                });

    if (activeListingCount(charId) <= before)
    {
        return false;
    }

    const auto name = itemName(itemId);
    LogBotEvent(charId, BotLogLevel::Detail, "item", "ah_listed",
                stack ? std::format("{} put a stack of {} up for auction at {} gil", PChar->getName(), name, price)
                      : std::format("{} put {} up for auction at {} gil", PChar->getName(), name, price),
                std::format(R"({{"item_id":{},"item":"{}","stack":{},"quantity":{},"price":{}}})", itemId, JsonEscape(name), stack, quantity, price));
    return true;
}

auto CancelBotAuction(uint32 charId, uint16 itemId, bool stack, uint32 price) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() == 0)
    {
        return false;
    }

    // Open "Sales Status" (fills the list the cancel indexes into). Its 5s
    // throttle is a guard against client spam; a bot opens it once here.
    PChar->m_AHHistoryTimestamp = timer::time_point::min();
    sendAuction(PChar, GP_CLI_COMMAND_AUC_COMMAND::Info, -1, [](GP_AUC_PARAM&) {});

    int8 index = -1;
    for (std::size_t i = 0; i < PChar->m_ah_history.size() && i < 7; ++i)
    {
        const auto& entry = PChar->m_ah_history[i];
        if (entry.itemid == itemId && (entry.stack != 0) == stack && entry.price == price)
        {
            index = static_cast<int8>(i);
            break;
        }
    }

    if (index < 0)
    {
        return false;
    }

    const auto before = activeListingCount(charId);
    sendAuction(PChar, GP_CLI_COMMAND_AUC_COMMAND::LotCancel, index, [](GP_AUC_PARAM&) {});
    if (activeListingCount(charId) >= before)
    {
        return false;
    }

    const auto name = itemName(itemId);
    LogBotEvent(charId, BotLogLevel::Detail, "item", "ah_cancelled", std::format("{} took {} off the auction house", PChar->getName(), name),
                std::format(R"({{"item_id":{},"item":"{}","price":{}}})", itemId, JsonEscape(name), price));
    return true;
}

auto FindBotAuctionUpgrades(uint32 charId, uint32 maxPrice) -> std::vector<BotAuctionUpgrade>
{
    std::vector<BotAuctionUpgrade> result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr || maxPrice == 0)
    {
        return result;
    }

    const auto  job      = static_cast<uint8>(PChar->GetMJob());
    const uint8 level    = PChar->GetMLevel();
    const uint8 minLevel = level > kUpgradeRange ? level - kUpgradeRange : 1;

    const auto rset = db::preparedStmt("SELECT a.itemid, MIN(a.price) AS price FROM auction_house a "
                                       "INNER JOIN item_equipment e ON e.itemId = a.itemid "
                                       "WHERE a.sale = 0 AND a.stack = 0 AND a.seller != ? AND (e.jobs & ?) != 0 AND e.level <= ? AND e.level >= ? "
                                       "GROUP BY a.itemid HAVING MIN(a.price) <= ? ORDER BY MIN(a.price) ASC LIMIT 40",
                                       charId, 1u << (job - 1), level, minLevel, maxPrice);
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        const auto itemId = rset->get<uint16>("itemid");
        const auto gain   = EvaluateBotGearItem(charId, itemId);
        if (gain > 0.0f)
        {
            result.push_back(BotAuctionUpgrade{ .itemId = itemId, .price = rset->get<uint32>("price"), .gain = gain, .name = itemName(itemId) });
        }
    }

    std::sort(result.begin(), result.end(),
              [](const BotAuctionUpgrade& a, const BotAuctionUpgrade& b)
              {
                  return a.gain > b.gain;
              });
    if (result.size() > 5)
    {
        result.resize(5);
    }

    return result;
}

auto BuyBotAuctionItem(uint32 charId, uint16 itemId, bool stack, uint32 maxPrice) -> uint32
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() == 0)
    {
        return 0;
    }

    // The cheapest listing sells first: never bid when that's its own.
    const auto market = GetBotAuctionMarket(charId, itemId, stack);
    if (market.listings == 0 || market.lowestIsMine || market.lowest > maxPrice)
    {
        return 0;
    }

    const auto price  = market.lowest;
    const auto before = countInInventory(PChar, itemId);
    sendAuction(PChar, GP_CLI_COMMAND_AUC_COMMAND::Bid, 0,
                [&](GP_AUC_PARAM& param)
                {
                    param.Bid.BidPrice   = price;
                    param.Bid.ItemNo     = itemId;
                    param.Bid.ItemStacks = stack ? 0 : 1;
                });

    if (countInInventory(PChar, itemId) <= before)
    {
        return 0;
    }

    const auto name = itemName(itemId);
    LogBotEvent(charId, BotLogLevel::Notable, "item", "ah_bought",
                std::format("{} bought {} at the auction house for {} gil", PChar->getName(), name, price),
                std::format(R"({{"item_id":{},"item":"{}","stack":{},"price":{}}})", itemId, JsonEscape(name), stack, price));
    return price;
}

auto CollectBotDeliveries(uint32 charId) -> BotDeliveries
{
    BotDeliveries result;

    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return result;
    }

    struct Row
    {
        uint16 slot;
        uint16 itemId;
        uint16 subId;
        uint32 quantity;
    };

    std::vector<Row> rows;
    {
        const auto rset = db::preparedStmt("SELECT slot, itemid, itemsubid, quantity FROM delivery_box "
                                           "WHERE charid = ? AND box = 1 AND sender = 'AH-Jeuno' ORDER BY slot ASC",
                                           charId);
        FOR_DB_MULTIPLE_RESULTS(rset)
        {
            rows.push_back(Row{ rset->get<uint16>("slot"), rset->get<uint16>("itemid"), rset->get<uint16>("itemsubid"), rset->get<uint32>("quantity") });
        }
    }

    for (const auto& row : rows)
    {
        if (row.itemId == kGilItemId)
        {
            // A sale: the gil goes in the purse (the caller credits it).
            if (db::preparedStmt("DELETE FROM delivery_box WHERE charid = ? AND box = 1 AND slot = ?", charId, row.slot))
            {
                result.gil += row.quantity;
                result.sold.emplace_back(row.subId, row.quantity);

                const auto name = itemName(row.subId);
                LogBotEvent(charId, BotLogLevel::Notable, "item", "ah_sold",
                            std::format("{} sold {} on the auction house for {} gil", PChar->getName(), name, row.quantity),
                            std::format(R"({{"item_id":{},"item":"{}","price":{}}})", row.subId, JsonEscape(name), row.quantity));
            }

            continue;
        }

        // An expired listing coming back.
        if (PChar->getStorage(LOC_INVENTORY)->GetFreeSlotsCount() == 0)
        {
            continue; // collect it another time
        }

        auto tx = ItemClaimTransaction::start(PChar);
        if (tx && tx->give(LOC_INVENTORY, row.itemId, row.quantity, Silence::Yes) && tx->commit())
        {
            db::preparedStmt("DELETE FROM delivery_box WHERE charid = ? AND box = 1 AND slot = ?", charId, row.slot);
            result.returned.push_back(row.itemId);

            const auto name = itemName(row.itemId);
            LogBotEvent(charId, BotLogLevel::Detail, "item", "ah_returned", std::format("{}'s {} didn't sell and came back", PChar->getName(), name),
                        std::format(R"({{"item_id":{},"item":"{}"}})", row.itemId, JsonEscape(name)));
        }
    }

    return result;
}

auto GetBotAuctionPurse(uint32 charId) -> uint32
{
    const auto rset = db::preparedStmt("SELECT ah_purse FROM world_bots WHERE charid = ?", charId);
    FOR_DB_SINGLE_RESULT(rset)
    {
        return rset->get<uint32>("ah_purse");
    }

    return 0;
}

auto AddBotAuctionPurse(uint32 charId, int32 delta, uint32 cap) -> uint32
{
    const int64  current = GetBotAuctionPurse(charId);
    const uint32 updated = static_cast<uint32>(std::clamp<int64>(current + delta, 0, cap));
    db::preparedStmt("UPDATE world_bots SET ah_purse = ? WHERE charid = ?", updated, charId);
    return updated;
}

auto GetBotAuctionFails(uint32 charId) -> std::vector<BotAuctionFail>
{
    std::vector<BotAuctionFail> result;

    const auto rset = db::preparedStmt("SELECT itemid, fails, last_fail FROM world_bot_ah WHERE charid = ?", charId);
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        result.push_back(BotAuctionFail{ rset->get<uint16>("itemid"), rset->get<uint8>("fails"), rset->get<uint32>("last_fail") });
    }

    return result;
}

void NoteBotAuctionFail(uint32 charId, uint16 itemId)
{
    db::preparedStmt("INSERT INTO world_bot_ah (charid, itemid, fails, last_fail) VALUES (?, ?, 1, ?) "
                     "ON DUPLICATE KEY UPDATE fails = LEAST(fails + 1, 250), last_fail = VALUES(last_fail)",
                     charId, itemId, earth_time::timestamp());
}

void ClearBotAuctionFail(uint32 charId, uint16 itemId)
{
    db::preparedStmt("DELETE FROM world_bot_ah WHERE charid = ? AND itemid = ?", charId, itemId);
}

void DeleteBotAuctionData(uint32 charId)
{
    // Unsold listings would otherwise sell for a character that no longer exists.
    db::preparedStmt("DELETE FROM auction_house WHERE seller = ? AND sale = 0", charId);
    db::preparedStmt("DELETE FROM world_bot_ah WHERE charid = ?", charId);
    ForgetBotAuctionItems(charId);
}

} // namespace botutils
