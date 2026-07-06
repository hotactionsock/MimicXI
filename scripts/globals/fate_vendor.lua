-----------------------------------
-- FATE Regional Vendor System
--
-- Each FATE region has one Adventurers' Liaison NPC whose stock is gated
-- by how many FATEs a player has completed in that region this week.
-- Stock is server-wide and limited — once an item sells out it won't
-- restock until Sunday midnight JST (aligned with the conquest update).
--
-- Purchase flow: talk to the NPC to see the catalog, then trade the
-- exact gil amount shown for the item you want.  Items you haven't
-- yet unlocked via FATE participation are shown as locked with a count
-- of how many completions are still needed.
-----------------------------------
require('scripts/globals/npc_util')

xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.vendor = xi.fate.vendor or {}

-----------------------------------
-- Server / char variable keys
-----------------------------------
local function weekStartKey()             return "[FATE_VENDOR]WeekStart"                                  end
local function stockKey(region, idx)      return string.format("[FATE_VENDOR][%s][%d]Stock",  region, idx) end
local function playerWeekFatesKey(region) return string.format("[FATE_VENDOR][%s]WeekFates",  region)      end
local function playerWeekStampKey(region) return string.format("[FATE_VENDOR][%s]WeekStamp",  region)      end

-----------------------------------
-- Week boundary helpers
-----------------------------------

-- Returns the Unix timestamp of the most recent Sunday midnight JST (UTC+9).
-- Aligns with the FFXI conquest weekly tally reset schedule.
local function getWeekStart()
    local now        = GetSystemTime()
    local JST_OFFSET = 9 * 3600
    local jstNow     = now + JST_OFFSET
    local jstDays    = math.floor(jstNow / 86400)
    -- Unix epoch (1970-01-01) was a Thursday.
    -- jstDays % 7 maps: 0=Thu, 1=Fri, 2=Sat, 3=Sun, 4=Mon, 5=Tue, 6=Wed
    local dow     = jstDays % 7
    local daySun  = (dow - 3 + 7) % 7   -- days elapsed since most recent Sunday
    local sunJST  = (jstDays - daySun) * 86400
    return sunJST - JST_OFFSET           -- convert back to UTC
end

-- Reset stock for every registered region if the week has rolled over.
-- Idempotent — safe to call multiple times per tick.
local function maybeResetWeek()
    local weekStart = getWeekStart()
    if GetServerVariable(weekStartKey()) >= weekStart then return end
    SetServerVariable(weekStartKey(), weekStart)
    for region, def in pairs(xi.fate.vendor.regions) do
        for idx, item in ipairs(def.stock) do
            SetServerVariable(stockKey(region, idx), item.weeklyServerStock)
        end
    end
end

-----------------------------------
-- Region definitions
-----------------------------------
-- Each region entry describes:
--   name             string   NPC display name
--   look             number   NPC model ID
--   vendorZone       number   xi.zone constant for the zone where the NPC spawns
--   vendorPos        table    { x, y, z, rotation }
--   stock            array    Item entries (see below)
--
-- Each stock entry:
--   item             number   xi.item constant
--   name             string   Display name shown in catalog
--   price            number   Gil cost AND purchase code (must be unique per region)
--   weeklyServerStock number  Maximum available across all players per week
--   requiredFates    number   Minimum weekly completions in the region to unlock
-----------------------------------
xi.fate.vendor.regions =
{
    STARTER_ZULKHEIM =
    {
        name       = "Adventurers' Liaison",
        look       = 1402,
        vendorZone = xi.zone.SOUTH_GUSTABERG,
        vendorPos  = { 568.0, 0.0, -290.0, 128 },  -- TODO: survey in-game

        stock =
        {
            -- Prices are unique integers — they double as the trade-window purchase code.
            { item = xi.item.BONE_CHIP,            name = "Bone Chip",               price =   50, weeklyServerStock = 60, requiredFates =  1 },
            { item = xi.item.CHUNK_OF_COPPER_ORE,  name = "Chunk of Copper Ore",     price =  100, weeklyServerStock = 40, requiredFates =  2 },
            { item = xi.item.BRONZE_ORE,           name = "Bronze Ore",              price =  150, weeklyServerStock = 40, requiredFates =  3 },
            { item = xi.item.GOBLIN_ARMOR,         name = "Goblin Armor",            price =  350, weeklyServerStock = 20, requiredFates =  5 },
            { item = xi.item.QUADAV_HELM,          name = "Quadav Helm",             price =  450, weeklyServerStock = 20, requiredFates =  5 },
            { item = xi.item.CLUMP_OF_SHEEP_WOOL,  name = "Clump of Sheep Wool",     price =  600, weeklyServerStock = 20, requiredFates =  8 },
            { item = xi.item.CHUNK_OF_IRON_ORE,    name = "Chunk of Iron Ore",       price =  800, weeklyServerStock = 15, requiredFates =  8 },
            { item = xi.item.CHUNK_OF_MYTHRIL_ORE, name = "Chunk of Mythril Ore",    price = 1500, weeklyServerStock =  8, requiredFates = 12 },
            { item = xi.item.RAM_HORN,             name = "Ram Horn",                price = 2500, weeklyServerStock =  5, requiredFates = 15 },
            { item = xi.item.WAILING_RAM_HORN,     name = "Wailing Ram Horn",        price = 5000, weeklyServerStock =  3, requiredFates = 20 },
        },
    },
}

