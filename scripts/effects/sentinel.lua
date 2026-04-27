-----------------------------------
-- xi.effect.SENTINEL
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local enmityBonus = 100

    if target:getMainJob() ~= xi.job.PLD then
        enmityBonus = 50
    end

    target:addMod(xi.mod.UDMGPHYS, -effect:getPower())
    target:addMod(xi.mod.UDMGRANGE, -effect:getPower())
    target:addMod(xi.mod.ENMITY, enmityBonus)
    target:addMod(xi.mod.ENMITY_LOSS_REDUCTION, effect:getSubPower())

    -- Holy Retribution: count physical hits absorbed; on expiry convert to a divine damage burst (PLD main only).
    -- Hit counter stored in effect tier (subPower is already used for enmity-loss-reduction).
    if target:getMainJob() == xi.job.PLD then
        effect:setTier(0)
        target:addListener('TAKE_DAMAGE', 'SENTINEL_RETRIBUTION', function(actorArg, damage, attacker, attackType, damageType)
            if damage <= 0 then return end
            if attackType ~= xi.attackType.PHYSICAL then return end
            local effectArg = actorArg:getStatusEffect(xi.effect.SENTINEL)
            if not effectArg then return end
            local stacks = effectArg:getTier()
            if stacks < 10 then
                effectArg:setTier(stacks + 1)
            end
        end)
    end
end

effectObject.onEffectTick = function(target, effect)
    local power = effect:getPower()
    local decayby = 0

    -- Damage reduction decays until 50% then stops
    if power > 5000 then
        -- final tick with feet just has to be odd.
        if power == 5500 then
            decayby = 500
            -- decay by 8% per tick
        else
            decayby = 800
        end

        effect:setPower(power - decayby)
        target:delMod(xi.mod.UDMGPHYS, -decayby)
        target:delMod(xi.mod.UDMGRANGE, -decayby)
    end
end

effectObject.onEffectLose = function(target, effect)
    local enmityBonus = 100

    if target:getMainJob() ~= xi.job.PLD then
        enmityBonus = 50
    end

    target:delMod(xi.mod.UDMGPHYS, -effect:getPower())
    target:delMod(xi.mod.UDMGRANGE, -effect:getPower())
    target:delMod(xi.mod.ENMITY, enmityBonus)
    target:delMod(xi.mod.ENMITY_LOSS_REDUCTION, effect:getSubPower())

    if target:getMainJob() == xi.job.PLD then
        target:removeListener('SENTINEL_RETRIBUTION')
        local stacks = effect:getTier()
        if stacks > 0 then
            target:addStatusEffect(xi.effect.HOLY_RETRIBUTION, { power = stacks, duration = 60, origin = target })
        end
    end
end

return effectObject
