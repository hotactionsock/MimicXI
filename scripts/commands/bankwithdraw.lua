-----------------------------------
-- func: bankwithdraw <itemId> <quantity>
-- desc: Withdraws quantity of itemId from the player's account-wide bank into
--       their inventory. See CLAUDE.md, "Account Bank System".
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 'ii'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!bankwithdraw <itemId> <quantity>')
end

commandObj.onTrigger = function(player, itemId, quantity)
    if itemId == nil or itemId < 1 then
        error(player, 'Invalid itemId.')
        return
    end

    quantity = quantity or 1
    if quantity < 1 then
        error(player, 'Invalid quantity.')
        return
    end

    if player:withdrawFromBank(itemId, quantity) then
        player:printToPlayer(string.format('Withdrew %d of item %d from your bank.', quantity, itemId))
    else
        player:printToPlayer(string.format('Could not withdraw %d of item %d. Check your bank has that many, and that you have room for it.', quantity, itemId))
    end
end

return commandObj
