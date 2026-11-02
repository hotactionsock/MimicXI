-----------------------------------
-- xi.worldbots.skillchain - skillchains and magic bursts in a party (Phase 4c).
--
-- Weapon skills (party members with 1000+ TP):
--   1. Close: if the target has an open skillchain window (3s+ after the last
--      weapon skill, before it expires), use the weapon skill that makes the
--      highest-level skillchain (PredictBotSkillchain - the engine's own rules).
--   2. Open: if another bot in the party also has 1000+ TP, pick a pair - my
--      opener, their closer - that makes the best skillchain, preferring
--      chains a party caster can magic burst on, and a weaker opener (the
--      closer does the damage). The partner is told which weapon skill to close
--      with (record.chainPlan).
--   3. Wait: if a partner is close to 1000 TP, hold TP a few seconds for them.
--   4. Otherwise use the strongest weapon skill, as solo.
-- Magic bursts are in worldbots_magic.lua: casters nuke with a matching element
-- the moment a skillchain goes off, and hold their nukes while one is being set up.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.skillchain = xi.worldbots.skillchain or {}

local skillchain = xi.worldbots.skillchain

local WS_CACHE_SEC          = 60   -- re-read a bot's weapon skills this often
local WINDOW_OPENS_MS       = 3000 -- a link needs this long after the previous one
local WINDOW_MIN_LEFT_MS    = 700  -- don't try to close with less than this left
local PLAN_EXPIRES_SEC      = 12
local PARTNER_SOON_TP       = 800  -- a partner this close to 1000 is worth waiting for
local HOLD_MAX_SEC          = 5
local HOLD_MAX_TP           = 2000 -- never sit on more TP than this waiting
local BURST_BONUS           = 50   -- score for a chain a party caster can burst on

-- Spell elements each skillchain lets you magic burst with
-- (battleutils::GetSkillchainMagicElement; ELEMENT ids: 1 fire, 2 ice, 3 wind,
-- 4 earth, 5 thunder, 6 water, 7 light, 8 dark).
local BURST_ELEMENTS =
{
    [1]  = { 7 },          [2]  = { 8 },          [3]  = { 1 },          [4] = { 4 },
    [5]  = { 6 },          [6]  = { 3 },          [7]  = { 2 },          [8] = { 5 },
    [9]  = { 8, 4 },       [10] = { 6, 2 },       [11] = { 7, 1 },       [12] = { 3, 5 },
    [13] = { 7, 1, 3, 5 }, [14] = { 8, 4, 6, 2 }, [15] = { 7, 1, 3, 5 }, [16] = { 8, 4, 6, 2 },
}

local function weaponSkillsOf(charId, now)
    local state = xi.worldbots.internal.getState(charId, now)
    state.sc = state.sc or {}
    if state.sc.ws == nil or now >= (state.sc.readAt or 0) + WS_CACHE_SEC then
        state.sc.ws     = GetBotWeaponSkills(charId)
        state.sc.readAt = now
    end

    return state.sc.ws
end

-- Elements the party's casters can nuke with (for burst-friendly chains).
local function partyBurstElements(record, now)
    local elements = {}
    for _, id in ipairs(record.members) do
        local state = xi.worldbots.internal.getState(id, now)
        for element in pairs(xi.worldbots.magic.nukeElements(state)) do
            elements[element] = true
        end
    end

    return elements
end

local function burstable(scElement, partyElements)
    for _, element in ipairs(BURST_ELEMENTS[scElement] or {}) do
        if partyElements[element] then
            return true
        end
    end

    return false
end

-- Bots in the party (not me) fighting the same target, with their TP.
local function partners(bot, charId)
    local result = {}
    local target = bot:getTarget()
    if target == nil then
        return result
    end

    for _, m in ipairs(GetBotParty(charId) or {}) do
        if
            m.charId ~= charId and
            m.isBot and
            not m.dead and
            m.engaged and
            m.targetId == target:getID()
        then
            table.insert(result, m)
        end
    end

    return result
end

-- Best weapon skill to close the target's open window with, or nil.
local function bestCloser(charId, now, preferred)
    local best, bestTier = nil, 0
    for _, ws in ipairs(weaponSkillsOf(charId, now)) do
        local result = PredictBotSkillchain(charId, ws.id)
        local tier   = result.tier + ((preferred == ws.id and result.tier > 0) and 0.5 or 0)
        if tier > bestTier then
            best, bestTier = ws.id, tier
        end
    end

    return best
end

-- Decides the weapon skill for a party member with 1000+ TP.
-- Returns wsId to use, 'hold' to keep the TP for now, or nil for the default
-- (strongest weapon skill). Solo bots get nil.
function skillchain.decide(bot, charId, state, now)
    local record = xi.worldbots.party.get(bot, charId, now)
    if record == nil then
        return nil
    end

    local plan = record.chainPlan
    if plan and now >= plan.at + PLAN_EXPIRES_SEC then
        record.chainPlan = nil
        plan = nil
    end

    -- 1. Close an open window.
    local window = GetBotTargetSkillchain(charId)
    if window and window.remainingMs > WINDOW_MIN_LEFT_MS then
        if window.ageMs >= WINDOW_OPENS_MS then
            local preferred = (plan and plan.closer == charId) and plan.ws or nil
            local closer    = bestCloser(charId, now, preferred)
            if closer then
                if plan and plan.closer == charId then
                    record.chainPlan = nil
                end

                return closer
            end
        elseif plan and plan.closer == charId then
            return 'hold' -- I'm the planned closer: wait for the window to open
        end
    end

    -- 2. Open with a partner who's ready.
    local partnerList = partners(bot, charId)
    local burstSet    = partyBurstElements(record, now)
    local best        = nil

    for _, partner in ipairs(partnerList) do
        if partner.tp >= 1000 then
            for _, mine in ipairs(weaponSkillsOf(charId, now)) do
                for _, theirs in ipairs(weaponSkillsOf(partner.charId, now)) do
                    local result = SkillchainBetween(mine.id, theirs.id)
                    if result.tier > 0 then
                        local score = result.tier * 100 +
                            (burstable(result.element, burstSet) and BURST_BONUS or 0) -
                            mine.skillLevel * 0.1
                        if best == nil or score > best.score then
                            best = { score = score, opener = mine.id, closer = theirs.id, partner = partner.charId }
                        end
                    end
                end
            end
        end
    end

    if best then
        record.chainPlan = { opener = charId, closer = best.partner, ws = best.closer, at = now }
        state.scHoldSince = nil
        return best.opener
    end

    -- 3. Someone's nearly ready: hold TP briefly.
    if bot:getTP() < HOLD_MAX_TP then
        for _, partner in ipairs(partnerList) do
            if partner.tp >= PARTNER_SOON_TP and partner.tp < 1000 then
                state.scHoldSince = state.scHoldSince or now
                if now < state.scHoldSince + HOLD_MAX_SEC then
                    return 'hold'
                end
            end
        end
    end

    state.scHoldSince = nil
    return nil
end

-- For worldbots_magic: is a skillchain being set up on this bot's target?
-- (Casters save their nuke for the burst.)
function skillchain.chainPending(bot, charId, now)
    local record = xi.worldbots.party.get(bot, charId, now)
    if record == nil then
        return false
    end

    if record.chainPlan and now < record.chainPlan.at + PLAN_EXPIRES_SEC then
        return true
    end

    local window = GetBotTargetSkillchain(charId)
    if window and not window.closed and window.remainingMs > WINDOW_MIN_LEFT_MS then
        for _, partner in ipairs(partners(bot, charId)) do
            if partner.tp >= 1000 then
                return true
            end
        end
    end

    return false
end

return skillchain
