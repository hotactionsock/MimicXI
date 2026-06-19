-----------------------------------
-- Module: Tier Trial Gatekeeper — Pso'Xja (Lv60)
-- NPC: Trial_Gatekeeper_PsoXja
-- Hume female warrior look (model 2552)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/PsoXja/Zone')

local m = Module:new('mimic_tt_gate_psoxja')

local gate = require('modules/custom/tier_trials/lua/tier_trial_gatekeeper')

m:addOverride('xi.zones.PsoXja.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Trial_Gatekeeper_PsoXja',
        look      = 2552,
        x         = -177.633,
        y         = 0.009,
        z         = -39.339,
        rotation  = 125,
        widescan  = 1,
        onTrigger = gate.onTrigger(60),
    })
end)

return m
