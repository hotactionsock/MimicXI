-----------------------------------
-- xi.worldbots.party - bot parties (Phase 4).
--
-- Forming: from level 5 (PARTY_MIN_LEVEL) a bot that picks a new levelling goal often also
-- puts itself on a "seeking party" list (it keeps levelling solo while it
-- waits). Every few seconds the matchmaker groups seekers of similar level
-- (within PARTY_LEVEL_SPREAD) who are a few zone hops apart into a balanced
-- party - a tank, a healer, a support job, then damage - and forms a real
-- engine party (FormBotParty). If the jobs available are lopsided it forms the
-- party anyway and designates roles: the sturdiest melee tanks, the best
-- available healer heals (see designateRoles). Bots never invite players.
--
-- Playing: the leader picks a camp suited to the party (tougher prey: Decent
-- Challenge..Tough for 3-4, Even Match..Very Tough for 5-6) and is the only
-- one who pulls - and only when everyone's there and rested. Members follow
-- the leader, travel after it across zones, assist on its target and rest
-- between fights. Roles drive what each member does in a fight (Phase 4b).
--
-- Breaking up: after a session (PARTY_SESSION_*), when levels drift too far
-- apart, or when a member needs a job change. A party left with one member is
-- disbanded by the engine.
--
-- State: parties[leaderId] = { leaderId, members = { charId... },
--   roles = { [charId] = role }, level, size, zoneId, formedAt, untilTime }
-- (Lua-side only: a reload forgets roles, and parties then carry on with
-- roles re-designated from their jobs on first use.)
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.party = xi.worldbots.party or {}

local party = xi.worldbots.party

local PARTY_MIN_LEVEL      = 5       -- below this, bots solo; from here they can team up for harder early camps
local SEEK_CHANCE          = 0.6     -- on picking a levelling goal, chance to also seek a party
local SEEK_TIMEOUT_SEC     = 15 * 60 -- give up seeking after this
local PARTY_LEVEL_SPREAD   = 4       -- max level gap within a party
local PARTY_MAX_HOPS       = 4       -- seekers this many zone hops apart can be grouped
local PARTY_MIN_SIZE       = 3
local PARTY_MAX_SIZE       = 6
local PARTY_SESSION_MIN    = 60 * 60
local PARTY_SESSION_MAX    = 120 * 60
local MATCH_INTERVAL_SEC   = 10
local CHECK_INTERVAL_SEC   = 60      -- leader/member housekeeping
local FOLLOW_NEAR_YALMS    = 6       -- members idle within this of the leader
local FOLLOW_FAR_YALMS     = 12      -- ...and walk back once further than this
local ASSIST_RANGE_YALMS   = 30
local READY_RANGE_YALMS    = 20      -- everyone this close to the leader before a pull
local READY_HPP            = 70
local READY_MPP            = 50      -- for members who use MP
local READY_WAIT_MAX_SEC   = 3 * 60  -- a leader waits this long for stragglers, then pulls anyway
local MEMBER_REST_HPP      = 50
local MEMBER_REST_MPP      = 40
local PARTY_GOAL_HOPS      = 6

