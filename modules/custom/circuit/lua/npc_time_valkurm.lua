-----------------------------------
-- Module: Circuit Timekeeper — Valkurm Dunes (Lv30)
-- NPC: Circuit_Timekeeper_Valkurm
-- Tarutaru male scholar look (model 2457)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Valkurm_Dunes/Zone')

local m = Module:new('mimic_ct_time_valkurm')

local timekeeper = require('modules/custom/circuit/lua/circuit_npc')

m:addOverride('xi.zones.Valkurm_Dunes.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Circuit_Timekeeper_Valkurm',
        look      = 2457,
        x         = 79.512,
        y         = -0.617,
        z         = -130.195,
        rotation  = 181,
        widescan  = 1,
        onTrigger = timekeeper.onTrigger(30),
    })
end)

return m
