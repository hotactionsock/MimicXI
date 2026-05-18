-----------------------------------
-- Trust: Kupofried
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

    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)

    local function applyDedication(party)
        for _, member in pairs(party) do
            if member:getObjType() == xi.objType.PC and not member:hasStatusEffect(xi.effect.DEDICATION) then
                member:addStatusEffect(xi.effect.DEDICATION, { power = 20, duration = 0, origin = member, subPower = 32767 })
            end
        end
    end

    applyDedication(mob:getMaster():getPartyWithTrusts())

    mob:addListener('COMBAT_TICK', 'KUPOFRIED_CTICK', function(mobArg)
        applyDedication(mobArg:getMaster():getPartyWithTrusts())
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
    local party = mob:getMaster():getPartyWithTrusts()
    for _, member in pairs(party) do
        if member:getObjType() == xi.objType.PC then
            member:delStatusEffect(xi.effect.DEDICATION)
        end
    end
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
