-----------------------------------
-- xi.worldbots.log - the Lua half of the bot activity log.
--
-- The engine logs what it does itself (created, learned a spell, equipped,
-- obtained, sold, tossed, used an item, unlocked or changed jobs, retired -
-- see src/map/utils/botlog.h). This module logs what only the AI knows about:
-- level-ups, careers, deaths, home points, trips and arrivals, hunt summaries,
-- parties, skillchains and magic bursts.
--
-- Levels: 1 milestone, 2 notable, 3 detail (map.WORLDBOTS_LOG_LEVEL decides
-- what's kept). Every line is a ready-to-show sentence plus a flat table of
-- facts the website can use.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.log = xi.worldbots.log or {}

local log = xi.worldbots.log

log.MILESTONE = 1
log.NOTABLE   = 2
log.DETAIL    = 3

local HUNT_SUMMARY_SEC = 30 * 60 -- a hunt summary at least this often while camping

local JOB_NAMES =
{
    'Warrior', 'Monk', 'White Mage', 'Black Mage', 'Red Mage', 'Thief', 'Paladin', 'Dark Knight',
    'Beastmaster', 'Bard', 'Ranger', 'Samurai', 'Ninja', 'Dragoon', 'Summoner', 'Blue Mage',
    'Corsair', 'Puppetmaster', 'Dancer', 'Scholar', 'Geomancer', 'Rune Fencer',
}

local SKILLCHAIN_NAMES =
{
    'Transfixion', 'Compression', 'Liquefaction', 'Scission', 'Reverberation', 'Detonation',
    'Induration', 'Impaction', 'Gravitation', 'Distortion', 'Fusion', 'Fragmentation',
    'Light', 'Darkness', 'Light', 'Darkness',
}

function log.jobName(job)
    return JOB_NAMES[job] or 'adventurer'
end

function log.skillchainName(element)
    return SKILLCHAIN_NAMES[element] or 'a skillchain'
end

-- "Goblin_Thug" -> "Goblin Thug" (engine names of mobs and NPCs).
function log.humanName(name)
    return (string.gsub(name or '', '_', ' '))
end

local function withCommas(n)
    local s = tostring(math.floor(n))
    local result = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
    return (result:gsub('^,', ''))
end

-- Logs one event for a bot entity.
function log.event(bot, level, category, event, message, data)
    LogBotEvent(bot:getID(), level, category, event, message, data)
end

-- Per-tick: level-ups (per job) and the periodic hunt summary.
function log.tick(bot, state, now)
    local job   = bot:getMainJob()
    local level = bot:getMainLvl()

    -- First sight (spawn, script reload): remember, don't log.
    if state.logJob ~= job then
        state.logJob, state.logLevel = job, level
    elseif level > (state.logLevel or level) then
        log.event(bot, log.MILESTONE, 'level', 'level_up',
            string.format('%s reached level %d %s', bot:getName(), level, log.jobName(job)),
            { job = job, level = level })
        state.logLevel = level
    elseif level < state.logLevel then
        state.logLevel = level -- de-levelled; not a milestone
    end

    state.nextHuntSummaryAt = state.nextHuntSummaryAt or (now + HUNT_SUMMARY_SEC)
    if now >= state.nextHuntSummaryAt then
        state.nextHuntSummaryAt = now + HUNT_SUMMARY_SEC
        log.huntSummary(bot, bot:getZoneID())
    end
end

-- "Testbot defeated 34 monsters in Valkurm Dunes, earning 4,210 EXP" - for
-- the hunting done since the last summary (none = nothing logged).
function log.huntSummary(bot, zoneId)
    local progress = TakeBotHuntProgress(bot:getID())
    if progress.kills == 0 and progress.exp == 0 then
        return
    end

    -- Remember that this zone pays off (worldbots_memory.lua).
    xi.worldbots.memory.recordHunt(bot:getID(), zoneId, progress.exp)

    local zoneName = GetBotZoneName(zoneId)
    log.event(bot, log.NOTABLE, 'combat', 'hunt_summary',
        string.format('%s defeated %d monster%s in %s, earning %s EXP', bot:getName(), progress.kills,
            progress.kills == 1 and '' or 's', zoneName, withCommas(progress.exp)),
        { zone_id = zoneId, zone = zoneName, kills = progress.kills, exp = progress.exp })
end

-- Crossed into a new zone: close the old zone's hunt summary, note the arrival.
function log.arrived(bot, fromZoneId, toZoneId)
    if fromZoneId then
        log.huntSummary(bot, fromZoneId)
    end

    local zoneName = GetBotZoneName(toZoneId)
    log.event(bot, log.NOTABLE, 'travel', 'arrived', string.format('%s arrived in %s', bot:getName(), zoneName),
        { zone_id = toZoneId, zone = zoneName, from_zone_id = fromZoneId or 0 })
end

-- A new goal that means a trip (only logged when it leads somewhere else).
local GOAL_PHRASES =
{
    level = 'set off for %s to train',
    home  = 'headed home to %s',
    zone  = 'set off for %s',
    sell  = 'headed to %s to sell their loot',
    shop  = 'headed to %s to go shopping',
    nm    = 'set off for %s to hunt a notorious monster',
    jobs  = 'headed to %s to change jobs',
    party = 'set off to meet their party in %s',
}

function log.goal(bot, kind, zoneId)
    local phrase = GOAL_PHRASES[kind]
    if phrase == nil or zoneId == bot:getZoneID() then
        return
    end

    local zoneName = GetBotZoneName(zoneId)
    log.event(bot, log.NOTABLE, 'travel', 'goal_' .. kind, bot:getName() .. ' ' .. string.format(phrase, zoneName),
        { goal = kind, zone_id = zoneId, zone = zoneName })
end

function log.died(bot, foeName)
    local zoneName = GetBotZoneName(bot:getZoneID())
    local message  = foeName and foeName ~= '' and
        string.format('%s was defeated by %s in %s', bot:getName(), foeName, zoneName) or
        string.format('%s was defeated in %s', bot:getName(), zoneName)

    log.event(bot, log.MILESTONE, 'death', 'died', message,
        { zone_id = bot:getZoneID(), zone = zoneName, foe = foeName or '', level = bot:getMainLvl(), job = bot:getMainJob() })
end

function log.homePoint(bot)
    local zoneName = GetBotZoneName(bot:getZoneID())
    log.event(bot, log.NOTABLE, 'travel', 'home_point', string.format('%s set their home point in %s', bot:getName(), zoneName),
        { zone_id = bot:getZoneID(), zone = zoneName })
end

function log.career(bot, job)
    log.event(bot, log.MILESTONE, 'job', 'career', string.format('%s set out to become a %s', bot:getName(), log.jobName(job)),
        { job = job })
end

function log.joinedParty(bot, leaderName, role, size)
    log.event(bot, log.NOTABLE, 'party', 'joined',
        string.format('%s joined %s\'s party (%d members) as %s', bot:getName(), leaderName, size, role == 'damage' and 'a damage dealer' or 'the ' .. role),
        { leader = leaderName, role = role, size = size })
end

function log.formedParty(bot, size)
    log.event(bot, log.NOTABLE, 'party', 'formed', string.format('%s formed a party of %d', bot:getName(), size), { size = size })
end

function log.leftParty(bot, reason, minutes)
    log.event(bot, log.NOTABLE, 'party', 'left',
        string.format('%s left their party after %d minute%s (%s)', bot:getName(), minutes, minutes == 1 and '' or 's', reason),
        { reason = reason, minutes = minutes })
end

function log.hired(bot, playerName)
    log.event(bot, log.NOTABLE, 'party', 'hired', string.format('%s joined %s\'s party', bot:getName(), playerName),
        { player = playerName, level = bot:getMainLvl(), job = bot:getMainJob() })
end

function log.synced(bot, level, playerName)
    log.event(bot, log.DETAIL, 'party', 'synced', string.format('%s was level-synced to %d to match %s', bot:getName(), level, playerName),
        { level = level, player = playerName })
end

function log.dismissed(bot, playerName, reason, minutes)
    log.event(bot, log.NOTABLE, 'party', 'dismissed',
        string.format('%s left %s\'s party after %d minute%s (%s)', bot:getName(), playerName, minutes, minutes == 1 and '' or 's', reason),
        { player = playerName, reason = reason, minutes = minutes })
end

function log.changedPlan(bot, hereName, plannedName)
    log.event(bot, log.NOTABLE, 'travel', 'changed_plan',
        string.format('%s decided to train in %s instead of travelling on to %s', bot:getName(), hereName, plannedName),
        { zone = hereName, planned = plannedName })
end

function log.gaveUpRoute(bot, zoneName, deaths)
    log.event(bot, log.NOTABLE, 'travel', 'gave_up_route',
        string.format('%s gave up on getting to %s after dying on the way %d time%s', bot:getName(), zoneName, deaths, deaths == 1 and '' or 's'),
        { zone = zoneName, deaths = deaths })
end

function log.gaveUpCamp(bot, zoneName)
    log.event(bot, log.NOTABLE, 'travel', 'gave_up_camp', string.format('%s stopped using a camp in %s that kept getting them killed', bot:getName(), zoneName),
        { zone = zoneName })
end

function log.movedCamp(bot, zoneName)
    log.event(bot, log.DETAIL, 'travel', 'moved_camp', string.format('%s moved to a busier camp in %s', bot:getName(), zoneName),
        { zone = zoneName })
end

local NM_METHODS =
{
    up      = 'it is up now',
    lottery = 'camping its placeholders',
    window  = 'waiting for its spawn window',
    pop     = 'bringing the item that calls it',
}

function log.nmCamp(bot, nmName, itemName, zoneName, mode)
    log.event(bot, log.NOTABLE, 'combat', 'nm_camp',
        string.format('%s went after %s in %s for its %s (%s)', bot:getName(), nmName, zoneName, itemName, NM_METHODS[mode] or mode),
        { nm = nmName, item = itemName, zone = zoneName, method = mode })
end

function log.nmResult(bot, nmName, outcome)
    local level = outcome == 'defeated' and log.MILESTONE or log.NOTABLE
    local text  = outcome == 'defeated' and string.format('%s defeated the notorious monster %s', bot:getName(), nmName) or
        string.format('%s stopped hunting %s (%s)', bot:getName(), nmName, outcome)
    log.event(bot, level, 'combat', outcome == 'defeated' and 'nm_defeated' or 'nm_ended', text, { nm = nmName, outcome = outcome })
end

function log.skillchain(bot, wsName, element)
    log.event(bot, log.DETAIL, 'combat', 'skillchain',
        string.format('%s closed %s with %s', bot:getName(), log.skillchainName(element), wsName),
        { weaponskill = wsName, skillchain = element })
end

function log.magicBurst(bot, spellName)
    log.event(bot, log.DETAIL, 'combat', 'magic_burst', string.format('%s magic burst with %s', bot:getName(), spellName),
        { spell = spellName })
end

return log
