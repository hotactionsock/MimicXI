-----------------------------------
-- Module: Resonance Forge — Lower Jeuno
-- NPC: Resonance_Forge
-- Galka male craftsman look (model 2580)
-- Single forge serves all tiers from the hub city
-----------------------------------
require('modules/module_utils')
require('scripts/zones/Lower_Jeuno/Zone')

local m = Module:new('mimic_pa_forge_jeuno')

local forge = require('modules/custom/proving_arms/lua/forge_npc')

m:addOverride('xi.zones.Lower_Jeuno.Zone.onInitialize', function(zone)
    super(zone)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Resonance_Forge',
        look      = 2580,
        x         = -10.495,
        y         = 0.000,
        z         = 11.046,
        rotation  = 20,
        widescan  = 1,
        onTrigger = forge.onTrigger,
    })
end)

return m
