-----------------------------------
-- Tier Trial Gatekeeper NPC — shared logic
--
-- Each entrance zone has a thin NPC script that calls through here,
-- passing its tier value. Handles difficulty selection, unlock checks,
-- and instance creation.
--
-- Usage from a zone NPC script:
--   local gatekeeper = require('modules/custom/tier_trials/lua/tier_trial_gatekeeper')
--   entity.onTrigger = function(player, npc) gatekeeper.onTrigger(player, npc, 30) end
--   entity.onEventUpdate = gatekeeper.onEventUpdate
--   entity.onEventFinish = gatekeeper.onEventFinish
-----------------------------------

local gatekeeper = {}

-- CSIDs (TODO: assign real cutscene IDs per entrance zone)
-- For now use a placeholder event; these are set per-zone
local CSID_DIFFICULTY_SELECT = 0 -- TODO

gatekeeper.onTrigger = function(player, npc, tier)
    local tierDef = xi.tierTrial.TIERS[tier]
    if not tierDef then return end

    player:setLocalVar('TT_Tier', tier)
    player:startEvent(CSID_DIFFICULTY_SELECT)
end

gatekeeper.onEventUpdate = function(player, csid, option, npc)
    -- option 0 = Standard, 1 = Hardened, 2 = Transcendent, 3 = Cancel
    if option == 3 then
        player:release()
        return false
    end

    local difficulty = option + 1
    local tier       = player:getLocalVar('TT_Tier')

    -- Validate unlock
    if not xi.tierTrial.canAttempt(player, tier, difficulty) then
        -- Difficulty not unlocked yet — loop back to menu
        return true
    end

    player:setLocalVar('TT_Difficulty', difficulty)

    if player:getLocalVar('TT_InstanceRequested') == 0 then
        player:createInstance(xi.tierTrial.TIERS[tier].instanceId)
        player:setLocalVar('TT_InstanceRequested', 1)
    end

    local requested = player:getLocalVar('TT_InstanceRequested')
    if player:getInstance() ~= nil or (requested > 0 and requested < 10) then
        player:setLocalVar('TT_InstanceRequested', requested + 1)
        return true
    end

    return false
end

gatekeeper.onEventFinish = function(player, csid, option, npc)
    local instance = player:getInstance()
    if not instance then
        player:setLocalVar('TT_InstanceRequested', 0)
        player:setLocalVar('TT_Tier', 0)
        return
    end

    local difficulty = player:getLocalVar('TT_Difficulty')
    instance:setLocalVar('difficulty', difficulty)

    player:setLocalVar('TT_Difficulty', 0)
    player:setLocalVar('TT_InstanceRequested', 0)

    for _, member in pairs(player:getParty()) do
        member:setPos(0, 0, 0, 0, instance:getZone():getID())
    end
end

return gatekeeper
