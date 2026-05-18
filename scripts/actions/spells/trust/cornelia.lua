-----------------------------------
-- Trust: Cornelia
-----------------------------------
-- Aura: Haste +20%, Accuracy +30, Ranged Accuracy +30, Magic Accuracy +30
-- Applied to all PC party members while summoned; removed on despawn.
---@type TSpellTrust
local spellObject = {}

-- Keyed by mob ID so multiple simultaneous instances don't collide.
local buffedByMob = {}

local HASTE = 2000  -- 20% magic haste (units: 1/10000)
local ACC   = 30
local RACC  = 30
local MACC  = 30

local function applyBuff(member)
    member:addMod(xi.mod.HASTE_MAGIC, HASTE)
    member:addMod(xi.mod.ACC,         ACC)
    member:addMod(xi.mod.RACC,        RACC)
    member:addMod(xi.mod.MACC,        MACC)
end

local function removeBuff(member)
    member:delMod(xi.mod.HASTE_MAGIC, HASTE)
    member:delMod(xi.mod.ACC,         ACC)
    member:delMod(xi.mod.RACC,        RACC)
    member:delMod(xi.mod.MACC,        MACC)
end

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

    local mobId = mob:getID()
    buffedByMob[mobId] = {}

    local function syncAura(party)
        local current = {}
        for _, member in pairs(party) do
            if member:getObjType() == xi.objType.PC then
                local memberId = member:getID()
                current[memberId] = member
                if not buffedByMob[mobId][memberId] then
                    applyBuff(member)
                    buffedByMob[mobId][memberId] = member
                end
            end
        end
        -- Remove mods from members who left the party
        for memberId, member in pairs(buffedByMob[mobId]) do
            if not current[memberId] then
                removeBuff(member)
                buffedByMob[mobId][memberId] = nil
            end
        end
    end

    syncAura(mob:getMaster():getPartyWithTrusts())

    mob:addListener('COMBAT_TICK', 'CORNELIA_CTICK', function(mobArg)
        syncAura(mobArg:getMaster():getPartyWithTrusts())
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
    local mobId = mob:getID()
    if buffedByMob[mobId] then
        for _, member in pairs(buffedByMob[mobId]) do
            removeBuff(member)
        end
        buffedByMob[mobId] = nil
    end
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
