-----------------------------------
-- xi.effect.COMPOSURE
-- Increases accuracy and lengthens recast time. Enhancement effects gained through white
-- and black magic you cast on yourself last longer.
-- MimicXI: Also amplifies enspell damage and gives crits a chance to reset Saboteur.
-----------------------------------
---@type TEffect
local effectObject = {}

local SABOTEUR_CRIT_RESET_CHANCE = 20

effectObject.onEffectGain = function(target, effect)
    local power = math.floor((24 * target:getMainLvl() + 74) / 49) + target:getJobPointLevel(xi.jp.COMPOSURE_EFFECT)

    effect:addMod(xi.mod.ACC, power)
    effect:addMod(xi.mod.ENSPELL_DMG_BONUS, 15)

    target:addListener('MELEE_SWING_HIT', 'COMPOSURE_SABOTEUR', function(actorArg, targetArg, attack)
        if not actorArg:getStatusEffect(xi.effect.COMPOSURE) then return end
        if not attack:isCritical() then return end
        if math.random(100) > SABOTEUR_CRIT_RESET_CHANCE then return end
        actorArg:resetRecast(xi.recast.ABILITY, xi.jobAbility.SABOTEUR)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('COMPOSURE_SABOTEUR')
end

return effectObject
