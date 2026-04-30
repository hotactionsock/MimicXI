-----------------------------------
-- /syncbuddy command
-- Allows two players to form a sync buddy pair.
-- When both are in the same party and level sync is active, each member
-- of the pair receives bonus EXP (mentor) or bonus EXP (pupil) depending
-- on their level relative to the sync target.  The bonus only fires for
-- the designated pair and does not affect other party members.
--
-- Usage:
--   /syncbuddy <playername>  - Send a sync buddy request
--   /syncbuddy accept        - Accept an incoming request
--   /syncbuddy decline       - Decline an incoming request
--   /syncbuddy clear         - Remove your current sync buddy
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

local VAR_BUDDY_ID      = 'sync_buddy_id'
local VAR_BUDDY_PENDING = 'sync_buddy_pending'

local function getCurrentBuddy(player)
    local buddyId = player:getCharVar(VAR_BUDDY_ID)
    if buddyId == 0 then
        return nil
    end
    return GetPlayerByID(buddyId)
end

commandObj.onTrigger = function(player, arg)
    if arg == nil or arg == '' then
        player:printToPlayer('[Sync Buddy] Usage: /syncbuddy <name> | accept | decline | clear')
        return
    end

    ----------------------------
    -- ACCEPT
    ----------------------------
    if arg == 'accept' then
        local requesterId = player:getCharVar(VAR_BUDDY_PENDING)
        if requesterId == 0 then
            player:printToPlayer('[Sync Buddy] You have no pending sync buddy request.')
            return
        end

        local requester = GetPlayerByID(requesterId)
        if requester == nil then
            player:setCharVar(VAR_BUDDY_PENDING, 0)
            player:printToPlayer('[Sync Buddy] The player who sent the request is no longer online.')
            return
        end

        -- Break any existing buddy relationships on both sides first
        local oldBuddyOfRequester = requester:getCharVar(VAR_BUDDY_ID)
        if oldBuddyOfRequester ~= 0 then
            local oldBuddy = GetPlayerByID(oldBuddyOfRequester)
            if oldBuddy then
                oldBuddy:setCharVar(VAR_BUDDY_ID, 0)
                oldBuddy:printToPlayer(string.format('[Sync Buddy] %s has set a new sync buddy. Your sync buddy link has been cleared.', requester:getName()))
            end
        end
        local oldBuddyOfAccepter = player:getCharVar(VAR_BUDDY_ID)
        if oldBuddyOfAccepter ~= 0 then
            local oldBuddy = GetPlayerByID(oldBuddyOfAccepter)
            if oldBuddy then
                oldBuddy:setCharVar(VAR_BUDDY_ID, 0)
                oldBuddy:printToPlayer(string.format('[Sync Buddy] %s has set a new sync buddy. Your sync buddy link has been cleared.', player:getName()))
            end
        end

        -- Form the pair
        requester:setCharVar(VAR_BUDDY_ID, player:getID())
        player:setCharVar(VAR_BUDDY_ID, requester:getID())
        player:setCharVar(VAR_BUDDY_PENDING, 0)

        player:printToPlayer(string.format('[Sync Buddy] You and %s are now sync buddies! You will both receive bonus EXP when level synced together.', requester:getName()))
        requester:printToPlayer(string.format('[Sync Buddy] %s has accepted your sync buddy request! You will both receive bonus EXP when level synced together.', player:getName()))
        return
    end

    ----------------------------
    -- DECLINE
    ----------------------------
    if arg == 'decline' then
        local requesterId = player:getCharVar(VAR_BUDDY_PENDING)
        if requesterId == 0 then
            player:printToPlayer('[Sync Buddy] You have no pending sync buddy request.')
            return
        end

        local requester = GetPlayerByID(requesterId)
        player:setCharVar(VAR_BUDDY_PENDING, 0)
        player:printToPlayer('[Sync Buddy] Sync buddy request declined.')
        if requester then
            requester:printToPlayer(string.format('[Sync Buddy] %s has declined your sync buddy request.', player:getName()))
        end
        return
    end

    ----------------------------
    -- CLEAR
    ----------------------------
    if arg == 'clear' then
        local buddyId = player:getCharVar(VAR_BUDDY_ID)
        if buddyId == 0 then
            player:printToPlayer('[Sync Buddy] You do not currently have a sync buddy.')
            return
        end

        local buddy = GetPlayerByID(buddyId)
        if buddy then
            buddy:setCharVar(VAR_BUDDY_ID, 0)
            buddy:printToPlayer(string.format('[Sync Buddy] %s has cleared the sync buddy link. You no longer have a sync buddy.', player:getName()))
        end
        player:setCharVar(VAR_BUDDY_ID, 0)
        player:printToPlayer('[Sync Buddy] Sync buddy link cleared.')
        return
    end

    ----------------------------
    -- SEND REQUEST
    ----------------------------
    local targetName = arg
    local target     = GetPlayerByName(targetName)

    if target == nil then
        player:printToPlayer(string.format('[Sync Buddy] Player "%s" not found or is not online.', targetName))
        return
    end

    if target:getID() == player:getID() then
        player:printToPlayer('[Sync Buddy] You cannot set yourself as your sync buddy.')
        return
    end

    -- Check target doesn't already have a pending request from this player
    if target:getCharVar(VAR_BUDDY_PENDING) == player:getID() then
        player:printToPlayer(string.format('[Sync Buddy] You have already sent a request to %s.', target:getName()))
        return
    end

    -- Notify sender
    player:printToPlayer(string.format('[Sync Buddy] Sync buddy request sent to %s.', target:getName()))

    -- Store volatile pending request on the target (cleared on relog)
    target:setVolatileCharVar(VAR_BUDDY_PENDING, player:getID())

    -- Notify target with clear instructions
    target:printToPlayer(string.format('[Sync Buddy] %s wants to be your sync buddy!', player:getName()))
    target:printToPlayer('[Sync Buddy] Type /syncbuddy accept to confirm, or /syncbuddy decline to refuse.')
end

return commandObj
