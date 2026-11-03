-----------------------------------
-- xi.worldbots.ah - the Auction House (Phase 6b-AH).
--
-- Every few hours a bot (level 10+, not hired) goes to an Auction Counter in
-- its home city and:
--   1. collects what the AH sent it: sale gil (into its AH purse) and
--      listings that expired unsold (back into its bags, one more "fail")
--   2. looks over its listings: one that has sat a day or more and been
--      undercut comes down (another "fail") to be priced again
--   3. fills its free listing slots (7 at most, as for players) with what's
--      most worth selling
--   4. maybe buys one gear upgrade for the job it's levelling
-- All through the real AH handler (botauction.h): fees, the 7-listing limit,
-- the cheapest listing selling first - exactly as for players.
--
-- What it sells (GetBotAuctionCandidates): never Rare/Ex items; gear for the
-- job it's levelling is kept for levelling (a duplicate copy is fair game);
-- scrolls one of its jobs could still learn are kept; nor the consumables it
-- buys from vendors itself (selling those would turn vendor gil into AH gil).
--
-- Priority: expected price x demand (recent sales against current supply),
-- halved for every recent time it failed to sell. Fails fade a day at a time,
-- so an item drops down the list and comes back later. A common drop that
-- keeps failing is given up: vendored on its next vendor visit, or tossed if
-- it's worth next to nothing.
--
-- Keeping the economy sane:
--   * Closed purse. Bots carry the gil cap for vendors, so AH money is kept
--     apart (world_bots.ah_purse): credited only by AH sales and vendor sales
--     of loot - the same faucets a player has - and capped by level. AH buys
--     must fit in it. Bots can only put back into the market what the market
--     and their own loot gave them.
--   * Anchored prices. A reference price comes from the median of recent
--     sales (or, with no history, a multiple of the vendor price). Listings
--     stay within [floor, ceiling] around it: a bot undercuts the cheapest
--     listing by 1-5%, but never below the floor (no race to the bottom, never
--     below what a vendor pays) and never above the ceiling (no runaway
--     prices). If the market is already below its floor it waits.
--   * Supply caps. A bot won't add to an item that already has plenty
--     listed, or that other bots already list heavily, or that it lists itself.
--   * Needs only. Bots buy gear upgrades for their own job and level - at most
--     one per visit, never more than half the purse, never well above the
--     going rate. No speculation, no flipping.
--
-- map.WORLDBOTS_AH = false turns it off.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.ah = xi.worldbots.ah or {}

local ah = xi.worldbots.ah

local AH_MIN_LEVEL       = 10
local VISIT_MIN_SEC      = 3 * 60 * 60  -- between AH trips
local VISIT_MAX_SEC      = 6 * 60 * 60
local FIRST_VISIT_MIN    = 20 * 60      -- first trip after it's first seen
local FIRST_VISIT_MAX    = 90 * 60
local MAX_LISTINGS       = 7
local STALE_SEC          = 24 * 60 * 60 -- an undercut listing older than this comes down
local DAY_SEC            = 24 * 60 * 60

-- Pricing
local NO_HISTORY_GEAR    = 4            -- no sales history: price at vendor x this (gear)...
local NO_HISTORY_OTHER   = 3            -- ...or x this (anything else)
local MIN_SINGLE_PRICE   = 100          -- never list a single below this...
local MIN_STACK_PRICE    = 300          -- ...or a stack below this
local HISTORY_TRUSTED    = 3            -- sales needed to trust the median alone
local FLOOR_OF_REFERENCE = 0.7
local CEILING_OF_REF     = 1.3
local FLOOR_OVER_VENDOR  = 1.1          -- never below what a vendor pays, plus a little
local UNDERCUT_MIN       = 0.01
local UNDERCUT_MAX       = 0.05

-- Supply
local SUPPLY_CAP_SINGLE  = 5            -- don't add to an item with this many listed...
local SUPPLY_CAP_STACK   = 3
local BOT_SHARE_CAP      = 2            -- ...or that bots already list this many of

-- Failing to sell
local GIVE_UP_FAILS      = 3
local COMMON_REF_OVER_VENDOR = 2        -- "common": worth at most this x vendor price...
local COMMON_MAX_PRICE   = 1000         -- ...or under this, with no sales in a week

-- Buying
local PURSE_BASE         = 20000
local PURSE_PER_LEVEL    = 3000
local BUY_PURSE_SHARE    = 0.5          -- never spend more than this share of the purse at once
local BUY_OVER_REFERENCE = 1.15         -- never pay more than this x the going rate
local BUY_NO_HISTORY     = 6            -- no history: at most vendor x this

