-----------------------------------
-- Lamb Chop
-- Family: Sheep
-- Description: Deals physical damage to a target.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        -- Jug pet bonus: +40% damage if target is currently sleeping (Sheep Song setup).
        if xi.mobskills.isJugPet(mob) then
            if target:hasStatusEffect(xi.effect.SLEEP_I) or target:hasStatusEffect(xi.effect.SLEEP_II) then
                info.damage = math.floor(info.damage * 1.4)
            end
            info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        end

        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
    end

    return info.damage
end

return mobskillObject
