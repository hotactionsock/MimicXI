-----------------------------------
-- Module: circuit
--
-- Twelve timed instanced dungeons across four level caps (30/40/50/60).
-- Each tier has Alpha (2-room), Beta (3-room), and Gamma (4-room) variants.
-- Players clear all mobs as fast as possible; clear time is scored into
-- Platinum/Gold/Silver/Bronze/Clear brackets and recorded to circuit_leaderboard.
-- Points accumulate permanently and are spent at the Timekeeper NPC.
-- Weekly leaderboard rank awards bonus points to top 3 per circuit.
--
-- Toggle: comment/uncomment entries in modules/init.txt
-----------------------------------
require('modules/module_utils')

local m = Module:new('mimic_circuit')

xi         = xi or {}
xi.circuit = xi.circuit or {}

-----------------------------------
-- Rank constants
-----------------------------------
xi.circuit.RANK =
{
    PLATINUM = 'Platinum',
    GOLD     = 'Gold',
    SILVER   = 'Silver',
    BRONZE   = 'Bronze',
    CLEAR    = 'Clear',
}

-----------------------------------
-- Char var keys
-----------------------------------
xi.circuit.POINT_VAR       = '[Circuit]Points'
xi.circuit.BADGE_VAR       = '[Circuit]PlatinumBadges'
xi.circuit.WEEKLY_VAR      = '[Circuit]LastWeeklyPayout'

