-----------------------------------
-- xi.worldbots.shop - buying from vendors (Phase 6a).
--
-- When a bot has gil to spend and has gained a few levels since it last went
-- shopping (or right after selling loot in town), it goes round the general
-- shops of a city: walks up to each vendor, looks at what it sells (the
-- vendor's own script runs, so stock and prices are what a player of that
-- nation and rank would see) and buys:
--   1. spell scrolls its main or sub job can use and doesn't know yet,
--   2. clear gear upgrades - judged by the same per-job stat weights as its
--      gear sets (EvaluateBotGearItem), best gain first, re-planning its sets
--      after each buy so it doesn't buy two of the same upgrade,
--   3. a small stock of travel and job consumables (Silent Oil, Prism Powder,
--      Shihei for Utsusemi users).
-- It always keeps a reserve of gil, and never spends on things it can't use
-- yet. Every purchase is in the activity log ("Testbot bought Scroll of Cure
-- for 61 gil" - logged engine-side).
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.shop = xi.worldbots.shop or {}

local shop = xi.worldbots.shop

local SHOP_MIN_GIL        = 300     -- don't go shopping with less than this
local SHOP_LEVELS_BETWEEN = 3       -- go again once this many levels have passed
local SHOP_RETRY_SEC      = 30 * 60 -- after a trip, wait at least this long before the next
local RESERVE_FRACTION    = 0.3     -- keep this share of gil...
local RESERVE_MIN         = 100     -- ...and at least this much
local MIN_GEAR_GAIN       = 3       -- weighted stat gain for gear to count as an upgrade
local MAX_SHOPS_PER_TRIP  = 8

-- Consumables kept in stock: item name, how many to keep, when.
local CONSUMABLES =
{
    { item = 'SILENT_OIL',   keep = 4,  minLevel = 10 },
    { item = 'PRISM_POWDER', keep = 4,  minLevel = 10 },
    { item = 'SHIHEI',       keep = 20, needsSpell = 'UTSUSEMI_ICHI' },
}

-- Item ids of the consumables it keeps in stock (never resold on the AH:
-- that would turn vendor gil into AH gil - worldbots_ah.lua).
function shop.consumableIds()
    local ids = {}
    for _, entry in ipairs(CONSUMABLES) do
        local id = xi.item[entry.item]
        if id then
            table.insert(ids, id)
        end
    end

    return ids
end

local function budget(bot)
    local gil = bot:getGil()
    return gil - math.max(RESERVE_MIN, math.floor(gil * RESERVE_FRACTION))
end

-- Should the bot plan a shopping trip now?
function shop.wantsTrip(bot, state, now)
    if bot:getGil() < SHOP_MIN_GIL or now < (state.nextShopTripAt or 0) then
        return false
    end

    return state.lastShopLevel == nil or bot:getMainLvl() >= state.lastShopLevel + SHOP_LEVELS_BETWEEN
end

-- Starts going round this zone's shops. False if there are none (or no gil).
function shop.begin(bot, charId, state, now, zoneId)
    if bot:getGil() < SHOP_MIN_GIL then
        return false
    end

    local shops = GetBotShops(zoneId)
    if #shops == 0 then
        return false
    end

    -- A random order, so bots don't all queue at the same counter.
    for i = #shops, 2, -1 do
        local j = math.random(1, i)
        shops[i], shops[j] = shops[j], shops[i]
    end

    local queue = {}
    for i = 1, math.min(#shops, MAX_SHOPS_PER_TRIP) do
        table.insert(queue, shops[i])
    end

    state.shopping = { queue = queue, index = 0, bought = 0 }
    return shop.next(bot, charId, state, now)
end

-- Walks to the next shop on the list. False when the round is over.
function shop.next(bot, charId, state, now)
    local trip = state.shopping
    if trip == nil then
        return false
    end

    trip.index = trip.index + 1
    local target = trip.queue[trip.index]
    if target == nil or budget(bot) <= 0 then
        return false
    end

    local zone = bot:getZone()
    -- target is already the floor in front of the counter (GetBotShops) - only
    -- a small scatter, so bots don't stack on one spot.
    local spot = zone and zone:getRandomNavmeshPoint(target, 0.5) or target
    state.walk = { target = spot, attempts = 0, bestDist = math.huge, purpose = 'shop' }
    state.walking, state.walkOrderAt = false, nil
    return true
end

local function knowsSpell(state, name)
    local id = xi.magic.spell[name]
    local m  = state.magic
    return id ~= nil and m ~= nil and m.spells ~= nil and m.spells[id] ~= nil
end

-- Buys what's worth buying at the shop the bot is standing at.
function shop.buyHere(bot, charId, state, now)
    local trip   = state.shopping
    local target = trip and trip.queue[trip.index]
    if target == nil then
        return
    end

    local items = BrowseBotShop(charId, target.npcId)
    if #items == 0 then
        return
    end

    -- 1. Spell scrolls it can use now.
    for _, item in ipairs(items) do
        if item.price <= budget(bot) and IsUsefulBotScroll(charId, item.itemId) then
            if BuyBotShopItem(charId, item.index, 1) then
                trip.bought = trip.bought + 1
            end
        end
    end

    -- 2. Gear upgrades, best gain first; re-plan after each so the same slot
    -- isn't bought twice.
    while true do
        local best, bestGain = nil, MIN_GEAR_GAIN
        for _, item in ipairs(items) do
            if item.price <= budget(bot) then
                local gain = EvaluateBotGearItem(charId, item.itemId)
                if gain > bestGain then
                    best, bestGain = item, gain
                end
            end
        end

        if best == nil or not BuyBotShopItem(charId, best.index, 1) then
            break
        end

        trip.bought = trip.bought + 1
        xi.worldbots.gear.plan(bot, charId, state)
    end

    -- 3. Consumables, topped up to their stock level.
    for _, want in ipairs(CONSUMABLES) do
        local itemId = xi.item[want.item]
        local needed =
            itemId ~= nil and
            (want.minLevel == nil or bot:getMainLvl() >= want.minLevel) and
            (want.needsSpell == nil or knowsSpell(state, want.needsSpell))

        if needed then
            for _, item in ipairs(items) do
                if item.itemId == itemId then
                    local missing    = want.keep - bot:getItemCount(itemId)
                    local affordable = item.price > 0 and math.floor(budget(bot) / item.price) or 0
                    local quantity   = math.min(missing, affordable)
                    if quantity > 0 and BuyBotShopItem(charId, item.index, quantity) then
                        trip.bought = trip.bought + 1
                    end
                end
            end
        end
    end
end

-- The round is over: put the new things to use and note when it went.
function shop.finish(bot, charId, state, now)
    local trip     = state.shopping
    state.shopping = nil

    state.lastShopLevel  = bot:getMainLvl()
    state.nextShopTripAt = now + SHOP_RETRY_SEC

    if trip and trip.bought > 0 then
        ManageBotInventory(charId) -- learn the scrolls
        xi.worldbots.magic.refresh(bot, charId, state, now, true)
        xi.worldbots.gear.plan(bot, charId, state)
        xi.worldbots.gear.base(bot, charId, state)
    end
end

return shop
