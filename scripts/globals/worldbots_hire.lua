-----------------------------------
-- xi.worldbots.hire - players hiring bots (Phase 5).
--
-- Finding bots: every bot that isn't in a party shows in /sea as seeking a
-- party (the /invite flag), with a comment like "Lv24 White Mage looking for a
-- party". Players can also just /pcmd add a bot they see in the world. Bots
-- never invite players.
--
-- Accepting: a bot accepts any real player's invite (a bot in a bots-only
-- party leaves it first - engine-side, FreeBotForPlayerInvite). It then plays
-- as a normal party member (worldbots_party.lua): follows the leader across
-- zones, assists, rests, and takes a role worked out from everyone's jobs, the
-- player's included - so it fills what the party is missing.
--
-- Level sync: a hired bot higher than the player who hired it is capped at the
-- player's level (Level Restriction - it earns EXP for the capped level), kept
-- in step as the player levels; a lower-level bot just joins as it is.
--
-- Leaving: when a player removes it, or when no real player is left in the
-- party (the player logged out or left). It then goes back to its own goals.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.hire = xi.worldbots.hire or {}

local hire = xi.worldbots.hire

local CHECK_INTERVAL_SEC  = 2  -- how often to look for invites / check the hire
local SEEK_REFRESH_SEC    = 60 -- how often to refresh the /sea comment

local function partyHasRealPlayer(engine)
    for _, m in ipairs(engine or {}) do
        if not m.isBot then
            return true
        end
    end

    return false
end

-- Ends a hire: drop the level cap, log it, and go back to its own life.
local function endHire(bot, charId, state, now, reason)
    local hired = state.hire
    state.hire  = nil

    SetBotLevelSync(charId, 0)
    if bot:getPartySize() > 1 then
        LeaveBotParty(charId)
    end

    local minutes = math.floor((now - hired.since) / 60)
    xi.worldbots.log.dismissed(bot, hired.hirerName, reason, minutes)

    state.goal = nil -- pick a fresh goal of its own
end

-- Keeps a hired bot's level cap at the hiring player's level.
local function updateSync(bot, charId, state)
    local hirer = GetPlayerByID(state.hire.hirerId)
    if hirer == nil then
        return -- hirer in another zone/process: keep the current cap
    end

    local trueLevel = GetBotTrueLevel(charId)
    local cap       = hirer:getMainLvl()
    local wanted    = trueLevel > cap and cap or 0

    if wanted ~= (state.hire.syncLevel or 0) then
        SetBotLevelSync(charId, wanted)
        state.hire.syncLevel = wanted
        if wanted > 0 then
            xi.worldbots.log.synced(bot, wanted, state.hire.hirerName)
        end
    end
end

-- The /sea entry: seeking a party when free, nothing when in one.
local function updateSeeking(bot, charId, state, now)
    local free = bot:getPartySize() <= 1 and not bot:isDead()
    if free then
        if state.seekingShown and now < (state.seekRefreshAt or 0) then
            return
        end

        state.seekRefreshAt = now + SEEK_REFRESH_SEC
        local comment = string.format('Lv%d %s looking for a party', GetBotTrueLevel(charId), xi.worldbots.log.jobName(bot:getMainJob()))
        if comment ~= state.seekingShown then
            SetBotSeekingParty(charId, true, comment)
            state.seekingShown = comment
        end
    elseif state.seekingShown then
        SetBotSeekingParty(charId, false, '')
        state.seekingShown = nil
    end
end

-- Per-tick entry point (from xi.worldbots.onZoneTick).
function hire.tick(bot, charId, state, now)
    if now < (state.nextHireCheckAt or 0) then
        return
    end

    state.nextHireCheckAt = now + CHECK_INTERVAL_SEC

    -- An invite waiting: players are always welcome; bots never invite.
    local invite = GetBotPendingInvite(charId)
    if invite then
        local accept = not invite.inviterIsBot
        if AnswerBotInvite(charId, accept) and accept then
            local hirer = GetPlayerByID(invite.inviterId)
            state.hire =
            {
                hirerId   = invite.inviterId,
                hirerName = hirer and hirer:getName() or 'a player',
                since     = now,
            }

            xi.worldbots.party.stopSeeking(charId)
            xi.worldbots.log.hired(bot, state.hire.hirerName)
        end
    end

    -- In a player's party without a record (e.g. after a script reload):
    -- treat it as hired by the party's player, leader first.
    if state.hire == nil and bot:getPartySize() > 1 then
        local engine = GetBotParty(charId)
        local player
        for _, m in ipairs(engine or {}) do
            if not m.isBot and (player == nil or m.isLeader) then
                player = m
            end
        end

        if player then
            local entity = GetPlayerByID(player.charId)
            state.hire = { hirerId = player.charId, hirerName = entity and entity:getName() or 'a player', since = now }
        end
    end

    -- On the job: still wanted, and synced?
    if state.hire then
        if bot:getPartySize() <= 1 then
            endHire(bot, charId, state, now, 'removed from the party')
        elseif not partyHasRealPlayer(GetBotParty(charId)) then
            endHire(bot, charId, state, now, 'no players left in the party')
        else
            updateSync(bot, charId, state)
        end
    end

    updateSeeking(bot, charId, state, now)
end

-- Is this bot currently working for a player?
function hire.isHired(state)
    return state.hire ~= nil
end

return hire
