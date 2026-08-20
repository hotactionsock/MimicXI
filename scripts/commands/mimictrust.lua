-----------------------------------
-- func: !mimictrust (charactername)
-- desc: Summons one of your own offline alt characters (same account) as a
--       trust-like ally, mirroring that character's real look, stats, and
--       equipped gear.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's'
}

commandObj.onTrigger = function(player, name)
    if type(name) ~= 'string' or name == '' then
        player:printToPlayer('!mimictrust <character name>')
        return
    end

    local ok = xi.trust.checkSlotCapacity(player)
    if not ok then
        return
    end

    local trust = player:spawnMimicTrust(name)
    if trust == nil then
        player:printToPlayer(string.format('Unable to summon "%s" as a mimic trust.', name))
    end
end

return commandObj
