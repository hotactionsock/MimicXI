-----------------------------------
-- Numbing Noise
-- Description: Creates an unsettling sound. Additional effect: Stun
-- Type: Physical
-- Utsusemi/Blink absorb: Ignore
-- Range: 10' cone
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STUN, 1, 0, 5))

    -- Jug coeurl: stun is followed immediately by a lingering paralysis.
    if xi.mobskills.isJugPet(mob) then
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 40, 0, 120)
    end

    return xi.effect.STUN
end

return mobskillObject
