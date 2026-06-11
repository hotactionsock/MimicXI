-----------------------------------
-- Tier Trial — Shared Instance Script Logic
--
-- Each tier's instance script (in scripts/zones/.../instances/) requires
-- this file and calls xi.tierTrial.instance.build(tier) to get the
-- instanceObject table.
--
-- Local vars used per instance:
--   'tier'         -- which tier (30/40/50/60)
--   'difficulty'   -- 1=Standard, 2=Hardened, 3=Transcendent
--   'wave'         -- current wave number (0 = pre-start)
--   'waveAlive'    -- mobs still alive in current wave
--   'locked'       -- 1 after first aggro in wave 1
--   'startTime'    -- elapsed ms when instance locked
--   'phaseTwo'     -- 1 after boss second phase triggered
--   'absorbElement'-- current absorb element for Valdris (tier 50)
--   'absorbTimer'  -- elapsed ms of last absorb cycle change
--   'weaknessIdx'  -- current weakness index for Vraeth (tier 60)
--   'ejectAt'      -- elapsed ms when ejection fires after complete/fail
-----------------------------------

xi.tierTrial         = xi.tierTrial or {}
xi.tierTrial.instance = xi.tierTrial.instance or {}

-----------------------------------
-- Spawn all mobs for a given wave
-----------------------------------
local function spawnWave(instance, tierDef, waveNum)
    local waveDef    = tierDef.waves[waveNum]
    local difficulty = instance:getLocalVar('difficulty')
    local mods       = xi.tierTrial.DIFFICULTY_MODS[difficulty]
    local alive      = 0

    for _, entry in ipairs(waveDef) do
        -- Skip summon-type entries (spawned reactively in onInstanceTimeUpdate)
        if not entry.isSummon then
            for i = 1, entry.count do
                local mob = SpawnMob(entry.mobId, instance)
                if mob then
                    mob:setHP(math.floor(mob:getMaxHP() * mods.hp))
                    mob:setLocalVar('dmgMod', math.floor(mods.dmg * 100))
                    alive = alive + 1
                end
            end
        end
    end

    instance:setLocalVar('waveAlive', alive)
    instance:setLocalVar('wave', waveNum)
end

-----------------------------------
-- Count alive mobs in the current wave
-- Uses mob local var 'waveNum' set at spawn time
-----------------------------------
local function countAlive(instance)
    local alive = 0
    for _, mob in pairs(instance:getMobs()) do
        if mob:isAlive() then
            alive = alive + 1
        end
    end
    return alive
end

-----------------------------------
-- Apply hardened aura to all players (waves 3-5 on Hardened/Transcendent)
-----------------------------------
local function applyHardenedAura(instance, tierDef)
    local aura = tierDef.hardenedAura
    if not aura then return end

    for _, player in pairs(instance:getChars()) do
        if not player:hasStatusEffect(aura.effect) then
            player:addStatusEffect(aura.effect, aura.power, 0, aura.duration)
        end
    end
end

local function removeHardenedAura(instance, tierDef)
    local aura = tierDef.hardenedAura
    if not aura then return end

    for _, player in pairs(instance:getChars()) do
        player:delStatusEffect(aura.effect)
    end
end

