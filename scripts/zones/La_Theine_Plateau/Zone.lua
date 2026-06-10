-----------------------------------
-- Zone: La_Theine_Plateau (102)
-----------------------------------
local ID = zones[xi.zone.LA_THEINE_PLATEAU]
local laTheineGlobal = require('scripts/zones/La_Theine_Plateau/globals')
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    laTheineGlobal.moveFallenEgg()
    xi.chocobo.initZone(zone)
    xi.voidwalker.zoneOnInit(zone)
    xi.fate.onZoneInitialize(zone, zone:getID())

    local rainbow = GetNPCByID(ID.npc.RAINBOW)

    if rainbow then
        rainbow:setNpcAlwaysRelevant(true)
    end
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-559, 0, 680, 73)
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

zoneObject.onZoneWeatherChange = function(weather)
    local rainbow = GetNPCByID(ID.npc.RAINBOW)
    if not rainbow then
        return
    end

    local timeOfTheDay = VanadielTOTD()
    local setRainbow   = rainbow:getLocalVar('setRainbow')
    if
        setRainbow == 1 and
        weather ~= xi.weather.RAIN and
        timeOfTheDay >= xi.time.DAWN and
        timeOfTheDay <= xi.time.EVENING and
        rainbow:getAnimation() == xi.anim.CLOSE_DOOR
    then
        rainbow:setAnimation(xi.anim.OPEN_DOOR)
    elseif
        setRainbow == 1 and
        weather == xi.weather.RAIN and
        rainbow:getAnimation() == xi.anim.OPEN_DOOR
    then
        rainbow:setAnimation(xi.anim.CLOSE_DOOR)
        rainbow:setLocalVar('setRainbow', 0)
    end
end

zoneObject.onTOTDChange = function(timeOfTheDay)
    local rainbow = GetNPCByID(ID.npc.RAINBOW)
    if not rainbow then
        return
    end

    local setRainbow = rainbow:getLocalVar('setRainbow')

    if
        setRainbow == 1 and
        timeOfTheDay >= xi.time.DAWN and
        timeOfTheDay <= xi.time.EVENING and
        rainbow:getAnimation() == xi.anim.CLOSE_DOOR
    then
        rainbow:setAnimation(xi.anim.OPEN_DOOR)
    elseif
        setRainbow == 1 and
        timeOfTheDay < xi.time.DAWN or
        timeOfTheDay > xi.time.EVENING and
        rainbow:getAnimation() == xi.anim.OPEN_DOOR
    then
        rainbow:setAnimation(xi.anim.CLOSE_DOOR)
        rainbow:setLocalVar('setRainbow', 0)
    end
end

return zoneObject