-----------------------------------
-- Public API
-----------------------------------

-- Returns the player's validated weekly FATE completion count for a region.
-- Returns 0 if the stored stamp is from a previous week (stale data).
xi.fate.vendor.getPlayerWeekFates = function(player, region)
    local weekStart = getWeekStart()
    if player:getCharVar(playerWeekStampKey(region)) < weekStart then
        return 0
    end
    return player:getCharVar(playerWeekFatesKey(region))
end

-- Increment a player's weekly FATE count for a region.
-- Called from fate.lua assignBandsAndRewards when a victory band is earned.
xi.fate.vendor.onFateComplete = function(player, region)
    if not region then return end
    local weekStart = getWeekStart()
    if player:getCharVar(playerWeekStampKey(region)) < weekStart then
        player:setCharVar(playerWeekFatesKey(region),  1)
        player:setCharVar(playerWeekStampKey(region), weekStart)
    else
        player:incrementCharVar(playerWeekFatesKey(region), 1)
    end
end

-- Force a full stock reset for all regions.
-- Called by zone onConquestUpdate when updatetype == TALLY_END (weekly reset).
xi.fate.vendor.onWeeklyReset = function()
    -- Advance the stored week start to trigger a full reset on the next vendor access.
    -- Calling maybeResetWeek() here is sufficient — it resets all regions atomically.
    local weekStart = getWeekStart()
    SetServerVariable(weekStartKey(), weekStart - 1)  -- force stale so maybeResetWeek() fires
    maybeResetWeek()
end

-- Spawn vendor NPCs for every registered region whose vendorZone matches zoneID.
-- Call from the zone's onInitialize.
xi.fate.vendor.onZoneInitialize = function(zone, zoneID)
    for region, def in pairs(xi.fate.vendor.regions) do
        if def.vendorZone == zoneID then
            local pos    = def.vendorPos
            local entity = zone:insertDynamicEntity({
                objtype  = xi.objType.NPC,
                name     = def.name,
                look     = def.look,
                x        = pos[1], y = pos[2], z = pos[3],
                rotation = pos[4] or 0,
                widescan = 1,
                onTrigger = function(player, npc)
                    -- Derive region from zone ID stored in entity local var (no closure capture).
                    local zID   = npc:getLocalVar("fateVendorZoneID")
                    local zData = xi.fate.zones and xi.fate.zones[zID]
                    local r     = zData and zData.region
                    if r and xi.fate.vendor.regions[r] then
                        xi.fate.vendor.showCatalog(player, r)
                    end
                end,
                onTrade = function(player, npc, trade)
                    local zID   = npc:getLocalVar("fateVendorZoneID")
                    local zData = xi.fate.zones and xi.fate.zones[zID]
                    local r     = zData and zData.region
                    if r and xi.fate.vendor.regions[r] then
                        xi.fate.vendor.handleTrade(player, npc, trade, r)
                    end
                end,
            })
            if entity then
                entity:setLocalVar("fateVendorZoneID", zoneID)
            end
        end
    end
