-----------------------------------
-- xi.worldbots.jobs - which jobs a world bot plays (Phase 3).
--
-- Every bot has one CAREER job: the main job it works towards for life
-- (world_bots.career_job). Other jobs are only played in service of it:
--   * A new character can only start on a basic job (WAR, MNK, WHM, BLM, RDM,
--     THF). A bot whose career is an advanced job first levels a FEEDER basic
--     job to 30, then unlocks its career job and switches to it at level 1.
--   * At 18 it unlocks subjobs, then uses the best subjob for its career by
--     widely used metas (SUBJOB_META). Advanced subjobs get unlocked once it
--     has any job at 30.
--   * When its subjob falls more than SUB_LAG levels behind half its main
--     level, it switches main to the subjob and levels that for a while, then
--     switches back - like a player catching up their sub.
-- Unlocks are instant for now: stand-ins for the unlock quests, which bots
-- will do themselves in the Quests & Content phase.
--
-- Job changes happen at a Mog House entrance in a home city (ChangeBotJobs),
-- as a 'jobs' goal in xi.worldbots: travel home, walk to the Mog House, change.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.jobs = xi.worldbots.jobs or {}

local jobs = xi.worldbots.jobs

local ADVANCED_UNLOCK_LEVEL = 30 -- any job at this level unlocks advanced jobs
local SUBJOB_UNLOCK_LEVEL   = 18 -- main level that unlocks subjobs
local SUB_LAG               = 3  -- level the subjob once it's this far below half the main level...
local SUB_CATCH_UP          = 1  -- ...until it's this far above half the main level
local SUB_MIN_MAIN_LEVEL    = 20 -- don't detour to level a subjob before the main is this high

local BASIC_JOBS = { 'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF' }

-- Careers new bots are given, by weight. 0 = not handed out yet (later scope).
-- Personalities will skew this later (see the design doc).
local CAREER_WEIGHTS =
{
    WAR = 10, MNK = 8, THF = 7, PLD = 8, NIN = 6, DRK = 8, SAM = 7, DRG = 6,
    WHM = 9, RDM = 8, BRD = 5, RUN = 5, BLM = 8,
    SCH = 0, SMN = 0, RNG = 0, COR = 0, DNC = 0, GEO = 0,
    BLU = 0, PUP = 0, BST = 0,
}

-- The basic job levelled to 30 before an advanced career unlocks. Chosen as a
-- job the career will want as a subjob, so the levels aren't wasted.
local FEEDER =
{
    PLD = 'WAR', NIN = 'WAR', DRK = 'WAR', SAM = 'WAR', DRG = 'WAR', RUN = 'WAR',
    RNG = 'WAR', DNC = 'WAR', COR = 'WAR', BST = 'WAR', BLU = 'WAR', PUP = 'WAR',
    BRD = 'WHM', SMN = 'WHM',
    SCH = 'RDM', GEO = 'RDM',
}

-- Preferred subjobs per main job, best first (the first one available is used).
local SUBJOB_META =
{
    WAR = { 'SAM', 'NIN', 'MNK' },
    MNK = { 'WAR', 'SAM', 'NIN' },
    WHM = { 'BLM', 'RDM', 'SCH' },
    BLM = { 'WHM', 'RDM', 'SCH' },
    RDM = { 'WHM', 'BLM', 'NIN' },
    THF = { 'NIN', 'WAR', 'DNC' },
    PLD = { 'WAR', 'NIN', 'RDM' },
    DRK = { 'SAM', 'WAR' },
    BST = { 'WHM', 'NIN', 'DNC' },
    BRD = { 'WHM', 'RDM', 'NIN' },
    RNG = { 'WAR', 'SAM', 'NIN' },
    SAM = { 'WAR', 'DNC' },
    NIN = { 'WAR', 'DNC' },
    DRG = { 'SAM', 'WAR' },
    SMN = { 'WHM', 'RDM', 'SCH' },
    BLU = { 'WAR', 'NIN', 'DNC' },
    COR = { 'NIN', 'RNG', 'WAR' },
    PUP = { 'WAR', 'DNC', 'WHM' },
    DNC = { 'WAR', 'NIN', 'SAM' },
    SCH = { 'RDM', 'WHM', 'BLM' },
    GEO = { 'RDM', 'WHM', 'BLM' },
    RUN = { 'WAR', 'NIN', 'SAM' },
}

local function jobId(name)
    return xi.job[name]
end

local function isBasic(job)
    for _, name in ipairs(BASIC_JOBS) do
        if jobId(name) == job then
            return true
        end
    end

    return false
end

local function jobName(job)
    for name, id in pairs(xi.job) do
        if id == job then
            return name
        end
    end

    return nil
end

local function feederOf(career)
    if isBasic(career) then
        return career
    end

    local name = FEEDER[jobName(career)]
    return name and jobId(name) or jobId('WAR')
end

