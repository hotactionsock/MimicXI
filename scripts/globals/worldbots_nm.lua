-----------------------------------
-- xi.worldbots.nm - camping notorious monsters for gear (Phase 6a).
--
-- Every so often a levelling bot (level 10+, not hired by a player) looks at
-- the NMs within a few zones that drop an upgrade for it (GetBotNMTargets -
-- gear judged by its own stat weights, or a scroll it can use) and picks one
-- it can actually get:
--   * already up and unclaimed  - go now
--   * lottery                   - camp its placeholders (from the NM script's
--                                 phList) and kill them until the NM pops
--   * timed window              - turn up shortly before the window opens and
--                                 wait at the spawn point
--   * forced pop (??? + item)   - only if it carries the pop item: walk to the
--                                 ??? and trade it (the real trade handler)
-- Too hard to solo? Solo bots take NMs up to Decent Challenge; tougher ones
-- need a party - a solo bot looks for one instead, and a party leader takes
-- its party (Tough for 3-4, Very Tough for 5-6).
--
-- Claim etiquette: bots never touch an NM someone else has claimed. When the
-- NM pops with a real player nearby, a bot waits a while before going for it,
-- so the player gets a fair chance at the claim (bots act on ticks, well before
-- any player could react).
--
-- A camp ends when the NM is killed, someone else claims it, or after
-- CAMP_MAX_SEC; the same NM then rests for NM_COOLDOWN_SEC.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.nm = xi.worldbots.nm or {}

local nm = xi.worldbots.nm

local NM_MIN_LEVEL       = 10
local NM_CHECK_SEC       = 15 * 60 -- consider an NM camp at most this often
local NM_CHANCE          = 0.5     -- ...and then only this often
local NM_MAX_HOPS        = 4
local CAMP_MAX_SEC       = 60 * 60
local NM_COOLDOWN_SEC    = 2 * 60 * 60
local WINDOW_LEAD_SEC    = 5 * 60  -- arrive this long before a timed window
local TRAVEL_SEC_PER_HOP = 150     -- rough travel time estimate
local PLAYER_NEAR_YALMS  = 40
local PLAYER_GRACE_MIN   = 8       -- with a player near, wait this many seconds...
local PLAYER_GRACE_MAX   = 15      -- ...up to this, before going for a fresh pop
local ENGAGE_RANGE       = 25
local PH_SEARCH_YALMS    = 80

-- EMobDifficulty values (charutils.h)
local CON_DECENT    = 3
local CON_TOUGH     = 5
local CON_VERY      = 6

-- Hardest con a group of this size takes on for an NM.
local function maxCon(partySize)
    if partySize >= 5 then
        return CON_VERY
    elseif partySize >= 3 then
        return CON_TOUGH
    end

    return CON_DECENT
end

-- The NM's placeholder mob ids, from its script's phList.
local function placeholdersOf(nmId)
    local mob = GetMobByID(nmId)
    if mob == nil then
        return {}
    end

    local zoneScripts = xi.zones and xi.zones[mob:getZoneName()]
    local script      = zoneScripts and zoneScripts.mobs and zoneScripts.mobs[mob:getName()]
    local phList      = script and script.phList
    local result      = {}

    for phId, target in pairs(phList or {}) do
        if
            target == nmId or
            (type(target) == 'table' and utils.contains(nmId, target))
        then
            table.insert(result, phId)
        end
    end

    return result
end

-- A ??? in the NM's zone that pops it, and an item the bot carries for it.
local function forcedPopFor(bot, target)
    local ids = zones[target.zoneId]
    if ids == nil or ids.mob == nil then
        return nil
    end

    for _, pop in ipairs(GetBotForcedPops(target.zoneId)) do
        for _, key in ipairs(pop.mobKeys) do
            if ids.mob[key] == target.mobId then
                for _, itemKey in ipairs(pop.itemKeys) do
                    local itemId = xi.item[itemKey]
                    if itemId and bot:getItemCount(itemId) > 0 then
                        return { npcId = pop.npcId, x = pop.x, y = pop.y, z = pop.z, itemId = itemId }
                    end
                end
            end
        end
    end

    return nil
end

-- Decides how to camp this NM now, or nil if it can't be got right now.
local function campPlan(bot, target)
    if target.claimed then
        return nil
    end

    if target.spawned then
        return { mode = 'up', spot = { x = target.x, y = target.y, z = target.z } }
    end

    if target.lottery then
        local phs = placeholdersOf(target.mobId)
        if #phs > 0 then
            return { mode = 'lottery', phs = phs, spot = { x = target.x, y = target.y, z = target.z } }
        end
    end

    if target.windowed and target.respawnSec >= 0 then
        local travel = target.hops * TRAVEL_SEC_PER_HOP
        if target.respawnSec <= travel + WINDOW_LEAD_SEC then
            return { mode = 'window', spot = { x = target.x, y = target.y, z = target.z } }
        end
    end

    if target.scripted then
        local pop = forcedPopFor(bot, target)
        if pop then
            return { mode = 'pop', pop = pop, spot = { x = pop.x, y = pop.y, z = pop.z } }
        end
    end

    return nil
end

