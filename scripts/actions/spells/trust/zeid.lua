-----------------------------------
-- Trust: Zeid
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ZEID_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Interrupt incoming weaponskills and spells
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_WS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_MS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_JA, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.CASTING_MA,  0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })

    -- Dark arts
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.ENDARK  }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ENDARK })
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS,     0               }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SOULEATER    })
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS,     0               }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.LAST_RESORT  })

    -- Drain TP and HP from enemy
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ABSORB_TP }, 30)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DRAIN     }, 30)

    mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.RANDOM, 2000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
