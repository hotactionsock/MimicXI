-----------------------------------
-- GM Commands: The Circuit
--
-- !circuit status              — show all circuit definitions
-- !circuit spawn <id>          — force-create circuit instance (id 1–12)
-- !circuit complete <ms>       — force-complete current instance with fake clear time
-- !circuit fail                — force-fail current instance
-- !circuit points              — show player's current Circuit Points
-- !circuit give <n>            — give player N Circuit Points
-- !circuit leaderboard <id>    — show top 5 for circuit id
-----------------------------------

-- Renamed to circuit.lua — this file is intentionally empty.
do return {} end

local CMD = {}

CMD['circuit'] = function(player, command, args)
    local sub = args[1]

    if sub == 'status' then
        for id, def in pairs(xi.circuit.CIRCUITS) do
            player:PrintToPlayer(string.format(
                '[%2d] Lv%d %s | instanceId=%d | Gamma=%s',
                id, def.tier, def.label, def.instanceId, tostring(def.isGamma)
            ))
        end

    elseif sub == 'spawn' then
        local id  = tonumber(args[2]) or 1
        local def = xi.circuit.CIRCUITS[id]
        if not def then
            player:PrintToPlayer('Unknown circuit id: ' .. tostring(id))
            return
        end
        player:createInstance(def.instanceId)
        player:PrintToPlayer(string.format('Creating Circuit %d (Lv%d %s)...', id, def.tier, def.label))

    elseif sub == 'complete' then
        local instance = player:getInstance()
        if not instance then
            player:PrintToPlayer('Not in an instance.')
            return
        end
        local fakeMs = tonumber(args[2]) or 300000
        instance:setLocalVar('startTime', 0)
        instance:setLocalVar('elapsed', fakeMs)
        instance:complete()
        player:PrintToPlayer(string.format('Circuit completed with fake time %dms.', fakeMs))

    elseif sub == 'fail' then
        local instance = player:getInstance()
        if not instance then
            player:PrintToPlayer('Not in an instance.')
            return
        end
        instance:fail()
        player:PrintToPlayer('Circuit failed.')

    elseif sub == 'points' then
        local pts = player:getCharVar(xi.circuit.POINT_VAR)
        local badges = player:getCharVar(xi.circuit.BADGE_VAR)
        player:PrintToPlayer(string.format(
            'Circuit Points: %d | Platinum Badges: %d', pts, badges
        ))

    elseif sub == 'give' then
        local n       = tonumber(args[2]) or 1
        local current = player:getCharVar(xi.circuit.POINT_VAR)
        player:setCharVar(xi.circuit.POINT_VAR, current + n)
        player:PrintToPlayer(string.format('Gave %d Circuit Points. Total: %d', n, current + n))

    elseif sub == 'leaderboard' then
        local id = tonumber(args[2]) or 1
        -- Stub: query circuit_leaderboard for top 5 runs on this circuit_id
        player:PrintToPlayer(string.format('Leaderboard for circuit %d: (DB query not yet wired)', id))

    else
        player:PrintToPlayer('Usage: !circuit <status|spawn|complete|fail|points|give|leaderboard>')
    end
end

return CMD
