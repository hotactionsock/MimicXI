-----------------------------------
-- xi.worldbots - AI for world-population bots.
--
-- A world bot is a real CCharEntity on a real (throwaway) account, spawned with
-- no live network socket (see src/map/utils/botutils.h) - not an NPC, not a mob,
-- not a mimic trust. The bot registry lives in the `world_bots` table (C++ side),
-- so this file holds only a per-bot AI scratch cache: reloading it loses
-- in-flight walks and current goals, nothing else.
--
-- Driven by xi.worldbots.onZoneTick, which the engine calls for every AWAKE zone
-- that contains bots (CZoneEntities::ZoneServer). A zone with no real players
-- goes dormant and stops ticking, so its bots simply freeze until someone
-- arrives. Session keep-alive is engine-side and works in dormant zones too.
--
-- Behaviour is GOAL-driven: a bot always has a reason to be where it is.
--   level - hunt in a zone whose mobs suit its level (engine-side scoring of
--           every zone's normal respawning mobs, see GetBotLevelingZones)
--   home  - go back to its nation's city (rest / shop / log off, later)
--   zone  - GM-ordered destination (!worldbot travel)
--   stay  - stay put (e.g. after a GM !bring)
-- If the goal zone isn't the current one, the bot follows a route across the
-- zone-line graph (GetBotRouteNextLine) - walking only to the line it needs,
-- one hop at a time. On arrival it settles at a sensible spot (a suitable mob
-- spawn point for `level`) and loiters there until the goal's dwell time runs
-- out, then picks a new goal, which is often "stay here".
--
-- In zones with social spots (cities: Mog House doors, Auction Counters, Home
-- Points - GetBotSocialSpots), non-levelling bots hang around those instead:
-- they drift between spots every few minutes, and often gather in small chat
-- circles - standing still in a ring, facing the centre, for a few minutes.
--
-- Combat (level goals): at its hunt spot a bot fights nearby mobs that suit
-- its level, always fights back when attacked (even mid-travel), rests with
-- /heal when hurt, and lots its loot. EXP and level-ups come from the normal
-- kill path. In a fight it uses its best weapon skill at 1000 TP and job
-- abilities from a per-ability policy (ABILITY_POLICY). If it dies it waits a little, returns to its home point, and its
-- goal walks it straight back to the same hunt spot.
--
-- Home point: a bot starts with a random crystal in its starting city (set
-- engine-side on spawn). It only changes when, leaving a city on a levelling
-- trip, the crystal nearest its exit is more convenient for that levelling zone
-- than its current home point - fewer zone hops away, or the same city but a
-- better-placed crystal. Sell trips and home visits never move it.
--
-- Bags: when nearly full it tosses its cheapest loot; if what's left is worth
-- selling, it heads to town, sells to the nearest vendor, then goes back.
--
-- Inventory: on spawn and every few minutes, a bot equips the best gear it can
-- wear and uses any spell scroll it can learn (ManageBotInventory - engine-side,
-- through the same equip/learn rules a player has).
--
-- Zone-line crossing itself is engine-side: any bot that walks into a usable
-- zone line's area crosses it, like a real player. Loitering steers clear of
-- zone lines, so crossings only happen as part of travel (or a clipped path).
-- Combat comes later.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}

-- charId -> per-bot scratch state:
--   zoneId, anchor = {x,y,z}, lastPos, walking, walkOrderAt, idleUntil,
--   lastPositionSaveTime, nextGoalCheckAt,
--   goal   = { kind, zoneId, untilTime, settled },
--   travel = { lineId, zoneId, target, attempts, bestDist }  -- walking to a zone line
--   walk   = { target, attempts, bestDist, purpose, circle } -- relocating within a zone
--   loiterRadius, nextSpotMoveAt, spotIndex,
--   chat   = { circle, untilTime }                           -- standing in a chat circle
-- Lazily filled on a bot's first tick; never authoritative (see header).
local states = {}

-- Logs every decision to the map log as [lua] lines. Testing aid only - keep
-- false: per-bot, per-step output would swamp the log at any real bot count.
local DEBUG = false

local LOITER_RADIUS_YALMS        = 8
local LOITER_MIN_STEP_YALMS      = 2  -- skip near-zero shuffles
local LOITER_PICK_ATTEMPTS       = 6
local LOITER_PAUSE_MIN_SEC       = 1  -- pause after arriving (initial test: keep moving;
local LOITER_PAUSE_MAX_SEC       = 2  -- longer "afk/idle" behaviour is a later phase)
local WALK_START_GRACE_SEC       = 2  -- a walk order that hasn't moved by then is retried
local WALK_MAX_STALLS            = 5  -- re-paths without getting closer before giving up
local POSITION_SAVE_INTERVAL_SEC = 30
local INVENTORY_CHECK_SEC        = 5 * 60 -- re-check gear/scrolls this often (and on spawn)

