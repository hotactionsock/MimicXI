-----------------------------------
-- func: worldbot <create name [race] [face]|edit charid [race] [face] [name]|
--                 spawn charid|despawn charid|delete charid|list|
--                 travel charid zoneid|goal charid [level|home]|lines|
--                 give charid itemid [qty]|inv charid|gear charid|
--                 populate count|delete all>
-- desc: GM management of AI-driven world-population bot characters (see
--       src/map/utils/botutils.h and scripts/globals/worldbots.lua).
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

-- name -> CharRace id (see src/map/entities/char_entity.h)
local RACES =
{
    humemale       = 1,
    humefemale     = 2,
    elvaanmale     = 3,
    elvaanfemale   = 4,
    tarutarumale   = 5,
    tarutarufemale = 6,
    mithra         = 7,
    galka          = 8,
}

local RACE_COUNT = 8

-- Standard faces only (0-15) - 16-23 are custom C-variant faces that need
-- custom client DATs, so they're never picked randomly, only if typed explicitly.
local STANDARD_FACE_COUNT = 16

-- The six jobs a new character can start as (WAR, MNK, WHM, BLM, RDM, THF).
local STARTING_JOBS = { 1, 2, 3, 4, 5, 6 }

local POPULATE_MAX = 50

-- Where a new character of each nation starts: one of its three cities, picked
-- at random - the same choice character creation makes (loginHelpers).
-- Position 0,0,0 is what a new character is saved with too: on first login
-- the city's zone script puts it outside a Mog House (xi.moghouse).
local STARTING_CITIES =
{
    { 'SOUTHERN_SAN_DORIA', 'NORTHERN_SAN_DORIA', 'PORT_SAN_DORIA' }, -- San d'Oria
    { 'BASTOK_MINES', 'BASTOK_MARKETS', 'PORT_BASTOK' },              -- Bastok
    { 'WINDURST_WATERS', 'PORT_WINDURST', 'WINDURST_WOODS' },         -- Windurst
}

-- Random two-to-three syllable names, FFXI style (letters only, 3-15 chars).
local NAME_ONSETS = { 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'z', 'br', 'ch', 'dr', 'gr', 'kr', 'sh', 'th', 'tr', 'st', '' }
local NAME_VOWELS = { 'a', 'e', 'i', 'o', 'u', 'a', 'e', 'ai', 'ia', 'ou', 'y' }
local NAME_CODAS  = { '', '', '', 'n', 'r', 's', 'l', 'th', 'x', 'm', 'k', 'd' }