-- AH fee, as auctionutils charges it (map settings).
local function auctionFee(price, stack)
    local map  = xi.settings.map or {}
    local base = stack and (map.AH_BASE_FEE_STACKS or 4) or (map.AH_BASE_FEE_SINGLE or 1)
    local rate = stack and (map.AH_TAX_RATE_STACKS or 0.5) or (map.AH_TAX_RATE_SINGLE or 1.0)
    return math.min(math.floor(base + price * rate / 100), map.AH_MAX_FEE or 10000)
end

local function enabled()
    local map = xi.settings and xi.settings.map
    return map == nil or map.WORLDBOTS_AH ~= false
end

function ah.purseCap(bot)
    return PURSE_BASE + PURSE_PER_LEVEL * bot:getMainLvl()
end

-- Vendor sales of loot add to the AH purse (the same faucet a player has).
function ah.creditVendorSale(bot, charId, gil)
    if gil > 0 then
        AddBotAuctionPurse(charId, gil, ah.purseCap(bot))
    end
end

-- Recent fails count, a day's grace taking one off.
local function effectiveFails(fail, now)
    if fail == nil then
        return 0
    end

    return math.max(0, fail.fails - math.floor((now - fail.lastFail) / DAY_SEC))
end

-- The going rate for one (or a stack), or nil if it can't be priced.
local function referencePrice(market, gear, stack)
    local fallback = market.vendorPrice * (gear and NO_HISTORY_GEAR or NO_HISTORY_OTHER)
    fallback = math.max(fallback, stack and MIN_STACK_PRICE or MIN_SINGLE_PRICE)

    if market.historyCount >= HISTORY_TRUSTED then
        return market.median
    elseif market.historyCount > 0 then
        return math.floor((market.median + fallback) / 2)
    end

    return fallback
end

local function priceBand(market, reference, stack)
    local minimum = stack and MIN_STACK_PRICE or MIN_SINGLE_PRICE
    local floor   = math.max(minimum, math.ceil(market.vendorPrice * FLOOR_OVER_VENDOR), math.floor(reference * FLOOR_OF_REFERENCE))
    local ceiling = math.max(floor, math.floor(reference * CEILING_OF_REF))
    return floor, ceiling
end

-- What to ask: the going rate, or a small undercut of the cheapest listing -
-- within the band. nil = the market is below its floor right now; wait.
local function askingPrice(market, reference, stack)
    local floor, ceiling = priceBand(market, reference, stack)
    local target = reference

    if market.lowest > 0 and not market.lowestIsMine then
        local undercut = math.max(1, math.floor(market.lowest * math.randomFloat(UNDERCUT_MIN, UNDERCUT_MAX)))
        target = math.min(target, market.lowest - undercut)
    end

    if target < floor then
        return nil
    end

    return math.min(target, ceiling)
end

-- A cheap, plentiful thing nobody's buying.
local function isCommon(market, reference)
    if
        market.vendorPrice > 0 and
        reference <= market.vendorPrice * COMMON_REF_OVER_VENDOR
    then
        return true
    end

    return market.sales7d == 0 and reference < COMMON_MAX_PRICE
end

-- Items it buys from vendors for itself: never resold on the AH.
local function vendorStock()
    local ids = {}
    for _, id in ipairs(xi.worldbots.shop.consumableIds and xi.worldbots.shop.consumableIds() or {}) do
        ids[id] = true
    end

    return ids
end

-- Should the bot plan an AH trip now?
function ah.wantsTrip(bot, charId, state, now)
    if
        not enabled() or
        bot:getMainLvl() < AH_MIN_LEVEL or
        xi.worldbots.hire.isHired(state)
    then
        return false
    end

    if state.nextAHAt == nil then
        state.nextAHAt = now + math.random(FIRST_VISIT_MIN, FIRST_VISIT_MAX)
        return false
    end

    if now < state.nextAHAt then
        return false
    end

    state.nextAHAt = now + math.random(VISIT_MIN_SEC, VISIT_MAX_SEC)

    -- Something to do there: listings to look after, or things to sell.
    return #GetBotAuctionListings(charId) > 0 or #GetBotAuctionCandidates(charId) > 0
end

-- A city with an Auction Counter to go to: its home city if that has one,
-- else nil. hasCounter(zoneId) tells.
function ah.tripZone(bot, zoneId, hasCounter)
    if hasCounter(zoneId) then
        return zoneId
    end

    local home = GetBotHomeZone(bot:getNation(), zoneId)
    if home ~= 0 and hasCounter(home) then
        return home
    end

    return nil
end

