-----------------------------------
-- Fluid Spread
-- Family: Slime
-- Description: Deals damage to targets in range of mob.
-- Note: This is a physical skill despite looking water based.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage       = mob:getWeaponDmg()
    params.numHits          = 1
    params.fTP              = { 1.0, 1.0, 1.0 }
    params.attackType       = xi.attackType.PHYSICAL
    params.damageType       = xi.damageType.SLASHING
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_3
    params.attackMultiplier = { 1.5, 1.5, 1.5 }

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
        -- Jug fly: spreads plague on contact.
        if xi.mobskills.isJugPet(mob) then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PLAGUE, 3, 3, 60)
        end
    end

    return info.damage
end

return mobskillObject
