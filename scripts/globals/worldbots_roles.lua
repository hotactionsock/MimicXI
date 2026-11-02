-----------------------------------
-- xi.worldbots.roles - what each party member does for the party (Phase 4b).
--
-- Roles are designated when a party forms (worldbots_party.lua):
--   tank    - holds the mob: Provoke at the start of a fight and whenever the
--             mob turns on someone else, Flash as a back-up
--   healer  - triage: cures whoever is lowest (the tank first on ties), keeps
--             Regen on a hurt tank, puts Protect/Shell on members between fights
--   support - Haste on the tank and melee, Refresh on MP users; cures in an
--             emergency if it can
--   damage  - controls enmity: while the mob is on it (and the party has a
--             living tank) it holds back weapon skills, nukes and abilities
-- Everyone still looks after themselves first (worldbots_magic urgent cures,
-- shadows). Solo bots have no role and skip all of this.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.roles = xi.worldbots.roles or {}

local roles = xi.worldbots.roles

local HEAL_IN_FIGHT_HPP     = 70  -- healer cures party members below this in a fight
local HEAL_BETWEEN_HPP      = 85  -- ...and below this between fights
local EMERGENCY_HPP         = 40  -- support/anyone with Cure steps in below this
local TANK_REGEN_HPP        = 85
local PROVOKE_OPEN_SEC      = 4   -- tank provokes within this long of engaging
local ROLE_RANGE_YALMS      = 20  -- members further than this are out of reach

-- Built on first use (enum load order).
local PROVOKE = nil

local function provokeId()
    PROVOKE = PROVOKE or (xi.jobAbility and xi.jobAbility.PROVOKE) or 35
    return PROVOKE
end

-- Party members in this zone and within reach, as entities, with their role.
local function nearbyMembers(bot, charId, record)
    local result = {}
    local engine = GetBotParty(charId) or {}

    for _, m in ipairs(engine) do
        if not m.dead and m.zoneId == bot:getZoneID() then
            local dx, dz = m.x - bot:getXPos(), m.z - bot:getZPos()
            if math.sqrt(dx * dx + dz * dz) <= ROLE_RANGE_YALMS then
                local entity = GetPlayerByID(m.charId)
                if entity then
                    table.insert(result, { entity = entity, role = record.roles[m.charId] or 'damage', hpp = m.hpp, mpp = m.mpp })
                end
            end
        end
    end

    return result
end

-- The member most in need of a cure below thresholdHpp (tank first on ties).
local function neediest(members, thresholdHpp)
    local best
    for _, m in ipairs(members) do
        if m.hpp < thresholdHpp then
            if
                best == nil or
                m.hpp < best.hpp or
                (m.hpp == best.hpp and m.role == 'tank')
            then
                best = m
            end
        end
    end

    return best
end

local function hasLivingTank(members, charId)
    for _, m in ipairs(members) do
        if m.role == 'tank' and m.entity:getID() ~= charId then
            return true
        end
    end

    return false
end

-- Who the bot's current target is attacking (nil if nothing).
local function mobTargetId(bot)
    local mob = bot:getTarget()
    if mob == nil or mob:isDead() then
        return nil
    end

    local victim = mob:getTarget()
    return victim and victim:getID() or nil
end

local function abilityReady(charId, abilityId)
    for _, ability in ipairs(GetBotAbilities(charId)) do
        if ability.id == abilityId then
            return ability.ready
        end
    end

    return false
end

-----------------------------------
-- Role behaviours
-----------------------------------

local function tankAct(bot, charId, state, now, members)
    local victim     = mobTargetId(bot)
    local engagedFor = now - (state.engagedAt or now)
    local lostHate   = victim ~= nil and victim ~= charId

    if lostHate or engagedFor <= PROVOKE_OPEN_SEC then
        if abilityReady(charId, provokeId()) and UseBotAbility(charId, provokeId()) then
            return true
        end

        if
            lostHate and
            xi.worldbots.magic.castFamily(bot, charId, state, now, 'flash')
        then
            return true
        end
    end

    return false
end

local function healerAct(bot, charId, state, now, members, fighting)
    local target = neediest(members, fighting and HEAL_IN_FIGHT_HPP or HEAL_BETWEEN_HPP)
    if
        target and
        xi.worldbots.magic.cureMember(bot, charId, state, now, target.entity)
    then
        return true
    end

    if fighting then
        -- Regen on a tank that's taking damage.
        for _, m in ipairs(members) do
            if m.role == 'tank' and m.hpp < TANK_REGEN_HPP then
                if xi.worldbots.magic.buffMember(bot, charId, state, now, m.entity, 'regen') then
                    return true
                end
            end
        end

        return false
    end

    -- Between fights: Protect and Shell on everyone who lacks them.
    for _, name in ipairs({ 'protect', 'shell' }) do
        for _, m in ipairs(members) do
            if xi.worldbots.magic.buffMember(bot, charId, state, now, m.entity, name) then
                return true
            end
        end
    end

    return false
end

local function supportAct(bot, charId, state, now, members)
    -- Someone about to die: cure first if it can.
    local critical = neediest(members, EMERGENCY_HPP)
    if
        critical and
        xi.worldbots.magic.cureMember(bot, charId, state, now, critical.entity)
    then
        return true
    end

    -- Haste on the front line: tank first, then damage dealers.
    for _, wanted in ipairs({ 'tank', 'damage' }) do
        for _, m in ipairs(members) do
            if
                m.role == wanted and
                xi.worldbots.magic.buffMember(bot, charId, state, now, m.entity, 'haste')
            then
                return true
            end
        end
    end

    -- Refresh on MP users: healer, support, then anyone with MP.
    for _, wanted in ipairs({ 'healer', 'support', 'damage', 'tank' }) do
        for _, m in ipairs(members) do
            if
                m.role == wanted and
                m.entity:getMaxMP() > 0 and
                xi.worldbots.magic.buffMember(bot, charId, state, now, m.entity, 'refresh')
            then
                return true
            end
        end
    end

    return false
end

-- Damage dealer with the mob on it: hold back so the tank can take it back.
local function damageHold(bot, charId, members)
    return mobTargetId(bot) == charId and hasLivingTank(members, charId)
end

-----------------------------------
-- Entry point
-----------------------------------

-- Runs the bot's party role. fighting = in a fight (from combatActions) or
-- between fights. True = it acted (or, for a damage dealer holding back,
-- that nothing else should happen this check).
function roles.act(bot, charId, state, now, fighting)
    local record = xi.worldbots.party.get(bot, charId, now)
    if record == nil then
        return false
    end

    local role    = record.roles[charId] or 'damage'
    local members = nearbyMembers(bot, charId, record)

    -- Anyone who can cure steps in for a member about to die, whatever their role.
    if
        role ~= 'healer' and
        role ~= 'support' and
        xi.worldbots.magic.knows(state, 'cure')
    then
        local critical = neediest(members, EMERGENCY_HPP)
        if
            critical and
            critical.entity:getID() ~= charId and
            xi.worldbots.magic.cureMember(bot, charId, state, now, critical.entity)
        then
            return true
        end
    end

    if role == 'tank' then
        return fighting and tankAct(bot, charId, state, now, members)
    elseif role == 'healer' then
        return healerAct(bot, charId, state, now, members, fighting)
    elseif role == 'support' then
        return supportAct(bot, charId, state, now, members)
    elseif role == 'damage' then
        return fighting and damageHold(bot, charId, members)
    end

    return false
end

return roles