-- What each main job brings (the design doc's job archetypes).
local JOB_ROLE =
{
    PLD = 'tank', NIN = 'tank', RUN = 'tank',
    WHM = 'healer',
    RDM = 'support', BRD = 'support', COR = 'support', GEO = 'support',
    BLM = 'damage', SCH = 'damage', SMN = 'damage',
}

-- Slots a party tries to fill, in order. Anything else is damage.
local COMPOSITION = { 'tank', 'healer', 'support', 'damage', 'damage', 'damage' }

-- Stand-ins when a party lacks a role, best first.
local TANK_STANDINS   = { 'WAR', 'NIN', 'RUN', 'PLD', 'DRK', 'SAM', 'MNK', 'DRG' }
local HEALER_STANDINS = { 'RDM', 'SCH', 'PLD', 'DNC', 'BRD' }

local parties  = {} -- leaderId -> party record
local memberOf = {} -- charId -> leaderId
local seekers  = {} -- charId -> { charId, level, job, zoneId, since }
local nextMatchAt = 0

local function jobName(job)
    for name, id in pairs(xi.job) do
        if id == job then
            return name
        end
    end

    return nil
end

local function roleOfJob(job)
    return JOB_ROLE[jobName(job) or ''] or 'damage'
end

local function hopsBetween(fromZone, toZone)
    if fromZone == toZone then
        return 0
    end

    local hop = GetBotRouteNextLine(fromZone, toZone)
    return hop and hop.hops or 99
end

-----------------------------------
-- Roles
-----------------------------------

-- members = { { charId, job }... } -> { [charId] = role }. Fills tank and
-- healer with stand-ins when no natural one is present, so every party has
-- someone holding hate and someone curing if at all possible.
local function designateRoles(members)
    local roles = {}
    local have  = {}

    for _, m in ipairs(members) do
        roles[m.charId] = roleOfJob(m.job)
        have[roles[m.charId]] = (have[roles[m.charId]] or 0) + 1
    end

    local function standIn(role, preferred)
        if have[role] then
            return
        end

        for _, name in ipairs(preferred) do
            for _, m in ipairs(members) do
                local current = roles[m.charId]
                -- Don't strip the only tank/healer to make another.
                if jobName(m.job) == name and current ~= 'tank' and current ~= 'healer' then
                    roles[m.charId] = role
                    have[role] = 1
                    return
                end
            end
        end
    end

    standIn('tank', TANK_STANDINS)
    standIn('healer', HEALER_STANDINS)

    return roles
end

-----------------------------------
-- Registry helpers
-----------------------------------

local function partyOf(charId)
    local leaderId = memberOf[charId] or (parties[charId] and charId)
    return leaderId and parties[leaderId] or nil
end

local function forgetParty(record)
    for _, id in ipairs(record.members) do
        memberOf[id] = nil
    end

    memberOf[record.leaderId] = nil
    parties[record.leaderId]  = nil
end

-- Rebuilds a record from the engine party (after a script reload, or a party
-- the matchmaker didn't make - e.g. a GM-formed one).
local function adoptEngineParty(charId, now)
    local engine = GetBotParty(charId)
    if engine == nil then
        return nil
    end

    local leaderId, members, list, minLevel = nil, {}, {}, 99
    for _, m in ipairs(engine) do
        if m.isLeader then
            leaderId = m.charId
        end

        table.insert(members, m.charId)
        table.insert(list, { charId = m.charId, job = m.mainJob })
        minLevel = math.min(minLevel, m.level)
    end

    if leaderId == nil then
        return nil
    end

    local record =
    {
        leaderId  = leaderId,
        members   = members,
        roles     = designateRoles(list),
        level     = minLevel,
        size      = #members,
        formedAt  = now,
        untilTime = now + math.random(PARTY_SESSION_MIN, PARTY_SESSION_MAX),
    }

    parties[leaderId] = record
    for _, id in ipairs(members) do
        if id ~= leaderId then
            memberOf[id] = leaderId
        end
    end

    return record
end

-- The bot's party record, or nil if it isn't in a party.
function party.get(bot, charId, now)
    if bot:getPartySize() <= 1 then
        local stale = partyOf(charId)
        if stale then
            forgetParty(stale)
        end

        return nil
    end

    return partyOf(charId) or adoptEngineParty(charId, now)
end

-- The bot's party role ('tank', 'healer', 'support', 'damage'), or nil solo.
function party.role(bot, charId, now)
    local record = party.get(bot, charId, now)
    return record and record.roles[charId] or nil
end

-- How many fight together (1 solo) - widens prey (IsBotPrey).
function party.huntSize(bot)
    return math.max(1, bot:getPartySize())
end

-- Level used for prey and camps: the party's lowest, so nobody's out of their depth.
function party.huntLevel(bot, charId, now)
    local record = party.get(bot, charId, now)
    return record and record.level or bot:getMainLvl()
end

function party.isLeader(bot, charId, now)
    local record = party.get(bot, charId, now)
    return record ~= nil and record.leaderId == charId
end

-----------------------------------
-- Seeking and matchmaking
-----------------------------------

-- Called when a bot picks a new levelling goal: maybe put it on the list.
function party.maybeSeek(bot, charId, now)
    if
        bot:getPartySize() > 1 or
        seekers[charId] or
        bot:getMainLvl() < PARTY_MIN_LEVEL
    then
        return
    end

    if math.randomFloat(0, 1) < SEEK_CHANCE then
        seekers[charId] =
        {
            charId = charId,
            level  = bot:getMainLvl(),
            job    = bot:getMainJob(),
            zoneId = bot:getZoneID(),
            since  = now,
        }
    end
end

function party.stopSeeking(charId)
    seekers[charId] = nil
end

-- Chooses up to PARTY_MAX_SIZE seekers around an anchor, filling COMPOSITION
-- slots first, then anyone left. Returns the chosen list.
local function compose(anchor, candidates)
    local chosen, used, need = { anchor }, { [anchor.charId] = true }, {}

    for _, role in ipairs(COMPOSITION) do
        need[role] = (need[role] or 0) + 1
    end

    need[roleOfJob(anchor.job)] = (need[roleOfJob(anchor.job)] or 1) - 1

    -- First pass: fill the roles the party wants.
    for _, c in ipairs(candidates) do
        if #chosen >= PARTY_MAX_SIZE then
            break
        end

        local role = roleOfJob(c.job)
        if not used[c.charId] and (need[role] or 0) > 0 then
            table.insert(chosen, c)
            used[c.charId] = true
            need[role] = need[role] - 1
        end
    end

    -- Second pass: lopsided is better than empty - take whoever's left.
    for _, c in ipairs(candidates) do
        if #chosen >= PARTY_MAX_SIZE then
            break
        end

        if not used[c.charId] then
            table.insert(chosen, c)
            used[c.charId] = true
        end
    end

    return chosen
end

-- Forms a party from chosen seekers. The leader pulls, so it's the tank (a
-- designated one if need be); otherwise the highest level, longest wait on ties.
local function formParty(chosen, now, keepFirstAsLeader)
    if not keepFirstAsLeader then
        local list = {}
        for _, c in ipairs(chosen) do
            table.insert(list, { charId = c.charId, job = c.job })
        end

        local planned = designateRoles(list)
        table.sort(chosen, function(a, b)
            local aTank, bTank = planned[a.charId] == 'tank', planned[b.charId] == 'tank'
            if aTank ~= bTank then
                return aTank
            end

            if a.level ~= b.level then
                return a.level > b.level
            end

            return a.since < b.since
        end)
    end

    local leader    = chosen[1]
    local memberIds = {}
    local minLevel  = leader.level
    for i = 2, #chosen do
        table.insert(memberIds, chosen[i].charId)
        minLevel = math.min(minLevel, chosen[i].level)
    end

    local joined = FormBotParty(leader.charId, memberIds)
    if joined == 0 then
        return nil
    end

    -- Only those who actually joined (someone may have despawned meanwhile).
    local engine = GetBotParty(leader.charId) or {}
    local inParty = {}
    for _, m in ipairs(engine) do
        inParty[m.charId] = true
    end

    local members, list = {}, {}
    for _, c in ipairs(chosen) do
        seekers[c.charId] = nil
        if inParty[c.charId] then
            table.insert(members, c.charId)
            table.insert(list, { charId = c.charId, job = c.job })
        end
    end

    local record =
    {
        leaderId  = leader.charId,
        members   = members,
        roles     = designateRoles(list),
        level     = minLevel,
        size      = #members,
        formedAt  = now,
        untilTime = now + math.random(PARTY_SESSION_MIN, PARTY_SESSION_MAX),
    }

    parties[leader.charId] = record
    for _, id in ipairs(members) do
        if id ~= leader.charId then
            memberOf[id] = leader.charId
        end
    end

    -- Activity log: who joined whose party, as what.
    local leaderBot = GetPlayerByID(leader.charId)
    for _, id in ipairs(members) do
        local member = GetPlayerByID(id)
        if member and leaderBot then
            if id == leader.charId then
                xi.worldbots.log.formedParty(member, #members)
            else
                xi.worldbots.log.joinedParty(member, leaderBot:getName(), record.roles[id] or 'damage', #members)
                xi.worldbots.social.onJoinedParty(member, id, xi.worldbots.internal.getState(id, now), now, leader.charId)
            end
        end
    end

    return record
end

-- Picks the party's camp from the leader's zone, then points everyone at it.
local function sendToCamp(record, now)
    local leaderBot = GetPlayerByID(record.leaderId)
    if leaderBot == nil then
        return
    end

    local zones = GetBotLevelingZones(record.level, leaderBot:getZoneID(), PARTY_GOAL_HOPS, record.size)
    local camp  = zones[1] and zones[1].zoneId or leaderBot:getZoneID()
    record.zoneId = camp

    local api = xi.worldbots.internal
    for _, id in ipairs(record.members) do
        local state = api.getState(id, now)
        if id == record.leaderId then
            api.setGoal(id, state, 'level', camp)
        else
            api.setGoal(id, state, 'party', camp)
        end
    end
end

-- Runs from any awake zone's tick (throttled): groups seekers into parties.
function party.matchmake(now)
    if now < nextMatchAt then
        return
    end

    nextMatchAt = now + MATCH_INTERVAL_SEC

    -- Drop stale seekers (despawned, already partied, timed out).
    local list = {}
    for id, s in pairs(seekers) do
        local bot = GetPlayerByID(id)
        if
            bot == nil or
            bot:getPartySize() > 1 or
            now >= s.since + SEEK_TIMEOUT_SEC
        then
            seekers[id] = nil
        else
            s.level  = bot:getMainLvl()
            s.job    = bot:getMainJob()
            s.zoneId = bot:getZoneID()
            table.insert(list, s)
        end
    end

    -- Longest-waiting first, as the anchor of each attempt.
    table.sort(list, function(a, b)
        return a.since < b.since
    end)

    for _, anchor in ipairs(list) do
        if seekers[anchor.charId] then
            local candidates = {}
            for _, c in ipairs(list) do
                if
                    c.charId ~= anchor.charId and
                    seekers[c.charId] and
                    math.abs(c.level - anchor.level) <= PARTY_LEVEL_SPREAD and
                    hopsBetween(anchor.zoneId, c.zoneId) <= PARTY_MAX_HOPS
                then
                    table.insert(candidates, c)
                end
            end

            if #candidates + 1 >= PARTY_MIN_SIZE then
                local record = formParty(compose(anchor, candidates), now)
                if record then
                    sendToCamp(record, now)
                end
            end
        end
    end
end

-- GM: force a party of these bots (first = leader). Returns the record or nil.
function party.forceForm(charIds, now)
    local chosen = {}
    for i, id in ipairs(charIds) do
        local bot = GetPlayerByID(id)
        if bot then
            table.insert(chosen, { charId = id, level = bot:getMainLvl(), job = bot:getMainJob(), zoneId = bot:getZoneID(), since = now - (100 - i) })
        end
    end

    if #chosen < 2 then
        return nil
    end

    -- Keep the GM's choice of leader.
    local record = formParty(chosen, now, true)
    if record then
        sendToCamp(record, now)
    end

    return record
end

-- Breaks the party up and sends everyone back to their own goals.
function party.disband(record, now)
    local api     = xi.worldbots.internal
    local minutes = math.floor((now - record.formedAt) / 60)
    for _, id in ipairs(record.members) do
        local member = GetPlayerByID(id)
        if member and member:getPartySize() > 1 then
            xi.worldbots.log.leftParty(member, 'the party broke up', minutes)
            xi.worldbots.social.onLeftParty(member, id, api.getState(id, now), now)
        end

        LeaveBotParty(id)
        local state = api.getState(id, now)
        if state.goal and (state.goal.kind == 'party' or state.goal.kind == 'level') then
            state.goal = nil -- pick a fresh (solo) goal
        end
    end

    forgetParty(record)
end

-----------------------------------
-- Playing as a party
-----------------------------------

-- Is everyone here, alive and rested enough for the leader to pull?
local function everyoneReady(bot, charId, record)
    local engine = GetBotParty(charId)
    if engine == nil then
        return true
    end

    local here = { x = bot:getXPos(), z = bot:getZPos() }
    for _, m in ipairs(engine) do
        if m.charId ~= charId then
            if m.dead or m.zoneId ~= bot:getZoneID() then
                return false
            end

            local dx, dz = m.x - here.x, m.z - here.z
            if math.sqrt(dx * dx + dz * dz) > READY_RANGE_YALMS or m.hpp < READY_HPP then
                return false
            end

            local role = record.roles[m.charId]
            if (role == 'healer' or role == 'support') and m.mpp < READY_MPP then
                return false
            end
        end
    end

    return true
end

-- The leader's pull check. A straggler (stuck, lost, or dead far away) only
-- holds the party up for READY_WAIT_MAX_SEC.
function party.readyToPull(bot, charId, now)
    local record = party.get(bot, charId, now)
    if record == nil or record.leaderId ~= charId then
        return true
    end

    if everyoneReady(bot, charId, record) then
        record.waitSince = nil
        return true
    end

    record.waitSince = record.waitSince or now
    if now >= record.waitSince + READY_WAIT_MAX_SEC then
        record.waitSince = nil
        return true
    end

    return false
end

-- Leader housekeeping: session over, or levels drifted too far apart.
local function leaderCheck(record, now)
    if now >= record.untilTime then
        party.disband(record, now)
        return
    end

    local engine = GetBotParty(record.leaderId)
    if engine == nil then
        forgetParty(record)
        return
    end

    local low, high = 99, 0
    for _, m in ipairs(engine) do
        low  = math.min(low, m.level)
        high = math.max(high, m.level)
    end

    record.size = #engine

    -- Someone out-levelled the rest: re-aim at the new lowest level, or end it.
    if high - low > PARTY_LEVEL_SPREAD + 2 then
        party.disband(record, now)
    elseif low ~= record.level then
        record.level = low
    end
end

-- Points the bot's goal at the leader's zone (if it isn't already).
local function followGoal(charId, state, zoneId)
    local goal = state.goal
    if
        goal == nil or
        goal.kind ~= 'party' or
        goal.zoneId ~= zoneId
    then
        xi.worldbots.internal.setGoal(charId, state, 'party', zoneId)
    end
end

-- Member step, run each tick for a bot in a party that isn't its leader.
-- True = it handled the bot this tick (following, assisting or resting);
-- false = let the normal AI run (e.g. travel after the leader).
local function memberStep(bot, charId, state, now, moving, record)
    local engine = GetBotParty(charId)
    if engine == nil then
        return false
    end

    local leader
    for _, m in ipairs(engine) do
        if m.isLeader then
            leader = m
        end
    end

    if leader == nil then
        return false
    end

    -- Wants a job change: leave the party first (it then plans as normal) -
    -- unless a player hired it: it stays until the player lets it go.
    if
        not xi.worldbots.hire.isHired(state) and
        now >= (state.nextPartyCheckAt or 0)
    then
        state.nextPartyCheckAt = now + CHECK_INTERVAL_SEC
        if xi.worldbots.jobs.plan(bot, charId, state) then
            xi.worldbots.log.leftParty(bot, 'to change jobs', math.floor((now - record.formedAt) / 60))
            LeaveBotParty(charId)
            memberOf[charId] = nil
            state.goal = nil
            return false
        end
    end

    -- Leader in another zone: travel there (the normal goal routing does it).
    if leader.zoneId ~= bot:getZoneID() then
        followGoal(charId, state, leader.zoneId)

        return false
    end

    -- Same zone: the 'party' goal is satisfied here.
    followGoal(charId, state, leader.zoneId)

    state.goal.settled   = true
    state.goal.untilTime = now + 24 * 60 * 60 -- the party decides when it ends
    state.travel, state.walk = nil, nil

    -- Assist: fight what the leader fights - or, if the leader isn't fighting
    -- (say, a mage player standing back), what another member in this zone is
    -- fighting, players first.
    local fighter = (leader.engaged and leader.targetId ~= 0) and leader or nil
    if fighter == nil then
        for _, m in ipairs(engine) do
            if
                m.charId ~= charId and
                m.engaged and
                m.targetId ~= 0 and
                m.zoneId == bot:getZoneID() and
                (fighter == nil or (fighter.isBot and not m.isBot))
            then
                fighter = m
            end
        end
    end

    if fighter then
        if state.healing then
            SetBotHealing(charId, false)
            state.healing = false
        end

        local dx, dz = fighter.x - bot:getXPos(), fighter.z - bot:getZPos()
        if math.sqrt(dx * dx + dz * dz) <= ASSIST_RANGE_YALMS then
            local target = bot:getTarget()
            if
                not bot:isEngaged() or
                target == nil or
                target:getID() ~= fighter.targetId
            then
                EngageBotTarget(charId, fighter.targetId)
            end
        else
            WalkBotTo(charId, fighter.x, fighter.y, fighter.z)
        end

        return true
    end

    -- Between fights: rest when low, otherwise stay near the leader.
    if not bot:isEngaged() then
        if
            not state.healing and
            not moving and
            (bot:getHPP() < MEMBER_REST_HPP or (bot:getMaxMP() > 0 and bot:getMPP() < MEMBER_REST_MPP))
        then
            SetBotHealing(charId, true)
            state.healing = true
            return true
        end

        if state.healing then
            return true -- combatStep's resting branch handles getting up
        end

        -- Its role between fights: cures, party buffs (worldbots_roles.lua).
        if IsBotCasting(charId) then
            return true
        end

        if not moving and now >= (state.nextRoleActAt or 0) then
            state.nextRoleActAt = now + 1
            xi.worldbots.gear.base(bot, charId, state)
            if
                xi.worldbots.magic.idle(bot, charId, state, now) or
                xi.worldbots.roles.act(bot, charId, state, now, false)
            then
                return true
            end
        end

        local dx, dz = leader.x - bot:getXPos(), leader.z - bot:getZPos()
        local dist   = math.sqrt(dx * dx + dz * dz)
        if dist > FOLLOW_FAR_YALMS then
            local zone   = bot:getZone()
            local target = { x = leader.x, y = leader.y, z = leader.z }
            local spot   = zone and zone:getRandomNavmeshPoint(target, FOLLOW_NEAR_YALMS / 2) or target
            WalkBotTo(charId, spot.x, spot.y, spot.z)
        end

        return true
    end

    return false
end

-- Per-tick entry point from xi.worldbots.onZoneTick (after combat handling).
-- True = the party logic handled the bot this tick.
function party.step(bot, charId, state, now, moving)
    local record = party.get(bot, charId, now)
    if record == nil then
        return false
    end

    if record.leaderId == charId then
        if now >= (state.nextPartyCheckAt or 0) then
            state.nextPartyCheckAt = now + CHECK_INTERVAL_SEC
            leaderCheck(record, now)
        end

        return false -- the leader runs the normal hunting AI (party-aware)
    end

    return memberStep(bot, charId, state, now, moving, record)
end

-- One-line summary for !worldbot party.
function party.describe(charId, now)
    local bot = GetPlayerByID(charId)
    if bot == nil then
        return nil
    end

    local record = party.get(bot, charId, now)
    if record == nil then
        return seekers[charId] and 'not in a party - seeking one' or 'not in a party'
    end

    local parts = {}
    for _, id in ipairs(record.members) do
        local member = GetPlayerByID(id)
        table.insert(parts, string.format('%s%s (%s %d, %s)',
            id == record.leaderId and '*' or '',
            member and member:getName() or tostring(id),
            member and (jobName(member:getMainJob()) or '?') or '?',
            member and member:getMainLvl() or 0,
            record.roles[id] or '?'))
    end

    return string.format('party of %d, camp zone %d, %d min left: %s',
        #record.members, record.zoneId or 0, math.max(0, math.floor((record.untilTime - now) / 60)), table.concat(parts, ', '))
end

return party
