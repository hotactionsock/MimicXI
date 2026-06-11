-----------------------------------
-- Module: tier_trials
--
-- Instanced solo/duo gauntlet fights at four level caps: 30 / 40 / 50 / 60.
-- Each tier has 5 waves of era-appropriate enemies ending in a named boss.
-- Three difficulty modes (Standard / Hardened / Transcendent) gate rewards
-- and drop rates for Tier I Proving Arms weapons and Trial Shards.
--
-- Toggle: comment/uncomment entries in modules/init.txt
--
-- Dependencies: none (proving_arms module consumes shards but is independent)
-----------------------------------
require('modules/module_utils')

local m = Module:new('mimic_tier_trials')

xi            = xi or {}
xi.tierTrial  = xi.tierTrial or {}

-----------------------------------
-- Constants
-----------------------------------
xi.tierTrial.DIFFICULTY =
{
    STANDARD     = 1,
    HARDENED     = 2,
    TRANSCENDENT = 3,
}

xi.tierTrial.WAVE_COUNT = 5

-- Char var used to track Transcendent unlock gate per tier
-- Format: '[TierTrial]<tier>HardenedCleared'
xi.tierTrial.VAR_HARDENED_CLEARED     = '[TierTrial]%dHardenedCleared'
xi.tierTrial.VAR_TRANSCENDENT_CLEARED = '[TierTrial]%dTranscendentCleared'

-----------------------------------
-- Difficulty modifiers
-----------------------------------
xi.tierTrial.DIFFICULTY_MODS =
{
    [xi.tierTrial.DIFFICULTY.STANDARD]     = { hp = 1.0,  dmg = 1.0 },
    [xi.tierTrial.DIFFICULTY.HARDENED]     = { hp = 1.75, dmg = 1.4 },
    [xi.tierTrial.DIFFICULTY.TRANSCENDENT] = { hp = 3.0,  dmg = 2.0 },
}

-----------------------------------
-- Mark rewards per difficulty
-- Index: difficulty → marks earned on clear
-----------------------------------
xi.tierTrial.MARK_REWARDS =
{
    [xi.tierTrial.DIFFICULTY.STANDARD]     = 1,
    [xi.tierTrial.DIFFICULTY.HARDENED]     = 2,
    [xi.tierTrial.DIFFICULTY.TRANSCENDENT] = 4,
}

-- Bonus mark for clearing under the time threshold (ms)
xi.tierTrial.TIME_BONUS_THRESHOLD = 600000 -- 10 minutes
xi.tierTrial.TIME_BONUS_MARKS     = 1

-----------------------------------
-- Shard drop count per difficulty
-----------------------------------
xi.tierTrial.SHARD_DROP_COUNT =
{
    [xi.tierTrial.DIFFICULTY.STANDARD]     = 1,
    [xi.tierTrial.DIFFICULTY.HARDENED]     = 2,
    [xi.tierTrial.DIFFICULTY.TRANSCENDENT] = 3,
}

-----------------------------------
-- Tier I weapon drop rates per difficulty
-----------------------------------
xi.tierTrial.WEAPON_DROP_RATE =
{
    [xi.tierTrial.DIFFICULTY.STANDARD]     = 30,  -- 30%
    [xi.tierTrial.DIFFICULTY.HARDENED]     = 60,  -- 60%
    [xi.tierTrial.DIFFICULTY.TRANSCENDENT] = 100, -- guaranteed
}

-----------------------------------
-- Tier definitions
-- Populated by individual tier files (tier_trial_30.lua etc.)
-----------------------------------
xi.tierTrial.TIERS = {}

-----------------------------------
-- Load tier definitions
-----------------------------------
require('modules/custom/tier_trials/lua/tier_trial_30')
require('modules/custom/tier_trials/lua/tier_trial_40')
require('modules/custom/tier_trials/lua/tier_trial_50')
require('modules/custom/tier_trials/lua/tier_trial_60')

