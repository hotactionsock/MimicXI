-----------------------------------
-- Spider Web
-- Entangles all targets in an area of effect.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local effectparams =
    {
        effectId = xi.effect.SLOW,
        power    = 3000,
        duration = 90,
        tier     = 8, -- https://wiki.ffo.jp/html/4125.html
    }

    if xi.mobskills.isJugPet(mob) then
        effectparams.power    = 3500
        effectparams.duration = 120
        effectparams.tier     = 9
    end

    xi.combat.action.executeMobskillStatusEffect(mob, target, skill, effectparams, true)

    -- Jug pet: webbed targets are physically vulnerable (+15% physical damage taken).
    if xi.mobskills.isJugPet(mob) then
        xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DEFENSE_DOWN, 15, 0, 120)
        -- Ambusher Allie also applies Bind.
        if mob:getPetID() == xi.petId.AMBUSHER_ALLIE then
            xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BIND, 1, 0, 3)
        end
    end

    return xi.effect.SLOW
end

return mobskillObject
