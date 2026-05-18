-----------------------------------
-- xi.effect.DEAD_AIM
-- COR: built by Quick Draw hits (1 stack per hit, max 5, 30s refresh).
-- Consumed on a ranged WS for +12% fTP per stack (up to +60%).
-- power = current stack count.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:setLocalVar('DEAD_AIM_STACKS', 0)
end

return effectObject
