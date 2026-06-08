-----------------------------------
-- func: !fatedef
-- desc: Sends FDEFZ + FDEF entries for every FATE in the player's current zone.
--       Called by the FATETracker addon via /ft discover.
--       permission=0 so any player can invoke it.
-----------------------------------
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = '',
}

commandObj.onTrigger = function(player)
    if not xi.fate or not xi.fate.sendAddonDef then return end
    xi.fate.sendAddonDef(player, player:getZoneID())
end

return commandObj
