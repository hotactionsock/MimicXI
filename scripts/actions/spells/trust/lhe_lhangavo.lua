-----------------------------------
-- Trust: Lhe Lhangavo
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

    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS,             0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DODGE   })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.SELF,   { ai.c.HPP_LT,            50 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAKRA  })
    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE,          1000 }, { ai.r.WS, ai.s.SPECIFIC, 9             }) -- Asuran Fists

    mob:addMod(xi.mod.DOUBLE_ATTACK,    xi.trust.modGrowthValMax(mob, 15))
    mob:addMod(xi.mod.KICK_ATTACK_RATE, xi.trust.modGrowthValMax(mob, 10))

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
