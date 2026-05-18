-----------------------------------
-- Bubble Shower
-- Family: Crabs
-- Description: Deals Water damage in an area of effect. Additional Effect: STR Down
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.percentMultipier = 0.0625
    params.damageCap        = 200
    params.bonusDamage      = 0
    params.mAccuracyBonus   = { 0, 0, 0 }
    params.resistStat       = xi.mod.INT
    params.element          = xi.element.WATER
    params.attackType       = xi.attackType.BREATH
    params.damageType       = xi.damageType.WATER
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    -- TODO: Jug Pet differences

    local info = xi.mobskills.mobBreathMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        if xi.mobskills.isJugPet(mob) then
            -- Jug pet version: potent Slow instead of the STR Down that wild crabs apply.
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, 3000, 0, 120, nil, nil, 7)
            -- Named crabs (Courier Carrie, Shellbuster Orob) also apply Weight.
            local petID = mob:getPetID()
            if petID == xi.petId.COURIER_CARRIE or petID == xi.petId.SHELLBUSTER_OROB then
                xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.WEIGHT, 50, 0, 60)
            end
        else
            local power    = 10
            local duration = 180
            -- TODO: Dreamland Dynamis Power
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STR_DOWN, power, 9, duration)
        end
    end

    return info.damage
end

return mobskillObject
