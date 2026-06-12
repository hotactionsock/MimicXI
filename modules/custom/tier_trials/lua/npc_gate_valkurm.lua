-----------------------------------
-- Module: Tier Trial Gatekeeper — Valkurm Dunes (Lv30)
-- NPC: Trial_Gatekeeper_Valkurm
-- Hume female warrior look (model 2552)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Valkurm_Dunes/Zone')

local m = Module:new('mimic_tt_gate_valkurm')

local gate = require('modules/custom/tier_trials/lua/tier_trial_gatekeeper')

m:addOverride('xi.zones.Valkurm_Dunes.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Trial_Gatekeeper_Valkurm',
        look      = 2552,
        x         = 75.502,
        y         = -1.081,
        z         = -130.593,
        rotation  = 184,
        widescan  = 1,
        onTrigger = gate.onTrigger(30),
    })
end)

return m
