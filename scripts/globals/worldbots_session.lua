-----------------------------------
-- xi.worldbots.session - play sessions: bots log on, play for a while and log
-- off, like players do.
--
-- A session lasts SESSION_MIN_MIN..SESSION_MAX_MIN minutes (a bit longer in the
-- evening). When it's up, at a natural break (not hired, not fighting, not in
-- the middle of an errand or an NM camp), the bot:
--   * in a city with a Mog House     - walks to the Mog House and goes in
--   * out in the field               - usually heads home to its Mog House;
--                                      otherwise logs off where it stands,
--                                      after the usual half-minute /logout
-- A bot in a bot party leaves it first (a leader disbands it).
--
-- It then stays offline for OFFLINE_MIN_HOURS..OFFLINE_MAX_HOURS, nudged so
-- most logins land in the afternoon and evening rather than the small hours,
-- and comes back where it left off (botutils::UpdateBotLogins) - out of its
-- Mog House door, or where it stood in the field. While offline a bot is out
-- of the world entirely: no EXP, no gil, nothing.
--
-- map.WORLDBOTS_SESSIONS = false turns this off (bots play around the clock).
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.session = xi.worldbots.session or {}

local session = xi.worldbots.session

local loadedAt = GetSystemTime()

local SESSION_MIN_MIN    = 90
local SESSION_MAX_MIN    = 240
local EVENING_STRETCH    = 1.3      -- sessions starting in the evening run this much longer
local FIRST_SESSION_MIN  = 20       -- a server start spreads the first logoffs out from here (minutes)...
local OFFLINE_MIN_HOURS  = 2
local OFFLINE_MAX_HOURS  = 10
local QUIET_FROM_HOUR    = 2        -- logins in these (server local) hours are mostly pushed back...
local QUIET_TO_HOUR      = 9
local QUIET_PUSH_CHANCE  = 0.65
local PEAK_FROM_HOUR     = 17       -- ...to the afternoon / evening
local FIELD_GO_HOME      = 0.6      -- in the field: head home to the Mog House (else log off there)
local LOGOUT_WAIT_MIN    = 20       -- /logout countdown standing in the field
local LOGOUT_WAIT_MAX    = 30
local RETRY_SEC          = 2 * 60   -- not a good moment: look again this much later
local STARTUP_SPREAD_SEC = 10 * 60  -- ...for bots first seen this soon after the server starts

-- Goals a bot can drop to go and log off. Errands (selling, shopping, a job
-- change), NM camps and party trips get finished first.
local INTERRUPTIBLE =
{
    level = true,
    home  = true,
    stay  = true,
    zone  = true,
}

local function enabled()
    local map = xi.settings and xi.settings.map
    return map == nil or map.WORLDBOTS_SESSIONS ~= false
end

local function hourNow()
    return tonumber(os.date('%H'))
end

local function isEvening(hour)
    return hour >= 18 and hour <= 23
end

local function isQuiet(hour)
    return hour >= QUIET_FROM_HOUR and hour <= QUIET_TO_HOUR
end

-- How long the next session lasts, in seconds.
local function sessionLength()
    local minutes = math.random(SESSION_MIN_MIN, SESSION_MAX_MIN)
    if isEvening(hourNow()) then
        minutes = math.floor(minutes * EVENING_STRETCH)
    end

    return minutes * 60
end

-- How long to stay away, in seconds - mostly not logging back in at 4am.
local function offlineLength(now)
    local offline    = math.random(OFFLINE_MIN_HOURS * 3600, OFFLINE_MAX_HOURS * 3600)
    local loginHour  = tonumber(os.date('%H', now + offline))

    if isQuiet(loginHour) and math.randomFloat(0, 1) < QUIET_PUSH_CHANCE then
        local hoursToPeak = (PEAK_FROM_HOUR - loginHour) % 24
        offline = offline + (hoursToPeak + math.random(0, 4)) * 3600 + math.random(0, 3599)
    end

    return offline
end

-- Logs the bot off now. The entity is gone afterwards - don't touch it.
function session.logOff(bot, charId, where)
    local now = GetSystemTime()
    xi.worldbots.forget(charId) -- a fresh session (and state) when it's back
    LogOffBot(charId, offlineLength(now), where)
end

-- Is now a natural break to stop playing?
local function canStop(bot, state)
    if
        bot:isDead() or
        bot:isEngaged() or
        state.inCombat or
        state.lootUntil or
        xi.worldbots.hire.isHired(state)
    then
        return false
    end

    local goal = state.goal
    return goal == nil or INTERRUPTIBLE[goal.kind] == true
end

-- Leaves (or, as leader, disbands) a bot party before logging off.
local function leaveParty(bot, charId, now)
    if bot:getPartySize() <= 1 then
        return
    end

    local record = xi.worldbots.party.get(bot, charId, now)
    if record and record.leaderId == charId then
        xi.worldbots.party.disband(record, now)
    else
        LeaveBotParty(charId)
    end

    xi.worldbots.party.stopSeeking(charId)
end

-- Per tick (from xi.worldbots.onZoneTick), before anything else acts.
-- Returns true if the bot logged off (the entity is gone) or is busy logging
-- off (standing out the /logout countdown) - skip the rest of its tick.
function session.tick(bot, charId, state, now, zoneId, hasMogHouse)
    if not enabled() then
        return false
    end

    -- First sight (logged on): when this session ends. Just after a server
    -- start everyone "logs on" at once, so spread those first logoffs out.
    if state.sessionEndsAt == nil then
        local length = sessionLength()
        if now - loadedAt < STARTUP_SPREAD_SEC then
            length = math.random(FIRST_SESSION_MIN * 60, length)
        end

        state.sessionEndsAt = now + length
    end

    -- Standing out the /logout countdown in the field.
    local logout = state.logout
    if logout then
        if
            bot:isEngaged() or
            bot:isDead() or
            FindBotAttacker(charId) ~= nil
        then
            -- Interrupted (attacked): fight, then try again later.
            state.logout        = nil
            state.sessionEndsAt = now + RETRY_SEC
            return false
        end

        if now >= logout.at then
            session.logOff(bot, charId, 'in ' .. GetBotZoneName(zoneId))
            return true
        end

        return true
    end

    if now < state.sessionEndsAt or (state.goal and state.goal.kind == 'logoff') then
        return false
    end

    if not canStop(bot, state) then
        state.sessionEndsAt = now + RETRY_SEC
        return false
    end

    leaveParty(bot, charId, now)

    -- In town (or heading home anyway): the Mog House. Out in the field: home
    -- to the Mog House most of the time, otherwise log off right there.
    local target = nil
    if hasMogHouse then
        target = zoneId
    elseif math.randomFloat(0, 1) < FIELD_GO_HOME then
        local home = GetBotHomeZone(bot:getNation(), zoneId)
        if home ~= 0 and GetBotRouteNextLine(zoneId, home) ~= nil then
            target = home
        end
    end

    if target then
        xi.worldbots.internal.setGoal(charId, state, 'logoff', target)
        return false
    end

    xi.worldbots.internal.setGoal(charId, state, 'stay', zoneId)
    state.goal.settled   = true
    state.goal.untilTime = now + 3600
    state.logout         = { at = now + math.random(LOGOUT_WAIT_MIN, LOGOUT_WAIT_MAX) }
    return true
end

return session
