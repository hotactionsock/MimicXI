-----------------------------------
-- Circuit — Shared Instance Script Logic
--
-- Each circuit's instance script requires this file and calls
-- xi.circuit.instance.build(circuitId) to get the instanceObject.
--
-- Local vars used per instance:
--   'circuitId'   -- which circuit (1–12)
--   'startTime'   -- elapsed ms when first mob is killed (timer starts on first kill)
--   'mobsAlive'   -- count of mobs currently alive
--   'locked'      -- 1 after first mob dies (timer running)
--   'ejectAt'     -- elapsed ms when players are ejected post-clear
-----------------------------------

xi.circuit         = xi.circuit or {}
xi.circuit.instance = xi.circuit.instance or {}

-----------------------------------
-- Spawn all mobs for this circuit
-- Mob layout is determined by roomCount in the circuit definition.
-- Each room's mobs are stored as a flat list in the circuit's mob tables.
-----------------------------------
local function spawnCircuitMobs(instance, circuitDef)
    local zoneId  = xi.zone.MAQUETTE_ABDHALJS_LEGION_A
    local ID      = zones[zoneId]
    local tierKey = 'C' .. circuitDef.tier  -- e.g. 'C30'
    local count   = 0

    if not ID or not ID.mob or not ID.mob[tierKey] then return 0 end

    -- Spawn based on roomCount: Alpha uses first 8, Beta first 12, Gamma all
    local roomLimits = { [2] = 8, [3] = 12, [4] = 13 }
    local limit      = roomLimits[circuitDef.roomCount] or 8
    local spawned    = 0

    for _, mobId in ipairs(ID.mob[tierKey]) do
        if spawned >= limit then break end
        local mob = SpawnMob(mobId, instance)
        if mob then
            -- Circuit mobs: reduced HP for speed tuning (75% of normal)
            mob:setHP(math.floor(mob:getMaxHP() * 0.75))
            count   = count + 1
            spawned = spawned + 1
        end
    end

    return count
end

-----------------------------------
-- Build instanceObject for a given circuit ID
-----------------------------------
xi.circuit.instance.build = function(circuitId)
    local instanceObject = {}
    local circuitDef     = xi.circuit.CIRCUITS[circuitId]

    instanceObject.onInstanceCreated = function(instance)
        instance:setLocalVar('circuitId', circuitId)
        instance:setLocalVar('startTime', 0)
        instance:setLocalVar('locked', 0)
        instance:setLocalVar('ejectAt', 0)

        instance:setLevelCap(circuitDef.levelCap)

        local alive = spawnCircuitMobs(instance, circuitDef)
        instance:setLocalVar('mobsAlive', alive)
    end

    instanceObject.onInstanceCreatedCallback = function(player, instance)
        xi.instance.onInstanceCreatedCallback(player, instance)
    end

    instanceObject.afterInstanceRegister = function(player)
        local instance = player:getInstance()
        player:messageSpecial(
            zones[player:getZoneID()].text.TIME_TO_COMPLETE or 0,
            instance:getTimeLimit()
        )
    end

    instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
        -- Eject after complete/fail
        if instance:completed() or instance:failed() then
            local ejectAt = instance:getLocalVar('ejectAt')
            if ejectAt > 0 and elapsed >= ejectAt then
                for _, player in pairs(instance:getChars()) do
                    player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
                end
            end
            return
        end

        -- Start timer on first mob death (mob's onMobDeath sets locked=1 and startTime)
        -- Check win condition: all mobs dead
        local locked = instance:getLocalVar('locked')
        if locked == 1 then
            local anyAlive = false
            for _, mob in pairs(instance:getMobs()) do
                if mob:isAlive() then
                    anyAlive = true
                    break
                end
            end

            if not anyAlive then
                instance:complete()
            end
        end

        xi.instance.updateInstanceTime(instance, elapsed,
            zones[instance:getZone():getID()].text)
    end

    instanceObject.onInstanceComplete = function(instance)
        local startTime  = instance:getLocalVar('startTime')
        local elapsed    = instance:getLocalVar('elapsed') or startTime
        local clearTime  = elapsed - startTime

        for _, player in pairs(instance:getChars()) do
            local rank, earned = xi.circuit.recordRun(player, circuitId, clearTime)
            if rank and earned then
                -- TODO: display rank/points via message once text IDs are assigned
                player:PrintToPlayer(string.format(
                    'Circuit clear! Rank: %s | Points earned: %d | Total: %d',
                    rank, earned, player:getCharVar(xi.circuit.POINT_VAR)
                ))
            end
        end

        instance:setLocalVar('ejectAt', elapsed + 10000)
    end

    instanceObject.onInstanceFailure = function(instance)
        for _, player in pairs(instance:getChars()) do
            player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
        end
    end

    instanceObject.onInstanceProgressUpdate = function(instance, progress)
    end

    return instanceObject
end

-----------------------------------
-- Called from mob death handler in circuit mob scripts
-- Starts the timer on first kill, tracks remaining mobs
-----------------------------------
xi.circuit.onMobDeath = function(mob, instance)
    if not instance then return end

    -- Start timer on first kill
    if instance:getLocalVar('locked') == 0 then
        instance:setLocalVar('locked', 1)
        -- startTime is set by the mob script passing current elapsed
        -- We use a local var set by the instance tick to track elapsed
    end

    local alive = instance:getLocalVar('mobsAlive')
    if alive and alive > 0 then
        instance:setLocalVar('mobsAlive', alive - 1)
    end
end
