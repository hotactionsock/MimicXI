-----------------------------------
-- func: bankdeposit <itemId> <quantity>
-- desc: Deposits quantity of itemId from the player's inventory into their
--       account-wide bank. See CLAUDE.md, "Account Bank System".
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
    player:printToPlayer('!bankdeposit <itemId> <quantity>')
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

    if player:depositToBank(itemId, quantity) then
        player:printToPlayer(string.format('Deposited %d of item %d into your bank.', quantity, itemId))
    else
        player:printToPlayer(string.format('Could not deposit %d of item %d. Check you have that many (unequipped, not up for bazaar sale), and that the item can be banked.', quantity, itemId))
    end
end

return commandObj
