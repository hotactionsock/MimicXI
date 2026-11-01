-----------------------------------
-- xi.worldbots - AI for world-population bots.
--
-- A world bot is a real CCharEntity on a real (throwaway) account, spawned with
-- no live network socket (see src/map/utils/botutils.h) - not an NPC, not a mob,
-- not a mimic trust. The bot registry lives in the `world_bots` table (C++ side),
-- so this file holds only a per-bot AI scratch cache: reloading it loses nothing
-- but in-flight walk state.
--
-- Driven by xi.worldbots.onZoneTick, which the engine calls for every AWAKE zone
-- that contains bots (CZoneEntities::ZoneServer). A zone with no real players
-- goes dormant and stops ticking, so its bots simply freeze until someone
-- arrives - no per-zone script hook needed. Session keep-alive is engine-side
-- (MapSessionContainer::cleanupSessions) and works in dormant zones too.
--
-- Current behaviour: loiter around an anchor point. Combat, travel and the
-- population manager come later.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}

-- charId -> { lastPositionSaveTime, anchor = {x,y,z}, lastPos, walking, walkOrderAt, idleUntil }
-- Lazily filled on a bot's first tick; never authoritative (see header).
local states = {}

-- Logs every loiter decision to the map log as [lua] lines. Testing aid only -
-- keep false: per-bot, per-step output would swamp the log at any real bot count.
local DEBUG = false

local LOITER_RADIUS_YALMS         = 8
local LOITER_MIN_STEP_YALMS       = 2  -- skip near-zero shuffles
local LOITER_PICK_ATTEMPTS        = 6
local LOITER_PAUSE_MIN_SEC        = 1  -- pause after arriving (initial test: keep moving;
local LOITER_PAUSE_MAX_SEC        = 2  -- longer "afk/idle" behaviour is a later phase)
local WALK_START_GRACE_SEC        = 2  -- a walk order that hasn't moved by then is retried
local POSITION_SAVE_INTERVAL_SEC  = 30

local function distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-----------------------------------
-- Registry helpers (thin wrappers over the C++ world_bots registry)
-----------------------------------

xi.worldbots.isBot = function(charId)
    return IsBotCharacter(charId)
end

-- Drops a bot's cached AI state, e.g. after it was despawned or moved, so its
-- next tick re-reads its anchor from the database.
xi.worldbots.forget = function(charId)
    states[charId] = nil
end

-- Safely relocates a bot - even one stuck mid zone-transition, since a bot has
-- no client to complete that sequence on its own - and re-anchors its loiter
-- area to the new spot. Use this (not setPos) for any GM-driven bot move; see
-- the !bring override in scripts/commands/bring.lua.
xi.worldbots.teleportBot = function(charId, x, y, z, rotation, zoneId)
    xi.worldbots.forget(charId)

    return TeleportBotCharacter(charId, zoneId, x, y, z, rotation)
end

-----------------------------------
-- Loiter: walk to a random walkable point near the bot's spawn anchor.
-- Bounded to that anchor (not "wherever it currently stands") so repeated
-- wander steps can't drift the bot arbitrarily far over time - unbounded
-- drift is what was walking bots into real zone lines and leaving them stuck
-- there (a bot has no client to complete the resulting zone-transition).
--
-- Arrival-driven, not interval-driven: the controller doesn't report "arrived"
-- to Lua, so arrival is inferred from the bot having stopped moving. As soon as
-- it stops, it pauses briefly (LOITER_PAUSE_*) and picks the next point. A walk
-- order that never starts moving (unreachable/rejected point) is retried after
-- a short grace period instead of burning a whole cycle.
-----------------------------------

local function diag(charId, fmt, ...)
    if DEBUG then
        print(string.format('[worldbots] %d: ' .. fmt, charId, ...))
    end
end

-- A random navmesh point centred on the anchor, within the wander radius and
-- far enough from the bot's current spot to be a visible move. Several tries,
-- since Detour's random point can land outside the requested circle.
local function pickLoiterPoint(bot, state, currentPos)
    local zone = bot:getZone()
    if zone == nil then
        return nil
    end

    for _ = 1, LOITER_PICK_ATTEMPTS do
        local pos = zone:getRandomNavmeshPoint(state.anchor, LOITER_RADIUS_YALMS)
        if
            pos and
            distance(pos, state.anchor) <= LOITER_RADIUS_YALMS and
            distance(pos, currentPos) >= LOITER_MIN_STEP_YALMS
        then
            return pos
        end
    end

    return nil
end

local function loiterStep(bot, charId, state, now)
    if not state.anchor then
        return
    end

    local currentPos = { x = bot:getXPos(), y = bot:getYPos(), z = bot:getZPos() }
    local moving     = state.lastPos ~= nil and distance(currentPos, state.lastPos) > 0.05
    state.lastPos    = currentPos

    if moving then
        state.walking     = true
        state.walkOrderAt = nil
        return
    end

    -- Just stopped: arrived (or the path ended) - short pause, then go again.
    if state.walking then
        state.walking   = false
        state.idleUntil = now + math.random(LOITER_PAUSE_MIN_SEC, LOITER_PAUSE_MAX_SEC)
        diag(charId, 'arrived at (%.1f, %.1f, %.1f), pausing', currentPos.x, currentPos.y, currentPos.z)
        return
    end

    -- Ordered to walk but hasn't started yet - give it a moment before retrying.
    if state.walkOrderAt and now < state.walkOrderAt + WALK_START_GRACE_SEC then
        return
    end

    if state.idleUntil and now < state.idleUntil then
        return
    end

    local target
    if distance(currentPos, state.anchor) > LOITER_RADIUS_YALMS then
        -- Drifted outside the wander area (e.g. combat knockback) - head back.
        target = state.anchor
        diag(charId, 'outside radius - walking back to anchor')
    else
        target = pickLoiterPoint(bot, state, currentPos)
        if target == nil then
            diag(charId, 'no valid loiter point found this tick')
            return
        end
    end

    if state.walkOrderAt then
        diag(charId, 'previous walk order never started moving - retrying')
    end

    diag(charId, 'walk (%.1f, %.1f, %.1f) -> (%.1f, %.1f, %.1f)',
        currentPos.x, currentPos.y, currentPos.z, target.x, target.y, target.z)

    WalkBotTo(charId, target.x, target.y, target.z)
    state.walkOrderAt = now
end

-----------------------------------
-- Zone tick: called by the engine for each awake zone holding bots, with the
-- list of bot entities in that zone.
-----------------------------------

xi.worldbots.onZoneTick = function(zone, bots)
    local now = GetSystemTime()

    for _, bot in ipairs(bots) do
        local charId = bot:getID()
        local state  = states[charId]

        if state == nil then
            state = { lastPositionSaveTime = now, anchor = GetBotAnchor(charId) }
            states[charId] = state
        end

        loiterStep(bot, charId, state, now)

        if state.lastPositionSaveTime + POSITION_SAVE_INTERVAL_SEC <= now then
            state.lastPositionSaveTime = now
            SaveBotPosition(charId)
        end
    end
end

return xi.worldbots