local function randomName()
    local name = ''
    for _ = 1, math.random(2, 3) do
        name = name .. NAME_ONSETS[math.random(#NAME_ONSETS)] .. NAME_VOWELS[math.random(#NAME_VOWELS)]
    end

    name = name .. NAME_CODAS[math.random(#NAME_CODAS)]
    name = name:sub(1, 12)

    return name:sub(1, 1):upper() .. name:sub(2)
end

local function usage(player)
    player:printToPlayer('!worldbot create <name> [race] [face] - created at your position; race/face random if omitted')
    player:printToPlayer('!worldbot edit <charid> [race] [face] [name] - use "-" to leave a field unchanged')
    player:printToPlayer('  race: 1-8 or a name (humemale, humefemale, elvaanmale, elvaanfemale, tarutarumale, tarutarufemale, mithra, galka)')
    player:printToPlayer('  face: 0-15')
    player:printToPlayer('!worldbot populate <count> - create+spawn that many new bots, each in a random starting city like a new character')
    player:printToPlayer('!worldbot populate <count> here - create+spawn them at your position instead, levelling in this zone')
    player:printToPlayer('!worldbot spawn <charid>')
    player:printToPlayer('!worldbot despawn <charid> - parks it (not respawned on restart)')
    player:printToPlayer('!worldbot delete <charid> - permanently deletes the bot and its account')
    player:printToPlayer('!worldbot delete all - permanently deletes every bot (bot accounts only)')
    player:printToPlayer('!worldbot list')
    player:printToPlayer('!worldbot zones - zones holding bots: awake/asleep, and why')
    player:printToPlayer('!worldbot jobs <charid> - career job, current jobs and levels')
    player:printToPlayer('!worldbot career <charid> <job> - set its career job (e.g. PLD or 7)')
    player:printToPlayer('!worldbot party <charid> - its party, roles and camp')
    player:printToPlayer('!worldbot party form <leaderid> <id> [id...] - put bots in a party (first = leader)')
    player:printToPlayer('!worldbot party disband <charid> - break up that bot\'s party')
    player:printToPlayer('!worldbot log <charid> [count] - its latest activity log lines (default 10, max 50)')
    player:printToPlayer('!worldbot travel <charid> <zoneid> - route across zone lines to that zone')
    player:printToPlayer('!worldbot goal <charid> [level|home] - show the goal, or give it a new one')
    player:printToPlayer('!worldbot goal all <level|home> - give every spawned bot in your zone that goal')
    player:printToPlayer('!worldbot lines - zone lines bots can use in your current zone')
    player:printToPlayer('!worldbot give <charid> <itemid> [qty] - give an item (then equips/learns it if useful)')
    player:printToPlayer('!worldbot inv <charid> - list its items (* = equipped)')
    player:printToPlayer('!worldbot gear <charid> - learn scrolls, re-plan gear sets and re-read spells now')
end

-- Resolves a race token (nil, a race name, or a number) to a valid CharRace id,
-- or nil if the token was given but isn't valid. Picks randomly if the token is nil.
local function resolveRace(token)
    if token == nil then
        return math.random(1, RACE_COUNT)
    end

    local byName = RACES[token:lower()]
    if byName then
        return byName
    end

    local byNumber = tonumber(token)
    if byNumber and byNumber >= 1 and byNumber <= RACE_COUNT then
        return byNumber
    end

    return nil
end

-- Resolves a face token (nil or a number) to a valid CharFace id, or nil if the
-- token was given but isn't valid. Picks randomly (standard faces only) if nil.
local function resolveFace(token)
    if token == nil then
        return math.random(0, STANDARD_FACE_COUNT - 1)
    end

    local byNumber = tonumber(token)
    if byNumber and byNumber >= 0 and byNumber <= 23 then
        return byNumber
    end

    return nil
end

-- Same as resolveRace/resolveFace but for `edit`: a nil or "-" token means
-- "leave unchanged" (the current value) rather than "pick randomly".
local function resolveRaceKeep(token, current)
    if token == nil or token == '-' then
        return current
    end

    return resolveRace(token)
end

local function resolveFaceKeep(token, current)
    if token == nil or token == '-' then
        return current
    end

    return resolveFace(token)
end

commandObj.onTrigger = function(player, args)
    local sub, rest = (args or ''):match('^(%S*)%s*(.*)$')

    if sub == 'create' then
        local nameArg, raceArg, faceArg = rest:match('^(%S*)%s*(%S*)%s*(%S*)$')

        local name = nameArg ~= '' and nameArg or 'Bot'

        local race = resolveRace(raceArg ~= '' and raceArg or nil)
        if race == nil then
            player:printToPlayer(string.format('Invalid race "%s".', raceArg))
            usage(player)
            return
        end

        local face = resolveFace(faceArg ~= '' and faceArg or nil)
        if face == nil then
            player:printToPlayer(string.format('Invalid face "%s".', faceArg))
            usage(player)
            return
        end

        local charId = CreateBotCharacter(player:getZoneID(), player:getXPos(), player:getYPos(), player:getZPos(), player:getRotPos(), race, face, name,
            STARTING_JOBS[math.random(#STARTING_JOBS)], math.random(0, 2))
        if charId == 0 then
            player:printToPlayer('Failed to create bot character (name taken?) - see map server log.')
            return
        end

        player:printToPlayer(string.format('Created bot character "%s" (charid %d, race %d, face %d) at your position. Use !worldbot spawn %d.', name, charId, race, face, charId))
    elseif sub == 'edit' then
        local charIdArg, raceArg, faceArg, nameArg = rest:match('^(%S*)%s*(%S*)%s*(%S*)%s*(%S*)$')

        local charId = tonumber(charIdArg)
        if charId == nil then
            usage(player)
            return
        end

        local current = GetBotAppearance(charId)
        if current == nil then
            player:printToPlayer(string.format('No bot character with charid %d.', charId))
            return
        end

        local race = resolveRaceKeep(raceArg ~= '' and raceArg or nil, current.race)
        if race == nil then
            player:printToPlayer(string.format('Invalid race "%s".', raceArg))
            usage(player)
            return
        end

        local face = resolveFaceKeep(faceArg ~= '' and faceArg or nil, current.face)
        if face == nil then
            player:printToPlayer(string.format('Invalid face "%s".', faceArg))
            usage(player)
            return
        end

        local name = (nameArg ~= '' and nameArg ~= '-') and nameArg or current.name

        -- Editing the DB row doesn't change what's already spawned in the world -
        -- despawn first so the new appearance is what shows up next time it's spawned.
        xi.worldbots.forget(charId)
        DespawnBotCharacter(charId)

        if not EditBotCharacter(charId, race, face, name) then
            player:printToPlayer('Failed to edit bot character - see map server log.')
            return
        end

        player:printToPlayer(string.format('Edited bot charid %d: name "%s", race %d, face %d. Use !worldbot spawn %d to see it.', charId, name, race, face, charId))
    elseif sub == 'spawn' then
        local charId = tonumber(rest)
        if charId == nil then
            usage(player)
            return
        end

        local bot = SpawnBotCharacter(charId)
        if bot == nil then
            player:printToPlayer('Failed to spawn bot - see map server log.')
            return
        end

        player:printToPlayer(string.format('Spawned bot charid %d.', charId))
    elseif sub == 'despawn' then
        local charId = tonumber(rest)
        if charId == nil then
            usage(player)
            return
        end

        if not IsBotCharacter(charId) then
            player:printToPlayer(string.format('No bot character with charid %d.', charId))
            return
        end

        xi.worldbots.forget(charId)
        DespawnBotCharacter(charId)
        player:printToPlayer(string.format('Despawned bot charid %d.', charId))
    elseif sub == 'populate' then
        local countToken, mode = (rest or ''):match('^(%S+)%s*(%S*)$')
        local count = tonumber(countToken)
        if count == nil or count < 1 or (mode ~= '' and mode ~= 'here') then
            usage(player)
            return
        end

        count = math.min(math.floor(count), POPULATE_MAX)

        local here     = mode == 'here'
        local created  = 0
        local leveling = 0
        local byNation = { 0, 0, 0 }

        for _ = 1, count do
            -- Where it starts: a random nation's random starting city (like a
            -- new character), or the GM's spot for 'here'.
            local nation = math.random(1, #STARTING_CITIES)
            local zoneId, x, y, z

            if here then
                zoneId, x, y, z = player:getZoneID(), player:getXPos(), player:getYPos(), player:getZPos()
            else
                local cities = STARTING_CITIES[nation]
                zoneId, x, y, z = xi.zone[cities[math.random(1, #cities)]], 0, 0, 0
            end

            -- A random name can clash with an existing character - retry a few times.
            local charId = 0
            for _ = 1, 10 do
                charId = CreateBotCharacter(zoneId, x, y, z, math.random(0, 255),
                    resolveRace(nil), resolveFace(nil), randomName(), STARTING_JOBS[math.random(#STARTING_JOBS)], math.random(0, 2))
                if charId ~= 0 then
                    break
                end
            end

            local bot = charId ~= 0 and SpawnBotCharacter(charId) or nil
            if bot ~= nil then
                created = created + 1

                if here then
                    if xi.worldbots.setGoal(charId, 'level', zoneId) then
                        leveling = leveling + 1
                    end
                else
                    -- Placed outside a Mog House on first login: anchor it there.
                    -- It picks its own levelling zone (and career) on its first plan.
                    SetBotAnchor(charId, bot:getXPos(), bot:getYPos(), bot:getZPos())
                    byNation[nation] = byNation[nation] + 1
                end
            end
        end

        if here then
            player:printToPlayer(string.format('Created and spawned %d/%d bot(s); %d levelling in this zone.', created, count, leveling))
        else
            player:printToPlayer(string.format('Created and spawned %d/%d bot(s) in their starting cities: %d San d\'Oria, %d Bastok, %d Windurst.',
                created, count, byNation[1], byNation[2], byNation[3]))
        end
    elseif sub == 'delete' and rest == 'all' then
        local count = 0
        for _, bot in ipairs(GetBotList()) do
            xi.worldbots.forget(bot.charId)
            if DeleteBotCharacter(bot.charId) then
                count = count + 1
            end
        end

        player:printToPlayer(string.format('Deleted %d bot(s) and their accounts.', count))
    elseif sub == 'delete' then
        local charId = tonumber(rest)
        if charId == nil then
            usage(player)
            return
        end

        xi.worldbots.forget(charId)
        if not DeleteBotCharacter(charId) then
            player:printToPlayer(string.format('No bot character with charid %d.', charId))
            return
        end

        player:printToPlayer(string.format('Deleted bot charid %d and its account.', charId))
    elseif sub == 'travel' then
        local charIdArg, zoneArg = rest:match('^(%S*)%s*(%S*)$')
        local charId     = tonumber(charIdArg)
        local destZoneId = tonumber(zoneArg)
        if charId == nil or destZoneId == nil then
            usage(player)
            return
        end

        local goal, reason = xi.worldbots.setGoal(charId, 'zone', destZoneId)
        if goal == nil then
            player:printToPlayer(string.format('Bot %d cannot travel: %s.', charId, reason))
            return
        end

        player:printToPlayer(string.format('Bot %d travelling to zone %d.', charId, goal.zoneId))
    elseif sub == 'goal' then
        local charIdArg, kindArg = rest:match('^(%S*)%s*(%S*)$')

        -- !worldbot goal all <kind>: every spawned bot in the GM's zone.
        if charIdArg == 'all' and kindArg ~= '' then
            local count = 0
            for _, bot in ipairs(GetBotList()) do
                if bot.spawned and bot.zoneId == player:getZoneID() and xi.worldbots.setGoal(bot.charId, kindArg, nil) then
                    count = count + 1
                end
            end

            player:printToPlayer(string.format('Gave %d bot(s) in this zone the goal: %s.', count, kindArg))
            return
        end

        local charId = tonumber(charIdArg)
        if charId == nil then
            usage(player)
            return
        end

        if kindArg == '' then
            local goal = xi.worldbots.getGoal(charId)
            if goal == nil then
                player:printToPlayer(string.format('Bot %d has no goal yet.', charId))
            else
                local remaining = goal.untilTime and math.max(0, goal.untilTime - GetSystemTime()) or nil
                player:printToPlayer(string.format('Bot %d: %s in zone %d - %s', charId, goal.kind, goal.zoneId,
                    goal.settled and string.format('settled, %d min left', math.floor((remaining or 0) / 60)) or 'on the way'))
            end

            return
        end

        local goal, reason = xi.worldbots.setGoal(charId, kindArg, nil)
        if goal == nil then
            player:printToPlayer(string.format('Bot %d: cannot set goal: %s.', charId, reason))
            return
        end

        player:printToPlayer(string.format('Bot %d: new goal %s in zone %d.', charId, goal.kind, goal.zoneId))
    elseif sub == 'give' then
        local charIdArg, itemArg, qtyArg = rest:match('^(%S*)%s*(%S*)%s*(%S*)$')
        local charId = tonumber(charIdArg)
        local itemId = tonumber(itemArg)
        local qty    = tonumber(qtyArg) or 1
        if charId == nil or itemId == nil then
            usage(player)
            return
        end

        local bot = GetPlayerByID(charId)
        if bot == nil or not IsBotCharacter(charId) then
            player:printToPlayer(string.format('Bot %d is not spawned.', charId))
            return
        end

        if not bot:addItem(itemId, qty, true) then
            player:printToPlayer(string.format('Bot %d could not take item %d (inventory full or invalid item).', charId, itemId))
            return
        end

        local result = ManageBotInventory(charId)
        player:printToPlayer(string.format('Gave bot %d item %d x%d - equipped %d, learned %d.', charId, itemId, qty, result.equipped, result.learned))
    elseif sub == 'gear' then
        local charId = tonumber(rest)
        if charId == nil then
            usage(player)
            return
        end

        local result = ManageBotInventory(charId)
        local planned = xi.worldbots.replanGear(charId)
        player:printToPlayer(string.format('Bot %d: equipped %d, learned %d%s.', charId, result.equipped, result.learned,
            planned and ', gear sets re-planned' or ''))
    elseif sub == 'inv' then
        local charId = tonumber(rest)
        if charId == nil then
            usage(player)
            return
        end

        local items = GetBotItems(charId)
        if #items == 0 then
            player:printToPlayer(string.format('Bot %d has no items (or is not spawned).', charId))
            return
        end

        local SLOT_NAMES = { [0] = 'main', 'sub', 'range', 'ammo', 'head', 'body', 'hands', 'legs', 'feet', 'neck', 'waist', 'ear1', 'ear2', 'ring1', 'ring2', 'back' }
        for _, item in ipairs(items) do
            local equipped = item.equipSlot >= 0 and string.format(' * %s', SLOT_NAMES[item.equipSlot] or '?') or ''
            player:printToPlayer(string.format('  [%d:%d] %s (%d) x%d%s', item.container, item.slot, item.name, item.itemId, item.quantity, equipped))
        end
    elseif sub == 'lines' then
        local lines = xi.worldbots.zoneLines(player:getZoneID())
        if #lines == 0 then
            player:printToPlayer('No zone lines bots can use in this zone.')
        else
            for _, line in ipairs(lines) do
                player:printToPlayer(string.format('  line %d -> zone %d at (%.1f, %.1f, %.1f)', line.id, line.zoneId, line.x, line.y, line.z))
            end
        end
    elseif sub == 'jobs' then
        local charId = tonumber(rest)
        if not charId then
            usage(player)
            return
        end

        local text = xi.worldbots.describeJobs(charId)
        player:printToPlayer(text or 'That bot is not spawned.')
    elseif sub == 'career' then
        local charIdToken, jobToken = (rest or ''):match('^(%S+)%s+(%S+)$')
        local charId = tonumber(charIdToken)
        local job    = tonumber(jobToken) or (jobToken and xi.job[string.upper(jobToken)])
        if not charId or not job or job <= 0 or not IsBotCharacter(charId) then
            usage(player)
            return
        end

        xi.worldbots.setCareer(charId, job)
        player:printToPlayer(string.format('Bot %d career set to job %d; it changes jobs at its next goal.', charId, job))
    elseif sub == 'party' then
        local action, args2 = (rest or ''):match('^(%S+)%s*(.*)$')
        local now = GetSystemTime()

        if action == 'form' then
            local ids = {}
            for token in (args2 or ''):gmatch('%S+') do
                local id = tonumber(token)
                if id and IsBotCharacter(id) then
                    table.insert(ids, id)
                end
            end

            local record = #ids >= 2 and xi.worldbots.party.forceForm(ids, now) or nil
            player:printToPlayer(record and xi.worldbots.party.describe(ids[1], now) or 'Could not form a party (need 2+ spawned bots not already in a party).')
        elseif action == 'disband' then
            local charId = tonumber(args2)
            local bot    = charId and GetPlayerByID(charId)
            local record = bot and xi.worldbots.party.get(bot, charId, now)
            if record then
                xi.worldbots.party.disband(record, now)
                player:printToPlayer('Party disbanded.')
            else
                player:printToPlayer('That bot is not in a party.')
            end
        else
            local charId = tonumber(action)
            if not charId then
                usage(player)
                return
            end

            player:printToPlayer(xi.worldbots.party.describe(charId, now) or 'That bot is not spawned.')
        end
    elseif sub == 'log' then
        local idToken, countToken = (rest or ''):match('^(%S+)%s*(%S*)$')
        local charId = tonumber(idToken)
        if not charId then
            usage(player)
            return
        end

        local lines = GetBotLog(charId, tonumber(countToken) or 10)
        if #lines == 0 then
            player:printToPlayer('No activity logged for that bot (check map.WORLDBOTS_LOG_LEVEL).')
        else
            -- Oldest first, so it reads top to bottom.
            for i = #lines, 1, -1 do
                player:printToPlayer(string.format('  [%s] %s', os.date('%m-%d %H:%M', lines[i].ts), lines[i].message))
            end
        end
    elseif sub == 'zones' then
        local zones = GetBotAwakeZones()
        if #zones == 0 then
            player:printToPlayer('No zones hold bots yet (updates every 5s).')
        else
            local held = 0
            table.sort(zones, function(a, b)
                return a.demand > b.demand
            end)

            for _, z in ipairs(zones) do
                local status = 'asleep'
                if z.players then
                    status = 'awake (players)'
                elseif z.held then
                    status = 'awake (bots)'
                    held   = held + 1
                elseif z.demand > 0 then
                    status = 'waiting for a slot'
                end

                player:printToPlayer(string.format('  zone %d - %d bot(s), demand %.2f - %s', z.zoneId, z.bots, z.demand, status))
            end

            player:printToPlayer(string.format('%d zone(s) held awake by bots (limit: map.WORLDBOTS_MAX_AWAKE_ZONES).', held))
        end
    elseif sub == 'list' then
        local bots = GetBotList()
        if #bots == 0 then
            player:printToPlayer('No world bots exist.')
        else
            for _, bot in ipairs(bots) do
                local status = bot.spawned and 'spawned' or (bot.active and 'active (not spawned)' or 'parked')
                player:printToPlayer(string.format('  %d %s - zone %d - %s', bot.charId, bot.name, bot.zoneId, status))
            end
        end
    else
        usage(player)
    end
end

return commandObj
