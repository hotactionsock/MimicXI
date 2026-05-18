-----------------------------------
-- Trust: Maximilian
-----------------------------------
-- THF/NIN melee. Dual wields swords (Fast Blade, Vorpal Blade, Swift Blade).
-- Passive traits: Treasure Hunter I, Dual Wield, Triple Attack.
-- SC opener: fires a random WS when the player reaches 1500 TP (not with trusts).
-- SC closer: closes with players/trusts when possible; otherwise fires at 2500 TP.
-- NOTE: No combined OPENER+CLOSER mode exists; using OPENER as primary behaviour.
--       CLOSER_UNTIL_TP (2500) can be substituted once a combined mode is available.
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

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)

    -- THF/NIN passive traits
    mob:addMod(xi.mod.TREASURE_HUNTER, 1)   -- TH I
    mob:addMod(xi.mod.DUAL_WIELD,      25)  -- NIN dual wield
    mob:addMod(xi.mod.TRIPLE_ATTACK,    5)  -- THF triple attack

    -- Open skillchains when the player hits 1500 TP; WS chosen at random.
    mob:setTrustTPSkillSettings(ai.tp.OPENER, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
