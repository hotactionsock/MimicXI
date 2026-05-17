-----------------------------------
-- Trust: Kuyin Hathdenna
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    local mlvl = mob:getMainLvl()
    local aura_power
    if mlvl == 99 then
        aura_power = 10
    elseif mlvl >= 75 then
        aura_power = 8
    else
        aura_power = 5
    end

    mob:addStatusEffect(xi.effect.COLURE_ACTIVE, { power = 6, origin = mob, tick = 3, subType = xi.effect.GEO_ACCURACY_BOOST, subPower = aura_power, tier = xi.auraTarget.ALLIES, flag = xi.effectFlag.AURA })
    mob:setAutoAttackEnabled(false)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
