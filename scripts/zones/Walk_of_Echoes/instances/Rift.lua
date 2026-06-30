-----------------------------------
-- Instance: Rift
-- Zone: Walk of Echoes (182)
-- Entered from: Xarcabard (112) via Rift_Surveyor NPC
-- Tiers 1-10, scaling mob level/HP per tier.
-- Mobs spawn dynamically — no instance_entities rows required.
-----------------------------------

require('globals/rift')

local instanceObject = {}

-- Spawns all regular mobs for the tier. Boss spawns only after all are killed.
instanceObject.onInstanceCreated = function(instance)
    local tier  = instance:getLocalVar('tier')
    local pool  = xi.rift.getMobPool(tier)
    local count = xi.rift.mobCount(tier)
    local lvl   = xi.rift.mobLevel(tier)
    local mult  = xi.rift.hpMult(tier)

    instance:setLocalVar('kills', 0)
    instance:setLocalVar('killsRequired', count)
    instance:setLocalVar('bossSpawned', 0)

    -- Shuffle spawn points so mob placement varies each run.
    local pts = {}
    for _, p in ipairs(xi.rift.SPAWN_POINTS) do
        pts[#pts + 1] = p
    end
    -- Fisher-Yates shuffle (skip last entry — that's the boss spawn point)
    local bossIdx = #pts
    for i = bossIdx - 1, 2, -1 do
        local j = math.random(i)
        pts[i], pts[j] = pts[j], pts[i]
    end

    for i = 1, count do
        local entry = pool[((i - 1) % #pool) + 1]
        local sp    = pts[((i - 1) % (bossIdx - 1)) + 1]

        instance:insertDynamicEntity({
            objtype     = xi.objType.MOB,
            name        = entry.name .. '_Rift',
            groupId     = entry.groupId,
            groupZoneId = entry.groupZoneId,
            minLevel    = lvl,
            maxLevel    = lvl,
            isAggroable = true,
            x = sp[1], y = sp[2], z = sp[3],
            rotation    = sp[4],

            onMobInitialize = function(mob)
                mob:setMaxHP(math.floor(mob:getMaxHP() * mult))
                mob:restoreHP()
                mob:setMobMod(xi.mobMod.TREASURE_HUNTER, xi.rift.thLevel(tier))
            end,

            onMobDeath = function(mob, player, optParams)
                xi.rift.onMobDeath(mob, player, instance, false)
            end,
        })
    end
end

-- Registers all party members to this instance. Do not modify.
instanceObject.onInstanceCreatedCallback = function(player, instance)
    xi.instance.onInstanceCreatedCallback(player, instance)
end

-- Welcome message when a player first enters.
instanceObject.afterInstanceRegister = function(player)
    local instance = player:getInstance()
    if not instance then return end
    local tier = instance:getLocalVar('tier')
    player:messageSpecial(zones[xi.zone.WALK_OF_ECHOES].text.NOTHING_OUT_OF_ORDINARY) -- placeholder; replace with a rift-specific message ID
end

-- Fires every second. Handles locking, ejection, and time updates.
instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    -- Track elapsed every tick so onInstanceComplete can read it.
    instance:setLocalVar('elapsed', elapsed)

    -- Lock the fight once any mob is engaged.
    if not instance:isLocked() then
        for _, mob in pairs(instance:getMobs()) do
            if mob:isEngaged() then
                instance:lock()
                break
            end
        end
    end

    -- Eject players 15 seconds after completion or failure.
    if instance:completed() or instance:failed() then
        local ejectAt = instance:getLocalVar('ejectAt')
        if ejectAt > 0 and elapsed >= ejectAt then
            for _, player in pairs(instance:getChars()) do
                player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
            end
        end
        return
    end

    xi.instance.updateInstanceTime(instance, elapsed, zones[xi.zone.WALK_OF_ECHOES].text)
end

-- Record the clear and schedule ejection.
instanceObject.onInstanceComplete = function(instance)
    local elapsed = instance:getLocalVar('elapsed')
    xi.rift.recordClear(instance, elapsed)
    instance:setLocalVar('ejectAt', elapsed + 15000)
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
end

-- Eject immediately on failure (wipe or time limit).
instanceObject.onInstanceFailure = function(instance)
    instance:setLocalVar('ejectAt', 1) -- eject on next tick
end

return instanceObject
