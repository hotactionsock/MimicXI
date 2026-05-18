-----------------------------------
-- Acid Spray
-- Family: Spider
-- Description: Deals Water damage to a target. Additional Effect: Poison
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = { 1.00, 1.00, 1.00 }
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        if xi.mobskills.isJugPet(mob) then
            -- Jug lizard: Defense Down instead of Poison — the acid eats through armour.
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 10, 0, 60)
        else
            local power = math.floor(mob:getMainLvl() / 10 * 2)
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.POISON, power, 3, 60)
        end
    end

    return info.damage
end

return mobskillObject
