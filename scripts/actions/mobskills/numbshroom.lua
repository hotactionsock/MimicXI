-----------------------------------
-- Queasyshroom
-- Family: Funguar
-- Description: Fires a mushroom cap, dealing damage to a single target. Additional Effect: paralysis.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if mob:getAnimationSub() == 1 then
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

        local power, duration = 25, 180
        if isJug then
            power, duration = 40, 240
            local petID = mob:getPetID()
            if petID == xi.petId.FLOWERPOT_BILL or petID == xi.petId.FLOWERPOT_BEN or petID == xi.petId.FLOWERPOT_MERLE then
                xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 30, 0, 120)
            end
        end
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, power, 0, duration)
    end

    skill:setFinalAnimationSub(2)

    return info.damage
end

return mobskillObject
