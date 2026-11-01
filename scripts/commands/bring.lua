-----------------------------------
-- func: bring <player>
-- desc: Brings the target to the player.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'si'
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!bring <player> (forceZone)')
end

commandObj.onTrigger = function(player, target, forceZone)
    -- validate target
    if target == nil then
        error(player, 'You must enter a target player name.')
        return
    end

    -- World bots (see xi.worldbots) have no client, so the normal cross-zone
    -- setPos flow below - which relies on the client completing a zone
    -- transition - never finishes for them; it can even leave them stuck
    -- mid-transition (findable by neither GetPlayerByName nor a normal
    -- !bring). Resolve by name via the DB (works even for a bot stuck in that
    -- limbo state) and route bots through the safe teleport path instead.
    local botCharId = GetPlayerIDByName(target)
    if botCharId and botCharId > 0 and xi.worldbots.isBot(botCharId) then
        xi.worldbots.teleportBot(botCharId, player:getXPos(), player:getYPos(), player:getZPos(), player:getRotPos(), player:getZoneID())
        player:printToPlayer(string.format('Brought bot "%s" (charid %d).', target, botCharId))
        return
    end

    local targ = GetPlayerByName(target)
    if targ == nil then
        if not player:bringPlayer(target) then
            error(player, string.format('Player named "%s" not found!', target))
        end

        return
    end

    -- validate forceZone
    if forceZone ~= nil then
        if forceZone ~= 0 and forceZone ~= 1 then
            error(player, 'If provided, forceZone must be 1 (true) or 0 (false).')
            return
        end
    else
        forceZone = 1
    end

    -- bring target
    if targ:getZoneID() ~= player:getZoneID() or forceZone == 1 then
        targ:setPos(player:getXPos(), player:getYPos(), player:getZPos(), player:getRotPos(), player:getZoneID())
    else
        targ:setPos(player:getXPos(), player:getYPos(), player:getZPos(), player:getRotPos())
    end
end

return commandObj
