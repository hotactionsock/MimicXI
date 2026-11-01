-----------------------------------
-- func: worldbot <create name [race] [face]|edit charid [race] [face] [name]|
--                 spawn charid|despawn charid|delete charid|list>
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

local function usage(player)
    player:printToPlayer('!worldbot create <name> [race] [face] - created at your position; race/face random if omitted')
    player:printToPlayer('!worldbot edit <charid> [race] [face] [name] - use "-" to leave a field unchanged')
    player:printToPlayer('  race: 1-8 or a name (humemale, humefemale, elvaanmale, elvaanfemale, tarutarumale, tarutarufemale, mithra, galka)')
    player:printToPlayer('  face: 0-15')
    player:printToPlayer('!worldbot spawn <charid>')
    player:printToPlayer('!worldbot despawn <charid> - parks it (not respawned on restart)')
    player:printToPlayer('!worldbot delete <charid> - permanently deletes the bot and its account')
    player:printToPlayer('!worldbot list')
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

        local charId = CreateBotCharacter(player:getZoneID(), player:getXPos(), player:getYPos(), player:getZPos(), player:getRotPos(), race, face, name)
        if charId == 0 then
            player:printToPlayer('Failed to create bot character - see map server log.')
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
