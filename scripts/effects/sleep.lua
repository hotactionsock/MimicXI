-----------------------------------
-- xi.effect.SLEEP_I
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    -- Immunobreak reset.
    target:setMod(xi.mod.SLEEP_IMMUNOBREAK, 0)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    -- Groggy: if this sleep came from a Lullaby, apply a brief physical damage vulnerability.
    if target:getLocalVar('LULLABY_GROGGY') == 1 then
        target:setLocalVar('LULLABY_GROGGY', 0)
        target:addStatusEffect(xi.effect.GROGGY, { power = 1, duration = 10, origin = target })
    end
end

return effectObject
