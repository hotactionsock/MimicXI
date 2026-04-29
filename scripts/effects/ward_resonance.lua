-----------------------------------
-- xi.effect.WARD_RESONANCE
-- Built by Blood Pact: Ward abilities (1 stack per use, max 5, 30s timer refreshes per stack).
-- Consumed when the avatar deals damage via a Blood Pact: Rage.
-- Each stack = +15% Rage BP damage (up to +75% at 5 stacks).
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
