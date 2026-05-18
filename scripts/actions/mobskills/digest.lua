-----------------------------------
-- Digest
-- Family: Slimes
-- Description: Drains HP from a target.
-- Notes: If used against undead, it will simply do damage and not drain HP.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- TODO: Move to mobskill script?
    if mob:getFamily() == 290 then -- Claret
        if mob:checkDistance(target) < 3 then -- Don't use it if he is on his target.
            return 1
        end
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local params = {}

    local isJug               = xi.mobskills.isJugPet(mob)
    params.baseDamage         = mob:getMainLvl() + 2
    params.fTP                = isJug and { 3.5, 3.5, 3.5 } or { 2.0, 2.0, 2.0 }
    params.element            = xi.element.NONE
    params.attackType         = xi.attackType.MAGICAL
    params.damageType         = xi.damageType.NONE
    params.shadowBehavior     = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.skipMagicBonusDiff = true

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, action, params)

    if xi.mobskills.processDamage(mob, target, skill, action, info) then
        info.damage = math.floor(info.damage * xi.mobskills.getJugPetDamageBonus(mob))
        skill:setMsg(xi.mobskills.mobDrainMove(mob, target, xi.mobskills.drainType.HP, info.damage))
        -- Jug fly: share 25% of the drain with the BST master.
        -- Lifedrinker Lars also restores a portion of master MP.
        if isJug then
            local master = mob:getMaster()
            master:addHP(math.floor(info.damage * 0.25))
            if mob:getPetID() == xi.petId.LIFEDRINKER_LARS then
                master:addMP(math.floor(info.damage * 0.10))
            end
        end
    end

    return info.damage
end

return mobskillObject
