-----------------------------------
-- Trust: Abenzio
-----------------------------------
-- Melee: MNK/WAR traits (Double Attack, Kick Attacks), HP+20%
-- TP skills: Blank Gaze (conal paralysis), Antiphase (AoE silence),
--            Uppercut, Blow (damage + stun) — random, no skillchain.
-- Summoning/dismiss/death text gated behind mandragora costume gear.
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

local isWearingMandragoraGear = function(player)
    local wearingHead = player:getEquipID(xi.slot.HEAD) == 26705 or player:getEquipID(xi.slot.HEAD) == 26706 -- Mandragora Masque / +1
    local wearingBody = player:getEquipID(xi.slot.BODY) == 27854 or player:getEquipID(xi.slot.BODY) == 27855 -- Mandragora Suit / +1
    return wearingHead and wearingBody
end

spellObject.onMobSpawn = function(mob)
    local master = mob:getMaster()
    if isWearingMandragoraGear(master) then
        xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
    end

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MELEE)

    -- HP+20% (Goobbue bulk)
    mob:addMod(xi.mod.HPP, 20)

    -- MNK/WAR passive traits
    mob:addMod(xi.mod.DOUBLE_ATTACK, 15)
    mob:addMod(xi.mod.KICK_ATTACK_RATE, 10)

    -- Random TP skill use, no skillchain targeting
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
end

spellObject.onMobDespawn = function(mob)
    local master = mob:getMaster()
    if isWearingMandragoraGear(master) then
        xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
    end
end

spellObject.onMobDeath = function(mob)
    local master = mob:getMaster()
    if isWearingMandragoraGear(master) then
        xi.trust.message(mob, xi.trust.messageOffset.DEATH)
    end
end

return spellObject
