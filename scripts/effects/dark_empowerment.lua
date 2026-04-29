-----------------------------------
-- xi.effect.DARK_EMPOWERMENT
-- Granted when Nether Void is consumed by a drain, aspir, or absorb spell.
-- While active, HP drains (Drain/Drain II/Drain III) additionally restore
-- TP equal to 25% of the amount drained. Duration: 30s.
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
