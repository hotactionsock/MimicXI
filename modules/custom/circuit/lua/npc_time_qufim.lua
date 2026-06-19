-----------------------------------
-- Module: Circuit Timekeeper — Qufim Island (Lv40)
-- NPC: Circuit_Timekeeper_Qufim
-- Tarutaru male scholar look (model 2457)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Qufim_Island/Zone')

local m = Module:new('mimic_ct_time_qufim')

local timekeeper = require('modules/custom/circuit/lua/circuit_npc')

m:addOverride('xi.zones.Qufim_Island.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Circuit_Timekeeper_Qufim',
        look      = 2457,
        x         = -274.371,
        y         = -20.000,
        z         = 312.753,
        rotation  = 230,
        widescan  = 1,
        onTrigger = timekeeper.onTrigger(40),
    })
end)

return m
