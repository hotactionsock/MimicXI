-----------------------------------
-- xi.effect.WYVERN_BLESSING
-- Granted when the wyvern's Healing Breath heals the DRG master.
-- power = total HP restored. Duration: 15s.
-- Consumed on next WS: 1 + power / (maxHP * 2), capped at 1.5x (+50%).
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
