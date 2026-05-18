-----------------------------------
-- Brain Crush
-- Family: Lizard
-- Description: Deals damage to single target. Additional Effect: Silence
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
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        local isJug = xi.mobskills.isJugPet(mob)
        if isJug then
            info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        end
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        if isJug then
            -- Jug beetle: stack Defense Down up to 3 applications (45% total) instead of Silence.
            local current = 0
            local existing = target:getStatusEffect(xi.effect.DEFENSE_DOWN)
            if existing then current = existing:getPower() end
            local newPower = math.min(current + 15, 45)
            target:delStatusEffect(xi.effect.DEFENSE_DOWN)
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, newPower, 0, 90)
        else
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SILENCE, 1, 0, 30)
        end
    end

    return info.damage
end

return mobskillObject
