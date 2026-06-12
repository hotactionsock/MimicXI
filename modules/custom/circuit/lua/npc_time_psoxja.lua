-----------------------------------
-- Module: Circuit Timekeeper — Pso'Xja (Lv60)
-- NPC: Circuit_Timekeeper_PsoXja
-- Tarutaru female scholar look (model 2463)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/PsoXja/Zone')

local m = Module:new('mimic_ct_time_psoxja')

local timekeeper = require('modules/custom/circuit/lua/circuit_npc')

m:addOverride('xi.zones.PsoXja.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Circuit_Timekeeper_PsoXja',
        look      = 2463,
        x         = -177.082,
        y         = 0.000,
        z         = -42.328,
        rotation  = 135,
        widescan  = 1,
        onTrigger = timekeeper.onTrigger(60),
    })
end)

return m