-- Combat
local HUNT_RADIUS                = 60     -- look for prey this far from the bot
local ENGAGE_RANGE               = 25     -- engage from here (the engine allows < 30); closer = walk first
local TARGET_CHECK_SEC           = 2      -- how often an idle hunter looks for prey
local ATTACKER_CHECK_SEC         = 1      -- how often to check for something attacking it
local REST_BELOW_HPP             = 50     -- /heal when HP% drops below this between fights
local REST_UNTIL_HPP             = 95     -- ...until back up to this
local LOOT_WINDOW_SEC            = 10     -- keep lotting this long after a fight ends
local DEATH_WAIT_SEC             = 20     -- lie dead this long before returning to the home point
local ACTION_CHECK_SEC           = 1      -- in a fight, consider a weapon skill / job ability this often
local ENGAGE_SETTLE_SEC          = 2      -- start-of-fight abilities wait this long after engaging

-- When to use each job ability (anything not listed is never used). Built from
-- xi.jobAbility names so a missing enum entry is simply skipped.
--   'engage'          - early in a fight (buffs, openers)
--   { hpBelow = n }   - when the bot's HP% drops below n (defensive / healing)
-- Provoke and the like are left out on purpose: pointless solo; parties later.
-- Built on first use (not at load) so it never depends on enum load order.
local ABILITY_POLICY = nil

local function abilityPolicy()
    if ABILITY_POLICY then
        return ABILITY_POLICY
    end

    ABILITY_POLICY = {}

    local policy =
    {
        -- WAR
        BERSERK     = 'engage',
        WARCRY      = 'engage',
        AGGRESSOR   = 'engage',
        RETALIATION = 'engage',
        RESTRAINT   = 'engage',
        BLOOD_RAGE  = 'engage',
        DEFENDER    = { hpBelow = 40 },
        -- MNK
        BOOST       = 'engage',
        FOCUS       = 'engage',
        DODGE       = { hpBelow = 60 },
        CHAKRA      = { hpBelow = 50 },
        -- THF
        STEAL       = 'engage',
        MUG         = 'engage',
        -- DRK
        LAST_RESORT = 'engage',
        -- PLD
        SENTINEL    = { hpBelow = 40 },
        -- DRG
        JUMP        = 'engage',
        HIGH_JUMP   = 'engage',
        -- SAM
        MEDITATE    = 'engage',
        THIRD_EYE   = 'engage',
        HASSO       = 'engage',
    }

    for name, when in pairs(policy) do
        local id = xi.jobAbility and xi.jobAbility[name]
        if id then
            ABILITY_POLICY[id] = when
        end
    end

    return ABILITY_POLICY
end

-- Bags
local BAG_CHECK_SEC              = 60     -- check bag space this often (and right after fights)
local BAG_WANT_FREE              = 2      -- keep at least this many slots free
local TOSS_MAX_VALUE             = 100    -- loot worth less than this (gil) gets tossed when bags fill
local HOMEPOINT_REACH_YALMS      = 6      -- must get this close to a crystal to set the home point

local ZONE_LINE_REACH_YALMS      = 10 -- fallback: cross explicitly if this close and stopped (C++ allows 20)
local ZONE_LINE_AVOID_MARGIN     = 3  -- loiter points stay this far outside any zone-line area
local SPOT_REACH_YALMS           = 4  -- close enough to a relocation spot to settle

-- Goals
local GOAL_DWELL_MIN_SEC         = 20 * 60 -- how long a bot stays once settled
local GOAL_DWELL_MAX_SEC         = 45 * 60
local GOAL_HOME_CHANCE           = 0.15    -- chance a new goal is "go home" rather than "level"
local GOAL_STAY_CHANCE           = 0.75    -- chance to keep levelling where it is, if the zone suits
local GOAL_MAX_HOPS              = 6       -- don't plan levelling trips further than this
local GOAL_MIN_SUITABLE          = 6       -- suitable mob spawns for a zone to count as a levelling zone
local GOAL_RETRY_SEC             = 60      -- after a failed plan, wait before trying again

-- Social spots (cities)
local SOCIAL_SPOT_WEIGHTS        = { ah = 3, mog = 3, hp = 2 }
local SOCIAL_SPOT_SCATTER        = 4       -- stand within this of the spot (NPCs are behind counters)
local SOCIAL_LOITER_RADIUS       = 5       -- tighter wander around a spot, so bots cluster
local SOCIAL_MOVE_MIN_SEC        = 3 * 60  -- drift to a different spot this often
local SOCIAL_MOVE_MAX_SEC        = 8 * 60

-- Chat circles
local CHAT_CHANCE                = 0.6     -- on heading to a spot, chance to join/start a chat circle
local CHAT_MAX_MEMBERS           = 5
local CHAT_RING_RADIUS           = 1.8     -- distance from the circle's centre
local CHAT_JOIN_YALMS            = 12      -- join an existing circle this close to the chosen spot
local CHAT_MIN_SEC               = 2 * 60
local CHAT_MAX_SEC               = 6 * 60

