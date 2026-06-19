-----------------------------------
-- Module: Circuit Timekeeper — Beaucedine Glacier (Lv50)
-- NPC: Circuit_Timekeeper_Beaucedine
-- Tarutaru male scholar look (model 2457)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Beaucedine_Glacier/Zone')

local m = Module:new('mimic_ct_time_beaucedine')

local timekeeper = require('modules/custom/circuit/lua/circuit_npc')

m:addOverride('xi.zones.Beaucedine_Glacier.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Circuit_Timekeeper_Beaucedine',
        look      = 2457,
        x         = -130.628,
        y         = -81.920,
        z         = 216.893,
        rotation  = 128,
        widescan  = 1,
        onTrigger = timekeeper.onTrigger(50),
    })
end)

return m
