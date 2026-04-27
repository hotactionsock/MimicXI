-----------------------------------
-- xi.effect.AGGRESSOR
-----------------------------------
---@type TEffect
local effectObject = {}

local SDT_BY_WEAPON_TYPE =
{
    [xi.damageType.SLASHING] = xi.mod.SLASH_SDT,
    [xi.damageType.PIERCING] = xi.mod.PIERCE_SDT,
    [xi.damageType.BLUNT]    = xi.mod.IMPACT_SDT,
    [xi.damageType.HTH]      = xi.mod.HTH_SDT,
}

local SDT_PER_STACK = 500 -- 5% per stack in basis points
local MAX_STACKS    = 3   -- 15% max vulnerability

effectObject.onEffectGain = function(target, effect)
    local jpLevel = target:getJobPointLevel(xi.jp.AGGRESSOR_EFFECT)
    local merits  = effect:getPower()

    effect:addMod(xi.mod.RACC, merits + jpLevel)
    effect:addMod(xi.mod.ACC, 25 + jpLevel)
    effect:addMod(xi.mod.EVA, -25)

    -- Snapshot the weapon damage type at activation time.
    -- power repurposed as SDT stack counter after mods are committed above.
    effect:setSubPower(target:getWeaponDamageType(xi.slot.MAIN))
    effect:setPower(0)
    effect:setTier(0) -- tracked target ID for cleanup

    target:addListener('MELEE_SWING_HIT', 'AGGRESSOR_HIT', function(actorArg, targetArg, attack)
        local effectArg = actorArg:getStatusEffect(xi.effect.AGGRESSOR)
        if not effectArg then
            return
        end

        local sdtMod = SDT_BY_WEAPON_TYPE[effectArg:getSubPower()]
        if not sdtMod then
            return
        end

        local stacks          = effectArg:getPower()
        local trackedTargetID = effectArg:getTier()
        local hitTargetID     = targetArg:getID()

        -- Target changed: remove accumulated mods from the previous target and reset.
        if trackedTargetID ~= 0 and trackedTargetID ~= hitTargetID then
            local oldTarget = GetMobByID(trackedTargetID)
            if oldTarget then
                oldTarget:delMod(sdtMod, stacks * SDT_PER_STACK)
            end

            stacks = 0
        end

        if stacks >= MAX_STACKS then
            return
        end

        targetArg:addMod(sdtMod, -SDT_PER_STACK)
        effectArg:setPower(stacks + 1)
        effectArg:setTier(hitTargetID)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('AGGRESSOR_HIT')

    local stacks = effect:getPower()
    if stacks == 0 then
        return
    end

    local sdtMod          = SDT_BY_WEAPON_TYPE[effect:getSubPower()]
    local trackedTargetID = effect:getTier()

    if sdtMod and trackedTargetID ~= 0 then
        local trackedTarget = GetMobByID(trackedTargetID)
        if trackedTarget then
            trackedTarget:delMod(sdtMod, stacks * SDT_PER_STACK)
        end
    end
end

return effectObject
