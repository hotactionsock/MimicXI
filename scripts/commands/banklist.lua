-----------------------------------
-- func: banklist
-- desc: Prints the player's account-wide bank contents to chat, and pushes the
--       same data to the client via GP_SERV_COMMAND_BANK_LIST for the companion
--       Ashita addon (tools/ashita-addons/mimicxi_bank) to render. See CLAUDE.md,
--       "Account Bank System".
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = ''
}

commandObj.onTrigger = function(player)
    local items = player:getBankItems()

    if #items == 0 then
        player:printToPlayer('Your bank is empty.')
    else
        player:printToPlayer('Your bank contains:')
        for _, entry in ipairs(items) do
            player:printToPlayer(string.format(' - %d x item %d', entry.quantity, entry.id))
        end
    end

    -- Refresh the Ashita addon's view even if it wasn't already showing anything.
    player:sendBankList()
end

return commandObj
