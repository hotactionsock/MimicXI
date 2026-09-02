-----------------------------------
-- func: bankdepositall
-- desc: Deposits every eligible item from the player's inventory into their
--       account-wide bank in one go. See CLAUDE.md, "Account Bank System".
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = ''
}

commandObj.onTrigger = function(player)
    local deposited = player:depositAllToBank()

    if #deposited == 0 then
        player:printToPlayer('Nothing to deposit.')
        return
    end

    player:printToPlayer(string.format('Deposited %d item type(s) into your bank:', #deposited))
    for _, entry in ipairs(deposited) do
        player:printToPlayer(string.format(' - %d x item %d', entry.quantity, entry.id))
    end
end

return commandObj
