-----------------------------------
-- /syncbuddy command
-- Allows two players to form a sync buddy pair.
-- When both are in the same party and level sync is active, each member
-- of the pair receives bonus EXP (mentor) or bonus EXP (pupil) depending
-- on their level relative to the sync target.  The bonus only fires for
-- the designated pair and does not affect other party members.
--
-- A 10-minute cooldown is applied to both players when a pair is formed.
-- While on cooldown a player cannot send requests or receive them.
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
local VAR_COOLDOWN_END  = 'sync_buddy_cooldown_end'
local COOLDOWN_SECONDS  = 600

-- Returns the number of seconds remaining on the cooldown, or 0 if not on cooldown.
local function cooldownRemaining(player)
    local endTime = player:getCharVar(VAR_COOLDOWN_END)
    if endTime == 0 then
        return 0
    end
    local remaining = endTime - os.time()
    return remaining > 0 and remaining or 0
end

-- Formats a duration in seconds as a human-readable string.
local function formatDuration(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    if mins > 0 and secs > 0 then
        return string.format('%d minute%s and %d second%s', mins, mins ~= 1 and 's' or '', secs, secs ~= 1 and 's' or '')
    elseif mins > 0 then
        return string.format('%d minute%s', mins, mins ~= 1 and 's' or '')
    else
        return string.format('%d second%s', secs, secs ~= 1 and 's' or '')
    end
end

-- Applies the post-accept cooldown to a player.
-- The end timestamp is stored as both the value and the DB expiry so the
-- row self-cleans once the cooldown lapses.
local function applyCooldown(player)
    local endTime = os.time() + COOLDOWN_SECONDS
    player:setCharVar(VAR_COOLDOWN_END, endTime, endTime)
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

        -- Cooldown check on the accepter
        local remaining = cooldownRemaining(player)
        if remaining > 0 then
            player:printToPlayer(string.format('[Sync Buddy] You cannot accept a sync buddy request for another %s.', formatDuration(remaining)))
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

        -- Apply cooldown to both players
        applyCooldown(player)
        applyCooldown(requester)

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

    -- Check the sender is not on cooldown
    local senderCooldown = cooldownRemaining(player)
    if senderCooldown > 0 then
        player:printToPlayer(string.format('[Sync Buddy] You cannot send sync buddy requests for another %s.', formatDuration(senderCooldown)))
        return
    end

    -- Check the target is not on cooldown
    if cooldownRemaining(target) > 0 then
        player:printToPlayer('[Sync Buddy] This player cannot receive Buddy Sync invites at this time.')
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
