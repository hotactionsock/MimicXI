-----------------------------------
-- Area: Xarcabard (112)
--  NPC: Rift Purveyor
-- Spawned dynamically in Zone.lua onInitialize — no npc_list row required.
--
-- Deposit: player trades shard items directly to the NPC.
--          The NPC takes the physical items and credits the player's stored balance.
-- Trade-down: cycle menu to convert one higher shard tier into lower ones.
-- Shop: browse items priced in stored shards (items populated in rift.lua).
-----------------------------------

require('globals/rift')

---@type TNpcEntity
local entity = {}

-- Deposit: player hands shard items to the Purveyor.
-- The NPC removes the physical items and adds them to the player's charvar balance.
entity.onTrade = function(player, npc, trade)
    local totalItems = trade:getItemCount()
    if totalItems == 0 then return end

    local deposited = false

    -- Check each shard type in the trade.
    for itemId, _ in pairs(xi.rift.PURVEYOR_VAR) do
        local qty = trade:getItemQty(itemId)
        if qty > 0 then
            trade:removeItem(itemId, qty)
            xi.rift.addPurveyorShards(player, itemId, qty)
            local newTotal = xi.rift.getPurveyorBalance(player, itemId)
            local shardName = xi.rift.SHARD_NAME[itemId]
            -- Vary the acknowledgement text slightly based on quantity.
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

-- Menu: show stored balances and offer trade-down or shop options.
entity.onTrigger = function(player, npc)
    local nascent  = xi.rift.getPurveyorBalance(player, xi.rift.NASCENT_SHARD)
    local tempered = xi.rift.getPurveyorBalance(player, xi.rift.TEMPERED_SHARD)
    local forged   = xi.rift.getPurveyorBalance(player, xi.rift.FORGED_SHARD)
    local resolute = xi.rift.getPurveyorBalance(player, xi.rift.RESOLUTE_SHARD)

    -- Build a balance summary as a text message then open the trade-down menu.
    -- A proper CS/menu will replace this once event IDs are assigned.
    player:messageText(npc, string.format(
        "Your stores: Nascent x%d | Tempered x%d | Forged x%d | Resolute x%d. "
        .. "Trade me shards to deposit them, or speak to me again to break them down.",
        nascent, tempered, forged, resolute))
end

-- Trade-down handler — keyed off charvar RIFT_PURVEYOR_TRADEDOWN set by a menu.
-- For now exposed as a direct command via RIFT_TRADEDOWN_FROM / RIFT_TRADEDOWN_QTY
-- charvars so a GM can test without a CS: set the vars then trigger the NPC.
--
-- Full CS flow to be wired in once menu event IDs are confirmed.
local function doTradeDown(player, fromItemId, qty)
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

-- Shop purchase handler.
local function doPurchase(player, shopIndex, qty)
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

-- Expose helpers so rift.lua and future menus/CS can call them.
entity.doTradeDown = doTradeDown
entity.doPurchase  = doPurchase

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
