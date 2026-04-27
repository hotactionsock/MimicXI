-----------------------------------
-- xi.effect.AFFLATUS_MISERY
-----------------------------------
---@type TEffect
local effectObject = {}

local MAX_MISERY_STACKS = 20

effectObject.onEffectGain = function(target, effect)
    target:setMod(xi.mod.AFFLATUS_MISERY, 0)
    effect:setSubPower(0)

    if target:hasStatusEffect(xi.effect.AUSPICE) then
        local power = target:getStatusEffect(xi.effect.AUSPICE):getPower()
        target:addMod(xi.mod.ENSPELL, 18)
        target:addMod(xi.mod.ENSPELL_DMG, power)
    end

    target:addListener('TAKE_DAMAGE', 'MISERY_STACK', function(actorArg, damage, attacker, attackType, damageType)
        local effectArg = actorArg:getStatusEffect(xi.effect.AFFLATUS_MISERY)
        if not effectArg then return end
        if damage <= 0 then return end
        local stacks = effectArg:getSubPower()
        if stacks >= MAX_MISERY_STACKS then return end
        actorArg:addMod(xi.mod.MACC, 1)
        actorArg:addMod(xi.mod.MATT, 1)
        effectArg:setSubPower(stacks + 1)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:setMod(xi.mod.AFFLATUS_MISERY, 0)
    target:removeListener('MISERY_STACK')

    local stacks = effect:getSubPower()
    if stacks > 0 then
        target:delMod(xi.mod.MACC, stacks)
        target:delMod(xi.mod.MATT, stacks)
    end

    if target:hasStatusEffect(xi.effect.AUSPICE) then
        target:setMod(xi.mod.ENSPELL, 0)
        target:setMod(xi.mod.ENSPELL_DMG, 0)
    end
end

return effectObject