-- 1. What the AH sent: sale gil into the purse, expired listings back.
local function collect(bot, charId, now)
    local deliveries = CollectBotDeliveries(charId)
    if deliveries.gil > 0 then
        AddBotAuctionPurse(charId, deliveries.gil, ah.purseCap(bot))
    end

    for _, sale in ipairs(deliveries.sold) do
        ClearBotAuctionFail(charId, sale.itemId)
    end

    for _, itemId in ipairs(deliveries.returned) do
        NoteBotAuctionFail(charId, itemId)
    end

    return deliveries
end

-- 2. Listings that sat a day and got undercut come down to be priced again.
local function review(charId, now)
    local listings = GetBotAuctionListings(charId)
    local active   = #listings

    for _, listing in ipairs(listings) do
        if now - listing.listedAt >= STALE_SEC then
            local market = GetBotAuctionMarket(charId, listing.itemId, listing.stack)
            if
                market.lowest > 0 and
                market.lowest < listing.price and
                CancelBotAuction(charId, listing.itemId, listing.stack, listing.price)
            then
                NoteBotAuctionFail(charId, listing.itemId)
                active = active - 1
            end
        end
    end

    return active
end

-- 3. Fill free listing slots with what's most worth selling.
local function list(bot, charId, now, freeSlots)
    if freeSlots <= 0 then
        return 0
    end

    local fails   = GetBotAuctionFails(charId)
    local exclude = vendorStock()
    local scored  = {}
    local seen    = {}

    for _, c in ipairs(GetBotAuctionCandidates(charId)) do
        local key = c.itemId * 2 + (c.stack and 1 or 0)
        if not exclude[c.itemId] and not seen[key] then
            seen[key] = true

            local market    = GetBotAuctionMarket(charId, c.itemId, c.stack)
            local reference = referencePrice(market, c.gear, c.stack)
            local failCount = effectiveFails(fails[c.itemId], now)

            if failCount >= GIVE_UP_FAILS and isCommon(market, reference) then
                -- A common drop that won't sell: give up - vendor or toss it.
                ReleaseBotKeptItem(charId, c.itemId)
                xi.worldbots.log.event(bot, xi.worldbots.log.DETAIL, 'item', 'ah_gave_up',
                    string.format('%s gave up selling %s on the auction house', bot:getName(), c.name),
                    { item_id = c.itemId, item = c.name })
            elseif
                market.mine == 0 and
                market.listings < (c.stack and SUPPLY_CAP_STACK or SUPPLY_CAP_SINGLE) and
                market.botListings < BOT_SHARE_CAP
            then
                local price = askingPrice(market, reference, c.stack)
                if price then
                    local demand = (1 + market.sales7d) / (1 + market.listings)
                    table.insert(scored, { c = c, price = price, score = price * demand * 0.5 ^ failCount })
                end
            end
        end
    end

    table.sort(scored, function(a, b)
        return a.score > b.score
    end)

    local listed = 0
    for _, pick in ipairs(scored) do
        if listed >= freeSlots then
            break
        end

        if ListBotAuctionItem(charId, pick.c.location, pick.c.slot, pick.price, pick.c.stack) then
            listed = listed + 1
            -- The fee is a sink: it comes out of the purse.
            AddBotAuctionPurse(charId, -auctionFee(pick.price, pick.c.stack), ah.purseCap(bot))
        end
    end

    return listed
end

-- 4. Maybe one gear upgrade for the job it's levelling, at a fair price.
local function buy(bot, charId)
    local purse  = GetBotAuctionPurse(charId)
    local budget = math.floor(purse * BUY_PURSE_SHARE)
    if budget <= 0 then
        return nil
    end

    for _, upgrade in ipairs(FindBotAuctionUpgrades(charId, budget)) do
        local market = GetBotAuctionMarket(charId, upgrade.itemId, false)
        local limit  = budget
        if market.historyCount >= HISTORY_TRUSTED then
            limit = math.min(limit, math.floor(market.median * BUY_OVER_REFERENCE))
        elseif market.vendorPrice > 0 then
            limit = math.min(limit, market.vendorPrice * BUY_NO_HISTORY)
        end

        local paid = BuyBotAuctionItem(charId, upgrade.itemId, false, limit)
        if paid > 0 then
            AddBotAuctionPurse(charId, -paid, ah.purseCap(bot))
            return upgrade.name
        end
    end

    return nil
end

-- At the Auction Counter.
function ah.visit(bot, charId, state, now)
    if not enabled() then
        return
    end

    local deliveries = collect(bot, charId, now)
    local active     = review(charId, now)
    local listed     = list(bot, charId, now, MAX_LISTINGS - active)
    local bought     = buy(bot, charId)

    -- Bought gear gets worn at the next inventory check.
    if bought then
        state.nextInventoryCheckAt = now
    end

    return { sold = #deliveries.sold, returned = #deliveries.returned, listed = listed, bought = bought }
end

return ah