-----------------------------------
-- Circuit definitions
-- id: 1–12 (matches circuit_leaderboard.circuit_id)
-- timeTargets: [ms] thresholds for Platinum / Gold / Silver / Bronze
--   times below Platinum get Platinum, above Bronze get Clear
-- points: [Plat, Gold, Silver, Bronze, Clear]
-- gammaMultiplier applied in scoring (Gamma is worth 1.5x points)
-----------------------------------
xi.circuit.CIRCUITS =
{
    -- Lv30 circuits
    [1] =
    {
        instanceId   = 18310,
        tier         = 30,
        label        = 'Alpha',
        levelCap     = 30,
        roomCount    = 2,
        timeTargets  = { 240000, 300000, 360000, 480000 }, -- 4 / 5 / 6 / 8 min
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [2] =
    {
        instanceId   = 18311,
        tier         = 30,
        label        = 'Beta',
        levelCap     = 30,
        roomCount    = 3,
        timeTargets  = { 360000, 450000, 540000, 720000 }, -- 6 / 7.5 / 9 / 12 min
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [3] =
    {
        instanceId   = 18312,
        tier         = 30,
        label        = 'Gamma',
        levelCap     = 30,
        roomCount    = 4,
        timeTargets  = { 480000, 600000, 720000, 960000 }, -- 8 / 10 / 12 / 16 min
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = true,
    },

    -- Lv40 circuits
    [4] =
    {
        instanceId   = 18313,
        tier         = 40,
        label        = 'Alpha',
        levelCap     = 40,
        roomCount    = 2,
        timeTargets  = { 240000, 300000, 360000, 480000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [5] =
    {
        instanceId   = 18314,
        tier         = 40,
        label        = 'Beta',
        levelCap     = 40,
        roomCount    = 3,
        timeTargets  = { 360000, 450000, 540000, 720000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [6] =
    {
        instanceId   = 18315,
        tier         = 40,
        label        = 'Gamma',
        levelCap     = 40,
        roomCount    = 4,
        timeTargets  = { 480000, 600000, 720000, 960000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = true,
    },

    -- Lv50 circuits
    [7] =
    {
        instanceId   = 18316,
        tier         = 50,
        label        = 'Alpha',
        levelCap     = 50,
        roomCount    = 2,
        timeTargets  = { 240000, 300000, 360000, 480000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [8] =
    {
        instanceId   = 18317,
        tier         = 50,
        label        = 'Beta',
        levelCap     = 50,
        roomCount    = 3,
        timeTargets  = { 360000, 450000, 540000, 720000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [9] =
    {
        instanceId   = 18318,
        tier         = 50,
        label        = 'Gamma',
        levelCap     = 50,
        roomCount    = 4,
        timeTargets  = { 480000, 600000, 720000, 960000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = true,
    },

    -- Lv60 circuits
    [10] =
    {
        instanceId   = 18319,
        tier         = 60,
        label        = 'Alpha',
        levelCap     = 60,
        roomCount    = 2,
        timeTargets  = { 240000, 300000, 360000, 480000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [11] =
    {
        instanceId   = 18320,
        tier         = 60,
        label        = 'Beta',
        levelCap     = 60,
        roomCount    = 3,
        timeTargets  = { 360000, 450000, 540000, 720000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = false,
    },
    [12] =
    {
        instanceId   = 18321,
        tier         = 60,
        label        = 'Gamma',
        levelCap     = 60,
        roomCount    = 4,
        timeTargets  = { 480000, 600000, 720000, 960000 },
        basePoints   = { 6, 4, 2, 1, 0 },
        isGamma      = true,
    },
}

-- Reverse lookup: instanceId → circuit_id
xi.circuit.INSTANCE_TO_ID = {}
for id, def in pairs(xi.circuit.CIRCUITS) do
    xi.circuit.INSTANCE_TO_ID[def.instanceId] = id
end

-----------------------------------
-- Score a run and return rank, points earned
-- clearTimeMs: elapsed ms at completion
-- circuitDef: entry from xi.circuit.CIRCUITS
-----------------------------------
xi.circuit.scoreRun = function(clearTimeMs, circuitDef)
    local targets = circuitDef.timeTargets
    local points  = circuitDef.basePoints

    local rank, earned
    if clearTimeMs < targets[1] then
        rank, earned = xi.circuit.RANK.PLATINUM, points[1]
    elseif clearTimeMs < targets[2] then
        rank, earned = xi.circuit.RANK.GOLD,     points[2]
    elseif clearTimeMs < targets[3] then
        rank, earned = xi.circuit.RANK.SILVER,   points[3]
    elseif clearTimeMs < targets[4] then
        rank, earned = xi.circuit.RANK.BRONZE,   points[4]
    else
        rank, earned = xi.circuit.RANK.CLEAR,    points[5]
    end

    -- Gamma 1.5x multiplier (round up)
    if circuitDef.isGamma then
        earned = math.ceil(earned * 1.5)
    end

    return rank, earned
end

-----------------------------------
-- Record a run to the leaderboard and award points
-- Called from onInstanceComplete in circuit instance scripts
-----------------------------------
xi.circuit.recordRun = function(player, circuitId, clearTimeMs)
    local circuitDef  = xi.circuit.CIRCUITS[circuitId]
    if not circuitDef then return end

    local rank, earned = xi.circuit.scoreRun(clearTimeMs, circuitDef)
    local weekNum      = os.date('*t').yday -- week approximation; replace with YEARWEEK if DB date func available

    -- Insert into circuit_leaderboard via raw query
    local sql = string.format(
        "INSERT INTO circuit_leaderboard (char_id, char_name, circuit_id, clear_time_ms, rank, points_earned, week_number) " ..
        "VALUES (%d, '%s', %d, %d, '%s', %d, %d)",
        player:getID(), player:getName(), circuitId, clearTimeMs, rank, earned, weekNum
    )
    -- Note: execute via server DB helper when available; stub shown here
    -- xi.db.query(sql)

    -- Award points
    local current = player:getCharVar(xi.circuit.POINT_VAR)
    player:setCharVar(xi.circuit.POINT_VAR, current + earned)

    -- Award Platinum Circuit Badge if Gamma + Platinum rank
    if circuitDef.isGamma and rank == xi.circuit.RANK.PLATINUM then
        local badges = player:getCharVar(xi.circuit.BADGE_VAR)
        player:setCharVar(xi.circuit.BADGE_VAR, badges + 1)
    end

    return rank, earned
end

-----------------------------------
-- Weekly rank bonus payout
-- Called lazily on zone-in if the stored week number has changed.
-- Queries top-3 per circuit for the previous week and awards bonus points.
-----------------------------------
xi.circuit.weeklyBonuses = { 10, 6, 3 } -- 1st / 2nd / 3rd place

xi.circuit.checkWeeklyReset = function(player)
    -- Stub: implement when DB query API is confirmed
    -- Compare stored week var against current week
    -- If changed: payout top-3 per circuit, update stored week
end

-----------------------------------
-- Load circuit instance script helper
-----------------------------------
require('modules/custom/circuit/lua/circuit_instance')

return m
