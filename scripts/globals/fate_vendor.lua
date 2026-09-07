-----------------------------------
-- FATE Regional Vendor System
--
-- Each FATE region has one Adventurers' Liaison NPC whose stock is gated
-- by how many FATEs a player has completed in that region this week.
-- Purchase limits are PER PLAYER, not shared -- each player has their own
-- weekly allowance of every item, independent of what anyone else has
-- bought. Allowances reset Sunday midnight JST (aligned with the conquest
-- update), the same clock used for the weekly completion tally.
--
-- Purchase flow: talk to the NPC to open a browsable menu (player:custom
-- Menu). Locked/claimed items are listed above the menu as plain text --
-- only what you can currently buy appears as a selectable option.
-- Selecting one buys exactly one instantly for gil, no trade window.
--
-- Why not a native buy/sell shop window (player:createShop)? That
-- purchase packet resolves entirely in the engine with no callback into
-- Lua, so there's no reliable way to detect a sale and decrement a
-- personal counter -- and diffing inventory counts between visits doesn't
-- work here, since these materials are also obtainable from normal mob
-- drops and other FATE loot rolls, which would falsely burn a player's
-- vendor allowance. player:customMenu (see modules/custom/LQS/lib/LQS.lua
-- for the established pattern -- LQS.shop/LQS.simpleShop) routes every
-- selection through a Lua callback, so the check-then-grant stays atomic
-- and exact, same as the trade window would give us, just without
-- requiring the player to type a gil amount into a trade.
-----------------------------------
require('scripts/globals/npc_util')

xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.vendor = xi.fate.vendor or {}

-----------------------------------
-- Char variable keys (all per-player -- there is no shared/server state)
-----------------------------------
local function playerWeekFatesKey(region)   return string.format("[FATE_VENDOR][%s]WeekFates",        region)      end
local function playerWeekStampKey(region)   return string.format("[FATE_VENDOR][%s]WeekStamp",        region)      end
local function playerBoughtKey(region, idx) return string.format("[FATE_VENDOR][%s][%d]Bought",       region, idx) end
local function boughtStampKey(region, idx)  return string.format("[FATE_VENDOR][%s][%d]BoughtStamp",  region, idx) end

-----------------------------------
-- Week boundary helper
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

-- Returns how many of a given stock item this player has bought this week.
-- Lazily treated as 0 once the stored stamp falls behind the current week --
-- same pattern as xi.fate.vendor.getPlayerWeekFates below.
local function getPlayerBought(player, region, idx)
    local weekStart = getWeekStart()
    if player:getCharVar(boughtStampKey(region, idx)) < weekStart then
        return 0
    end
    return player:getCharVar(playerBoughtKey(region, idx))
end

