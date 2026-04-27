-----------------------------------
-- xi.effect.SNEAK_ATTACK
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.SNEAK_ATTACK_EFFECT)
    effect:addMod(xi.mod.SNEAK_ATK_DEX, jpValue)

    target:addListener('MELEE_SWING_HIT', 'SA_PICKPOCKET', function(actorArg, targetArg, attack)
        if not actorArg:getStatusEffect(xi.effect.SNEAK_ATTACK) then
            return
        end

        -- Pickpocket: drain 10 DEX from the target for 30s on a SA hit
        targetArg:addStatusEffect(xi.effect.DEX_DOWN, { power = 10, duration = 30, origin = actorArg })
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('SA_PICKPOCKET')
end

return effectObject
