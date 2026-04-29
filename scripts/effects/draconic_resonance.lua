-----------------------------------
-- xi.effect.DRACONIC_RESONANCE
-- Built by damaging Jump abilities (Jump/High Jump = 1 stack, Spirit/Soul Jump = 2 stacks).
-- Caps at 3 stacks. Timer refreshes to 10s on each jump.
-- Consumed on polearm WS: +20% damage per stack (up to +60%).
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
