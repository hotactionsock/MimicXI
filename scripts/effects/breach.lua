-----------------------------------
-- xi.effect.BREACH
-- Granted when Angon's defense-down successfully lands.
-- Duration matches Angon's duration (15s base + merits).
-- Consumed on next jump: +35% bonus damage.
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
