-----------------------------------
-- func: !fateaddon register
-- desc: Called automatically by the FATETracker Ashita4 addon on load and
--       on every zone change. Silently marks the player as an addon user so
--       the server can send targeted FSYNC/FDEF messages instead of
--       zone-broadcasting them to all players.
--       permission=0 so any player can invoke it.
-----------------------------------
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

commandObj.onTrigger = function(player, subcmd)
    if subcmd == 'register' then
        if xi.fate and xi.fate.registerAddonUser then
            xi.fate.registerAddonUser(player)
        end
    end
end

return commandObj
