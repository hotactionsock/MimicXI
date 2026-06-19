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
local DIFF_NAMES = { [1] = 'Standard', [2] = 'Hardened', [3] = 'Transcendent' }

-----------------------------------
-- Called from the boss onMobDeath with the mob entity as dropper so that
-- shards and weapons enter the party treasure pool (lot/pass UI).
-----------------------------------
xi.tierTrial.dropLoot = function(instance, dropper)
    local tier       = instance:getLocalVar('tier')
    local difficulty = instance:getLocalVar('difficulty')
    local tierDef    = xi.tierTrial.TIERS[tier]
    if not tierDef then return end

    local shards   = xi.tierTrial.SHARD_DROP_COUNT[difficulty]
    local dropRate = xi.tierTrial.WEAPON_DROP_RATE[difficulty]

    for _, player in pairs(instance:getChars()) do
        -- Each player earns their own shard(s) via treasure pool
        if tierDef.shardItem and tierDef.shardItem > 0 then
            for _ = 1, shards do
                player:addTreasure(tierDef.shardItem, dropper)
            end
        end

        -- Per-player weapon roll, job-family matched, into treasure pool
        local roll = math.random(100)
        if roll <= dropRate then
            local jobFamily  = xi.tierTrial.getJobFamily(player:getMainJob())
            local weaponItem = jobFamily and tierDef.weapons[jobFamily]
            if weaponItem and weaponItem > 0 then
                player:addTreasure(weaponItem, dropper)
            end
        end
    end
end

-----------------------------------
-- Called from onInstanceComplete: awards Proving Marks and records the clear.
-- Item drops are handled separately in dropLoot (boss onMobDeath).
-----------------------------------
xi.tierTrial.grantRewards = function(instance, elapsed)
    local tier       = instance:getLocalVar('tier')
    local difficulty = instance:getLocalVar('difficulty')
    local tierDef    = xi.tierTrial.TIERS[tier]

    if not tierDef then return end

    local marks = xi.tierTrial.MARK_REWARDS[difficulty]

    -- Time bonus
    local timeBonus = false
    local startTime = instance:getLocalVar('startTime')
    if startTime > 0 and (elapsed - startTime) < xi.tierTrial.TIME_BONUS_THRESHOLD then
        marks     = marks + xi.tierTrial.TIME_BONUS_MARKS
        timeBonus = true
    end

    local diffName = DIFF_NAMES[difficulty] or 'Standard'

    for _, player in pairs(instance:getChars()) do
        local markVar = tierDef.markVar
        player:setCharVar(markVar, player:getCharVar(markVar) + marks)

        local bonusSuffix = timeBonus and ' (+1 time bonus)' or ''
        player:printToPlayer(
            string.format('Tier Trial Lv%d %s complete. Proving Marks awarded: %d%s.',
                tier, diffName, marks, bonusSuffix),
            xi.msg.channel.SYSTEM_1)

        xi.tierTrial.recordClear(player, tier, difficulty)
    end
end

-----------------------------------
-- Shared helper: map job to weapon family key
-----------------------------------
xi.tierTrial.getJobFamily = function(job)
    local map =
    {
        [xi.job.WAR] = 'blade',    [xi.job.DRK] = 'blade',
        [xi.job.DRG] = 'blade',    [xi.job.RDM] = 'blade',
        [xi.job.BRD] = 'blade',
        [xi.job.SAM] = 'nodachi',
        [xi.job.NIN] = 'kukri',    [xi.job.THF] = 'kukri',
        [xi.job.RNG] = 'kukri',    [xi.job.COR] = 'kukri',
        [xi.job.DNC] = 'kukri',
        [xi.job.MNK] = 'cesti',    [xi.job.PUP] = 'cesti',
        [xi.job.WHM] = 'rod',      [xi.job.BLM] = 'rod',
        [xi.job.SMN] = 'rod',      [xi.job.SCH] = 'rod',
        [xi.job.GEO] = 'rod',
        [xi.job.BLU] = 'falchion',
        [xi.job.PLD] = 'spatha',
    }
    return map[job]
end

return m
