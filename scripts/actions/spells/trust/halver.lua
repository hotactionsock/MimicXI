-----------------------------------
-- Trust: Halver
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

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.DIVINE_EMBLEM }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_EMBLEM  })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH         }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH  })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_HAS_TOP_ENMITY, 0               }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE        })
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS,           0                 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SHIELD_BASH    })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS,       xi.effect.SENTINEL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL      })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS,       xi.effect.RAMPART  }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RAMPART       })
    mob:addGambit(ai.t.PARTY,  { ai.c.HPP_LT,           75                }, { ai.r.MA, ai.s.HIGHEST,   xi.magic.spellFamily.CURE })

    mob:addMod(xi.mod.DEF, 60) -- extra tank DEF on top of the global skill multiplier

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
