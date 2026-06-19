-----------------------------------
-- func: !fate [subcommand] [zoneID] [eventID]
-- desc: GM commands for the FATE system.
--
--   !fate                              -- status for current zone
--   !fate spawn [zoneID] [eventID]     -- force-activate (random if no eventID)
--   !fate end   [zoneID] <eventID>     -- force-resolve as VICTORY
--   !fate lose  [zoneID] <eventID>     -- force-resolve as DEFEAT
--   !fate reset [zoneID] [eventID]     -- reset event (all if no eventID)
--
-- zoneID defaults to current zone when arg1 is non-numeric.
-----------------------------------
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss',
}

local STATE_IDLE     = 0
local STATE_ACTIVE   = 1
local STATE_COOLDOWN = 2
local STATE_PENDING  = 3

local function stateKey(zoneID, eventIdx)    return string.format("[FATE][%d][%d]State",       zoneID, eventIdx) end
local function cooldownKey(zoneID, eventIdx) return string.format("[FATE][%d][%d]CooldownEnd", zoneID, eventIdx) end

local function printUsage(player)
    player:printToPlayer("Usage:")
    player:printToPlayer("  !fate                          -- status for current zone")
    player:printToPlayer("  !fate spawn [zoneID] [eventID] -- force-activate (random if no eventID)")
    player:printToPlayer("  !fate end   [zoneID] <eventID> -- force-resolve as VICTORY")
    player:printToPlayer("  !fate lose  [zoneID] <eventID> -- force-resolve as DEFEAT")
    player:printToPlayer("  !fate reset [zoneID] [eventID] -- reset event (all if no eventID)")
    player:printToPlayer("zoneID defaults to current zone if omitted.")
end

