-----------------------------------
-- Trust: Zazarg
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

    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS,     0                    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DODGE   })
    mob:addGambit(ai.t.SELF, { ai.c.HPP_LT,    50                   }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHAKRA  })
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS,     0                   }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MANTRA  })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.IMPETUS   }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.IMPETUS })

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
