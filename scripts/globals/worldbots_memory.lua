-----------------------------------
-- xi.worldbots.memory - learning from experience.
--
-- Each bot remembers how things went (world_bot_memory, survives restarts -
-- see src/map/utils/botmemory.h):
--   zone  - deaths there, and EXP earned training there
--   route - deaths on the way to a zone (before getting there), arrivals
--   camp  - deaths at a particular camp
--   NM    - deaths fighting a particular NM
--
-- How much a past death still counts ("danger"): recent deaths count fully
-- and fade with a half-life of DEATH_HALF_LIFE_SEC; deaths it has since
-- outlevelled count less for every level gained, and not at all past
-- OUTLEVELLED_AFTER levels. Once the danger of a destination, camp or NM
-- reaches AVOID_DANGER the bot stops trying it and picks something else;
-- below that, danger just makes an option less appealing. Zones where it has
-- earned EXP lately get a small boost - it goes back to what works.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.memory = xi.worldbots.memory or {}

local memory = xi.worldbots.memory

memory.ZONE  = 1
memory.ROUTE = 2
memory.CAMP  = 3
memory.NM    = 4

local DEATH_HALF_LIFE_SEC = 3 * 60 * 60 -- a death counts half after this long
local OUTLEVELLED_AFTER   = 5           -- levels past the death level at which it no longer counts
local OUTLEVEL_FACTOR     = 0.6         -- each level gained since, a death counts this much less
local AVOID_DANGER        = 2           -- stop trying something at this much danger (about 2 recent deaths)
local SUCCESS_BOOST       = 0.15        -- appeal bonus for a zone it earned EXP in lately...
local SUCCESS_RECENT_SEC  = 24 * 60 * 60 -- ...within this long
local CAMP_GRID_YALMS     = 40
local CAMP_PLAYER_YALMS   = 20          -- don't pick a camp with a real player this close

-- A camp's memory key: the zone and the 40-yalm grid cell its spot is in.
function memory.campKey(zoneId, pos)
    local gx = math.floor((pos.x + 5120) / CAMP_GRID_YALMS) % 256
    local gz = math.floor((pos.z + 5120) / CAMP_GRID_YALMS) % 256
    return zoneId * 65536 + gx * 256 + gz
end

-- How much past deaths at this thing still count (0 = none that matter).
function memory.danger(bot, kind, ref, now)
    local m = GetBotMemory(bot:getID(), kind, ref)
    if m.deaths == 0 then
        return 0
    end

    local levelsSince = bot:getMainLvl() - m.deathLevel
    if levelsSince >= OUTLEVELLED_AFTER then
        return 0
    end

    local fade = 0.5 ^ ((now - m.lastDeathTs) / DEATH_HALF_LIFE_SEC)
    local outlevel = levelsSince > 0 and OUTLEVEL_FACTOR ^ levelsSince or 1
    return m.deaths * fade * outlevel
end

-- Should the bot stop trying this?
function memory.avoid(bot, kind, ref, now)
    return memory.danger(bot, kind, ref, now) >= AVOID_DANGER
end

-- Appeal multiplier from experience: below 1 for places it has died, a little
-- above 1 for zones it has trained in successfully lately.
function memory.trust(bot, kind, ref, now)
    local factor = 1 / (1 + memory.danger(bot, kind, ref, now))
    if kind == memory.ZONE then
        local m = GetBotMemory(bot:getID(), kind, ref)
        if m.exp > 0 and now - m.lastSuccessTs <= SUCCESS_RECENT_SEC then
            factor = factor * (1 + SUCCESS_BOOST)
        end
    end

    return factor
end

-- The bot just died: blame it on what it was doing, and give up on whatever
-- has now cost it too much.
function memory.recordDeath(bot, charId, state, now)
    local zoneId = bot:getZoneID()
    local level  = bot:getMainLvl()
    local goal   = state.goal

    RecordBotDeath(charId, memory.ZONE, zoneId, level)

    if goal == nil then
        return
    end

    if goal.kind == 'nm' and goal.nm then
        RecordBotDeath(charId, memory.NM, goal.nm.mobId, level)
        if memory.avoid(bot, memory.NM, goal.nm.mobId, now) then
            xi.worldbots.log.nmResult(bot, goal.nm.name, 'too dangerous for now')
            state.goal = nil
        end

        return
    end

    if goal.zoneId ~= zoneId or not goal.settled then
        -- Died before getting there.
        RecordBotDeath(charId, memory.ROUTE, goal.zoneId, level)
        if memory.avoid(bot, memory.ROUTE, goal.zoneId, now) then
            xi.worldbots.log.gaveUpRoute(bot, GetBotZoneName(goal.zoneId), GetBotMemory(charId, memory.ROUTE, goal.zoneId).deaths)
            state.goal = nil -- after the home point, it picks somewhere else
        end

        return
    end

    if goal.kind == 'level' and goal.spot then
        local key = memory.campKey(zoneId, goal.spot)
        RecordBotDeath(charId, memory.CAMP, key, level)
        if memory.avoid(bot, memory.CAMP, key, now) then
            xi.worldbots.log.gaveUpCamp(bot, GetBotZoneName(zoneId))
            goal.spot = nil -- comes back to this zone, but to a different camp
        end
    end
end

-- Arrived where it was heading.
function memory.recordArrival(charId, zoneId)
    RecordBotSuccess(charId, memory.ROUTE, zoneId, 0)
end

-- Earned EXP training in a zone (from the hunt summary).
function memory.recordHunt(charId, zoneId, exp)
    if exp > 0 then
        RecordBotSuccess(charId, memory.ZONE, zoneId, exp)
    end
end

-- A camp spot that hasn't gone badly: asks for camps until one isn't
-- avoided (up to 3 tries). getSpot(avoidPos) returns a spot or nil.
function memory.safeCamp(bot, zoneId, now, getSpot)
    local avoidPos = nil
    for _ = 1, 3 do
        local spot = getSpot(avoidPos)
        if spot == nil then
            return nil
        end

        -- Not one that has gone badly, and not right on top of a real player.
        if
            not memory.avoid(bot, memory.CAMP, memory.campKey(zoneId, spot), now) and
            CountRealPlayersNear(zoneId, spot.x, spot.y, spot.z, CAMP_PLAYER_YALMS) == 0
        then
            return spot
        end

        avoidPos = spot
    end

    return nil
end

return memory
