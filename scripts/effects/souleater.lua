-----------------------------------
-- xi.effect.SOULEATER
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.ACC, 25)
    if target:getMainJob() == xi.job.DRK then
        effect:setTier(0)
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    if target:getMainJob() == xi.job.DRK then
        local drained = effect:getTier()
        if drained > 0 then
            target:addStatusEffect(xi.effect.SOUL_RESERVOIR, { power = drained, duration = 60, origin = target })
        end
    end
end

return effectObject
