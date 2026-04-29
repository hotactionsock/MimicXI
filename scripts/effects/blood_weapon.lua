-----------------------------------
-- xi.effect.BLOOD_WEAPON
-- Does not overwritte any existing "Enspell" effect, including "Soul Enslavement"
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.ENSPELL, 17)
    effect:addMod(xi.mod.ENSPELL_DMG, effect:getPower())

    if target:getMainJob() == xi.job.DRK then
        effect:setTier(0)
        target:addListener('MELEE_SWING_HIT', 'BLOOD_WEAPON_HITS', function(actorArg, targetArg, attack)
            local effectArg = actorArg:getStatusEffect(xi.effect.BLOOD_WEAPON)
            if not effectArg then return end
            local hits = effectArg:getTier()
            if hits < 20 then
                effectArg:setTier(hits + 1)
            end
        end)
    end
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    if target:getMainJob() == xi.job.DRK then
        target:removeListener('BLOOD_WEAPON_HITS')
        local hits = effect:getTier()
        if hits > 0 then
            target:addStatusEffect(xi.effect.CRIMSON_TIDE, { power = hits, duration = 30, origin = target })
        end
    end
end

return effectObject
