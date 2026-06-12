-----------------------------------
-- Tier Trial Gatekeeper NPC — shared entry logic
--
-- Usage from a zone NPC script:
--   local gate = require('modules/custom/tier_trials/lua/tier_trial_gatekeeper')
--   entity.onTrigger = gate.onTrigger(30)   -- pass cap level: 30/40/50/60
-----------------------------------

local gate = {}

local DIFFICULTY_LABEL = { [1]='Normal', [2]='Hardened', [3]='Transcendent' }

local function warpParty(player, instance, tier, difficulty)
    instance:setLocalVar('tier',       tier)
    instance:setLocalVar('difficulty', difficulty)
    for _, member in pairs(player:getParty()) do
        -- TODO: replace 0,0,0,0 with real zone 183 start coords once measured
        member:setPos(0, 0, 0, 0, instance:getZone():getID())
    end
    player:setLocalVar('TT_InstanceRequested', 0)
end

local function pollAndWarp(player, tier, difficulty, attempts)
    attempts = attempts or 0
    local instance = player:getInstance()
    if instance then
        warpParty(player, instance, tier, difficulty)
    elseif attempts < 10 then
        player:timer(500, function(p)
            pollAndWarp(p, tier, difficulty, attempts + 1)
        end)
    else
        player:printToPlayer('Instance unavailable. Try again.', xi.msg.channel.SYSTEM_3)
        player:setLocalVar('TT_InstanceRequested', 0)
    end
end

local function tryJoin(player, tier, difficulty)
    local def = xi.tierTrial.TIERS[tier]

    if not xi.tierTrial.canAttempt(player, tier, difficulty) then
        player:printToPlayer('Requirements not met.', xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getLocalVar('TT_InstanceRequested') == 1 then
        return  -- already waiting
    end

    player:setLocalVar('TT_InstanceRequested', 1)
    player:createInstance(def.instanceId)
    player:timer(500, function(p)
        pollAndWarp(p, tier, difficulty, 0)
    end)
end

local function showDifficultyMenu(player, tier, def)
    local options = {}

    for diff = 1, 3 do
        if xi.tierTrial.canAttempt(player, tier, diff) then
            local d = diff
            table.insert(options, {
                DIFFICULTY_LABEL[d],
                function(p) tryJoin(p, tier, d) end,
            })
        end
    end

    table.insert(options, { 'Leave', function() end })

    player:timer(100, function(p)
        p:customMenu({ title = def.label, options = options })
    end)
end

-- Returns an onTrigger function bound to a specific cap tier
gate.onTrigger = function(tier)
    return function(player, npc)
        local def = xi.tierTrial.TIERS[tier]
        if not def then return end

        local marks = player:getCharVar(def.markVar)
        player:printToPlayer(
            string.format('Lv%d Trial | Marks: %d', tier, marks),
            xi.msg.channel.SYSTEM_3
        )
        player:printToPlayer('Wave 5 clear rewards a Trial Shard.', xi.msg.channel.SYSTEM_3)

        showDifficultyMenu(player, tier, def)
    end
end

return gate
