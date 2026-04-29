-----------------------------------
-- xi.effect.SEIGAN
-- MimicXI: While active, each Zanshin proc stacks ZANSHIN_MOMENTUM
-- (+5% TWOHAND haste per proc, cap 15%, timer refreshes to 10s).
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    -- TODO: confirm if this def bonus is only active with 2hander equipped and either follow the pattern currently in hasso/desperate blows or consider a latent sytle effect
    local jpValue = target:getJobPointLevel(xi.jp.SEIGAN_EFFECT)

    effect:addMod(xi.mod.DEF, jpValue * 3)

    -- SAM main job bonus: Seigan gives counter chance at 25% of Zanshin rate
    if target:getMainJob() == xi.job.SAM then
        effect:addMod(xi.mod.SEIGAN_COUNTER_BONUS, 1)
    end

    -- Zanshin Momentum: each Zanshin follow-up hit stacks haste while Seigan is active.
    target:addListener('MELEE_SWING_HIT', 'ZANSHIN_MOMENTUM', function(actorArg, targetArg, attack)
        if not actorArg:hasStatusEffect(xi.effect.SEIGAN) then return end
        if attack:getAttackType() ~= xi.physicalAttackType.ZANSHIN then return end

        local current = 0
        local momEffect = actorArg:getStatusEffect(xi.effect.ZANSHIN_MOMENTUM)
        if momEffect then
            current = momEffect:getPower()
        end

        local newPower = math.min(current + 500, 1500)
        actorArg:delStatusEffect(xi.effect.ZANSHIN_MOMENTUM)
        actorArg:addStatusEffect(xi.effect.ZANSHIN_MOMENTUM, { power = newPower, duration = 10, origin = actorArg })
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('ZANSHIN_MOMENTUM')
end

return effectObject
