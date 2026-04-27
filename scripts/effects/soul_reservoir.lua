-----------------------------------
-- xi.effect.SOUL_RESERVOIR
-- Granted when Souleater expires (DRK main only).
-- Stores total HP sacrificed during Souleater (capped at 3000).
-- Consumed by the next weaponskill for up to +50% bonus damage.
-- Multiplier = 1 + (power / 3000) * 0.5
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