-----------------------------------
-- Shared helper: check difficulty unlock eligibility
-----------------------------------
xi.tierTrial.canAttempt = function(player, tier, difficulty)
    if difficulty == xi.tierTrial.DIFFICULTY.STANDARD then
        return true
    end

    if difficulty == xi.tierTrial.DIFFICULTY.HARDENED then
        local varName = string.format(xi.tierTrial.VAR_HARDENED_CLEARED, tier)
        return player:getCharVar(varName) >= 1
    end

    if difficulty == xi.tierTrial.DIFFICULTY.TRANSCENDENT then
        local varName = string.format(xi.tierTrial.VAR_TRANSCENDENT_CLEARED, tier)
        return player:getCharVar(varName) >= 1
    end

    return false
end

-----------------------------------
-- Shared helper: record a clear and unlock next difficulty
-----------------------------------
xi.tierTrial.recordClear = function(player, tier, difficulty)
    if difficulty == xi.tierTrial.DIFFICULTY.STANDARD then
        local varName = string.format(xi.tierTrial.VAR_HARDENED_CLEARED, tier)
        if player:getCharVar(varName) == 0 then
            player:setCharVar(varName, 1)
        end
    elseif difficulty == xi.tierTrial.DIFFICULTY.HARDENED then
        local varName = string.format(xi.tierTrial.VAR_TRANSCENDENT_CLEARED, tier)
        if player:getCharVar(varName) == 0 then
            player:setCharVar(varName, 1)
        end
    end
end

-----------------------------------
-- Shared helper: grant rewards on wave 5 clear
-- Called from each instance script's onInstanceComplete
-----------------------------------
xi.tierTrial.grantRewards = function(instance, elapsed)
    local tier       = instance:getLocalVar('tier')
    local difficulty = instance:getLocalVar('difficulty')
    local tierDef    = xi.tierTrial.TIERS[tier]

    if not tierDef then return end

    local marks    = xi.tierTrial.MARK_REWARDS[difficulty]
    local shards   = xi.tierTrial.SHARD_DROP_COUNT[difficulty]
    local dropRate = xi.tierTrial.WEAPON_DROP_RATE[difficulty]

    -- Time bonus
    local startTime = instance:getLocalVar('startTime')
    if startTime > 0 and (elapsed - startTime) < xi.tierTrial.TIME_BONUS_THRESHOLD then
        marks = marks + xi.tierTrial.TIME_BONUS_MARKS
    end

    for _, player in pairs(instance:getChars()) do
        -- Marks (stored as char var, spent at vendor NPC)
        local markVar = tierDef.markVar
        player:setCharVar(markVar, player:getCharVar(markVar) + marks)

        -- Shards
        for i = 1, shards do
            player:addItem(tierDef.shardItem, 1)
        end

        -- Tier I weapon (job-family lookup)
        local roll = math.random(100)
        if roll <= dropRate then
            local jobFamily  = xi.tierTrial.getJobFamily(player:getMainJob())
            local weaponItem = tierDef.weapons[jobFamily]
            if weaponItem then
                player:addItem(weaponItem, 1)
            end
        end

        -- Record clear and unlock next difficulty
        xi.tierTrial.recordClear(player, tier, difficulty)
    end
end

-----------------------------------
-- Shared helper: map job to weapon family key
-----------------------------------
xi.tierTrial.getJobFamily = function(job)
    local map =
    {
        [xi.job.WAR] = 'greatsword',
        [xi.job.DRK] = 'greatsword',
        [xi.job.DRG] = 'greatsword',
        [xi.job.MNK] = 'handtohand',
        [xi.job.PUP] = 'handtohand',
        [xi.job.WHM] = 'staff_healing',
        [xi.job.SCH] = 'staff_healing',
        [xi.job.BLM] = 'staff_magic',
        [xi.job.SMN] = 'staff_magic',
        [xi.job.RDM] = 'sword',
        [xi.job.BRD] = 'sword',
        [xi.job.THF] = 'dagger',
        [xi.job.NIN] = 'dagger',
        [xi.job.RNG] = 'ranged',
        [xi.job.COR] = 'ranged',
        [xi.job.PLD] = 'sword_shield',
        [xi.job.SAM] = 'greatkatana',
        [xi.job.BST] = 'axe',
    }

    return map[job] or 'greatsword'
end

return m
