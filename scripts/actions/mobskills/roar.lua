-----------------------------------
-- Roar
-- Description: Paralyzes targets in an area of effect.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: 10' radial
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 50, 0, 120))

    -- Jug tiger: roar also applies Defense Down, making it a genuine setup for Claw Cyclone.
    if xi.mobskills.isJugPet(mob) then
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 20, 0, 90)
    end

    return xi.effect.PARALYSIS
end

return mobskillObject
