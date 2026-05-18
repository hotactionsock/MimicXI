-----------------------------------
-- Shakeshroom
-- Family: Funguar
-- Description: Deal physical damage to a a single target. Additional Effect: Disease
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if mob:getAnimationSub() == 2 then
        return 0
    end

    return 1
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    params.baseDamage     = mob:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.canCrit        = true
    params.criticalChance = { 0.10, 0.20, 0.25 } -- TODO: Capture crit rate

    local info = xi.mobskills.mobPhysicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        local isJug = xi.mobskills.isJugPet(mob)
        if isJug then
            info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        end
        target:takeDamage(info.damage, mob, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DISEASE, 1, 0, 720)
        if isJug then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, 2000, 0, 90, nil, nil, 6)
            local petID = mob:getPetID()
            if petID == xi.petId.FLOWERPOT_BILL or petID == xi.petId.FLOWERPOT_BEN or petID == xi.petId.FLOWERPOT_MERLE then
                xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.POISON, 4, 3, 60)
            end
        end
    end

    skill:setFinalAnimationSub(3)

    return info.damage
end

return mobskillObject
