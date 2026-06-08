-----------------------------------
-- FATE System Module
-- Toggle: add FATE = { ENABLED = false } to map settings to disable.
-- Zone definitions: uncomment requires below as zones are implemented.
-----------------------------------
local m = Module:new("lqs_fate_system")

if xi.settings and xi.settings.main and xi.settings.main.FATE and xi.settings.main.FATE.ENABLED == false then
    return m
end

-- Regional loot pool definitions (must load before zone files):
require('scripts/globals/fate_zones/regions')

-- Starter zones (Lv 1-15):
require('scripts/globals/fate_zones/South_Gustaberg')
require('scripts/globals/fate_zones/North_Gustaberg')
require('scripts/globals/fate_zones/West_Ronfaure')
require('scripts/globals/fate_zones/East_Ronfaure')
require('scripts/globals/fate_zones/West_Sarutabaruta')
require('scripts/globals/fate_zones/East_Sarutabaruta')


-- Zulkheim (Lv 18-30):
require('scripts/globals/fate_zones/Tahrongi_Canyon')
require('scripts/globals/fate_zones/La_Theine_Plateau')
require('scripts/globals/fate_zones/Valkurm_Dunes')
require('scripts/globals/fate_zones/Konschtat_Highlands')

-- Derfland + Aragoneu (Lv 15-40):
require('scripts/globals/fate_zones/Pashhow_Marshlands')
require('scripts/globals/fate_zones/Rolanberry_Fields')
require('scripts/globals/fate_zones/Buburimu_Peninsula')
require('scripts/globals/fate_zones/Meriphataud_Mountains')

-- Norvallen + Qufim (Lv 25-48):
require('scripts/globals/fate_zones/Jugner_Forest')
require('scripts/globals/fate_zones/Batallia_Downs')
require('scripts/globals/fate_zones/Qufim_Island')
require('scripts/globals/fate_zones/Sauromugue_Champaign')

-- Northlands (Lv 40-65):
require('scripts/globals/fate_zones/Beaucedine_Glacier')
require('scripts/globals/fate_zones/Xarcabard')

-- Kolshushu + Elshimo (Lv 40-70):
require('scripts/globals/fate_zones/Cape_Teriggan')
require('scripts/globals/fate_zones/Bibiki_Bay')
require('scripts/globals/fate_zones/Yuhtunga_Jungle')
require('scripts/globals/fate_zones/Yhoator_Jungle')

-- Li'Telor (Lv 55-75):
require('scripts/globals/fate_zones/The_Sanctuary_of_Zitah')
require('scripts/globals/fate_zones/Romaeve')

-- Sky / Sea / High-end (Lv 65-75):
require('scripts/globals/fate_zones/Ruaun_Gardens')
require('scripts/globals/fate_zones/Altaieu')
require('scripts/globals/fate_zones/Uleguerand_Range')
require('scripts/globals/fate_zones/Attohwa_Chasm')

-- Lufaise / Misareaux (Lv 35-58):
require('scripts/globals/fate_zones/Lufaise_Meadows')
require('scripts/globals/fate_zones/Misareaux_Coast')

-- Treasures of Aht Urhgan (Lv 55-75):
require('scripts/globals/fate_zones/Bhaflau_Thickets')
require('scripts/globals/fate_zones/Mount_Zhayolm')
require('scripts/globals/fate_zones/Caedarva_Mire')

if not xi.fate or not xi.fate.zones then return m end

-----------------------------------
-- Register zone callbacks for each FATE-enabled zone.
-- zoneID and zoneName come from the zone definition tables populated above.
-- Each override stacks onto the existing zone callback via super().
-----------------------------------
for zoneID, zoneData in pairs(xi.fate.zones) do
    local zoneName = zoneData.zoneName

    m:addOverride(string.format("xi.zones.%s.Zone.onInitialize", zoneName), function(zone)
        super(zone)
        xi.fate.onZoneInitialize(zone, zoneID)
    end)

    m:addOverride(string.format("xi.zones.%s.Zone.onZoneTick", zoneName), function(zone)
        super(zone)
        xi.fate.tick(zone, zoneID)
    end)

    m:addOverride(string.format("xi.zones.%s.Zone.afterZoneIn", zoneName), function(player)
        super(player)
        xi.fate.checkSyncOnZoneIn(player)
        -- Only send FSYNC if the addon is already registered (prevents raw text for non-addon users).
        -- !fateaddon register re-sends the sync immediately after zone-in for addon users.
        if xi.fate.addonUsers[player:getID()] then
            xi.fate.sendAddonSync(player, zoneID)
        end
    end)

    m:addOverride(string.format("xi.zones.%s.Zone.onZoneOut", zoneName), function(player)
        super(player)
        xi.fate.unregisterAddonUser(player:getID())
    end)

    m:addOverride(string.format("xi.zones.%s.Zone.onTriggerAreaEnter", zoneName), function(player, triggerArea, optInstance)
        super(player, triggerArea, optInstance)
        xi.fate.onAreaEnter(player, triggerArea, zoneID)
    end)

    m:addOverride(string.format("xi.zones.%s.Zone.onTriggerAreaLeave", zoneName), function(player, triggerArea, optInstance)
        super(player, triggerArea, optInstance)
        xi.fate.onAreaLeave(player, triggerArea, zoneID)
    end)
end

return m
