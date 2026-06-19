-----------------------------------
-- GM Command: !circuit
--
-- !circuit status              — show all circuit definitions
-- !circuit spawn <id>          — force-create circuit instance (id 1–12)
-- !circuit complete <ms>       — force-complete with fake clear time
-- !circuit fail                — force-fail current instance
-- !circuit points              — show player's current Circuit Points
-- !circuit give <n>            — give player N Circuit Points
-- !circuit leaderboard <id>    — show top 5 for circuit id
-----------------------------------
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss',
}

commandObj.onTrigger = function(player, sub, arg1, arg2)
    if sub == 'status' then
        for id, def in pairs(xi.circuit.CIRCUITS) do
            player:printToPlayer(string.format(
                '[%2d] Lv%d %s | instanceId=%d | Gamma=%s',
                id, def.tier, def.label, def.instanceId, tostring(def.isGamma)
            ))
        end

    elseif sub == 'spawn' then
        local id  = tonumber(arg1) or 1
        local def = xi.circuit.CIRCUITS[id]
        if not def then
            player:printToPlayer('Unknown circuit id: ' .. tostring(id))
            return
        end
        player:createInstance(def.instanceId)
        player:printToPlayer(string.format('Creating Circuit %d (Lv%d %s)...', id, def.tier, def.label))

    elseif sub == 'complete' then
        local instance = player:getInstance()
        if not instance then player:printToPlayer('Not in an instance.') return end
        local fakeMs = tonumber(arg1) or 300000
        instance:setLocalVar('startTime', 0)
        instance:setLocalVar('elapsed', fakeMs)
        instance:complete()
        player:printToPlayer(string.format('Circuit completed with fake time %dms.', fakeMs))

    elseif sub == 'fail' then
        local instance = player:getInstance()
        if not instance then player:printToPlayer('Not in an instance.') return end
        instance:fail()
        player:printToPlayer('Circuit failed.')

    elseif sub == 'points' then
        local pts    = player:getCharVar(xi.circuit.POINT_VAR)
        local badges = player:getCharVar(xi.circuit.BADGE_VAR)
        player:printToPlayer(string.format('Circuit Points: %d | Platinum Badges: %d', pts, badges))

    elseif sub == 'give' then
        local n       = tonumber(arg1) or 1
        local current = player:getCharVar(xi.circuit.POINT_VAR)
        player:setCharVar(xi.circuit.POINT_VAR, current + n)
        player:printToPlayer(string.format('Gave %d Circuit Points. Total: %d', n, current + n))

    elseif sub == 'leaderboard' then
        local id = tonumber(arg1) or 1
        player:printToPlayer(string.format('Leaderboard for circuit %d: (DB query not yet wired)', id))

    else
        player:printToPlayer('Usage: !circuit <status|spawn|complete|fail|points|give|leaderboard>')
    end
end

return commandObj
