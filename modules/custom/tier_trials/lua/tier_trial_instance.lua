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
--   'waveEndAt'    -- elapsed ms when current wave was cleared (0 = wave still active)
--   'locked'       -- 1 after first aggro in wave 1
--   'startTime'    -- elapsed ms when instance locked
--   'phaseTwo'     -- 1 after boss second phase triggered
--   'absorbElement'-- current absorb element for Valdris (tier 50)
--   'absorbTimer'  -- elapsed ms of last absorb cycle change
--   'weaknessIdx'  -- current weakness index for Vraeth (tier 60)
--   'ejectAt'      -- elapsed ms when ejection fires after complete/fail
--
-- Mob local vars set on every dynamic entity:
--   'ttWave'       -- which wave this mob belongs to (1-5)
--   'ttIsBoss'     -- 1 if boss mob, 0 otherwise
--   'ttIsSummon'   -- 1 if reactive summon (not spawned by spawnWave), 0 otherwise
-----------------------------------

xi.tierTrial          = xi.tierTrial or {}
xi.tierTrial.instance = xi.tierTrial.instance or {}

-- Arena centre for zone 183 (Maquette Abdhaljs-Legion A).
local SPAWN_X   = -19.391
local SPAWN_Y   =  12.500
local SPAWN_Z   =  29.284
local SPAWN_ROT =  65

-- Rest period between waves in milliseconds.
local WAVE_REST_MS = 10000

-- Exit NPC spawned on victory. Model 2471 is the pillar-of-light object.
local EXIT_NPC_LOOK = 2471
local EXIT_NPC_Z_OFFSET = -12  -- behind the mob arena, clearly visible on approach

-- XZ offsets from arena centre for each mob slot, indexed 1-based.
-- Slot 1 is centre (boss / solo mobs). Remaining slots fan outward so
-- groups of 2-4 mobs are not stacked on a single point.
local SPAWN_OFFSETS =
{
    {  0,   0 },
    {  3,  -2 },
    { -3,  -2 },
    {  0,   4 },
    {  3,   3 },
    { -3,   3 },
    {  0,  -4 },
    {  4,   0 },
    { -4,   0 },
}

local function getSpawnPos(idx)
    local off = SPAWN_OFFSETS[((idx - 1) % #SPAWN_OFFSETS) + 1]
    return SPAWN_X + off[1], SPAWN_Y, SPAWN_Z + off[2]
end

-----------------------------------
-- Create and immediately spawn all non-summon mobs for waveNum.
-- Mobs are created on-demand here rather than pre-created upfront,
-- so no future-wave mobs exist in the instance until their wave starts.
-----------------------------------
local function spawnWave(instance, waveNum)
    local tierDef    = xi.tierTrial.TIERS[instance:getLocalVar('tier')]
    local difficulty = instance:getLocalVar('difficulty')
    local mods       = xi.tierTrial.DIFFICULTY_MODS[difficulty]
    local waveDef    = tierDef.waves[waveNum]
    local alive      = 0
    local idx        = 0

    for _, entry in ipairs(waveDef) do
        if not entry.isSummon then
            local count  = entry.count or 1
            local isBoss = entry.isBoss and true or false

            for _ = 1, count do
                idx = idx + 1
                local sx, sy, sz = getSpawnPos(idx)
                local mob = instance:insertDynamicEntity({
                    objtype     = xi.objType.MOB,
                    name        = entry.name,
                    groupId     = entry.groupId,
                    groupZoneId = entry.groupZoneId,
                    minLevel    = entry.level,
                    maxLevel    = entry.level,
                    isAggroable = true,
                    x = sx, y = sy, z = sz,
                    onMobDeath  = function(m, player, optParams)
                        if isBoss then
                            local inst = m:getInstance()
                            if inst then
                                xi.tierTrial.dropLoot(inst, m)
                                inst:complete()
                            end
                        end
                    end,
                })
                if mob then
                    mob:setSpawn(sx, sy, sz, SPAWN_ROT)
                    mob:spawn()
                    mob:setHP(math.floor(mob:getMaxHP() * mods.hp))
                    mob:setLocalVar('ttWave',    waveNum)
                    mob:setLocalVar('ttIsBoss',   isBoss and 1 or 0)
                    mob:setLocalVar('ttIsSummon', 0)
                    mob:setLocalVar('dmgMod', math.floor(mods.dmg * 100))
                    alive = alive + 1
                end
            end
        end
    end

    instance:setLocalVar('waveAlive', alive)
    instance:setLocalVar('wave',      waveNum)
end

-----------------------------------
-- Create and spawn a single summon entry on demand (e.g. Kalabaros Wight).
-- Uses spawn slot 2 so it doesn't overlap with the boss at slot 1 (centre).
-----------------------------------
local function spawnSummon(instance, waveNum, entry)
    local difficulty = instance:getLocalVar('difficulty')
    local mods       = xi.tierTrial.DIFFICULTY_MODS[difficulty]
    local sx, sy, sz = getSpawnPos(2)

    local mob = instance:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = entry.name,
        groupId     = entry.groupId,
        groupZoneId = entry.groupZoneId,
        minLevel    = entry.level,
        maxLevel    = entry.level,
        isAggroable = true,
        x = sx, y = sy, z = sz,
    })
    if mob then
        mob:setSpawn(sx, sy, sz, SPAWN_ROT)
        mob:spawn()
        mob:setHP(math.floor(mob:getMaxHP() * mods.hp))
        mob:setLocalVar('ttWave',    waveNum)
        mob:setLocalVar('ttIsBoss',   0)
        mob:setLocalVar('ttIsSummon', 1)
        mob:setLocalVar('dmgMod', math.floor(mods.dmg * 100))
    end
