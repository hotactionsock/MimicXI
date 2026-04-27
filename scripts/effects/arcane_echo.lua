-----------------------------------
-- xi.effect.ARCANE_ECHO
-- Granted when Elemental Seal is consumed by an elemental spell.
-- The BLM's next spell of the same element deals 150% damage.
-- effect power = the element ID of the triggering spell.
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
