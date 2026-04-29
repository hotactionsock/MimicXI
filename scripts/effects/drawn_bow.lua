-----------------------------------
-- xi.effect.DRAWN_BOW
-- Granted to SAM after landing a ranged WS while Hasso is active.
-- The next melee WS deals +20% bonus damage. Duration: 20s. Consumed on use.
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
