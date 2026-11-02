-----------------------------------
-- xi.worldbots.travel - travelling safely (Phase 3).
--
-- While a bot walks somewhere (a trip across zones, or across a zone to its
-- camp), it watches for mobs that would aggro it and are too strong to fight
-- (ScanBotThreats - the engine's own aggression and detection rules):
--   * Mobs that detect by sound: it puts Sneak on (spell, or Silent Oil).
--   * Mobs that detect by sight: it puts Invisible on (spell, or Prism Powder).
--   * Mobs it can't hide from (true sight/sound, or no Sneak/Invisible to hand):
--     it stops and waits for the mob to roam away, backing off if the mob comes
--     closer. After WAIT_MAX_SEC it gives up waiting and carries on anyway, so
--     a mob camped on a doorway can't strand it forever.
-- Fighting back still comes first: the AI loop handles anything that does aggro.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.travel = xi.worldbots.travel or {}

local travel = xi.worldbots.travel

local SCAN_RADIUS_YALMS     = 45   -- look this far for threats
local SCAN_INTERVAL_SEC     = 1
local DETECT_MARGIN_YALMS   = 10   -- hide when within detection range + this
local WAIT_MARGIN_YALMS     = 6    -- wait when within detection range + this of an unavoidable mob
local BACKOFF_MARGIN_YALMS  = 3    -- back off when an unavoidable mob closes to detection range + this
local BACKOFF_YALMS         = 10   -- how far to back off
local WAIT_MAX_SEC          = 45   -- give up waiting after this...
local WAIT_COOLDOWN_SEC     = 30   -- ...and don't wait again for this long
local ITEM_USE_PAUSE_SEC    = 3    -- hold still while an item is used

local SNEAK_ITEMS     = { 'SILENT_OIL' }
local INVISIBLE_ITEMS = { 'PRISM_POWDER' }

local function safetyState(state)
    state.safety = state.safety or {}
    return state.safety
end

-- Tries the spell, then any item that gives the effect. True if one started.
local function applyCover(bot, charId, state, now, family, items)
    if xi.worldbots.magic.castFamily(bot, charId, state, now, family) then
        return true
    end

    for _, name in ipairs(items) do
        local itemId = xi.item[name]
        if itemId and BotHasItem(charId, itemId) and UseBotItem(charId, itemId) then
            safetyState(state).busyUntil = now + ITEM_USE_PAUSE_SEC
            return true
        end
    end

    return false
end

local function detectRange(threat)
    local range = 0
    if threat.sight then
        range = math.max(range, threat.sightRange)
    end

    if threat.sound then
        range = math.max(range, threat.soundRange)
    end

    return range
end

-- Walks a few yalms directly away from the threat.
local function backOff(bot, charId, threat)
    local dx, dz = bot:getXPos() - threat.x, bot:getZPos() - threat.z
    local len    = math.sqrt(dx * dx + dz * dz)
    if len < 0.1 then
        dx, dz, len = 1, 0, 1
    end

    WalkBotTo(charId,
        bot:getXPos() + dx / len * BACKOFF_YALMS,
        bot:getYPos(),
        bot:getZPos() + dz / len * BACKOFF_YALMS)
end

-- Call before each walking step. True = hold this tick (hiding, waiting for a
-- mob to pass, or backing off); false = carry on walking.
function travel.step(bot, charId, state, now)
    local safety = safetyState(state)

    if IsBotCasting(charId) or now < (safety.busyUntil or 0) then
        return true
    end

    -- Re-use the last verdict between scans.
    if now < (safety.nextScanAt or 0) then
        return safety.holding == true
    end

    safety.nextScanAt = now + SCAN_INTERVAL_SEC
    safety.holding    = false

    local hasSneak     = bot:hasStatusEffect(xi.effect.SNEAK)
    local hasInvisible = bot:hasStatusEffect(xi.effect.INVISIBLE)
    local needSneak, needInvisible = false, false
    local unavoidable

    for _, threat in ipairs(ScanBotThreats(charId, SCAN_RADIUS_YALMS)) do
        local hearsUs = threat.sound and threat.distance < threat.soundRange + DETECT_MARGIN_YALMS
        local seesUs  = threat.sight and threat.distance < threat.sightRange + DETECT_MARGIN_YALMS

        if hearsUs or seesUs then
            if threat.trueDetection then
                unavoidable = unavoidable or threat
            else
                needSneak     = needSneak or (hearsUs and not hasSneak)
                needInvisible = needInvisible or (seesUs and not hasInvisible)
            end
        end
    end

    -- Hide from what can be hidden from.
    if needSneak then
        if applyCover(bot, charId, state, now, 'sneak', SNEAK_ITEMS) then
            safety.holding = true
            return true
        end
    end

    if needInvisible then
        if applyCover(bot, charId, state, now, 'invisible', INVISIBLE_ITEMS) then
            safety.holding = true
            return true
        end
    end

    -- Couldn't hide: the nearest exposed threat has to be waited out too.
    if (needSneak or needInvisible) and unavoidable == nil then
        for _, threat in ipairs(ScanBotThreats(charId, SCAN_RADIUS_YALMS)) do
            if not threat.trueDetection then
                unavoidable = threat
                break
            end
        end
    end

    if unavoidable == nil or now < (safety.noWaitUntil or 0) then
        safety.waitingSince = nil
        return false
    end

    local range = detectRange(unavoidable)
    if unavoidable.distance >= range + WAIT_MARGIN_YALMS then
        safety.waitingSince = nil
        return false
    end

    -- Waited long enough: carry on and take the risk.
    safety.waitingSince = safety.waitingSince or now
    if now >= safety.waitingSince + WAIT_MAX_SEC then
        safety.waitingSince = nil
        safety.noWaitUntil  = now + WAIT_COOLDOWN_SEC
        return false
    end

    -- Coming our way: step back. Otherwise just stand still until it roams off.
    local closing = safety.lastThreatId == unavoidable.mobId and unavoidable.distance < (safety.lastThreatDistance or 999) - 0.5
    if closing and unavoidable.distance < range + BACKOFF_MARGIN_YALMS then
        backOff(bot, charId, unavoidable)
    else
        StopBot(charId)
    end

    safety.lastThreatId       = unavoidable.mobId
    safety.lastThreatDistance = unavoidable.distance
    safety.holding            = true
    return true
end

return travel
