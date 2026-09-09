-----------------------------------
-- Zone: North_Gustaberg (106)
-----------------------------------
local ID = zones[xi.zone.NORTH_GUSTABERG]
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.conquest.setRegionalConquestOverseers(zone:getRegionID())
    xi.voidwalker.zoneOnInit(zone)
    xi.fate.onZoneInitialize(zone, zone:getID())

    local sirensTear = GetNPCByID(ID.npc.SIRENS_TEAR_QM)

    -- randomize Siren's Tear position
    if sirensTear then
        sirensTear:setPos(unpack(ID.positions.sirensTear[math.randomInt(1, #ID.positions.sirensTear)]))
    end
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(660, 0, 306, 190)
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

return zoneObject
