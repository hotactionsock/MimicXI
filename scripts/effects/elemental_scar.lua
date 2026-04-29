-----------------------------------
-- xi.effect.ELEMENTAL_SCAR
-- Applied to a target after it is struck by ninjutsu.
-- power = xi.element of the last ninjutsu that hit.
-- The next ninjutsu cast of the same element deals +25% damage and then overwrites the scar.
-- Duration: 35s (shorter than Ni recast 45s, longer than Ichi recast 30s — enforces Ichi→Ni pattern).
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
