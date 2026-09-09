-----------------------------------
-- Zone: East_Ronfaure (101)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.helm.initZone(zone, xi.helmType.LOGGING)
    xi.fate.onZoneInitialize(zone, zone:getID())
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(86.131, -65.817, 273.861, 25)
    end

    return cs
end

zoneObject.afterZoneIn = function(player)
    xi.fate.checkSyncOnZoneIn(player)
    xi.fate.sendAddonDef(player, player:getZoneID())
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onZoneTick = function(zone)
    xi.fate.tick(zone, zone:getID())
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
    xi.fate.onAreaEnter(player, triggerArea, player:getZoneID())
end

zoneObject.onTriggerAreaLeave = function(player, triggerArea)
    xi.fate.onAreaLeave(player, triggerArea, player:getZoneID())
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

zoneObject.onZoneOut = function(player)
    xi.helm.onZoneOut(player)
end

return zoneObject
