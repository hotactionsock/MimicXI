-----------------------------------
-- xi.effect.FOOTWORK
-----------------------------------
---@type TEffect
local effectObject = {}

local THIRD_STRIKE_COUNT = 3 -- Every 3rd kick lands as a guaranteed critical hit

effectObject.onEffectGain = function(target, effect)
    local jpLevel = target:getJobPointLevel(xi.jp.FOOTWORK_EFFECT)

    effect:addMod(xi.mod.KICK_ATTACK_RATE, 20)
    effect:addMod(xi.mod.KICK_DMG, effect:getPower() + jpLevel)

    -- Repurpose power as the kick counter after mods are committed above.
    effect:setPower(0)

    target:addListener('MELEE_SWING_HIT', 'FOOTWORK_HIT', function(actorArg, targetArg, attack)
        local effectArg = actorArg:getStatusEffect(xi.effect.FOOTWORK)
        if not effectArg then
            return
        end

        if attack:getAttackType() ~= xi.physicalAttackType.KICK then
            return
        end

        local kicks = effectArg:getPower() + 1

        if kicks >= THIRD_STRIKE_COUNT then
            attack:setCritical(true)
            kicks = 0
        end

        effectArg:setPower(kicks)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('FOOTWORK_HIT')
end

return effectObject
