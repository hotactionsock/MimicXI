-----------------------------------
-- xi.effect.STRATEGIC_CLARITY
-- Granted to the BRD when Finale successfully strips a buff.
-- The next Threnody, Elegy, or Lullaby cast resets its own recast on landing.
-- Duration: 15s. Consumed on use.
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
