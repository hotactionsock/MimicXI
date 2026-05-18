-----------------------------------
-- Silence Gas
-- Family: Funguar
-- Description: Deals Dark Breath damage to targets in front of mob. Additional Effect: Silence
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.percentMultipier = 0.25
    params.damageCap        = 800 -- TODO: Capture cap
    params.bonusDamage      = 0
    params.mAccuracyBonus   = { 0, 0, 0 }
    params.resistStat       = xi.mod.INT
    params.element          = xi.element.DARK
    params.attackType       = xi.attackType.BREATH
    params.damageType       = xi.damageType.DARK
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobBreathMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        local isJug  = xi.mobskills.isJugPet(mob)
        local petID  = isJug and mob:getPetID() or 0
        local isNamed = petID == xi.petId.FLOWERPOT_BILL or petID == xi.petId.FLOWERPOT_BEN or petID == xi.petId.FLOWERPOT_MERLE
        local duration = isNamed and 90 or (isJug and 60 or math.random(15, 60))
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SILENCE, 1, 0, duration)
        if isNamed then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 25, 0, 60)
        end
    end

    return info.damage
end

return mobskillObject
