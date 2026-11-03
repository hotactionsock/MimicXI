-----------------------------------
-- xi.worldbots.social - small human touches.
--
-- Emotes at the right moments (through the real emote handler, so everyone
-- nearby sees them like a player's):
--   * /cheer at a party member who levels up (and /joy from the one who did)
--   * /bow on joining a party or being hired, /wave goodbye on leaving
--   * /wave at a real player passing close by (each player once in a while)
--   * /panic at low HP in a fight, /sigh back at the home point after dying
--   * /hurray after defeating a notorious monster
--   * in a city chat circle: an opening /wave, then the odd /laugh, /yes,
--     /no, /smile, /clap, /think and, now and then, a /dance
-- Every emote is rate-limited per bot so nobody spams.
--
-- /away: a small, fixed share of bots (AWAY_SHARE) mark themselves away
-- while idling in a city, like players parked in town.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.social = xi.worldbots.social or {}

local social = xi.worldbots.social

local EMOTE_COOLDOWN_SEC   = 20      -- at most one emote per bot this often
local WAVE_RADIUS_YALMS    = 12
local WAVE_CHANCE          = 0.35    -- chance to wave at a newly-near player
local WAVE_SAME_PLAYER_SEC = 10 * 60 -- don't wave at the same player again for this long
local CHEER_CHANCE         = 0.6
local PANIC_HPP            = 25
local PANIC_CHANCE         = 0.35
local CHAT_EMOTE_MIN_SEC   = 30
local CHAT_EMOTE_MAX_SEC   = 75
local AWAY_SHARE           = 7       -- 1 in this many bots uses /away when idle in town
local SCAN_SEC             = 3

local CHAT_EMOTES = { 'LAUGH', 'YES', 'NO', 'SMILE', 'CLAP', 'THINK', 'LAUGH', 'YES' }

local function socialState(state)
    state.social = state.social or { wavedAt = {} }
    return state.social
end

-- Plays an emote if the bot hasn't emoted lately. True if it did.
function social.emote(bot, charId, state, now, name, targetId, force)
    local s = socialState(state)
    if not force and now < (s.nextEmoteAt or 0) then
        return false
    end

    local emote = xi.emote[name]
    if emote == nil or not BotEmote(charId, emote, targetId or 0, true) then
        return false
    end

    s.nextEmoteAt = now + EMOTE_COOLDOWN_SEC
    return true
end

-- A bot levelled up: it rejoices, nearby party bots cheer it.
function social.onLevelUp(bot, charId, state, now)
    social.emote(bot, charId, state, now, 'JOY', nil, true)

    for _, m in ipairs(GetBotParty(charId) or {}) do
        if
            m.isBot and
            m.charId ~= charId and
            not m.dead and
            m.zoneId == bot:getZoneID()
        then
            local member = GetPlayerByID(m.charId)
            if member and math.randomFloat(0, 1) < CHEER_CHANCE then
                local memberState = xi.worldbots.internal.getState(m.charId, now)
                social.emote(member, m.charId, memberState, now, 'CHEER', charId)
            end
        end
    end
end

function social.onJoinedParty(bot, charId, state, now, leaderId)
    social.emote(bot, charId, state, now, 'BOW', leaderId, true)
end

function social.onLeftParty(bot, charId, state, now)
    social.emote(bot, charId, state, now, 'WAVE', nil, true)
end

function social.onDied(state)
    socialState(state).sighPending = true
end

function social.onNMDefeated(bot, charId, state, now)
    social.emote(bot, charId, state, now, 'HURRAY', nil, true)
end

function social.onChatStart(bot, charId, state, now)
    social.emote(bot, charId, state, now, 'WAVE')
    socialState(state).nextChatEmoteAt = now + math.random(CHAT_EMOTE_MIN_SEC, CHAT_EMOTE_MAX_SEC)
end

-- Is this one of the bots that likes to sit /away in town?
local function awayType(charId)
    return charId % AWAY_SHARE == 0
end

-- Per tick (from xi.worldbots.onZoneTick).
function social.tick(bot, charId, state, now, inCity)
    local s = socialState(state)
    if now < (s.nextScanAt or 0) then
        return
    end

    s.nextScanAt = now + SCAN_SEC

    if bot:isDead() then
        return
    end

    -- Back on its feet after dying.
    if s.sighPending then
        s.sighPending = false
        social.emote(bot, charId, state, now, 'SIGH', nil, true)
        return
    end

    -- In a fight: panic when it's going badly (once per fight).
    if bot:isEngaged() then
        if
            bot:getHPP() < PANIC_HPP and
            not s.panicked and
            math.randomFloat(0, 1) < PANIC_CHANCE
        then
            s.panicked = social.emote(bot, charId, state, now, 'PANIC')
        end

        return
    end

    s.panicked = false

    -- Chatting in a circle in town.
    if state.chat then
        if now >= (s.nextChatEmoteAt or 0) then
            s.nextChatEmoteAt = now + math.random(CHAT_EMOTE_MIN_SEC, CHAT_EMOTE_MAX_SEC)
            local name = math.randomFloat(0, 1) < 0.08 and 'DANCE' or CHAT_EMOTES[math.random(1, #CHAT_EMOTES)]
            social.emote(bot, charId, state, now, name)
        end
    end

    -- A real player walking by: maybe wave.
    for _, playerId in ipairs(GetRealPlayersNearBot(charId, WAVE_RADIUS_YALMS)) do
        if now >= (s.wavedAt[playerId] or 0) then
            s.wavedAt[playerId] = now + WAVE_SAME_PLAYER_SEC
            if math.randomFloat(0, 1) < WAVE_CHANCE then
                social.emote(bot, charId, state, now, 'WAVE', playerId)
            end

            break
        end
    end

    -- /away while idling in town (a few bots only).
    local away = inCity and awayType(charId) and state.reportedActivity == 2 -- resting (see reportActivity)
    if away ~= (s.away or false) then
        SetBotAway(charId, away)
        s.away = away
    end
end

return social
