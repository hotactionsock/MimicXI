-----------------------------------
-- Infrasonics
-- Reduces evasion of targets in area of effect.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power, duration = 40, 180

    if xi.mobskills.isJugPet(mob) then
        power, duration = 65, 240
        -- Named coeurls (Chopsuey Chucky, Bloodclaw Shasra) also strip some defense.
        local petID = mob:getPetID()
        if petID == xi.petId.CHOPSUEY_CHUCKY or petID == xi.petId.BLOODCLAW_SHASRA then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 10, 0, 120)
        end
    end

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.EVASION_DOWN, power, 0, duration))

    return xi.effect.EVASION_DOWN
end

return mobskillObject
