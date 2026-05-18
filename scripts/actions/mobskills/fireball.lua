-----------------------------------
-- Fireball
-- Family: Lizards
-- Description: Deals Fire damage in an area of effect.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    local isJug           = xi.mobskills.isJugPet(mob)
    params.baseDamage     = mob:getMainLvl() + 2
    params.fTP            = isJug and { 3.5, 3.5, 3.5 } or { 2.5, 2.5, 2.5 }
    params.element        = xi.element.FIRE
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.FIRE
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)
        -- Jug lizard: leaves a Burn DoT.
        if isJug then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BURN, 3, 3, 30)
        end
    end

    return info.damage
end

return mobskillObject
