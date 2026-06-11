-----------------------------------
-- GM Commands: Tier Trials
--
-- !tt status              — show tier trial info for current zone
-- !tt spawn <tier>        — force-create a Tier Trial instance for GM player
-- !tt difficulty <1|2|3>  — set difficulty for next spawn (default 1)
-- !tt wave <n>            — skip directly to wave n in current instance
-- !tt complete            — force complete current instance
-- !tt fail                — force fail current instance
-- !tt marks <tier> <n>    — give player N marks for a tier (30/40/50/60)
-- !tt weapon <tier> <job> — give Tier I weapon for tier/job (for testing)
-----------------------------------

local CMD = {}

CMD['tt'] = function(player, command, args)
    local sub = args[1]

    if sub == 'status' then
        for tier, def in pairs(xi.tierTrial.TIERS) do
            player:PrintToPlayer(string.format('Tier %d: instanceId=%d levelCap=%d', tier, def.instanceId, def.levelCap))
        end

    elseif sub == 'spawn' then
        local tier = tonumber(args[2]) or 30
        local tierDef = xi.tierTrial.TIERS[tier]
        if not tierDef then
            player:PrintToPlayer('Unknown tier: ' .. tostring(tier))
            return
        end

        local difficulty = player:getLocalVar('TT_GMDifficulty')
        if difficulty == 0 then difficulty = 1 end

        player:setLocalVar('TT_Difficulty', difficulty)
        player:createInstance(tierDef.instanceId)
        player:PrintToPlayer(string.format('Creating Tier %d instance (difficulty %d)...', tier, difficulty))

    elseif sub == 'difficulty' then
        local diff = tonumber(args[2]) or 1
        diff = math.max(1, math.min(3, diff))
        player:setLocalVar('TT_GMDifficulty', diff)
        local names = { 'Standard', 'Hardened', 'Transcendent' }
        player:PrintToPlayer('Next spawn difficulty: ' .. names[diff])

    elseif sub == 'wave' then
        local instance = player:getInstance()
        if not instance then
            player:PrintToPlayer('Not in an instance.')
            return
        end
        local n = tonumber(args[2]) or 1
        n = math.max(1, math.min(xi.tierTrial.WAVE_COUNT, n))
        -- Despawn all current mobs, set wave counter back so instance script spawns next
        for _, mob in pairs(instance:getMobs()) do
            if mob:isAlive() then
                mob:setHP(0)
            end
        end
        instance:setLocalVar('wave', n - 1)
        player:PrintToPlayer('Skipping to wave ' .. n)

    elseif sub == 'complete' then
        local instance = player:getInstance()
        if not instance then
            player:PrintToPlayer('Not in an instance.')
            return
        end
        instance:complete()
        player:PrintToPlayer('Instance completed.')

    elseif sub == 'fail' then
        local instance = player:getInstance()
        if not instance then
            player:PrintToPlayer('Not in an instance.')
            return
        end
        instance:fail()
        player:PrintToPlayer('Instance failed.')

    elseif sub == 'marks' then
        local tier = tonumber(args[2]) or 30
        local n    = tonumber(args[3]) or 1
        local tierDef = xi.tierTrial.TIERS[tier]
        if not tierDef then
            player:PrintToPlayer('Unknown tier: ' .. tostring(tier))
            return
        end
        local current = player:getCharVar(tierDef.markVar)
        player:setCharVar(tierDef.markVar, current + n)
        player:PrintToPlayer(string.format('Gave %d marks for tier %d. Total: %d', n, tier, current + n))

    elseif sub == 'weapon' then
        local tier = tonumber(args[2]) or 30
        local job  = tonumber(args[3]) or player:getMainJob()
        local tierDef = xi.tierTrial.TIERS[tier]
        if not tierDef then
            player:PrintToPlayer('Unknown tier: ' .. tostring(tier))
            return
        end
        local family    = xi.tierTrial.getJobFamily(job)
        local weaponId  = tierDef.weapons[family]
        if weaponId and weaponId > 0 then
            player:addItem(weaponId, 1)
            player:PrintToPlayer(string.format('Gave Tier %d weapon (family: %s, id: %d)', tier, family, weaponId))
        else
            player:PrintToPlayer(string.format('Weapon ID not set for tier %d / family %s (TODO)', tier, family))
        end

    else
        player:PrintToPlayer('Usage: !tt <status|spawn|difficulty|wave|complete|fail|marks|weapon>')
    end
end

return CMD
