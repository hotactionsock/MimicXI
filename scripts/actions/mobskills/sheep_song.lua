-----------------------------------
-- Sheep Song
-- 15' AoE sleep
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power    = 1
    local duration = 45

    if xi.mobskills.isJugPet(mob) then
        local petID   = mob:getPetID()
        local isNamed = petID == xi.petId.LULLABY_MELODIA or
                        petID == xi.petId.KEENEARED_STEFFI or
                        petID == xi.petId.NURSERY_NAZUNA
        power    = 2
        duration = isNamed and 90 or 60
    end

    skill:setMsg(xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLEEP_I, power, 0, duration))

    return xi.effect.SLEEP_I
end

return mobskillObject
