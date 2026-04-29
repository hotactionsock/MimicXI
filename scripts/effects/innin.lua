-----------------------------------
-- xi.effect.INNIN
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect) -- Power = 30 initially, subpower = 20 for enmity
    local power   = effect:getPower()
    local jpValue = target:getJobPointLevel(xi.jp.INNIN_EFFECT)

    effect:addMod(xi.mod.NIN_NUKE_BONUS_INNIN, power)
    effect:addMod(xi.mod.EVA, -power)
    effect:addMod(xi.mod.ENMITY, -effect:getSubPower())
    effect:addMod(xi.mod.ACC, jpValue)

    -- Blade Dance: melee hits from behind while Innin is active build stacks (max 5) that
    -- amplify the next ninjutsu cast (if also from behind) by +8% per stack (up to +40%).
    target:addListener('MELEE_SWING_HIT', 'INNIN_BLADE_DANCE', function(actorArg, targetArg, attack)
        if not actorArg:hasStatusEffect(xi.effect.INNIN) then return end
        if not actorArg:isBehind(targetArg, 23) then return end
        local stacks = actorArg:getLocalVar('BLADE_DANCE_STACKS')
        if stacks < 5 then
            local newStacks = stacks + 1
            actorArg:setLocalVar('BLADE_DANCE_STACKS', newStacks)
            if xi.settings.map.MIMIC_COMBAT_NOTIFICATIONS then
                actorArg:printToPlayer(string.format('Blade Dance: %d/5', newStacks), xi.msg.channel.SYSTEM_3, '')
            end
        end
    end)
end

effectObject.onEffectTick = function(target, effect)
    -- Tick down the effect and reduce the overall power.
    local power = effect:getPower()

    -- Handle decay. Minimum values are 10, at which point, decay stops.
    if power > 10 then
        power = power - 1
        effect:setPower(power)

        effect:addMod(xi.mod.NIN_NUKE_BONUS_INNIN, -1)
        effect:addMod(xi.mod.EVA, 1)

        -- Enmity decay is twice as slow. Minimal value will be 10 at the end of the day.
        if power % 2 == 0 then
            effect:setSubPower(effect:getSubPower() - 1)
            effect:addMod(xi.mod.ENMITY, 1)
        end
    end
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('INNIN_BLADE_DANCE')
    target:setLocalVar('BLADE_DANCE_STACKS', 0)
end

return effectObject
