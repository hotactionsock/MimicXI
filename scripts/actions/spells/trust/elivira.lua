-----------------------------------
-- Trust: Elivira
-----------------------------------
-- RNG/WAR hybrid: melee when in range, ranged attacks regardless of position.
-- Holds position at engagement distance — neither advances nor retreats.
-- Abilities: Berserk (WAR), Barrage, Double Shot, Decoy Shot (RNG).
-- WS: Split Shot, Slug Shot, Heavy Shot, Coronach. ASAP at 1000 TP; closes SCs when available.
-- Store TP+30 passive. Coronach relic aftermath: enmity -10 (permanent mod approximation;
-- retail behavior is a temporary timed effect triggered per Coronach cast).
-- Note: per-weapon TP values (127 sword / 178 marksmanship) cannot be differentiated with
-- current mods; STORETP=30 reflects the stated Store TP+30 trait only.
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

    -- Holds position at engagement range; does not advance or retreat.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)

    -- Store TP+30 passive trait.
    mob:addMod(xi.mod.STORETP, 30)

    -- Coronach relic aftermath: enmity -10.
    mob:addMod(xi.mod.ENMITY, -10)

    -- WAR ability: Berserk (ATK up)
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BERSERK },     { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })

    -- RNG abilities
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BARRAGE },     { ai.r.JA, ai.s.SPECIFIC, xi.ja.BARRAGE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DOUBLE_SHOT }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DOUBLE_SHOT })
    mob:addGambit(ai.t.SELF, { ai.c.HAS_TOP_ENMITY, 0 },                { ai.r.JA, ai.s.SPECIFIC, xi.ja.DECOY_SHOT })

    -- Ranged attack regardless of position; melee auto-attack also fires when in range.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 })

    -- Uses TP immediately at 1000; RANDOM selection closes skillchains when available.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
