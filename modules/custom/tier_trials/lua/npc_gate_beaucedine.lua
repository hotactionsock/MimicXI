-----------------------------------
-- Module: Tier Trial Gatekeeper — Beaucedine Glacier (Lv50)
-- NPC: Trial_Gatekeeper_Beaucedine
-- Hume female warrior look (model 2552)
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Beaucedine_Glacier/Zone')

local m = Module:new('mimic_tt_gate_beaucedine')

local gate = require('modules/custom/tier_trials/lua/tier_trial_gatekeeper')

m:addOverride('xi.zones.Beaucedine_Glacier.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Trial_Gatekeeper_Beaucedine',
        look      = 2552,
        x         = -132.398,
        y         = -81.691,
        z         = 219.127,
        rotation  = 126,
        widescan  = 1,
        onTrigger = gate.onTrigger(50),
    })
end)

return m
