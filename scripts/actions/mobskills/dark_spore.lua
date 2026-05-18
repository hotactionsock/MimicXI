-----------------------------------
-- Dark Spore
-- Family: Funguar
-- Description: Unleashes a torrent of black spores in a fan-shaped area of effect, dealing Dark damage to targets. Additional Effect: Blind
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.percentMultipier = 0.25
    params.damageCap        = 600 -- TODO: Capture damage cap.
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

        local power, duration = 30, 90
        if xi.mobskills.isJugPet(mob) then
            power, duration = 40, 120
            local petID = mob:getPetID()
            if petID == xi.petId.FLOWERPOT_BILL or petID == xi.petId.FLOWERPOT_BEN or petID == xi.petId.FLOWERPOT_MERLE then
                xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DISEASE, 1, 0, 180)
            end
        end
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, power, 0, duration)
    end

    return info.damage
end

return mobskillObject
