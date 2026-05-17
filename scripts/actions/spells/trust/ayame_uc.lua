-----------------------------------
-- Trust: Ayame UC
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.AYAME)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Switch to Seigan+Third Eye when holding enmity; Hasso when not
    mob:addGambit(ai.t.SELF, { { ai.c.HAS_TOP_ENMITY, 0     }, { ai.c.NOT_STATUS, xi.effect.SEIGAN } }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SEIGAN    })
    mob:addGambit(ai.t.SELF, {   ai.c.HAS_TOP_ENMITY, 0                                               }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.THIRD_EYE })
    mob:addGambit(ai.t.SELF, { { ai.c.NOT_STATUS, xi.effect.HASSO }, { ai.c.NOT_HAS_TOP_ENMITY, 0 }  }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.HASSO     })
    mob:addGambit(ai.t.SELF, {   ai.c.TP_LT, 1000                                                     }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MEDITATE   })
    mob:addGambit(ai.t.SELF, {   ai.c.ALWAYS, 0                                                       }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENGIKORI  })

    mob:setTrustTPSkillSettings(ai.tp.OPENER, ai.s.SPECIAL_AYAME)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