-- Records one purchase of a stock item against this player's personal
-- weekly allowance.
local function recordPlayerBought(player, region, idx)
    local weekStart = getWeekStart()
    if player:getCharVar(boughtStampKey(region, idx)) < weekStart then
        player:setCharVar(playerBoughtKey(region, idx), 1)
        player:setCharVar(boughtStampKey(region, idx), weekStart)
    else
        player:incrementCharVar(playerBoughtKey(region, idx), 1)
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
--   item              number   xi.item constant
--   name              string   Display name shown in the catalog/menu
--   price             number   Gil cost, deducted directly via player:delGil()
--   weeklyPlayerLimit number   Max this ONE player may buy per week (not shared with anyone else)
--   requiredFates     number   Minimum weekly completions in the region to unlock
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
            -- Prices are gil costs only now (no longer double as a trade-window code).
            { item = xi.item.BONE_CHIP,            name = "Bone Chip",               price =   50, weeklyPlayerLimit = 6, requiredFates =  1 },
            { item = xi.item.CHUNK_OF_COPPER_ORE,  name = "Chunk of Copper Ore",     price =  100, weeklyPlayerLimit = 5, requiredFates =  2 },
            { item = xi.item.BRONZE_ORE,           name = "Bronze Ore",              price =  150, weeklyPlayerLimit = 5, requiredFates =  3 },
            { item = xi.item.GOBLIN_ARMOR,         name = "Goblin Armor",            price =  350, weeklyPlayerLimit = 3, requiredFates =  5 },
            { item = xi.item.QUADAV_HELM,          name = "Quadav Helm",             price =  450, weeklyPlayerLimit = 3, requiredFates =  5 },
            { item = xi.item.CLUMP_OF_SHEEP_WOOL,  name = "Clump of Sheep Wool",     price =  600, weeklyPlayerLimit = 3, requiredFates =  8 },
            { item = xi.item.CHUNK_OF_IRON_ORE,    name = "Chunk of Iron Ore",       price =  800, weeklyPlayerLimit = 2, requiredFates =  8 },
            { item = xi.item.CHUNK_OF_MYTHRIL_ORE, name = "Chunk of Mythril Ore",    price = 1500, weeklyPlayerLimit = 2, requiredFates = 12 },
            { item = xi.item.RAM_HORN,             name = "Ram Horn",                price = 2500, weeklyPlayerLimit = 1, requiredFates = 15 },
            { item = xi.item.WAILING_RAM_HORN,     name = "Wailing Ram Horn",        price = 5000, weeklyPlayerLimit = 1, requiredFates = 20 },
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
                        xi.fate.vendor.openMenu(player, r, 0)
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
-- Internal: purchase (invoked from a customMenu option callback)
-----------------------------------
local function purchaseItem(player, region, idx)
    local def  = xi.fate.vendor.regions[region]
    local item = def and def.stock[idx]
    if not item then return end

    local weekFates = xi.fate.vendor.getPlayerWeekFates(player, region)
    if weekFates < item.requiredFates then
        player:printToPlayer(
            string.format("[Liaison] You need %d more completion(s) this week to unlock that item.", item.requiredFates - weekFates),
            xi.msg.channel.SYSTEM_3)
        return
    end

    local bought    = getPlayerBought(player, region, idx)
    local remaining = item.weeklyPlayerLimit - bought
    if remaining <= 0 then
        player:printToPlayer(
            "[Liaison] You have already claimed your allowance of that for the week. Come back Sunday.",
            xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getFreeSlotsCount() < 1 then
        player:printToPlayer(
            "[Liaison] Your inventory is full. Please make room and try again.",
            xi.msg.channel.SYSTEM_3)
        return
    end

    if not player:delGil(item.price) then
        player:printToPlayer(
            string.format("[Liaison] You need %d gil for that.", item.price),
            xi.msg.channel.SYSTEM_3)
        return
    end

    npcUtil.giveItem(player, item.item)
    recordPlayerBought(player, region, idx)

    player:printToPlayer(
        string.format("[Liaison] Excellent work out there. Here is your %s. %d left in your allowance this week.",
            item.name, remaining - 1),
        xi.msg.channel.SYSTEM_3)
end

-----------------------------------
-- Internal: browsable menu (player:customMenu)
-----------------------------------
local PAGE_SIZE = 4

-- HandleCustomMenu (luautils.cpp) erases the player's menu context right
-- after running the selected option's callback. Opening another menu
-- synchronously inside that callback would get wiped by that same erase,
-- so every reopen has to be deferred past it -- same pattern as
-- LQS.lib's delaySendMenu.
local function reopenMenu(player, region, page)
    player:timer(300, function(playerArg)
        xi.fate.vendor.openMenu(playerArg, region, page)
    end)
end

-- Prints the header plus every locked / claimed-out item as plain text,
-- then opens a customMenu containing only what's currently purchasable.
xi.fate.vendor.openMenu = function(player, region, page)
    page = page or 0
    local def = xi.fate.vendor.regions[region]
    if not def then return end

    local weekFates = xi.fate.vendor.getPlayerWeekFates(player, region)
    local streak     = GetServerVariable(string.format("[FATE][%d]Streak", player:getZoneID()))

    player:printToPlayer(
        string.format("=== %s -- Regional FATE Rewards ===", def.name),
        xi.msg.channel.SYSTEM_3)
    player:printToPlayer(
        string.format("Your completions this week: %d  |  Zone streak: %d",
            weekFates, streak),
        xi.msg.channel.SYSTEM_3)
    player:printToPlayer(
        "Select an item below to buy it instantly with gil. Allowance resets Sunday midnight (JST).",
        xi.msg.channel.SYSTEM_3)
    player:printToPlayer(
        "-----------------------------------------------------------",
        xi.msg.channel.SYSTEM_3)

    -- Locked/claimed items are informational only -- not part of the
    -- clickable menu, since customMenu options are all selectable.
    local purchasable = {}
    for idx, item in ipairs(def.stock) do
        if weekFates < item.requiredFates then
            player:printToPlayer(
                string.format("  [%2d more FATE(s)]  %-22s  %5d gil",
                    item.requiredFates - weekFates, item.name, item.price),
                xi.msg.channel.SYSTEM_3)
        else
            local bought    = getPlayerBought(player, region, idx)
            local remaining = item.weeklyPlayerLimit - bought
            if remaining <= 0 then
                player:printToPlayer(
                    string.format("  [CLAIMED]  %-24s  (resets Sunday)", item.name),
                    xi.msg.channel.SYSTEM_3)
            else
                table.insert(purchasable, { idx = idx, item = item, remaining = remaining })
            end
        end
    end
    player:printToPlayer(
        "-----------------------------------------------------------",
        xi.msg.channel.SYSTEM_3)

    if #purchasable == 0 then
        player:printToPlayer("[Liaison] Nothing available to purchase right now.", xi.msg.channel.SYSTEM_3)
        return
    end

    local totalPages = math.ceil(#purchasable / PAGE_SIZE)
    page = math.min(page, totalPages - 1)

    local options = {}

    if page > 0 then
        table.insert(options, {
            "<< Previous Page",
            function(p) reopenMenu(p, region, page - 1) end,
        })
    end

    for i = 1, PAGE_SIZE do
        local entry = purchasable[page * PAGE_SIZE + i]
        if entry then
            local label = string.format("%s -- %d gil (%d/%d left)",
                entry.item.name, entry.item.price, entry.remaining, entry.item.weeklyPlayerLimit)
            table.insert(options, {
                label,
                function(p)
                    purchaseItem(p, region, entry.idx)
                    reopenMenu(p, region, page)
                end,
            })
        end
    end

    if (page + 1) * PAGE_SIZE < #purchasable then
        table.insert(options, {
            "Next Page >>",
            function(p) reopenMenu(p, region, page + 1) end,
        })
    end

    table.insert(options, { "(Close)", function(p) end })

    player:customMenu({
        title   = def.name,
        options = options,
    })
end
