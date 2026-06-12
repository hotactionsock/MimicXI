-----------------------------------
-- Module: Tier Trial Gatekeeper — Qufim Island (Lv40)
-- NPC: Trial_Gatekeeper_Qufim
-- Elvaan male warrior look (model 2562)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Qufim_Island/Zone')

local m = Module:new('mimic_tt_gate_qufim')

local gate = require('modules/custom/tier_trials/lua/tier_trial_gatekeeper')

m:addOverride('xi.zones.Qufim_Island.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Trial_Gatekeeper_Qufim',
        look      = 2562,
        x         = -275.192,
        y         = -20.000,
        z         = 326.279,
        rotation  = 2,
        widescan  = 1,
        onTrigger = gate.onTrigger(40),
    })
end)

return m
