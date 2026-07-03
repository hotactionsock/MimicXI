-----------------------------------
-- Nephalem Rift — LQS Module
-- Toggle: add RIFT = { ENABLED = false } to map settings to disable.
-----------------------------------
local m = Module:new("lqs_rift")

if xi.settings and xi.settings.main and xi.settings.main.RIFT and xi.settings.main.RIFT.ENABLED == false then
    return m
end

require('scripts/globals/rift')

-----------------------------------
-- NPC definitions
-----------------------------------

-- Surveyor: cycles available tiers and sends the player into the Rift.
local function surveyorTrigger(player, npc)
    xi.rift.onSurveyorTrigger(player, npc)
end

-- Purveyor: accepts shard deposits, trade-downs, and shop purchases.
local function purveyorTrade(player, npc, trade)
    local deposited = false

    for itemId, _ in pairs(xi.rift.PURVEYOR_VAR) do
        local qty = trade:getItemQty(itemId)
        if qty > 0 then
            trade:removeItem(itemId, qty)
            xi.rift.addPurveyorShards(player, itemId, qty)
            local newTotal  = xi.rift.getPurveyorBalance(player, itemId)
            local shardName = xi.rift.SHARD_NAME[itemId]
            if qty == 1 then
                player:messageText(npc, string.format(
                    "So, that's 1 %s. You've got %d in total now.",
                    shardName, newTotal))
            else
                player:messageText(npc, string.format(
                    "So, that's %d %ss, very nice. You've got %d in total now.",
                    qty, shardName, newTotal))
            end
            deposited = true
        end
    end

    if not deposited then
        player:messageText(npc, "Hmm, I'm afraid I can't do anything with that.")
    end
end

local function purveyorTrigger(player, npc)
    local nascent  = xi.rift.getPurveyorBalance(player, xi.rift.NASCENT_SHARD)
    local tempered = xi.rift.getPurveyorBalance(player, xi.rift.TEMPERED_SHARD)
    local forged   = xi.rift.getPurveyorBalance(player, xi.rift.FORGED_SHARD)
    local resolute = xi.rift.getPurveyorBalance(player, xi.rift.RESOLUTE_SHARD)

    player:messageText(npc, string.format(
        "Your stores: Nascent x%d | Tempered x%d | Forged x%d | Resolute x%d. "
        .. "Trade me shards to deposit them.",
        nascent, tempered, forged, resolute))
end

-- Perform a trade-down: spend qty of fromItemId, receive ratio × qty of the next tier down.
-- Returns true on success, false if the player can't afford it.
local function doTradeDown(player, npc, fromItemId, qty)
    qty = qty or 1
    local balance = xi.rift.getPurveyorBalance(player, fromItemId)

    if balance < qty then
        player:messageText(npc, string.format(
            "You don't have enough %ss for that.",
            xi.rift.SHARD_NAME[fromItemId] or 'shards'))
        return false
    end

    for _, entry in ipairs(xi.rift.TRADE_DOWN) do
        if entry.from == fromItemId then
            xi.rift.addPurveyorShards(player, fromItemId, -qty)
            local gained = qty * entry.ratio
            xi.rift.addPurveyorShards(player, entry.to, gained)
            local newFrom = xi.rift.getPurveyorBalance(player, fromItemId)
            local newTo   = xi.rift.getPurveyorBalance(player, entry.to)
            player:messageText(npc, string.format(
                "Converted %d %s into %d %s. You now have %d and %d respectively.",
                qty, xi.rift.SHARD_NAME[fromItemId],
                gained, xi.rift.SHARD_NAME[entry.to],
                newFrom, newTo))
            return true
        end
    end

    return false
end

-- Purchase an item from the Purveyor shop catalogue.
-- shopIndex matches an entry in xi.rift.PURVEYOR_SHOP.
local function doPurchase(player, npc, shopIndex, qty)
    qty = qty or 1
    local item = xi.rift.PURVEYOR_SHOP[shopIndex]

    if not item then
        player:messageText(npc, "That item isn't available right now.")
        return false
    end

    local totalCost = item.cost * qty
    local balance   = xi.rift.getPurveyorBalance(player, item.currency)

    if balance < totalCost then
        local currencyName = xi.rift.SHARD_NAME[item.currency] or 'shards'
        player:messageText(npc, string.format(
            "You need %d %s for %s. You only have %d.",
            totalCost, currencyName, item.name, balance))
        return false
    end

    xi.rift.addPurveyorShards(player, item.currency, -totalCost)
    player:addItem(item.item, qty)
    local remaining = xi.rift.getPurveyorBalance(player, item.currency)
    player:messageText(npc, string.format(
        "There you are — %s. You have %d %s remaining.",
        item.name, remaining, xi.rift.SHARD_NAME[item.currency] or 'shards'))
    return true
end

-- Expose trade-down and purchase helpers on xi.rift so other scripts can call them.
xi.rift.doTradeDown = doTradeDown
xi.rift.doPurchase  = doPurchase

-----------------------------------
-- Register NPC entities via LQS
-----------------------------------

LQS.npc(m, {
    Xarcabard =
    {
        -- Rift Surveyor — tier selection and entry
        -- Replace pos with /pos output before going live.
        {
            name       = "Rift_Surveyor",
            packetName = "Rift Surveyor",
            look       = 0x0000B009, -- placeholder model
            pos        = { -285.0, -100.0, 196.0, 0 },
            namevis    = 1,
            onTrigger  = surveyorTrigger,
        },

        -- Rift Purveyor — shard storage, trade-down, and shop
        -- Positioned next to the Surveyor (4 units east). Replace before going live.
        {
            name       = "Rift_Purveyor",
            packetName = "Rift Purveyor",
            look       = 0x0000B009, -- placeholder model
            pos        = { -281.0, -100.0, 196.0, 0 },
            namevis    = 1,
            onTrigger  = purveyorTrigger,
            onTrade    = purveyorTrade,
        },
    },
})

-----------------------------------
-- Walk of Echoes — detect pending tier on zone-in and enter layer.
-----------------------------------

m:addOverride("xi.zones.Walk_of_Echoes.Zone.onZoneIn", function(player, prevZone)
    local cs = super(player, prevZone)
    xi.rift.onZoneIn(player)
    return cs
end)

return m
