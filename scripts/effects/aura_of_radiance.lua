-----------------------------------
-- xi.effect.AURA_OF_RADIANCE
-- Granted when Divine Seal is consumed by a cure spell.
-- The WHM's next Holy or Banish spell deals 150% damage.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