-- Weighted pick among careers - those whose feeder is the job the bot is
-- already playing, so an existing bot's levels count towards its career.
local function pickCareer(currentMain)
    local total, choices = 0, {}

    for name, weight in pairs(CAREER_WEIGHTS) do
        local id = jobId(name)
        if id and weight > 0 and feederOf(id) == currentMain then
            total = total + weight
            table.insert(choices, { id = id, weight = weight })
        end
    end

    if total == 0 then
        return currentMain
    end

    local roll = math.randomFloat(0, total)
    for _, choice in ipairs(choices) do
        roll = roll - choice.weight
        if roll <= 0 then
            return choice.id
        end
    end

    return choices[#choices].id
end

-- The bot's career job, chosen (and saved) the first time it's asked for.
function jobs.career(bot, charId, state)
    if state.careerJob then
        return state.careerJob
    end

    local career = GetBotCareerJob(charId)
    if career == 0 then
        career = pickCareer(bot:getMainJob())
        SetBotCareerJob(charId, career)
        xi.worldbots.log.career(bot, career)
    end

    state.careerJob = career
    return career
end

local function highestLevel(info)
    local best = 0
    for _, level in pairs(info.levels) do
        best = math.max(best, level)
    end

    return best
end

-- Unlocks job if it's locked and the bot qualifies (any job at 30 for an
-- advanced job; basic jobs are always open). True if usable afterwards.
local function ensureUnlocked(charId, info, job)
    if info.unlocked[job] then
        return true
    end

    if isBasic(job) or highestLevel(info) >= ADVANCED_UNLOCK_LEVEL then
        if UnlockBotJob(charId, job) then
            info.unlocked[job] = true
            info.levels[job]   = math.max(info.levels[job] or 0, 1)
            return true
        end
    end

    return false
end

-- Best usable subjob for main from the meta list (unlocking it if allowed).
local function bestSubjob(charId, info, main)
    for _, name in ipairs(SUBJOB_META[jobName(main)] or {}) do
        local id = jobId(name)
        if id and id ~= main and ensureUnlocked(charId, info, id) then
            return id
        end
    end

    return 0
end

-- What the bot should be playing: { main, sub } (0 = none/keep).
local function desiredJobs(bot, charId, state)
    local info = GetBotJobInfo(charId)
    if info == nil then
        return nil
    end

    local career = jobs.career(bot, charId, state)

    -- 1. Main: the career once unlocked, otherwise its feeder basic job.
    local main = career
    if not ensureUnlocked(charId, info, career) then
        main = feederOf(career)
    end

    -- 2. Subjobs unlock at 18 on the main.
    if
        not info.subjobUnlocked and
        (info.levels[main] or 0) >= SUBJOB_UNLOCK_LEVEL
    then
        if UnlockBotJob(charId, 0) then
            info.subjobUnlocked = true
        end
    end

    if not info.subjobUnlocked then
        return { main = main, sub = 0, info = info }
    end

    local sub = bestSubjob(charId, info, main)
    if sub == 0 then
        return { main = main, sub = 0, info = info }
    end

    -- 3. Subjob levelling: if it lags too far behind half the main level, play
    -- it as main until it catches up (keep going if already doing so).
    local mainLevel = info.levels[main] or 0
    local subLevel  = info.levels[sub] or 0
    local target    = math.floor(mainLevel / 2)

    if mainLevel >= SUB_MIN_MAIN_LEVEL then
        local levellingSub = info.mainJob == sub and subLevel < target + SUB_CATCH_UP
        local lagging      = subLevel < target - SUB_LAG

        if levellingSub or lagging then
            -- Play the subjob, supported by the best sub it can use (often the main).
            local supportSub = bestSubjob(charId, info, sub)
            return { main = sub, sub = supportSub, info = info, levellingSub = true }
        end
    end

    return { main = main, sub = sub, info = info }
end

-- Called when the bot picks a new goal. Returns { main, sub } if it should go
-- and change jobs, or nil if it's already playing the right ones.
function jobs.plan(bot, charId, state)
    local want = desiredJobs(bot, charId, state)
    if want == nil then
        return nil
    end

    local info = want.info
    if info.mainJob == want.main and (want.sub == 0 or info.subJob == want.sub) then
        return nil
    end

    return { main = want.main, sub = want.sub }
end

-- At the Mog House: make the change. True if anything changed.
function jobs.apply(charId, want)
    local info = GetBotJobInfo(charId)
    if info == nil then
        return false
    end

    local main = info.mainJob ~= want.main and want.main or 0
    local sub  = (want.sub ~= 0 and info.subJob ~= want.sub) and want.sub or 0

    -- A sub equal to the new main is swapped by the handler; set main first.
    return ChangeBotJobs(charId, main, sub)
end

-- For !worldbot jobs.
function jobs.describe(bot, charId, state)
    local info = GetBotJobInfo(charId)
    if info == nil then
        return nil
    end

    local career = jobs.career(bot, charId, state)
    local levels = {}
    for job, level in pairs(info.levels) do
        if level > 0 then
            table.insert(levels, string.format('%s %d', jobName(job) or tostring(job), level))
        end
    end

    table.sort(levels)

    return string.format('career %s - playing %s/%s - subjob %s - %s',
        jobName(career) or '?',
        jobName(info.mainJob) or '?',
        jobName(info.subJob) or '-',
        info.subjobUnlocked and 'unlocked' or 'locked',
        table.concat(levels, ', '))
end

return jobs
