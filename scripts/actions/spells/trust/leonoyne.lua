-----------------------------------
-- Trust: Leonoyne
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

    -- DRK abilities
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS,     0                    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.LAST_RESORT  })
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS,     0                    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SOULEATER    })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS,     0                    }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WEAPON_BASH  })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.ICE_SPIKES }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ICE_SPIKES })

    -- Ice magic — burst on available SC, then sustained single-target
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS,       0 }, { ai.r.MA, ai.s.SPECIFIC,   xi.magic.spell.BLIZZARD_IV })

    -- Self-cure when critically wounded
    mob:addGambit(ai.t.SELF,   { ai.c.HPP_LT,     30 }, { ai.r.MA, ai.s.SPECIFIC,   xi.magic.spell.CURE_IV })

    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 104 }) -- Spiral Hell

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