end

-----------------------------------
-- Internal: catalog display
-----------------------------------
xi.fate.vendor.showCatalog = function(player, region)
    maybeResetWeek()
    local def       = xi.fate.vendor.regions[region]
    local weekFates = xi.fate.vendor.getPlayerWeekFates(player, region)
    local streak    = xi.fate and GetServerVariable(string.format("[FATE][%d]Streak", player:getZoneID())) or 0

    player:printToPlayer(
        string.format("=== %s — Regional FATE Rewards ===", def.name),
        xi.msg.channel.SYSTEM_3)
    player:printToPlayer(
        string.format("Your completions this week: %d  |  Zone streak: %d",
            weekFates, streak),
        xi.msg.channel.SYSTEM_3)
    player:printToPlayer(
        "Trade the exact gil amount to purchase. Stock resets Sunday midnight (JST).",
        xi.msg.channel.SYSTEM_3)
    player:printToPlayer(
        "-----------------------------------------------------------",
        xi.msg.channel.SYSTEM_3)

    for idx, item in ipairs(def.stock) do
        local remaining = GetServerVariable(stockKey(region, idx))
        if weekFates >= item.requiredFates then
            if remaining > 0 then
                player:printToPlayer(
                    string.format("  %-28s  %5d gil  (%d in stock)",
                        item.name, item.price, remaining),
                    xi.msg.channel.SYSTEM_3)
            else
                player:printToPlayer(
                    string.format("  [SOLD OUT]  %-24s  (restocks Sunday)",
                        item.name),
                    xi.msg.channel.SYSTEM_3)
            end
        else
            local needed = item.requiredFates - weekFates
            player:printToPlayer(
                string.format("  [%2d more FATE(s)]  %-22s  %5d gil",
                    needed, item.name, item.price),
                xi.msg.channel.SYSTEM_3)
        end
    end
    player:printToPlayer(
        "-----------------------------------------------------------",
        xi.msg.channel.SYSTEM_3)
end

-----------------------------------
-- Internal: purchase via trade
-----------------------------------
xi.fate.vendor.handleTrade = function(player, npc, trade, region)
    maybeResetWeek()
    local def = xi.fate.vendor.regions[region]
    if not def then return end

    -- Only accept pure gil trades (no items in the window).
    local tradedGil = trade:getGil()
    if tradedGil == 0 or trade:getItemCount() > 0 then return end

    -- Match gil amount to a stock entry.
    local matched  = nil
    local matchIdx = nil
    for idx, item in ipairs(def.stock) do
        if item.price == tradedGil then
            matched  = item
            matchIdx = idx
            break
        end
    end

    if not matched then
        player:printToPlayer(
            string.format("[Liaison] %d gil doesn't match anything in our stock. Talk to me first to browse.", tradedGil),
            xi.msg.channel.SYSTEM_3)
        return
    end

    local weekFates = xi.fate.vendor.getPlayerWeekFates(player, region)
    if weekFates < matched.requiredFates then
        local needed = matched.requiredFates - weekFates
        player:printToPlayer(
            string.format("[Liaison] You need %d more completion(s) this week to unlock that item.", needed),
            xi.msg.channel.SYSTEM_3)
        return
    end

    local remaining = GetServerVariable(stockKey(region, matchIdx))
    if remaining <= 0 then
        player:printToPlayer(
            "[Liaison] My apologies — that item sold out for the week. Come back on Sunday.",
            xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getFreeSlotsCount() < 1 then
        player:printToPlayer(
            "[Liaison] Your inventory is full. Please make room and try again.",
            xi.msg.channel.SYSTEM_3)
        return
    end

    -- All checks passed — consume the gil and deliver the item.
    player:tradeComplete()
    npcUtil.giveItem(player, matched.item)
    SetServerVariable(stockKey(region, matchIdx), remaining - 1)

    player:printToPlayer(
        string.format("[Liaison] Excellent work out there. Here is your %s. %d remain in stock this week.",
            matched.name, remaining - 1),
        xi.msg.channel.SYSTEM_3)
end