-- Called when the bot picks a new goal: maybe go camp an NM. True if it did.
function nm.maybeCamp(bot, charId, state, now)
    if
        bot:getMainLvl() < NM_MIN_LEVEL or
        xi.worldbots.hire.isHired(state) or
        now < (state.nextNMCheckAt or 0)
    then
        return false
    end

    state.nextNMCheckAt = now + NM_CHECK_SEC
    if math.randomFloat(0, 1) >= NM_CHANCE then
        return false
    end

    -- Only a solo bot or a party leader decides on a camp.
    local record = xi.worldbots.party.get(bot, charId, now)
    if record and record.leaderId ~= charId then
        return false
    end

    local size     = xi.worldbots.party.huntSize(bot)
    local limit    = maxCon(size)
    local cooldown = state.nmCooldown or {}
    state.nmCooldown = cooldown

    local wantsParty = false
    for _, target in ipairs(GetBotNMTargets(charId, NM_MAX_HOPS)) do
        -- Not on cooldown, and not one that keeps killing it.
        local mem = xi.worldbots.memory
        if
            now >= (cooldown[target.mobId] or 0) and
            not mem.avoid(bot, mem.NM, target.mobId, now)
        then
            if target.con > limit then
                wantsParty = wantsParty or target.con <= CON_VERY
            else
                local plan = campPlan(bot, target)
                if plan then
                    plan.mobId    = target.mobId
                    plan.name     = target.name
                    plan.item     = target.bestItemName
                    plan.zoneId   = target.zoneId
                    plan.untilAt  = now + CAMP_MAX_SEC
                    xi.worldbots.internal.setGoal(charId, state, 'nm', target.zoneId)
                    state.goal.nm        = plan
                    state.goal.untilTime = plan.untilAt -- the camp, not the usual dwell, decides
                    xi.worldbots.log.nmCamp(bot, target.name, target.bestItemName, GetBotZoneName(target.zoneId), plan.mode)
                    return true
                end
            end
        end
    end

    -- An NM worth having but too tough alone: look for a party.
    if wantsParty and size <= 1 then
        xi.worldbots.party.maybeSeek(bot, charId, now)
    end

    return false
end

-- Arrived in the NM's zone: where to wait.
function nm.campSpot(state)
    local plan = state.goal and state.goal.nm
    return plan and plan.spot or nil
end

local function endCamp(bot, charId, state, now, outcome)
    local plan = state.goal and state.goal.nm
    if plan then
        state.nmCooldown = state.nmCooldown or {}
        state.nmCooldown[plan.mobId] = now + NM_COOLDOWN_SEC
        xi.worldbots.log.nmResult(bot, plan.name, outcome)
    end

    state.goal = nil
end

-- Goes for the mob: walk closer if needed, then engage.
local function attack(bot, charId, status, mobId)
    if status.distance > ENGAGE_RANGE then
        WalkBotTo(charId, status.x, status.y, status.z)
    else
        EngageBotTarget(charId, mobId)
    end
end

-- Per tick while the bot's goal is an NM camp in this zone. True = handled.
function nm.step(bot, charId, state, now, zoneId)
    local goal = state.goal
    local plan = goal and goal.kind == 'nm' and goal.nm
    if not plan or goal.zoneId ~= zoneId or not goal.settled then
        return false
    end

    if now >= plan.untilAt then
        endCamp(bot, charId, state, now, 'gave up')
        return false
    end

    local status = GetBotMobStatus(charId, plan.mobId)
    if not status.found then
        endCamp(bot, charId, state, now, 'gave up')
        return false
    end

    -- We had it and now it's gone: done.
    if plan.engaged and not status.alive then
        endCamp(bot, charId, state, now, 'defeated')
        return false
    end

    if status.alive then
        if status.claimed and not status.ours then
            -- Someone else's: hands off.
            endCamp(bot, charId, state, now, 'claimed by someone else')
            return false
        end

        if not status.claimed then
            -- Fresh pop: give a nearby player their chance first.
            plan.seenAt = plan.seenAt or now
            if IsRealPlayerNearMob(plan.mobId, zoneId, PLAYER_NEAR_YALMS) then
                plan.grace = plan.grace or math.random(PLAYER_GRACE_MIN, PLAYER_GRACE_MAX)
                if now < plan.seenAt + plan.grace then
                    return true
                end
            end
        end

        plan.engaged = true
        attack(bot, charId, status, plan.mobId)
        return true
    end

    plan.seenAt, plan.grace = nil, nil

    -- Not up yet.
    if plan.mode == 'lottery' then
        -- Kill its placeholders as they come up.
        for _, phId in ipairs(plan.phs) do
            local ph = GetBotMobStatus(charId, phId)
            if ph.alive and not ph.claimed and ph.distance <= PH_SEARCH_YALMS then
                attack(bot, charId, ph, phId)
                return true
            end
        end
    elseif plan.mode == 'pop' and not plan.traded then
        local dx, dz = plan.pop.x - bot:getXPos(), plan.pop.z - bot:getZPos()
        if math.sqrt(dx * dx + dz * dz) > 4 then
            WalkBotTo(charId, plan.pop.x, plan.pop.y, plan.pop.z)
            return true
        end

        plan.traded = TradeBotItemToNpc(charId, plan.pop.npcId, plan.pop.itemId, 1)
        if not plan.traded then
            endCamp(bot, charId, state, now, 'could not pop it')
            return false
        end

        return true
    end

    return false -- waiting: let it loiter / rest / fight back as usual
end

return nm
