-----------------------------------
-- Bubble Curtain
--
-- Description: Reduces magical damage received by 50%
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- Notes:Nightmare Crabs use an enhanced version that applies a Magic Defense Boost that cannot be dispelled.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    skill:setMsg(xi.mobskills.mobBuffMove(target, xi.effect.SHELL, 5000, 0, 180))

    -- Jug pet bonus: also shield the BST master with Stoneskin.
    if xi.mobskills.isJugPet(mob) then
        local master = mob:getMaster()
        if not master:hasStatusEffect(xi.effect.STONESKIN) then
            local petID  = mob:getPetID()
            local isNamed = petID == xi.petId.COURIER_CARRIE or petID == xi.petId.SHELLBUSTER_OROB
            local power  = isNamed and 160 or 80
            master:addStatusEffect(xi.effect.STONESKIN, { power = power, duration = 60, origin = mob })
        end
    end

    return xi.effect.SHELL
end

return mobskillObject
