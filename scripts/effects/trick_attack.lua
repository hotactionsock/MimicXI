-----------------------------------
-- xi.effect.TRICK_ATTACK
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.TRICK_ATTACK_EFFECT)
    effect:addMod(xi.mod.TRICK_ATK_AGI, jpValue)

    target:addListener('MELEE_SWING_HIT', 'TA_PICKPOCKET', function(actorArg, targetArg, attack)
        if not actorArg:getStatusEffect(xi.effect.TRICK_ATTACK) then
            return
        end

        -- Pickpocket: drain 10 AGI from the target for 30s on a TA hit
        targetArg:addStatusEffect(xi.effect.AGI_DOWN, { power = 10, duration = 30, origin = actorArg })
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('TA_PICKPOCKET')
end

return effectObject
