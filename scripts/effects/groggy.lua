-----------------------------------
-- xi.effect.GROGGY
-- Applied to a target when Lullaby expires.
-- Grants +5% physical damage taken for 10s.
-- UDMGPHYS scale: value/10000, so 500 = +5%.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.UDMGPHYS, 500)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
