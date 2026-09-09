-----------------------------------
-- Zone: Uleguerand_Range (5)
-----------------------------------
local ID = zones[xi.zone.ULEGUERAND_RANGE]
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    -- Set to move every 5 vana minutes as observed on retail
    GetNPCByID(ID.npc.RABBIT_FOOTPRINT):addPeriodicTrigger(0, 5, 0)
    xi.fate.onZoneInitialize(zone, zone:getID())
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.afterZoneIn = function(player)
    xi.fate.checkSyncOnZoneIn(player)
    xi.fate.sendAddonDef(player, player:getZoneID())
end

zoneObject.onZoneTick = function(zone)
    xi.fate.tick(zone, zone:getID())
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(363.025, 16, -60, 12)
    end

    return cs
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

zoneObject.onZoneWeatherChange = function(weather)
    local waterfall = GetNPCByID(ID.npc.WATERFALL)

    if waterfall then
        if weather == xi.weather.SNOW or weather == xi.weather.BLIZZARDS then
            if waterfall:getAnimation() ~= xi.animation.CLOSE_DOOR then
                waterfall:setAnimation(xi.animation.CLOSE_DOOR)
            end
        else
            if waterfall:getAnimation() ~= xi.animation.OPEN_DOOR then
                waterfall:setAnimation(xi.animation.OPEN_DOOR)
            end
        end
    end
end

return zoneObject
