-----------------------------------
-- Trust: Aldo
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.ALDO_UC)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK     })
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRICK_ATTACK     })
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ASSASSINS_CHARGE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEINT            })

    mob:addGambit(ai.t.TARGET, { ai.c.TP_GTE, 1000 }, { ai.r.WS, ai.s.SPECIFIC, 25 }) -- Evisceration

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
