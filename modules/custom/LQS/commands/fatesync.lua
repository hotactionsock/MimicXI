-----------------------------------
-- func: !fatesync
-- desc: Sends current FATE state for the player's zone to their client.
--       Called by the FATETracker Ashita4 addon via /fatesync.
--       permission=0 so any player can invoke it.
-----------------------------------
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = '',
}

commandObj.onTrigger = function(player)
    if not xi.fate or not xi.fate.sendAddonSync then
        return
    end
    xi.fate.sendAddonSync(player, player:getZoneID())
end

return commandObj
