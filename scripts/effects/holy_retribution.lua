-----------------------------------
-- xi.effect.HOLY_RETRIBUTION
-- Granted when Sentinel expires after absorbing physical hits.
-- The PLD's next Holy, Banish, or Flash deals bonus damage.
-- effect power = number of hits absorbed during Sentinel (1-10).
-- Multiplier = 1 + (power * 0.1), so 10% to 100% bonus damage.
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
