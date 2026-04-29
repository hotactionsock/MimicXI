-----------------------------------
-- xi.effect.ZANSHIN_MOMENTUM
-- Granted each time SAM's Zanshin fires while Seigan is active.
-- Stacks: +500 per proc (500/1000/1500 = 5/10/15% TWOHAND haste).
-- Duration refreshes to 10s on each proc. Capped at 1500 (15%).
-- del+add pattern on refresh: onEffectLose clears old mod, onEffectGain applies new.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.TWOHAND_HASTE_ABILITY, effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
