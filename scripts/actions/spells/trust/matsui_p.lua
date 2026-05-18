-----------------------------------
-- Trust: Matsui-P
-- https://ffxiclopedia.fandom.com/wiki/Trust:_Matsui-P
-- https://www.bg-wiki.com/ffxi/Cipher:_Matsui-P
-- NIN/BLM: Maintains Utsusemi shadows; casts ninjutsu and BLM magic.
-- WS fires only with shadows up; opens Light/Darkness SCs for the master
-- (SPECIAL_MATSUI_P select), or random at 3000 TP if no SC opportunity.
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

    -- Utsusemi: recast immediately when shadows drop; picks highest available tier.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.UTSUSEMI })

    -- Stun: interrupt mob special moves.
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_MS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })

    -- NIN stances and combat buffs.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.INNIN         }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.INNIN          })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SANGE         }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SANGE          })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.FUTAE         }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.FUTAE          })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL}, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL })

    -- Magic burst: match the open skillchain's element.
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })

    -- Ninjutsu San rotation (one per element, each on its own 60s timer).
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KATON_SAN  }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HYOTON_SAN }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HUTON_SAN  }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.DOTON_SAN  }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.RAITON_SAN }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SUITON_SAN }, 60)

    -- Burn (fire damage over time, 60s between casts).
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.BURN }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BURN }, 60)

    -- Migawari: shadow-substitute (120s cooldown for the spell recast).
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MIGAWARI }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.MIGAWARI_ICHI }, 120)

    -- Utility ninjutsu buffs (long personal cooldowns to avoid spam).
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.MYOSHU_ICHI }, 180)
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.KAKKA_ICHI  }, 180)
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.YURIN_ICHI  }, 180)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.AISHA_ICHI  }, 120)

    -- Mana Wall: converts magic damage to MP (BLM defensive JA).
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MANA_WALL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MANA_WALL })

    -- Aspir: drain MP when low.
    mob:addGambit(ai.t.TARGET, { ai.c.MPP_LT, 50 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ASPIR })

    -- TP: opens Light/Darkness SCs for master (shadow-gated); fires random at 3000 TP.
    mob:setTrustTPSkillSettings(ai.tp.OPENER_AND_CLOSER_UNTIL_TP, ai.s.SPECIAL_MATSUI_P, 3000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
