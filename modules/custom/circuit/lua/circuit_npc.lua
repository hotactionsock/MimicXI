-----------------------------------
-- Circuit Timekeeper NPC — shared entry logic
--
-- One NPC per cap tier lists Alpha/Beta/Gamma and launches the chosen run.
-- Usage from a zone NPC script:
--
--   local timekeeper = require('modules/custom/circuit/lua/circuit_npc')
--   entity.onTrigger = timekeeper.onTrigger(30)   -- pass cap: 30/40/50/60
-----------------------------------

local timekeeper = {}

local function msg(player, text)
    player:printToPlayer(text, xi.msg.channel.SYSTEM_3)
end

local function pollAndWarp(player, circuitId, attempts)
    attempts = attempts or 0
    local instance = player:getInstance()
    if instance then
        instance:setLocalVar('circuitId', circuitId)
        for _, member in pairs(player:getParty()) do
            -- TODO: replace 0,0,0,0 with real zone 183 start coords once measured
            member:setPos(0, 0, 0, 0, instance:getZone():getID())
        end
        player:setLocalVar('CR_Requested', 0)
    elseif attempts < 10 then
        player:timer(500, function(p)
            pollAndWarp(p, circuitId, attempts + 1)
        end)
    else
        msg(player, 'Instance unavailable. Try again.')
        player:setLocalVar('CR_Requested', 0)
    end
end

local function tryJoin(player, circuitId)
    if player:getLocalVar('CR_Requested') == 1 then return end

    local def = xi.circuit.CIRCUITS[circuitId]
    if not def then return end

    player:setLocalVar('CR_Requested', 1)
    player:createInstance(def.instanceId)
    player:timer(500, function(p)
        pollAndWarp(p, circuitId, 0)
    end)
end

local function msToMin(ms)
    return string.format('%dm', math.floor(ms / 60000))
end

-- Returns an onTrigger function bound to a specific cap tier
timekeeper.onTrigger = function(tier)
    return function(player, npc)
        local pts = player:getCharVar(xi.circuit.POINT_VAR)
        msg(player, string.format('Lv%d Circuit | Points: %d', tier, pts))

        -- Collect circuits for this tier
        local tieredCircuits = {}
        for id, def in pairs(xi.circuit.CIRCUITS) do
            if def.tier == tier then
                tieredCircuits[#tieredCircuits+1] = { id=id, def=def }
            end
        end
        table.sort(tieredCircuits, function(a, b) return a.id < b.id end)

        local options = {}
        for _, entry in ipairs(tieredCircuits) do
            local e   = entry
            local def = e.def
            local plat = msToMin(def.timeTargets[1])
            local label = string.format('%s (Plat<%s)', def.label, plat)
            table.insert(options, {
                label,
                function(p) tryJoin(p, e.id) end,
            })
        end
        table.insert(options, { 'Leave', function() end })

        player:timer(100, function(p)
            p:customMenu({
                title   = string.format('The Circuit Lv%d', tier),
                options = options,
            })
        end)
    end
end

return timekeeper
