-----------------------------------
-- Trust: King of Hearts
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

    -- Stance and MP management
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.COMPOSURE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.COMPOSURE })
    mob:addGambit(ai.t.SELF, { ai.c.MPP_LT,     25                  }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CONVERT   })

    -- Self buffs
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.PROTECT })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SHELL   }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.SHELL   })
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS,     0                 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.TEMPER        }, 180)

    -- Enfeebling (Saboteur boosts potency of next enfeeble)
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.SABOTEUR }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SABOTEUR                        })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS,     0                  }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DIA_III }, 30)

    -- Party buffs
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.HASTE   }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HASTE_II })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REFRESH_II })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PHALANX }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX })

    -- Status removal and healing
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50                          }, { ai.r.MA, ai.s.HIGHEST,  xi.magic.spellFamily.CURE })

    mob:setAutoAttackEnabled(false)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
