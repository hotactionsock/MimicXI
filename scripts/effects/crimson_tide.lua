-----------------------------------
-- xi.effect.CRIMSON_TIDE
-- Granted when Blood Weapon expires (DRK main only).
-- Converts hits landed during Blood Weapon into a crit rate bonus.
-- effect power = hit count (1-20); grants +2% crit rate per hit (up to +40%).
-- Duration: 30s.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.CRITHITRATE, effect:getPower() * 2)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
