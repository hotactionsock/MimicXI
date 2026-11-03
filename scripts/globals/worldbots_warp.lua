-----------------------------------
-- xi.worldbots.warp - faster travel: outpost teleports and home point warps.
--
-- Before a long walk out of a city, a bot looks for a quicker way, under the
-- same rules and fees as a player:
--   * outpost teleport - from its own nation's gate guard (the _IM/_TK/_WW
--                        conquest guards), to any region outpost it has
--                        unlocked (map.UNLOCK_OUTPOST_WARPS) and is high
--                        enough level for - xi.conquest.canTeleportToOutpost
--                        and outpostFee (triple outside its nation's regions)
--   * home point warp  - from a city crystal to another home point it has
--                        touched, for the usual home point fee
-- It only bothers when it saves at least MIN_HOPS_SAVED zones of walking; it
-- walks to the guard or crystal, pays, and arrives at the other end.
--
-- Bots unlock home points the way players do: by passing close to a crystal
-- (touch()).
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.warp = xi.worldbots.warp or {}

local warp = xi.worldbots.warp

local MIN_HOPS_SAVED     = 3   -- a warp must save at least this many zone hops
local TOUCH_YALMS        = 6   -- passing this close to a crystal unlocks it
local TOUCH_CHECK_SEC    = 5
local WARP_RETRY_SEC     = 10 * 60 -- after a warp fails, walk instead for a while

-- Each nation's city gate guards (conquest guards that sell outpost teleports
-- to their own nation's citizens).
local GATE_GUARDS = nil

local function gateGuards()
    if GATE_GUARDS then
        return GATE_GUARDS
    end

    GATE_GUARDS =
    {
        [xi.zone.SOUTHERN_SAN_DORIA] = { nation = xi.nation.SANDORIA, names = { 'Arpevion_TK', 'Aravoge_TK' } },
        [xi.zone.NORTHERN_SAN_DORIA] = { nation = xi.nation.SANDORIA, names = { 'Achantere_TK' } },
        [xi.zone.BASTOK_MINES]       = { nation = xi.nation.BASTOK,   names = { 'Crying_Wind_IM' } },
        [xi.zone.BASTOK_MARKETS]     = { nation = xi.nation.BASTOK,   names = { 'Rabid_Wolf_IM' } },
        [xi.zone.PORT_BASTOK]        = { nation = xi.nation.BASTOK,   names = { 'Flying_Axe_IM' } },
        [xi.zone.WINDURST_WATERS]    = { nation = xi.nation.WINDURST, names = { 'Puroiko-Maiko_WW' } },
        [xi.zone.WINDURST_WOODS]     = { nation = xi.nation.WINDURST, names = { 'Harara_WW' } },
        [xi.zone.PORT_WINDURST]      = { nation = xi.nation.WINDURST, names = { 'Milma-Hapilma_WW' } },
    }

    return GATE_GUARDS
end

local function distance2d(a, b)
    local dx, dz = a.x - b.x, a.z - b.z
    return math.sqrt(dx * dx + dz * dz)
end

local function posOf(entity)
    return { x = entity:getXPos(), y = entity:getYPos(), z = entity:getZPos() }
end

-- The nearest of the bot's own-nation gate guards in this zone, or nil.
local function nearestGuard(bot, zone)
    local guards = gateGuards()[zone:getID()]
    if guards == nil or guards.nation ~= bot:getNation() then
        return nil
    end

    local here = posOf(bot)
    local best, bestDist = nil, math.huge
    for _, name in ipairs(guards.names) do
        for _, npc in ipairs(zone:queryEntitiesByName(name) or {}) do
            local dist = distance2d(here, posOf(npc))
            if dist < bestDist then
                best, bestDist = npc, dist
            end
        end
    end

    return best
end

-- Passing a crystal unlocks its home point (from xi.worldbots.onZoneTick, in
-- zones with social spots). crystals: the zone's 'hp' social spots.
function warp.touch(bot, state, now, zoneId, crystals)
    if now < (state.nextTouchCheckAt or 0) then
        return
    end

    state.nextTouchCheckAt = now + TOUCH_CHECK_SEC

    local here = posOf(bot)
    for _, crystal in ipairs(crystals) do
        if distance2d(here, crystal) <= TOUCH_YALMS then
            local index = xi.homepoint.indexNear(zoneId, crystal)
            if index and xi.homepoint.unlock(bot, index) then
                xi.worldbots.log.event(bot, xi.worldbots.log.DETAIL, 'travel', 'homepoint_unlocked',
                    string.format('%s touched the home point crystal in %s', bot:getName(), GetBotZoneName(zoneId)),
                    { zone_id = zoneId, homepoint = index })
            end
        end
    end
end

-- Looks for a warp that saves walking to goalZoneId. Returns a walk plan
-- target and the warp, or nil. hopsBetween(from, to) counts zone hops.
function warp.find(bot, state, now, zoneId, goalZoneId, crystals, hopsBetween)
    if now < (state.warpRetryAt or 0) or bot:isEngaged() then
        return nil
    end

    local walkHops = hopsBetween(zoneId, goalZoneId)
    if walkHops < MIN_HOPS_SAVED + 1 then
        return nil
    end

    local zone = bot:getZone()
    if zone == nil then
        return nil
    end

    local best     = nil
    local bestHops = walkHops - MIN_HOPS_SAVED

    -- Outpost teleports from its own nation's gate guard.
    local guard = nearestGuard(bot, zone)
    if guard then
        for region = xi.region.RONFAURE, xi.region.TAVNAZIANARCH do
            local dest = xi.teleport.outpostDestination(region)
            if dest and xi.conquest.canTeleportToOutpost(bot, region) then
                local hops = hopsBetween(dest[5], goalZoneId)
                if hops <= bestHops then
                    best, bestHops = { kind = 'outpost', dest = dest, cost = xi.conquest.outpostFee(bot, region), at = posOf(guard) }, hops
                end
            end
        end
    end

    -- Home point warps from the nearest city crystal.
    local here = posOf(bot)
    local crystal, crystalDist = nil, math.huge
    for _, spot in ipairs(crystals) do
        local dist = distance2d(here, spot)
        if dist < crystalDist then
            crystal, crystalDist = spot, dist
        end
    end

    local origin = crystal and xi.homepoint.indexNear(zoneId, crystal)
    if origin then
        for _, option in ipairs(xi.homepoint.destinations(bot, origin)) do
            local hops = hopsBetween(option.zoneId, goalZoneId)
            if hops < bestHops then
                best, bestHops = { kind = 'homepoint', dest = option.dest, cost = option.cost, at = crystal }, hops
            end
        end
    end

    if best and bot:getGil() < best.cost then
        return nil
    end

    return best
end

-- At the guard or crystal: pay and go. True if the bot warped (the entity is
-- gone - don't touch it).
function warp.take(bot, charId, state, now, plan)
    if
        plan == nil or
        distance2d(posOf(bot), plan.at) > 8 or
        bot:getGil() < plan.cost
    then
        state.warpRetryAt = now + WARP_RETRY_SEC
        return false
    end

    local dest     = plan.dest
    local fromName = GetBotZoneName(bot:getZoneID())
    local toName   = GetBotZoneName(dest[5])
    local what     = plan.kind == 'outpost' and 'an outpost teleport' or 'a home point warp'

    if plan.cost > 0 then
        bot:delGil(plan.cost)
    end

    xi.worldbots.log.event(bot, xi.worldbots.log.NOTABLE, 'travel', 'warp',
        string.format('%s took %s from %s to %s', bot:getName(), what, fromName, toName),
        { kind = plan.kind, from = fromName, to = toName, zone_id = dest[5], gil = plan.cost })

    if TeleportBotCharacter(charId, dest[5], dest[1], dest[2], dest[3], dest[4]) == nil then
        state.warpRetryAt = now + WARP_RETRY_SEC
    end

    return true
end

return warp
