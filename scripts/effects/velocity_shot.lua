-----------------------------------
-- xi.effect.VELOCITY_SHOT
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    local jpValue = target:getJobPointLevel(xi.jp.VELOCITY_SHOT_EFFECT)

    effect:addMod(xi.mod.RATT, jpValue * 2)
    effect:addMod(xi.mod.ATTP, -15)
    effect:addMod(xi.mod.HASTE_ABILITY, -1500)
    effect:addMod(xi.mod.RATTP, 15)

    -- Point Blank: 1h axe hits generate +50 bonus TP, turning the melee haste penalty
    -- into a TP-generation window for axe weaponskills.
    target:addListener('MELEE_SWING_HIT', 'VELOCITY_SHOT_POINT_BLANK', function(actorArg, targetArg, attack)
        if actorArg:getWeaponSkillType(xi.slot.MAIN) ~= xi.skill.AXE then return end
        actorArg:addTP(50)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:removeListener('VELOCITY_SHOT_POINT_BLANK')
end

return effectObject
