-----------------------------------
-- Sync Buddy Milestone System
-- Shared logic for the three Expedition Chronicler NPCs.
--
-- Players accumulate bonus XP through the Sync Buddy system.
-- Each tier can be claimed once at the relevant NPC in any starting city.
-- Talking to the NPC awards the lowest unclaimed eligible tier automatically.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi      = xi or {}
xi.sb   = xi.sb or {}

local VAR_BONUS_EXP = 'sync_buddy_bonus_exp'

-- Milestone tier definitions.
-- var:     char var set to 1 when this tier has been claimed.
-- xp:      cumulative bonus XP required to unlock.
-- label:   shown in progress messages.
-- rewards: list of { itemId, qty } tables; nil entries skipped (placeholder tiers).
local TIERS =
{
    {
        var    = 'sync_buddy_milestone_1',
        xp     = 25000,
        label  = 'Tier I',
        rewards =
        {
            { itemId = xi.item.SCROLL_OF_RERAISE_III, qty = 1, name = 'Scroll of Reraise III' },
            { itemId = xi.item.HI_RERAISER,           qty = 3, name = 'Hi-Reraiser'           },
        },
    },
    {
        var    = 'sync_buddy_milestone_2',
        xp     = 75000,
        label  = 'Tier II',
        rewards =
        {
            { itemId = xi.item.PEACOCK_CHARM, qty = 1, name = 'Peacock Charm' },
        },
    },
    {
        var    = 'sync_buddy_milestone_3',
        xp     = 200000,
        label  = 'Tier III',
        rewards =
        {
            { itemId = xi.item.QUICK_BELT, qty = 1, name = 'Quick Belt' },
        },
    },
    {
        var    = 'sync_buddy_milestone_4',
        xp     = 400000,
        label  = 'Tier IV',
        rewards =
        {
            { itemId = xi.item.JELLY_RING, qty = 1, name = 'Jelly Ring' },
        },
    },
    {
        var     = 'sync_buddy_milestone_5',
        xp      = 700000,
        label   = 'Tier V',
        rewards = nil, -- Placeholder: custom item pending DAT work
    },
    {
        var    = 'sync_buddy_milestone_6',
        xp     = 1000000,
        label  = 'Tier VI',
        rewards =
        {
            { itemId = xi.item.NINURTAS_SASH, qty = 1, name = "Ninurta's Sash" },
        },
    },
}

-- Returns the player's total accumulated sync buddy bonus XP.
local function getBonusExp(player)
    return player:getCharVar(VAR_BONUS_EXP)
end

-- Returns the index of the lowest unclaimed eligible tier, or nil if none.
local function getClaimableTier(player)
    local bonusExp = getBonusExp(player)
    for i, tier in ipairs(TIERS) do
        if player:getCharVar(tier.var) == 0 and bonusExp >= tier.xp then
            return i, tier
        end
    end
    return nil, nil
end

-- Returns the next locked tier (first not yet reachable), or nil if all are unlocked.
local function getNextLockedTier(player)
    local bonusExp = getBonusExp(player)
    for _, tier in ipairs(TIERS) do
        if bonusExp < tier.xp then
            return tier
        end
    end
    return nil
end

-- Grants all items for the given tier. Returns true if successful.
local function grantRewards(player, tier)
    if tier.rewards == nil then
        return false
    end

    -- Check inventory space first
    local slotsNeeded = #tier.rewards
    if player:getFreeSlotsCount() < slotsNeeded then
        player:printToPlayer('[Expedition Chronicler] You do not have enough inventory space to receive this reward. Please make room and return.')
        return false
    end

    for _, reward in ipairs(tier.rewards) do
        player:addItem(reward.itemId, reward.qty)
    end
    return true
end

-- Formats a large number with comma separators for readability.
local function formatNumber(n)
    local s = tostring(n)
    return s:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
end

-- Main NPC interaction handler — called by each city's Expedition Chronicler.
function xi.sb.onTrigger(player, npc)
    local bonusExp  = getBonusExp(player)
    local tierIdx, claimable = getClaimableTier(player)

    -- Greet the player and show their total
    player:printToPlayer(string.format('[Expedition Chronicler] Greetings, %s. I have been observing your journeys with your companion.', player:getName()))
    player:printToPlayer(string.format('[Expedition Chronicler] Your bond has earned you %s bonus experience thus far.', formatNumber(bonusExp)))

    -- Award the lowest unclaimed eligible tier
    if claimable then
        if claimable.rewards == nil then
            -- Placeholder tier — reward not yet available
            player:printToPlayer(string.format('[Expedition Chronicler] You have reached %s, but this reward is not yet ready. Return in time and it shall be yours.', claimable.label))
        else
            local rewardNames = {}
            for _, r in ipairs(claimable.rewards) do
                table.insert(rewardNames, r.qty > 1 and string.format('%dx %s', r.qty, r.name) or r.name)
            end
            player:printToPlayer(string.format('[Expedition Chronicler] You have proven yourself worthy of your %s reward: %s.', claimable.label, table.concat(rewardNames, ', ')))

            if grantRewards(player, claimable) then
                player:setCharVar(claimable.var, 1)
                player:printToPlayer('[Expedition Chronicler] May these serve you well on future adventures.')

                -- Check if the next tier is also immediately claimable (e.g. returning player)
                local nextIdx, nextClaimable = getClaimableTier(player)
                if nextClaimable then
                    player:printToPlayer('[Expedition Chronicler] It seems you have earned further rewards as well. Please speak with me again.')
                end
            end
        end
    else
        -- All claimed, or none yet reached
        local allClaimed = true
        for _, tier in ipairs(TIERS) do
            if player:getCharVar(tier.var) == 0 then
                allClaimed = false
                break
            end
        end

        if allClaimed then
            player:printToPlayer('[Expedition Chronicler] You have claimed every reward available. Your dedication to your companion is truly remarkable.')
        else
            local next = getNextLockedTier(player)
            if next then
                local needed = next.xp - bonusExp
                player:printToPlayer(string.format('[Expedition Chronicler] You are not yet ready for your next reward. Earn %s more bonus experience and return.', formatNumber(needed)))
            end
        end
    end
end
