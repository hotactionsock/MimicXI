-----------------------------------
-- xi.effect.FOCUS
-- Note: Glanzfaust bonus is implemented as a latent effect while wearing the equipment and having the effect
-----------------------------------
---@type TEffect
local effectObject = {}

local DEF_PER_CRIT = 20 -- DEF reduction per critical hit while focused
local MAX_STACKS   = 3  -- 60 total DEF reduction at max stacks

-- TODO: implement focus ranged accuracy bonus (needs verification)
effectObject.onEffectGain = function(target, effect)
    local bonusPower = effect:getPower()
    local monkLevel  = utils.getActiveJobLevel(target, xi.job.MNK) + 1

    -- https://wiki.ffo.jp/html/2841.html
    effect:addMod(xi.mod.ACC, monkLevel + bonusPower)

    -- https://www.bg-wiki.com/ffxi/Focus
    effect:addMod(xi.mod.CRITHITRATE, math.floor(monkLevel * 0.2))

    -- Repurpose power as DEF stack counter after mods are committed above.
    effect:setPower(0)
    effect:setTier(0) -- tracked target ID for cleanup

    target:addListener('MELEE_SWING_HIT', 'FOCUS_VITAL_POINT', function(actorArg, targetArg, attack)
        local effectArg = actorArg:getStatusEffect(xi.effect.FOCUS)
        if not effectArg then
            return
        end

        if not attack:isCritical() then
            return
        end

        local stacks          = effectArg:getPower()
        local trackedTargetID = effectArg:getTier()
        local hitTargetID     = targetArg:getID()

        -- Target changed: remove accumulated DEF reduction from the previous target and reset.
        if trackedTargetID ~= 0 and trackedTargetID ~= hitTargetID then
            local oldTarget = GetMobByID(trackedTargetID)
            if oldTarget then
                oldTarget:delMod(xi.mod.DEF, stacks * DEF_PER_CRIT)
            end

            stacks = 0
        end

        if stacks >= MAX_STACKS then
            return
        end

        targetArg:addMod(xi.mod.DEF, -DEF_PER_CRIT)
        effectArg:setPower(stacks + 1)
        effectArg:setTier(hitTargetID)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('FOCUS_VITAL_POINT')

    local stacks = effect:getPower()
    if stacks == 0 then
        return
    end

    local trackedTargetID = effect:getTier()
    if trackedTargetID ~= 0 then
        local trackedTarget = GetMobByID(trackedTargetID)
        if trackedTarget then
            trackedTarget:delMod(xi.mod.DEF, stacks * DEF_PER_CRIT)
        end
    end
end

return effectObject
