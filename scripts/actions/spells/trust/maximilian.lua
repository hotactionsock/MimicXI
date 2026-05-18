-----------------------------------
-- Trust: Maximilian
-----------------------------------
-- THF/NIN melee. Dual wields swords (Fast Blade, Vorpal Blade, Swift Blade).
-- Passive traits: Treasure Hunter I, Dual Wield, Triple Attack.
-- SC priority: close open SCs → open when a PC reaches 1500 TP (ignores trusts) → fire at 2500 TP.
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

    -- Close SCs when available; open with player at 1500 TP (not trusts); fire at 2500 otherwise.
    mob:setTrustTPSkillSettings(ai.tp.OPENER_AND_CLOSER_UNTIL_TP, ai.s.RANDOM, 2500)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
