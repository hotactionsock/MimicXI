-----------------------------------
-- Metalid Body
--
-- Gives the effect of "Stoneskin."
-- Type: Magical
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power = 25 -- ffxiclopedia claims its always 25 on the crabs page. Tested on wootzshell in mt zhayolm..
    --[[
    if mob:isNM() then
        power = ???  Betting NMs aren't 25 but I don't have data..
    end
    ]]
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.STONESKIN, power, 0, 300))

    -- Jug beetle: also grant the BST master Stoneskin. Named pets give a stronger shield.
    if xi.mobskills.isJugPet(mob) then
        local master = mob:getMaster()
        if not master:hasStatusEffect(xi.effect.STONESKIN) then
            local petID   = mob:getPetID()
            local isNamed = petID == xi.petId.PANZER_GALAHAD or petID == xi.petId.MAILBUSTER_CETAS
            local mPower  = isNamed and 200 or 100
            master:addStatusEffect(xi.effect.STONESKIN, { power = mPower, duration = 60, origin = mob })
        end
    end

    return xi.effect.STONESKIN
end

return mobskillObject