local function showStatus(player, zoneID, zoneData)
    player:printToPlayer(string.format("[FATE] Zone %d (%s) — %d event(s):", zoneID, zoneData.zoneName, #zoneData.events))
    for eventIdx, def in ipairs(zoneData.events) do
        local state    = GetServerVariable(stateKey(zoneID, eventIdx))
        local stateStr = state == STATE_ACTIVE   and "ACTIVE"   or
                         state == STATE_COOLDOWN and "COOLDOWN" or
                         state == STATE_PENDING  and "PENDING"  or "IDLE"
        local extra    = ""
        if state == STATE_ACTIVE then
            extra = string.format(" — %ds remaining", xi.fate.getRemaining(zoneID, eventIdx))
        elseif state == STATE_COOLDOWN then
            local cd = math.max(0, GetServerVariable(cooldownKey(zoneID, eventIdx)) - GetSystemTime())
            extra = string.format(" — cooldown %ds", cd)
        end
        local tag = def.chainOnly and " [chain]" or ""
        player:printToPlayer(string.format("  [%d] %-24s %s (Lv%d)%s%s", eventIdx, def.id, stateStr, def.level, tag, extra))
    end
end

-- Returns zoneID and secondArg.
-- If arg1 is numeric it is the zoneID; otherwise current zone is used.
local function resolveZone(player, arg1, arg2)
    local asNum = tonumber(arg1)
    if asNum then
        return math.floor(asNum), arg2
    else
        return player:getZoneID(), arg1
    end
end

local function findEventIdx(zoneID, eventID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return nil end
    for i, def in ipairs(zoneData.events) do
        if def.id == eventID then return i end
    end
    return nil
end

commandObj.onTrigger = function(player, subcmd, arg1, arg2)
    if not xi.fate or not xi.fate.zones then
        player:printToPlayer("[FATE] Engine not loaded.")
        return
    end

    -- No subcommand: status for current zone
    if subcmd == nil then
        local zoneID   = player:getZoneID()
        local zoneData = xi.fate.zones[zoneID]
        if not zoneData then
            player:printToPlayer(string.format("[FATE] Zone %d has no FATE definitions.", zoneID))
            return
        end
        showStatus(player, zoneID, zoneData)
        return
    end

    subcmd = string.lower(subcmd)

    -----------------------------------
    if subcmd == "spawn" then
        local zoneID, eventID = resolveZone(player, arg1, arg2)
        local zoneData        = xi.fate.zones[zoneID]

        if not zoneData then
            player:printToPlayer(string.format("[FATE] Zone %d has no FATE definitions.", zoneID))
            return
        end

        if eventID then
            local eventIdx = findEventIdx(zoneID, eventID)
            if not eventIdx then
                player:printToPlayer(string.format("[FATE] Event '%s' not found in zone %d.", eventID, zoneID))
                return
            end
            if xi.fate.isActive(zoneID, eventIdx) then
                player:printToPlayer(string.format("[FATE] Event %s is already active.", eventID))
                return
            end
            SetServerVariable(stateKey(zoneID, eventIdx), STATE_IDLE)
            xi.fate.activateByID(zoneID, eventID)
            player:printToPlayer(string.format("[FATE] Zone %d: spawned %s.", zoneID, eventID))
        else
            local zone     = GetZone(zoneID)
            local eligible = {}
            for i, def in ipairs(zoneData.events) do
                if not def.chainOnly and not xi.fate.isActive(zoneID, i) then
                    table.insert(eligible, { idx = i, def = def })
                end
            end

            if #eligible == 0 then
                player:printToPlayer(string.format("[FATE] Zone %d: no eligible events to spawn.", zoneID))
                return
            end

            local pick = eligible[math.random(#eligible)]
            SetServerVariable(stateKey(zoneID, pick.idx), STATE_IDLE)
            xi.fate.activate(zone, pick.def, zoneID, pick.idx)
            player:printToPlayer(string.format("[FATE] Zone %d: spawned %s.", zoneID, pick.def.id))
        end

    -----------------------------------
    elseif subcmd == "end" or subcmd == "lose" then
        local zoneID, eventID = resolveZone(player, arg1, arg2)
        local victory         = (subcmd == "end")

        if not eventID then
            player:printToPlayer("[FATE] Usage: !fate end [zoneID] <eventID>  OR  !fate lose [zoneID] <eventID>")
            return
        end

        local eventIdx = findEventIdx(zoneID, eventID)
        if not eventIdx then
            player:printToPlayer(string.format("[FATE] Event '%s' not found in zone %d.", eventID, zoneID))
            return
        end

        if not xi.fate.isActive(zoneID, eventIdx) then
            player:printToPlayer(string.format("[FATE] Event %s is not currently active.", eventID))
            return
        end

        xi.fate.resolve(zoneID, eventIdx, victory)
        player:printToPlayer(string.format("[FATE] Zone %d event %s: resolved as %s.", zoneID, eventID, victory and "VICTORY" or "DEFEAT"))

    -----------------------------------
    elseif subcmd == "reset" then
        local zoneID, eventID = resolveZone(player, arg1, arg2)
        local zoneData        = xi.fate.zones[zoneID]

        if not zoneData then
            player:printToPlayer(string.format("[FATE] Zone %d has no FATE definitions.", zoneID))
            return
        end

        local zone = GetZone(zoneID)

        local function resetEvent(eventIdx)
            local def = xi.fate.getEventDef(zoneID, eventIdx)
            if xi.fate.isActive(zoneID, eventIdx) and zone then
                xi.fate.sweepMobs(zoneID, eventIdx)
                local entry = xi.fate.entryNPCs and xi.fate.entryNPCs[zoneID] and xi.fate.entryNPCs[zoneID][eventIdx]
                if entry then entry:setStatus(xi.status.DISAPPEAR) end
                -- Hide defense target NPCs (Supply Posts etc.)
                if def and def.objective and def.objective.type == "defend" then
                    SetVolatileServerVariable(string.format("[SBOSS][%d][%d]Wave", zoneID, eventIdx), 0)
                    local dTargets = xi.fate.defenseTargetNPCs and xi.fate.defenseTargetNPCs[zoneID] and xi.fate.defenseTargetNPCs[zoneID][eventIdx]
                    if dTargets then
                        for _, t in ipairs(dTargets) do
                            t:setStatus(xi.status.DISAPPEAR)
                        end
                    end
                end
                -- Hide collection-point NPCs
                if def and def.objective and def.objective.type == "collect" then
                    local cnpcs = xi.fate.collectNPCs and xi.fate.collectNPCs[zoneID] and xi.fate.collectNPCs[zoneID][eventIdx]
                    if cnpcs then
                        for _, c in ipairs(cnpcs) do
                            c:setStatus(xi.status.DISAPPEAR)
                            c:setLocalVar("fateCollected", 0)
                        end
                    end
                end
            end
            SetServerVariable(stateKey(zoneID, eventIdx),    STATE_IDLE)
            SetServerVariable(cooldownKey(zoneID, eventIdx), 0)
        end

        if eventID then
            local eventIdx = findEventIdx(zoneID, eventID)
            if not eventIdx then
                player:printToPlayer(string.format("[FATE] Event '%s' not found in zone %d.", eventID, zoneID))
                return
            end
            resetEvent(eventIdx)
            xi.fate.participants[zoneID]           = xi.fate.participants[zoneID] or {}
            xi.fate.participants[zoneID][eventIdx] = {}
            player:printToPlayer(string.format("[FATE] Zone %d event %s: reset to IDLE.", zoneID, eventID))
        else
            for eventIdx, _ in ipairs(zoneData.events) do
                resetEvent(eventIdx)
            end
            xi.fate.participants[zoneID] = {}
            player:printToPlayer(string.format("[FATE] Zone %d: all events reset to IDLE.", zoneID))
        end

    -----------------------------------
    else
        printUsage(player)
    end
end

return commandObj
