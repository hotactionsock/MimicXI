-----------------------------------
-- Zone: Buburimu_Peninsula (118)
-----------------------------------
require('scripts/missions/amk/helpers')
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.conquest.setRegionalConquestOverseers(zone:getRegionID())

    xi.helm.initZone(zone, xi.helmType.LOGGING)
    xi.fate.onZoneInitialize(zone, zone:getID())

    xi.expeditionaryForce.initZone(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-276.529, 16.403, -324.519, 14)
    end

    -- AMK06/AMK07
    if xi.settings.main.ENABLE_AMK == 1 then
        xi.amk.helpers.tryRandomlyPlaceDiggingLocation(player)
    end

    return cs
end

zoneObject.afterZoneIn = function(player)
    xi.chocoboGame.handleMessage(player)
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