local function distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function horizontalDistance(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z

    return math.sqrt(dx * dx + dz * dz)
end

local function diag(charId, fmt, ...)
    if DEBUG then
        print(string.format('[worldbots] %d: ' .. fmt, charId, ...))
    end
end

-----------------------------------
-- Zone-line data (static per zone - fetched once)
-----------------------------------

local zoneLinesCache = {}

local function getZoneLines(zoneId)
    local lines = zoneLinesCache[zoneId]

    if lines == nil then
        lines = GetBotZoneLines(zoneId)
        zoneLinesCache[zoneId] = lines
    end

    return lines
end

local function nearZoneLine(pos, zoneId)
    for _, line in ipairs(getZoneLines(zoneId)) do
        if horizontalDistance(pos, line) <= line.radius + ZONE_LINE_AVOID_MARGIN then
            return true
        end
    end

    return false
end

-----------------------------------
-- Social spots (static per zone - fetched once)
-----------------------------------

local socialSpotsCache = {}

local function getSocialSpots(zoneId)
    local spots = socialSpotsCache[zoneId]

    if spots == nil then
        spots = GetBotSocialSpots(zoneId)
        socialSpotsCache[zoneId] = spots
    end

    return spots
end

-- Weighted random spot index, avoiding `exclude` when there's a choice.
local function pickSocialSpot(spots, exclude)
    local total = 0
    for i, spot in ipairs(spots) do
        if i ~= exclude or #spots == 1 then
            total = total + (SOCIAL_SPOT_WEIGHTS[spot.kind] or 1)
        end
    end

    local roll = math.random() * total
    for i, spot in ipairs(spots) do
        if i ~= exclude or #spots == 1 then
            roll = roll - (SOCIAL_SPOT_WEIGHTS[spot.kind] or 1)
            if roll <= 0 then
                return i
            end
        end
    end

    return #spots
end

-----------------------------------
-- Chat circles: zoneId -> list of { center = {x,y,z}, members = { [charId] = angle }, count }
-- Shared across bots so they can find each other.
-----------------------------------

local circles = {}

local function leaveCircles(charId)
    for zoneId, list in pairs(circles) do
        for i = #list, 1, -1 do
            local circle = list[i]
            if circle.members[charId] then
                circle.members[charId] = nil
                circle.count = circle.count - 1
            end

            if circle.count <= 0 then
                table.remove(list, i)
            end
        end

        if #list == 0 then
            circles[zoneId] = nil
        end
    end
end

-- Angle on the ring furthest from the members already standing there.
local function freeAngle(circle)
    local best, bestGap = 0, -1

    for step = 0, 7 do
        local angle = step * math.pi / 4 + math.random() * 0.3
        local gap   = math.pi * 2

        for _, other in pairs(circle.members) do
            local d = math.abs(angle - other) % (math.pi * 2)
            gap = math.min(gap, math.min(d, math.pi * 2 - d))
        end

        if gap > bestGap then
            best, bestGap = angle, gap
        end
    end

    return best
end

-- Joins the nearest circle with room near `spot`, or starts one there. Returns
-- the circle and the bot's standing slot, or nil if no walkable slot was found.
local function joinCircle(charId, zone, spot)
    local zoneId = zone:getID()
    local list   = circles[zoneId] or {}
    local circle

    for _, c in ipairs(list) do
        if c.count < CHAT_MAX_MEMBERS and horizontalDistance(c.center, spot) <= CHAT_JOIN_YALMS then
            circle = c
            break
        end
    end

    if circle == nil then
        local center = zone:getRandomNavmeshPoint(spot, SOCIAL_SPOT_SCATTER) or spot
        circle = { center = { x = center.x, y = center.y, z = center.z }, members = {}, count = 0 }
    end

    for _ = 1, 4 do
        local angle = freeAngle(circle)
        local slot  =
        {
            x = circle.center.x + math.cos(angle) * CHAT_RING_RADIUS,
            y = circle.center.y,
            z = circle.center.z + math.sin(angle) * CHAT_RING_RADIUS,
        }

        if zone:isNavigablePoint(slot) then
            if circle.count == 0 then
                table.insert(list, circle)
                circles[zoneId] = list
            end

            circle.members[charId] = angle
            circle.count = circle.count + 1

            return circle, slot
        end
    end

    return nil
end

-----------------------------------
-- State
-----------------------------------

local function getState(charId, now)
    local state = states[charId]

    if state == nil then
        state = { lastPositionSaveTime = now, anchor = GetBotAnchor(charId) }
        states[charId] = state
    end

    return state
end

local function clearMovement(state)
    state.travel       = nil
    state.walk         = nil
    state.walking      = false
    state.walkOrderAt  = nil
    state.idleUntil    = nil
    state.chat         = nil
    state.loiterRadius = nil
end

local function setAnchor(charId, state, pos)
    state.anchor = { x = pos.x, y = pos.y, z = pos.z }
    SetBotAnchor(charId, pos.x, pos.y, pos.z)
end

-----------------------------------
-- Goals
-----------------------------------

local function dwellTime()
    return math.random(GOAL_DWELL_MIN_SEC, GOAL_DWELL_MAX_SEC)
end

local function setGoal(charId, state, kind, zoneId)
    leaveCircles(charId)
    clearMovement(state)
    state.goal = { kind = kind, zoneId = zoneId, settled = false }
    diag(charId, 'new goal: %s in zone %d', kind, zoneId)
end

-- Picks where to level: usually stays if the current zone suits, otherwise a
-- weighted pick among suitable zones, favouring more mobs and fewer hops.
local function pickLevelingZone(bot, zoneId)
    local zones = GetBotLevelingZones(bot:getMainLvl(), zoneId, GOAL_MAX_HOPS)
    local total = 0
    local candidates = {}

    for _, z in ipairs(zones) do
        if z.suitable >= GOAL_MIN_SUITABLE then
            if z.zoneId == zoneId and math.random() < GOAL_STAY_CHANCE then
                return zoneId
            end

            local weight = z.suitable / (1 + z.hops)
            total = total + weight
            table.insert(candidates, { zoneId = z.zoneId, weight = weight })
        end
    end

    if total <= 0 then
        return nil
    end

    local roll = math.random() * total
    for _, c in ipairs(candidates) do
        roll = roll - c.weight
        if roll <= 0 then
            return c.zoneId
        end
    end

    return candidates[#candidates].zoneId
end

local function pickGoal(bot, charId, state, zoneId)
    if math.random() < GOAL_HOME_CHANCE then
        local home = GetBotHomeZone(bot:getNation(), zoneId)
        if home ~= 0 then
            setGoal(charId, state, 'home', home)
            return true
        end
    end

    local levelZone = pickLevelingZone(bot, zoneId)
    if levelZone then
        setGoal(charId, state, 'level', levelZone)
        return true
    end

    return false
end

-- Where to settle in the goal zone: a suitable mob spawn point for levelling,
-- or any walkable point otherwise. nil = just settle where it stands.
local function pickSettleSpot(bot, state)
    if state.goal.kind == 'level' then
        -- Remember it, so after a death or a sell trip it returns to the same place.
        state.goal.spot = state.goal.spot or GetBotHuntSpot(bot:getZoneID(), bot:getMainLvl())
        return state.goal.spot
    end

    if state.goal.kind == 'home' then
        local zone = bot:getZone()
        return zone and zone:getRandomNavmeshPoint() or nil
    end

    return nil
end

-----------------------------------
-- Walking (shared by zone-line travel and in-zone relocation). Long walks are
-- chunked by the pathfinder and can pause briefly between chunks, so stopping
-- short just re-issues the walk; only repeated stops WITHOUT getting any closer
-- count as stalls. Returns 'arrived', 'stuck', or nil (still going).
-----------------------------------

local function walkStep(charId, state, plan, now, currentPos, moving, reach)
    if moving then
        state.walking     = true
        state.walkOrderAt = nil
        return nil
    end

    local dist = distance(currentPos, plan.target)
    if dist <= reach then
        return 'arrived'
    end

    state.walking = false

    if state.walkOrderAt and now < state.walkOrderAt + WALK_START_GRACE_SEC then
        return nil
    end

    if dist < plan.bestDist - 1 then
        plan.bestDist = dist
        plan.attempts = 0
    else
        plan.attempts = plan.attempts + 1
    end

    if plan.attempts > WALK_MAX_STALLS then
        return 'stuck'
    end

    WalkBotTo(charId, plan.target.x, plan.target.y, plan.target.z)
    state.walkOrderAt = now

    return nil
end

local function newPlan(target)
    return { target = { x = target.x, y = target.y, z = target.z }, attempts = 0, bestDist = math.huge }
end

-- Returns true if the bot zoned out (its entity is gone - don't touch it).
local function travelStep(charId, state, now, currentPos, moving)
    local travel = state.travel
    local result = walkStep(charId, state, travel, now, currentPos, moving, ZONE_LINE_REACH_YALMS)

    if result == 'arrived' then
        -- Normally the engine crosses as soon as the bot enters the line's area;
        -- this is the fallback for a path that ends just short of it.
        diag(charId, 'crossing zone line %d -> zone %d', travel.lineId, travel.zoneId)
        if ZoneBotThroughLine(charId, travel.lineId) then
            return true
        end

        result = 'stuck'
    end

    if result == 'stuck' then
        diag(charId, 'could not reach zone line %d - dropping goal', travel.lineId)
        state.goal            = nil
        state.nextGoalCheckAt = now + GOAL_RETRY_SEC
        clearMovement(state)
    end

    return false
end

local function relocateStep(bot, charId, state, now, currentPos, moving)
    local walk   = state.walk
    local reach  = walk.purpose == 'chat' and 1 or SPOT_REACH_YALMS
    local result = walkStep(charId, state, walk, now, currentPos, moving, reach)

    if result == 'arrived' or result == 'stuck' then
        state.walk = nil

        -- Errands: set the home point / sell loot, then carry on with the goal.
        if walk.purpose == 'homepoint' then
            if distance(currentPos, walk.target) <= HOMEPOINT_REACH_YALMS then
                bot:setHomePoint()
                diag(charId, 'home point set')
            end

            return
        end

        if walk.purpose == 'vendor' then
            local sale = SellBotItems(charId)
            diag(charId, 'sold %d stacks for %d gil', sale.sold, sale.gil)

            local resume = state.resumeGoal
            state.resumeGoal = nil
            if resume then
                setGoal(charId, state, resume.kind, resume.zoneId)
                state.goal.spot      = resume.spot
                state.goal.untilTime = resume.untilTime
            else
                state.goal = nil
            end

            return
        end

        -- Settle wherever it got to - a stuck walk usually ends close enough.
        diag(charId, 'settled at (%.1f, %.1f, %.1f)', currentPos.x, currentPos.y, currentPos.z)
        setAnchor(charId, state, currentPos)

        if walk.purpose == 'chat' then
            bot:lookAt(walk.circle.center)
            state.chat = { circle = walk.circle, untilTime = now + math.random(CHAT_MIN_SEC, CHAT_MAX_SEC) }
        elseif walk.purpose == 'spot' then
            state.loiterRadius   = SOCIAL_LOITER_RADIUS
            state.nextSpotMoveAt = now + math.random(SOCIAL_MOVE_MIN_SEC, SOCIAL_MOVE_MAX_SEC)
        end

        if state.goal and not state.goal.settled then
            state.goal.settled   = true
            state.goal.untilTime = state.goal.untilTime or now + dwellTime()
        end
    end
end

-- Heads for a social spot (different from the current one): either to stand
-- in a chat circle there, or just to hang around it.
local function goToSocialSpot(bot, charId, state)
    local zone  = bot:getZone()
    local spots = zone and getSocialSpots(zone:getID()) or {}
    if #spots == 0 then
        return false
    end

    local index = pickSocialSpot(spots, state.spotIndex)
    local spot  = spots[index]
    state.spotIndex    = index
    state.loiterRadius = nil

    leaveCircles(charId)

    if math.random() < CHAT_CHANCE then
        local circle, slot = joinCircle(charId, zone, spot)
        if circle then
            diag(charId, 'joining a chat circle at the %s (%d there)', spot.kind, circle.count)
            state.walk         = newPlan(slot)
            state.walk.purpose = 'chat'
            state.walk.circle  = circle
            return true
        end
    end

    local target = zone:getRandomNavmeshPoint(spot, SOCIAL_SPOT_SCATTER) or spot
    diag(charId, 'heading for the %s', spot.kind)
    state.walk         = newPlan(target)
    state.walk.purpose = 'spot'

    return true
end

-----------------------------------
-- Loiter: walk to a random walkable point near the anchor, bounded to it (not
-- "wherever it currently stands") so wandering can't drift over time, and
-- clear of zone lines. Arrival-driven: as soon as the bot stops, it pauses
-- briefly and picks the next point.
-----------------------------------

local function pickLoiterPoint(bot, state, currentPos)
    local zone = bot:getZone()
    if zone == nil then
        return nil
    end

    local zoneId = zone:getID()

    local radius = state.loiterRadius or LOITER_RADIUS_YALMS

    for _ = 1, LOITER_PICK_ATTEMPTS do
        local pos = zone:getRandomNavmeshPoint(state.anchor, radius)
        if
            pos and
            distance(pos, state.anchor) <= radius and
            distance(pos, currentPos) >= LOITER_MIN_STEP_YALMS and
            not nearZoneLine(pos, zoneId)
        then
            return pos
        end
    end

    return nil
end

local function loiterStep(bot, charId, state, now, currentPos, moving)
    if not state.anchor then
        return
    end

    if moving then
        state.walking     = true
        state.walkOrderAt = nil
        return
    end

    if state.walking then
        state.walking   = false
        state.idleUntil = now + math.random(LOITER_PAUSE_MIN_SEC, LOITER_PAUSE_MAX_SEC)
        return
    end

    if state.walkOrderAt and now < state.walkOrderAt + WALK_START_GRACE_SEC then
        return
    end

    if state.idleUntil and now < state.idleUntil then
        return
    end

    local target
    if distance(currentPos, state.anchor) > (state.loiterRadius or LOITER_RADIUS_YALMS) then
        -- Drifted outside the wander area - head back. The anchor can be right
        -- next to a zone line (e.g. an arrival point); walking onto it would
        -- cross, so aim for a safe loiter point around it instead.
        target = state.anchor
        if nearZoneLine(state.anchor, bot:getZoneID()) then
            target = pickLoiterPoint(bot, state, currentPos) or state.anchor
        end
    else
        target = pickLoiterPoint(bot, state, currentPos)
        if target == nil then
            return
        end
    end

    WalkBotTo(charId, target.x, target.y, target.z)
    state.walkOrderAt = now
end

local function nearestOf(points, from)
    local best, bestDist

    for _, p in ipairs(points) do
        local d = horizontalDistance(p, from)
        if bestDist == nil or d < bestDist then
            best, bestDist = p, d
        end
    end

    return best
end

-- In a city (it has an Auction Counter or Mog House), the Home Point crystal
-- nearest `toward` - the zone line the bot is about to leave by.
local function nearestCityCrystal(zoneId, toward)
    local crystals = {}
    local isCity   = false

    for _, spot in ipairs(getSocialSpots(zoneId)) do
        if spot.kind == 'hp' then
            table.insert(crystals, spot)
        elseif spot.kind == 'ah' or spot.kind == 'mog' then
            isCity = true
        end
    end

    return isCity and nearestOf(crystals, toward) or nil
end

local function hopsBetween(fromZone, toZone)
    if fromZone == toZone then
        return 0
    end

    local hop = GetBotRouteNextLine(fromZone, toZone)
    return hop and hop.hops or math.huge
end

-- Would a home point at `crystal` (in zoneId) beat the bot's current one for
-- levelling in levelZone? Fewer zone hops wins; in the same city, a crystal
-- meaningfully closer to the exit (i.e. a different one) wins.
local function isMoreConvenientHome(charId, zoneId, crystal, levelZone)
    local home = GetBotHomePoint(charId)
    if home == nil then
        return true
    end

    local hopsHere = hopsBetween(zoneId, levelZone)
    local hopsHome = hopsBetween(home.zoneId, levelZone)

    if hopsHere ~= hopsHome then
        return hopsHere < hopsHome
    end

    return home.zoneId == zoneId and horizontalDistance(home, crystal) > 10
end

-----------------------------------
-- Combat: fight back, rest, hunt. Returns true if it used the bot's tick.
-----------------------------------

local function combatStep(bot, charId, state, now, moving)
    -- Always fight back - even mid-travel or mid-chat.
    if now >= (state.nextAttackerCheckAt or 0) then
        state.nextAttackerCheckAt = now + ATTACKER_CHECK_SEC

        local attacker = FindBotAttacker(charId)
        if attacker then
            if state.healing then
                SetBotHealing(charId, false)
                state.healing = false
            end

            leaveCircles(charId)
            state.chat = nil
            EngageBotTarget(charId, attacker.mobId)
            return true
        end
    end

    if state.healing then
        if bot:getHPP() >= REST_UNTIL_HPP then
            SetBotHealing(charId, false)
            state.healing = false
        else
            return true
        end
    end

    local goal    = state.goal
    local hunting = goal and goal.kind == 'level' and goal.settled and goal.zoneId == bot:getZoneID() and
                    not state.walk and not state.travel
    if not hunting then
        return false
    end

    if bot:getHPP() < REST_BELOW_HPP then
        if not moving then
            diag(charId, 'resting')
            SetBotHealing(charId, true)
            state.healing = true
        end

        return true
    end

    if now >= (state.nextTargetCheckAt or 0) then
        state.nextTargetCheckAt = now + TARGET_CHECK_SEC

        local target = FindBotTarget(charId, HUNT_RADIUS)
        if target then
            if target.distance <= ENGAGE_RANGE then
                EngageBotTarget(charId, target.mobId)
            else
                WalkBotTo(charId, target.x, target.y, target.z)
                state.walkOrderAt = now
            end

            state.idleUntil = now + TARGET_CHECK_SEC
            return true
        end
    end

    return false
end

-- In a fight: weapon skill at 1000 TP, otherwise a job ability its policy
-- says fits right now. At most one action per check.
local function combatActions(bot, charId, state, now)
    if now < (state.nextActionAt or 0) then
        return
    end

    state.nextActionAt = now + ACTION_CHECK_SEC

    if bot:getTP() >= 1000 then
        local ws = UseBotWeaponSkill(charId)
        if ws ~= 0 then
            diag(charId, 'weapon skill %d', ws)
            return
        end
    end

    local engagedFor = now - (state.engagedAt or now)
    local hpp        = bot:getHPP()

    for _, ability in ipairs(GetBotAbilities(charId)) do
        local when = ability.ready and abilityPolicy()[ability.id]
        if
            when and
            ((when == 'engage' and engagedFor >= ENGAGE_SETTLE_SEC) or
            (type(when) == 'table' and when.hpBelow and hpp < when.hpBelow))
        then
            if UseBotAbility(charId, ability.id) then
                diag(charId, 'job ability %d', ability.id)
                return
            end
        end
    end
end

-- Lie dead a while, then return to the home point. The goal survives the trip
-- (see the zone-change handling in onZoneTick), so it walks back afterwards.
local function deathStep(charId, state, now)
    if state.deadSince == nil then
        state.deadSince = now
        state.healing   = false
        leaveCircles(charId)
        clearMovement(state)
        diag(charId, 'died')
        return
    end

    if now >= state.deadSince + DEATH_WAIT_SEC then
        state.deadSince = nil
        HomepointBot(charId)
    end
end

-- Bags nearly full: toss cheap loot; if still full and the rest is worth
-- something, go sell it in town and come back.
local function bagStep(bot, charId, state, now, zoneId)
    state.nextBagCheckAt = now + BAG_CHECK_SEC

    if GetBotFreeSlots(charId) >= BAG_WANT_FREE then
        return
    end

    local tossed = TossBotJunk(charId, TOSS_MAX_VALUE, BAG_WANT_FREE)
    if tossed > 0 then
        diag(charId, 'tossed %d stacks of junk', tossed)
    end

    local goal = state.goal
    if GetBotFreeSlots(charId) > 0 or GetBotSellableValue(charId) == 0 or (goal and goal.kind == 'sell') then
        return
    end

    local home = GetBotHomeZone(bot:getNation(), zoneId)
    if home == 0 then
        return
    end

    diag(charId, 'bags full - heading to town to sell')
    state.resumeGoal = goal and { kind = goal.kind, zoneId = goal.zoneId, spot = goal.spot, untilTime = goal.untilTime } or nil
    setGoal(charId, state, 'sell', home)
end

-----------------------------------
-- Planner: decides what the bot should be doing for its goal. Runs only when
-- it isn't already mid-travel or mid-relocation.
-----------------------------------

local function plan(bot, charId, state, now, zoneId)
    local goal = state.goal

    -- Need a (new) goal?
    if goal == nil or (goal.settled and now >= goal.untilTime) then
        if state.nextGoalCheckAt and now < state.nextGoalCheckAt then
            return
        end

        local previous = goal
        if not pickGoal(bot, charId, state, zoneId) then
            state.nextGoalCheckAt = now + GOAL_RETRY_SEC
            return
        end

        -- Same kind of goal in the same zone - just stay longer where it is.
        if previous and previous.settled and state.goal.zoneId == zoneId and state.goal.kind == previous.kind then
            state.goal.settled   = true
            state.goal.untilTime = now + dwellTime()
            return
        end

        goal = state.goal
    end

    -- Not there yet: head for the next zone line on the route.
    if goal.zoneId ~= zoneId then
        local line = GetBotRouteNextLine(zoneId, goal.zoneId)
        if line == nil then
            diag(charId, 'no route from zone %d to %d - dropping goal', zoneId, goal.zoneId)
            state.goal            = nil
            state.nextGoalCheckAt = now + GOAL_RETRY_SEC
            return
        end

        -- Leaving a city to level: re-home at the crystal by the exit, if that's
        -- more convenient for the levelling zone than the current home point.
        if not state.departHomepointDone and goal.kind == 'level' then
            state.departHomepointDone = true -- once per zone visit, even if the walk fails

            local crystal = nearestCityCrystal(zoneId, line)
            if crystal and isMoreConvenientHome(charId, zoneId, crystal, goal.zoneId) then
                local zone   = bot:getZone()
                local target = zone and zone:getRandomNavmeshPoint(crystal, 3) or crystal
                state.walk         = newPlan(target)
                state.walk.purpose = 'homepoint'
                return
            end
        end

        diag(charId, 'route: zone %d -> %d via line %d (%d hops left)', zoneId, goal.zoneId, line.id, line.hops)
        state.travel        = newPlan(line)
        state.travel.lineId = line.id
        state.travel.zoneId = line.zoneId
        return
    end

    -- Sell trip: walk to the nearest vendor (selling happens on arrival).
    if goal.kind == 'sell' then
        local vendor = nearestOf(GetBotVendors(zoneId), { x = bot:getXPos(), y = bot:getYPos(), z = bot:getZPos() })
        if vendor == nil then
            -- No vendor here after all - give up and carry on with the old goal.
            local resume = state.resumeGoal
            state.resumeGoal = nil
            state.goal = resume and { kind = resume.kind, zoneId = resume.zoneId, spot = resume.spot, untilTime = resume.untilTime, settled = false } or nil
            return
        end

        local zone   = bot:getZone()
        state.walk         = newPlan(zone and zone:getRandomNavmeshPoint(vendor, 3) or vendor)
        state.walk.purpose = 'vendor'
        return
    end

    -- Arrived in the goal zone but not settled: walk to a sensible spot. Outside
    -- of levelling, that's a social spot if the zone has any (cities).
    if not goal.settled and goal.kind ~= 'level' and goal.kind ~= 'stay' and goal.kind ~= 'sell' then
        if goToSocialSpot(bot, charId, state) then
            return
        end
    end

    -- Settled in a zone with social spots: drift to another one now and then.
    if goal.settled and state.nextSpotMoveAt and now >= state.nextSpotMoveAt then
        state.nextSpotMoveAt = nil
        goToSocialSpot(bot, charId, state)
        return
    end

    if not goal.settled then
        local spot = pickSettleSpot(bot, state)
        if spot then
            state.walk = newPlan(spot)
        else
            setAnchor(charId, state, { x = bot:getXPos(), y = bot:getYPos(), z = bot:getZPos() })
            goal.settled   = true
            goal.untilTime = now + dwellTime()
        end
    end
end

-----------------------------------
-- Public helpers (GM commands, !bring)
-----------------------------------

xi.worldbots.isBot = function(charId)
    return IsBotCharacter(charId)
end

-- Drops a bot's cached AI state (including its goal), e.g. after a despawn.
xi.worldbots.forget = function(charId)
    leaveCircles(charId)
    states[charId] = nil
end

-- Safely relocates a bot - even one stuck mid zone-transition - re-anchors it
-- there, and gives it a "stay" goal so it doesn't immediately walk off. Use
-- this (not setPos) for any GM-driven bot move; see scripts/commands/bring.lua.
xi.worldbots.teleportBot = function(charId, x, y, z, rotation, zoneId)
    leaveCircles(charId)

    local bot = TeleportBotCharacter(charId, zoneId, x, y, z, rotation)

    if bot then
        local now = GetSystemTime()
        states[charId] =
        {
            lastPositionSaveTime = now,
            anchor = { x = x, y = y, z = z },
            zoneId = zoneId,
            goal   = { kind = 'stay', zoneId = zoneId, settled = true, untilTime = now + dwellTime() },
        }
    end

    return bot
end

-- GM-ordered goal. kind: 'level' (destZoneId optional - levels there instead
-- of picking a zone) | 'home' | 'zone' (needs destZoneId).
-- Returns the goal, or nil + a reason.
xi.worldbots.setGoal = function(charId, kind, destZoneId)
    local bot = GetPlayerByID(charId)
    if bot == nil or not IsBotCharacter(charId) then
        return nil, 'not a spawned bot'
    end

    local state  = getState(charId, GetSystemTime())
    local zoneId = bot:getZoneID()
    local target

    if kind == 'level' then
        target = destZoneId or pickLevelingZone(bot, zoneId)
    elseif kind == 'home' then
        target = GetBotHomeZone(bot:getNation(), zoneId)
        target = target ~= 0 and target or nil
    elseif kind == 'zone' then
        target = destZoneId
    else
        return nil, 'unknown goal kind'
    end

    if target == nil then
        return nil, 'no suitable destination'
    end

    if target ~= zoneId and GetBotRouteNextLine(zoneId, target) == nil then
        return nil, string.format('no zone-line route from zone %d to %d', zoneId, target)
    end

    setGoal(charId, state, kind, target)

    return state.goal
end

xi.worldbots.getGoal = function(charId)
    local state = states[charId]
    return state and state.goal or nil
end

-- Usable zone lines out of zoneId, for the !worldbot lines command.
xi.worldbots.zoneLines = function(zoneId)
    return getZoneLines(zoneId)
end

-----------------------------------
-- Zone tick: called by the engine for each awake zone holding bots, with the
-- list of bot entities in that zone.
-----------------------------------

xi.worldbots.onZoneTick = function(zone, bots)
    local now    = GetSystemTime()
    local zoneId = zone:getID()

    for _, bot in ipairs(bots) do
        local charId = bot:getID()
        local state  = getState(charId, now)

        -- Arrived from another zone: keep the goal (that's the point of the
        -- trip), drop everything else - the new anchor was written by the move.
        if state.zoneId ~= nil and state.zoneId ~= zoneId then
            local goal   = state.goal
            local resume = state.resumeGoal
            xi.worldbots.forget(charId)
            state            = getState(charId, now)
            state.goal       = goal
            state.resumeGoal = resume

            if goal then
                goal.settled = false -- walk back to its spot (e.g. after a home point)
            end
        end

        state.zoneId = zoneId

        local currentPos = { x = bot:getXPos(), y = bot:getYPos(), z = bot:getZPos() }
        local moving     = state.lastPos ~= nil and distance(currentPos, state.lastPos) > 0.05
        state.lastPos    = currentPos

        local zoned = false

        if bot:isDead() then
            deathStep(charId, state, now)
            goto continue
        end

        if bot:isEngaged() then
            if not state.inCombat then
                state.inCombat  = true
                state.engagedAt = now
            end

            combatActions(bot, charId, state, now)
        elseif state.inCombat then
            -- Fight just ended: lot the drops, check bags and gear soon.
            state.inCombat             = false
            state.lootUntil            = now + LOOT_WINDOW_SEC
            state.nextBagCheckAt       = now + 2
            state.nextInventoryCheckAt = now + LOOT_WINDOW_SEC
            state.walking              = false
            state.walkOrderAt          = nil
        end

        if state.lootUntil then
            if now < state.lootUntil then
                LotBotTreasure(charId)
            else
                state.lootUntil = nil
            end
        end

        if state.inCombat or combatStep(bot, charId, state, now, moving) then
            -- fighting, resting or closing in on prey this tick
        elseif state.travel then
            zoned = travelStep(charId, state, now, currentPos, moving)
        elseif state.walk then
            relocateStep(bot, charId, state, now, currentPos, moving)
        elseif state.chat then
            -- Standing in a chat circle: stay put until the chat is over, then
            -- drift off to another spot.
            if now >= state.chat.untilTime then
                leaveCircles(charId)
                state.chat           = nil
                state.nextSpotMoveAt = now
            end
        else
            if not moving then
                plan(bot, charId, state, now, zoneId)
            end

            if not state.travel and not state.walk then
                loiterStep(bot, charId, state, now, currentPos, moving)
            end
        end

        if not zoned and not state.inCombat and now >= (state.nextBagCheckAt or 0) then
            bagStep(bot, charId, state, now, zoneId)
        end

        -- Gear/scroll upkeep: on spawn, then every few minutes - never mid-walk.
        if not zoned and not moving and not state.inCombat and (state.nextInventoryCheckAt == nil or now >= state.nextInventoryCheckAt) then
            state.nextInventoryCheckAt = now + INVENTORY_CHECK_SEC
            local result = ManageBotInventory(charId)
            if result.equipped > 0 or result.learned > 0 then
                diag(charId, 'inventory: equipped %d, learned %d', result.equipped, result.learned)
            end
        end

        if not zoned and state.lastPositionSaveTime + POSITION_SAVE_INTERVAL_SEC <= now then
            state.lastPositionSaveTime = now
            SaveBotPosition(charId)
        end

        ::continue::
    end
end

return xi.worldbots