-----------------------------------
-- Build instanceObject for a given tier
-----------------------------------
xi.tierTrial.instance.build = function(tier)
    local instanceObject = {}

    instanceObject.onInstanceCreated = function(instance)
        instance:setLocalVar('tier', tier)
        instance:setLocalVar('wave', 0)
        instance:setLocalVar('locked', 0)
        instance:setLocalVar('phaseTwo', 0)
        instance:setLocalVar('startTime', 0)
        instance:setLocalVar('absorbElement', 1)
        instance:setLocalVar('absorbTimer', 0)
        instance:setLocalVar('weaknessIdx', 1)
        instance:setLocalVar('ejectAt', 0)

        local tierDef = xi.tierTrial.TIERS[tier]
        instance:setLevelCap(tier)

        -- Transcendent: halve the time limit
        local difficulty = instance:getLocalVar('difficulty')
        if difficulty == xi.tierTrial.DIFFICULTY.TRANSCENDENT then
            instance:setTimeLimit(math.floor(instance:getTimeLimit() / 2))
        end

        -- Spawn wave 1 immediately
        spawnWave(instance, tierDef, 1)
    end

    instanceObject.onInstanceCreatedCallback = function(player, instance)
        xi.instance.onInstanceCreatedCallback(player, instance)
    end

    instanceObject.afterInstanceRegister = function(player)
        local instance   = player:getInstance()
        local difficulty = instance:getLocalVar('difficulty')
        local diffNames  = { 'Standard', 'Hardened', 'Transcendent' }
        player:messageSpecial(
            zones[player:getZoneID()].text.INSTANCE_START or 0,
            diffNames[difficulty] or 'Standard'
        )
    end

    instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
        local tierDef    = xi.tierTrial.TIERS[tier]
        local difficulty = instance:getLocalVar('difficulty')
        local wave       = instance:getLocalVar('wave')

        -- Eject after complete/fail
        if instance:completed() or instance:failed() then
            local ejectAt = instance:getLocalVar('ejectAt')
            if ejectAt > 0 and elapsed >= ejectAt then
                for _, player in pairs(instance:getChars()) do
                    player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
                end
            end
            return
        end

        -- Lock on first mob aggro in wave 1
        if instance:getLocalVar('locked') == 0 then
            for _, mob in pairs(instance:getMobs()) do
                if mob:isEngaged() then
                    instance:lock()
                    instance:setLocalVar('locked', 1)
                    instance:setLocalVar('startTime', elapsed)
                    break
                end
            end
        end

        -- Wave progression: check if all mobs in current wave are dead
        if wave >= 1 and wave < xi.tierTrial.WAVE_COUNT then
            if countAlive(instance) == 0 then
                -- Clean up hardened aura between waves
                if difficulty >= xi.tierTrial.DIFFICULTY.HARDENED then
                    removeHardenedAura(instance, tierDef)
                end

                local nextWave = wave + 1
                spawnWave(instance, tierDef, nextWave)

                -- Apply hardened aura from wave 3+
                if nextWave >= 3 and difficulty >= xi.tierTrial.DIFFICULTY.HARDENED then
                    applyHardenedAura(instance, tierDef)
                end

                -- Handle boss summon entries at wave 5 (e.g. Kalabaros Wight)
                -- Reactive spawns handled below in boss phase logic
            end
        end

        -- Tier-50 Valdris: cycle absorb element every absorbCycle ms
        if tier == 50 and wave == 5 then
            local cycleMs   = tierDef.bossAbsorbCycle or 60000
            local lastTimer = instance:getLocalVar('absorbTimer')
            if elapsed - lastTimer >= cycleMs then
                local elements = { xi.element.FIRE, xi.element.ICE, xi.element.THUNDER,
                                   xi.element.WATER, xi.element.WIND, xi.element.EARTH }
                local idx      = math.random(#elements)
                instance:setLocalVar('absorbElement', elements[idx])
                instance:setLocalVar('absorbTimer', elapsed)
                -- Boss mob picks up the absorb var in its own onMobFight hook
            end
        end

        -- Tier-60 Vraeth: change weakness at HP thresholds
        if tier == 60 and wave == 5 then
            local boss = nil
            for _, mob in pairs(instance:getMobs()) do
                if mob:isAlive() then
                    boss = mob
                    break
                end
            end

            if boss then
                local hpPct          = (boss:getHP() / boss:getMaxHP()) * 100
                local thresholds     = { 80, 60, 40, 20 }
                local currentWkIdx   = instance:getLocalVar('weaknessIdx')
                local newIdx         = currentWkIdx

                for i, threshold in ipairs(thresholds) do
                    if hpPct <= threshold and i > currentWkIdx then
                        newIdx = i
                    end
                end

                if newIdx ~= currentWkIdx then
                    instance:setLocalVar('weaknessIdx', newIdx)
                    -- Boss script reads 'weaknessIdx' to change resist values
                end
            end
        end

        -- Kalabaros (Tier 40) summons Wight at 33% HP
        if tier == 40 and wave == 5 and instance:getLocalVar('phaseTwo') == 0 then
            local boss = nil
            for _, mob in pairs(instance:getMobs()) do
                if mob:isAlive() and not mob:getLocalVar('isSummon') then
                    boss = mob
                    break
                end
            end

            if boss then
                local hpPct = (boss:getHP() / boss:getMaxHP()) * 100
                if hpPct <= 33 then
                    instance:setLocalVar('phaseTwo', 1)
                    local summonEntry = tierDef.waves[5]
                    for _, entry in ipairs(summonEntry) do
                        if entry.isSummon then
                            local summon = SpawnMob(entry.mobId, instance)
                            if summon then
                                summon:setLocalVar('isSummon', 1)
                            end
                        end
                    end
                end
            end
        end

        -- General boss phase 2 trigger for other tiers (Transcendent only)
        if difficulty == xi.tierTrial.DIFFICULTY.TRANSCENDENT
            and wave == 5
            and instance:getLocalVar('phaseTwo') == 0 then
            local threshold = tierDef.bossPhaseThreshold
            for _, mob in pairs(instance:getMobs()) do
                if mob:isAlive() then
                    local hpPct = (mob:getHP() / mob:getMaxHP()) * 100
                    if hpPct <= threshold then
                        instance:setLocalVar('phaseTwo', 1)
                        -- Boss script onMobFight checks 'phaseTwo' local var
                        -- to activate enhanced TP move usage
                    end
                    break
                end
            end
        end

        xi.instance.updateInstanceTime(instance, elapsed,
            zones[instance:getZone():getID()].text)
    end

    instanceObject.onInstanceComplete = function(instance)
        local elapsed = instance:getLocalVar('startTime')
        xi.tierTrial.grantRewards(instance, elapsed)
        instance:setLocalVar('ejectAt', elapsed + 10000)
    end

    instanceObject.onInstanceFailure = function(instance)
        for _, player in pairs(instance:getChars()) do
            player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
        end
    end

    instanceObject.onInstanceProgressUpdate = function(instance, progress)
    end

    return instanceObject
end