end

-----------------------------------
-- Count alive mobs in the current wave.
-----------------------------------
local function countAlive(instance)
    local wave  = instance:getLocalVar('wave')
    local alive = 0
    for _, mob in pairs(instance:getMobs()) do
        if mob:getLocalVar('ttWave') == wave and mob:isAlive() then
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
            player:addStatusEffect(aura.effect, { power = aura.power, duration = aura.duration, origin = player })
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

local function ejectPlayers(instance)
    for _, player in pairs(instance:getChars()) do
        player:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
        player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
    end
end

local function spawnExitNpc(instance)
    instance:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Trial Gate',
        look      = EXIT_NPC_LOOK,
        x         = SPAWN_X,
        y         = SPAWN_Y,
        z         = SPAWN_Z + EXIT_NPC_Z_OFFSET,
        rotation  = 0,
        widescan  = 0,
        onTrigger = function(player, npc)
            player:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
            player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
        end,
    })
end

-----------------------------------
-- Build instanceObject for a given tier
-----------------------------------
xi.tierTrial.instance.build = function(tier)
    local instanceObject = {}

    instanceObject.onInstanceCreated = function(instance)
        instance:setLevelCap(tier)
        instance:setLocalVar('tier',         tier)
        instance:setLocalVar('wave',         0)
        instance:setLocalVar('waveEndAt',    0)
        instance:setLocalVar('locked',       0)
        instance:setLocalVar('phaseTwo',     0)
        instance:setLocalVar('startTime',    0)
        instance:setLocalVar('absorbElement',1)
        instance:setLocalVar('absorbTimer',  0)
        instance:setLocalVar('weaknessIdx',  1)
    end

    instanceObject.onInstanceCreatedCallback = function(player, instance)
        -- difficulty==0 means first call; set it once from player var then spawn wave 1
        if instance:getLocalVar('difficulty') == 0 then
            local diff = player:getLocalVar('TT_Difficulty')
            if diff == 0 then diff = 1 end
            instance:setLocalVar('difficulty', diff)
            player:setLocalVar('TT_Difficulty', 0)

            if diff == xi.tierTrial.DIFFICULTY.TRANSCENDENT then
                -- getTimeLimit() returns minutes; setTimeLimit() takes seconds
                instance:setTimeLimit(math.floor(instance:getTimeLimit() * 30))
            end

            spawnWave(instance, 1)
        end

        for _, member in pairs(player:getParty()) do
            member:setInstance(instance)
            member:setPos(0, 0, 0, 0, instance:getZone():getID())
        end
    end

    -- Fires after zone-in completes, after CharZoneIn/updateCharLevelRestriction
    -- have already run. setLevelCap in onInstanceCreated causes IncreaseZoneCounter
    -- to apply the restriction automatically; this is a belt-and-suspenders re-apply
    -- in case anything strips it during zone-in processing.
    instanceObject.afterInstanceRegister = function(player)
        local instance   = player:getInstance()
        local difficulty = instance:getLocalVar('difficulty')

        player:addStatusEffect(xi.effect.LEVEL_RESTRICTION, {
            power  = tier,
            origin = player,
        })

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

        -- Stop further processing once the instance has ended.
        if instance:completed() or instance:failed() then
            return
        end

        -- Lock on first mob aggro in wave 1
        if instance:getLocalVar('locked') == 0 then
            for _, mob in pairs(instance:getMobs()) do
                if mob:isEngaged() then
                    instance:lock()
                    instance:setLocalVar('locked',    1)
                    instance:setLocalVar('startTime', elapsed)
                    break
                end
            end
        end

        -- Wave progression: advance when current wave is fully cleared,
        -- after a rest period that gives players time to recover.
        if wave >= 1 and wave < xi.tierTrial.WAVE_COUNT then
            if countAlive(instance) == 0 then
                local waveEndAt = instance:getLocalVar('waveEndAt')
                if waveEndAt == 0 then
                    -- Wave just cleared — start the rest timer and remove hardened aura
                    instance:setLocalVar('waveEndAt', elapsed)
                    if difficulty >= xi.tierTrial.DIFFICULTY.HARDENED then
                        removeHardenedAura(instance, tierDef)
                    end
                elseif elapsed - waveEndAt >= WAVE_REST_MS then
                    -- Rest period over — spawn the next wave
                    instance:setLocalVar('waveEndAt', 0)
                    local nextWave = wave + 1
                    spawnWave(instance, nextWave)
                    if nextWave >= 3 and difficulty >= xi.tierTrial.DIFFICULTY.HARDENED then
                        applyHardenedAura(instance, tierDef)
                    end
                end
            end
        end

        -- Tier-50 Valdris: cycle absorb element every absorbCycle ms
        if tier == 50 and wave == 5 then
            local cycleMs   = tierDef.bossAbsorbCycle or 60000
            local lastTimer = instance:getLocalVar('absorbTimer')
            if elapsed - lastTimer >= cycleMs then
                local elements = { xi.element.FIRE, xi.element.ICE, xi.element.THUNDER,
                                   xi.element.WATER, xi.element.WIND, xi.element.EARTH }
                local idx = math.random(#elements)
                instance:setLocalVar('absorbElement', elements[idx])
                instance:setLocalVar('absorbTimer',   elapsed)
            end
        end

        -- Tier-60 Vraeth: change weakness at HP thresholds
        if tier == 60 and wave == 5 then
            local boss = nil
            for _, mob in pairs(instance:getMobs()) do
                if mob:getLocalVar('ttIsBoss') == 1 and mob:isAlive() then
                    boss = mob
                    break
                end
            end

            if boss then
                local hpPct        = (boss:getHP() / boss:getMaxHP()) * 100
                local thresholds   = { 80, 60, 40, 20 }
                local currentWkIdx = instance:getLocalVar('weaknessIdx')
                local newIdx       = currentWkIdx

                for i, threshold in ipairs(thresholds) do
                    if hpPct <= threshold and i > currentWkIdx then
                        newIdx = i
                    end
                end

                if newIdx ~= currentWkIdx then
                    instance:setLocalVar('weaknessIdx', newIdx)
                end
            end
        end

        -- Kalabaros (Tier 40): summon Wight at 33% boss HP
        if tier == 40 and wave == 5 and instance:getLocalVar('phaseTwo') == 0 then
            local boss = nil
            for _, mob in pairs(instance:getMobs()) do
                if mob:getLocalVar('ttIsBoss') == 1 and mob:isAlive() then
                    boss = mob
                    break
                end
            end

            if boss then
                local hpPct = (boss:getHP() / boss:getMaxHP()) * 100
                if hpPct <= 33 then
                    instance:setLocalVar('phaseTwo', 1)
                    local waveDef = xi.tierTrial.TIERS[40].waves[5]
                    for _, entry in ipairs(waveDef) do
                        if entry.isSummon then
                            spawnSummon(instance, 5, entry)
                            break
                        end
                    end
                end
            end
        end

        -- Transcendent boss phase 2 trigger for tiers other than 40
        if difficulty == xi.tierTrial.DIFFICULTY.TRANSCENDENT
            and wave == 5
            and tier ~= 40
            and instance:getLocalVar('phaseTwo') == 0 then
            local threshold = tierDef.bossPhaseThreshold
            for _, mob in pairs(instance:getMobs()) do
                if mob:getLocalVar('ttIsBoss') == 1 and mob:isAlive() then
                    local hpPct = (mob:getHP() / mob:getMaxHP()) * 100
                    if hpPct <= threshold then
                        instance:setLocalVar('phaseTwo', 1)
                    end
                    break
                end
            end
        end

        instance:setLocalVar('elapsed', elapsed)
        xi.instance.updateInstanceTime(instance, elapsed,
            zones[instance:getZone():getID()].text)
    end

    instanceObject.onInstanceComplete = function(instance)
        local elapsed = instance:getLocalVar('elapsed')

        local ok, err = pcall(xi.tierTrial.grantRewards, instance, elapsed)
        if not ok then
            print('[TierTrial] grantRewards error: ' .. tostring(err))
        end

        ok, err = pcall(spawnExitNpc, instance)
        if not ok then
            print('[TierTrial] spawnExitNpc error: ' .. tostring(err))
        end
    end

    instanceObject.onInstanceFailure = function(instance)
        ejectPlayers(instance)
    end

    instanceObject.onInstanceProgressUpdate = function(instance, progress)
    end

    return instanceObject
end

return {}
