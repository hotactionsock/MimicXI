-----------------------------------
-- Rift System — shared utilities
-- Instanced content in Walk of Echoes, entered from Xarcabard.
-----------------------------------

xi = xi or {}
xi.rift = xi.rift or {}

-- Item players must possess to unlock tier 1.
-- TODO: Replace with a custom rift unlock item once defined.
xi.rift.UNLOCK_ITEM = xi.item.DARK_MATTER

-- Shard drops from rift mobs. Replace with real item IDs once defined.
xi.rift.NASCENT_SHARD  = xi.item.DARK_MATTER -- TODO: Nascent Shard item ID
xi.rift.TEMPERED_SHARD = xi.item.DARK_MATTER -- TODO: Tempered Shard item ID

-- Ultra-rare item pool (boss-only).
-- One item is chosen at random if the UR rate roll succeeds — never multiple per kill.
-- Add entries here as new UR items are introduced; displayName is used in the announcement.
xi.rift.UR_POOL =
{
    { item = xi.item.VOIDHEART_HAUBERGEON, displayName = 'Voidheart Haubergeon' },
}

-- Char var tracking highest tier cleared (0 = never cleared any tier).
xi.rift.VAR_CLEARED  = 'RIFT_TIER_CLEARED'

-- Char var used to hand the chosen tier through the zone transition.
xi.rift.VAR_PENDING  = 'RIFT_PENDING_TIER'

-- Instance definition ID (matches instance_list.instanceid).
xi.rift.INSTANCE_ID  = 18200

-- Maximum tier available.
xi.rift.MAX_TIER     = 10

-- ---------------------------------------------------------------------------
-- Mob pools per tier bracket.
-- Each entry is { groupId, groupZoneId, name } pointing to a mob_groups row.
-- groupZoneId = 182 (Walk of Echoes) throughout.
-- ---------------------------------------------------------------------------
local WOE = xi.zone.WALK_OF_ECHOES

xi.rift.MOB_POOLS =
{
    -- Tiers 1-3: Crabs, slimes, antlions — accessible WoE fauna
    [1] = {
        { groupId = 1,  groupZoneId = WOE, name = 'Caldera_Crab'        },
        { groupId = 2,  groupZoneId = WOE, name = 'Cyanic_Crab'         },
        { groupId = 4,  groupZoneId = WOE, name = 'Morbid_Molasses'     },
        { groupId = 8,  groupZoneId = WOE, name = 'Anthracite_Antlion'  },
        { groupId = 9,  groupZoneId = WOE, name = 'Albino_Antlion'      },
    },
    -- Tiers 4-6: Mandragoras, coeurls, birds
    [4] = {
        { groupId = 24, groupZoneId = WOE, name = 'Lunatic_Lycopodium'  },
        { groupId = 25, groupZoneId = WOE, name = 'Killer_Korrigan'     },
        { groupId = 26, groupZoneId = WOE, name = 'Murderous_Mandragora' },
        { groupId = 39, groupZoneId = WOE, name = 'Coeurl_Mystic'       },
        { groupId = 40, groupZoneId = WOE, name = 'Coeurl_prentice'     },
        { groupId = 37, groupZoneId = WOE, name = 'Malicious_Magpie'    },
    },
    -- Tiers 7-9: Yanthu elementals, Iron Crania
    [7] = {
        { groupId = 48, groupZoneId = WOE, name = 'Scorched_Yanthu'     },
        { groupId = 49, groupZoneId = WOE, name = 'Glaciated_Yanthu'    },
        { groupId = 50, groupZoneId = WOE, name = 'Electrified_Yanthu'  },
        { groupId = 31, groupZoneId = WOE, name = 'Iron_CraniumV1'      },
        { groupId = 32, groupZoneId = WOE, name = 'Iron_CraniumV2'      },
    },
    -- Tier 10: Elite mix
    [10] = {
        { groupId = 51, groupZoneId = WOE, name = 'Entombed_Yanthu'     },
        { groupId = 29, groupZoneId = WOE, name = 'Ironclad_Harbinger'  },
        { groupId = 30, groupZoneId = WOE, name = 'Ironclad_Vaporizer'  },
        { groupId = 41, groupZoneId = WOE, name = 'Coeurl_Tiro'         },
    },
}

-- Boss per tier bracket.
xi.rift.BOSSES =
{
    [1]  = { groupId = 27, groupZoneId = WOE, name = 'Tapana'               }, -- tiers 1-3
    [4]  = { groupId = 29, groupZoneId = WOE, name = 'Ironclad_Harbinger'   }, -- tiers 4-6
    [7]  = { groupId = 30, groupZoneId = WOE, name = 'Ironclad_Vaporizer'   }, -- tiers 7-9
    [10] = { groupId = 56, groupZoneId = WOE, name = 'Lady_Lilith'          }, -- tier 10
}

-- Spawn points distributed across the WoE floor.
-- FORMAT: { x, y, z, rot }   ← replace these with /pos readings in-game.
xi.rift.SPAWN_POINTS =
{
    { -420,  14,  -49, 192 }, -- default entry point (used as anchor)
    { -380,  14,  -80, 128 },
    { -460,  14,  -80,  64 },
    { -340,  14, -120, 192 },
    { -500,  14, -120,   0 },
    { -420,  14, -150, 128 },
    { -380,  14, -160,  64 },
    { -460,  14, -160, 192 },
    { -340,  14, -200,   0 },
    { -500,  14, -200, 128 },
    { -420,  14, -240, 192 },
    { -360,  14, -260,  64 },
    { -480,  14, -260, 128 },
    { -420,  14, -310,   0 }, -- boss arena centre — adjust to a clear open area
}

-- Boss always spawns at the last entry (index #SPAWN_POINTS).
xi.rift.BOSS_SPAWN = xi.rift.SPAWN_POINTS[#xi.rift.SPAWN_POINTS]

-- ---------------------------------------------------------------------------
-- Scaling functions
-- ---------------------------------------------------------------------------

-- Returns the mob pool table for a given tier.
function xi.rift.getMobPool(tier)
    local bracket = 1
    for b = 10, 1, -1 do
        if xi.rift.MOB_POOLS[b] and tier >= b then
            bracket = b
            break
        end
    end
    return xi.rift.MOB_POOLS[bracket]
end

-- Returns the boss entry for a given tier.
function xi.rift.getBoss(tier)
    local bracket = 1
    for b = 10, 1, -1 do
        if xi.rift.BOSSES[b] and tier >= b then
            bracket = b
            break
        end
    end
    return xi.rift.BOSSES[bracket]
end

-- Base mob level for a tier (75 at tier 1, 120 at tier 10).
function xi.rift.mobLevel(tier)
    return 75 + (tier - 1) * 5
end

-- HP multiplier applied at spawn via onMobInitialize (1.0x at tier 1, 4.6x at tier 10).
function xi.rift.hpMult(tier)
    return 1.0 + (tier - 1) * 0.4
end

-- Number of non-boss mobs to spawn (5 at tier 1, 14 at tier 10).
function xi.rift.mobCount(tier)
    return 4 + tier
end

-- Treasure Hunter level applied to every rift mob (1 per 2 tiers, no cap).
function xi.rift.thLevel(tier)
    return math.ceil(tier / 2)
end

-- All drop rates are out of 10000.
-- Shard rates are generous — players should reliably accumulate these as currency.
-- Voidheart Haubergeon is a true chase item even at peak tier.
-- Boss mobs receive 2x on all rates.
--
-- Nascent Shard  (common):      2% at T1  → 18% at T20  (~4-5 per run at T20)
-- Tempered Shard (uncommon):    0.5% at T1 → 8% at T20  (~2 per run at T20)
-- Ultra-Rare (boss-only):        0.03% at T1 → 4% at T20  (1 in 3333 at T1, 1 in 25 at T20)

local NASCENT_RATES =
{
    [1]  =  200, [2]  =  300, [3]  =  400, [4]  =  500, [5]  =  600,
    [6]  =  700, [7]  =  800, [8]  =  900, [9]  = 1000, [10] = 1100,
    [11] = 1200, [12] = 1300, [13] = 1400, [14] = 1450, [15] = 1500,
    [16] = 1550, [17] = 1600, [18] = 1650, [19] = 1700, [20] = 1800,
}

local TEMPERED_RATES =
{
    [1]  =   50, [2]  =   75, [3]  =  100, [4]  =  150, [5]  =  200,
    [6]  =  250, [7]  =  300, [8]  =  350, [9]  =  400, [10] =  450,
    [11] =  500, [12] =  550, [13] =  600, [14] =  630, [15] =  660,
    [16] =  700, [17] =  730, [18] =  760, [19] =  780, [20] =  800,
}

-- Power curve (^1.5) from T1 to T10, linear extension T11-T20.
-- T1=0.03%, T10=1% (1 in 100), T20=2% (1 in 50).
local UR_RATES =
{
    [1]  =   3, [2]  =   9, [3]  =  16, [4]  =  25, [5]  =  35,
    [6]  =  46, [7]  =  59, [8]  =  72, [9]  =  85, [10] = 100,
    [11] = 130, [12] = 160, [13] = 190, [14] = 220, [15] = 250,
    [16] = 280, [17] = 310, [18] = 340, [19] = 370, [20] = 400,
}

function xi.rift.rollDrops(player, tier, isBoss)
    local mult         = isBoss and 2 or 1
    local cap          = xi.rift.MAX_TIER
    local nascentRate  = (NASCENT_RATES[tier]   or NASCENT_RATES[cap]) * mult
    local temperedRate = (TEMPERED_RATES[tier]  or TEMPERED_RATES[cap]) * mult
    local urRate       = (UR_RATES[tier] or UR_RATES[cap])

    if math.random(10000) <= nascentRate then
        player:addItem(xi.rift.NASCENT_SHARD)
    end

    if math.random(10000) <= temperedRate then
        player:addItem(xi.rift.TEMPERED_SHARD)
    end

    if isBoss and math.random(10000) <= urRate then
        local pool  = xi.rift.UR_POOL
        local entry = pool[math.random(#pool)]
        player:addItem(entry.item)
        local msg = string.format('[Rift] %s has obtained the %s!', player:getName(), entry.displayName)
        player:printToArea(msg, xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM)
    end
end

-- ---------------------------------------------------------------------------
-- Leaderboard write
-- Called from onInstanceComplete with the elapsed time in milliseconds.
-- Checks for a new tier speed record and broadcasts globally if beaten.
-- ---------------------------------------------------------------------------
local function formatTime(seconds)
    return string.format('%d:%02d', math.floor(seconds / 60), seconds % 60)
end

function xi.rift.recordClear(instance, elapsedMs)
    local tier    = instance:getLocalVar('tier')
    local seconds = math.floor(elapsedMs / 1000)
    local season  = xi.serverVariable.get('RIFT_SEASON') or 1

    -- Check current speed record for this tier/season before inserting.
    local recordVar = string.format('RIFT_RECORD_T%d_S%d', tier, season)
    local prevRecord = xi.serverVariable.get(recordVar) or 0

    local isNewRecord = prevRecord == 0 or seconds < prevRecord
    if isNewRecord then
        xi.serverVariable.set(recordVar, seconds)
    end

    local chars = instance:getChars()
    for _, player in pairs(chars) do
        db.query(
            "INSERT INTO rift_leaderboard (char_id, char_name, tier, clear_time, season) "
            .. "VALUES (%u, '%s', %u, %u, %u)",
            player:getID(),
            player:getName(),
            tier,
            seconds,
            season
        )

        -- Advance the player's cleared tier if this is a new high.
        local cleared = player:getCharVar(xi.rift.VAR_CLEARED)
        if tier > cleared then
            player:setCharVar(xi.rift.VAR_CLEARED, tier)
        end
    end

    -- Broadcast new record to entire server using first party member as the sender vehicle.
    if isNewRecord then
        local announcer = next(chars)
        if announcer then
            local msg = string.format(
                '[Rift] The speed record for Rift T%d has been beaten! The new record is %s, set by %s!',
                tier,
                formatTime(seconds),
                announcer:getName()
            )
            announcer:printToArea(msg, xi.msg.channel.SYSTEM_3, xi.msg.area.SYSTEM)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Mob death handler — called from each dynamic mob's onMobDeath.
-- Tracks remaining mobs; completes the instance when the boss dies.
-- Awards shard drops to the killing player.
-- ---------------------------------------------------------------------------
function xi.rift.onMobDeath(mob, player, instance, isBoss)
    if not instance then return end

    local tier = instance:getLocalVar('tier')

    -- Award shard drops to the killing player (if a PC).
    if player and player:isPC() then
        xi.rift.rollDrops(player, tier, isBoss)
    end

    if not isBoss then
        -- Regular mob killed; increment kill counter.
        local kills    = instance:getLocalVar('kills') + 1
        local required = instance:getLocalVar('killsRequired')
        instance:setLocalVar('kills', kills)

        if kills >= required then
            xi.rift.spawnBoss(instance)
        end
    else
        -- Boss died — fight won.
        instance:complete()
    end
end

-- Spawns the boss mob into the instance.
function xi.rift.spawnBoss(instance)
    local tier = instance:getLocalVar('tier')
    local boss = xi.rift.getBoss(tier)
    local sp   = xi.rift.BOSS_SPAWN
    local mult = xi.rift.hpMult(tier)
    local lvl  = xi.rift.mobLevel(tier) + 5 -- boss is always 5 levels above regular mobs

    instance:setLocalVar('bossSpawned', 1)

    instance:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = boss.name .. '_Rift',
        groupId     = boss.groupId,
        groupZoneId = boss.groupZoneId,
        minLevel    = lvl,
        maxLevel    = lvl,
        isAggroable = true,
        x = sp[1], y = sp[2], z = sp[3],
        rotation    = sp[4],

        onMobInitialize = function(mob)
            mob:setMaxHP(math.floor(mob:getMaxHP() * mult * 2)) -- boss has 2x the regular HP mult
            mob:restoreHP()
            mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
            xi.rift.applyBossModifiers(mob, tier)
        end,

        onMobDeath = function(mob, player, optParams)
            xi.rift.onMobDeath(mob, player, instance, true)
        end,
    })
end

-- ---------------------------------------------------------------------------
-- Seasonal modifier system
--
-- Modifiers are named entries in xi.rift.MODIFIERS. Each may define:
--   onMobInit(mob, tier)              — called inside every mob's onMobInitialize
--   onBossInit(mob, tier)             — called inside the boss's onMobInitialize
--   onTick(instance, elapsed, tier)   — called every second in onInstanceTimeUpdate
--
-- Active modifiers for the current season are stored in server vars:
--   RIFT_MOD_1 .. RIFT_MOD_5  (string keys matching xi.rift.MODIFIERS)
-- Set them via GM command or SQL:
--   UPDATE server_vars SET value = 'BLOODDRAIN' WHERE varname = 'RIFT_MOD_1';
-- Clear a slot by setting its value to '' or 0.
--
-- Up to 5 modifiers can stack simultaneously.
-- ---------------------------------------------------------------------------

-- PDT/MDT note: xi.mod.DMGPHYS / DMGMAGIC use negative values to reduce damage taken
-- and positive values to increase it. Vanilla cap is ±50%; UDMGPHYS/UDMGMAGIC bypass it.
-- Applied via mob:addMod() which works on any CBattleEntity.

xi.rift.MODIFIERS =
{
    -- All enemies attack faster.
    ENRAGE =
    {
        description = 'All enemies move with terrible haste.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.HASTE, 20 + tier * 2)
        end,
        onBossInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.HASTE, 30 + tier * 2)
        end,
    },

    -- Players lose HP every 3 seconds. Cannot kill (stops at 1 HP).
    BLOODDRAIN =
    {
        description = 'A dark force steadily drains the life of all within.',
        onTick = function(instance, elapsed, tier)
            if elapsed % 3000 < 1000 then
                local drain = math.max(1, math.floor(50 + tier * 10))
                for _, player in pairs(instance:getChars()) do
                    if player:getHP() > drain then
                        player:addHP(-drain)
                    end
                end
            end
        end,
    },

    -- Players lose MP every 5 seconds.
    MANADRAIN =
    {
        description = 'Arcane interference saps the magical reserves of all within.',
        onTick = function(instance, elapsed, tier)
            if elapsed % 5000 < 1000 then
                local drain = math.max(1, math.floor(20 + tier * 5))
                for _, player in pairs(instance:getChars()) do
                    if player:getMP() > drain then
                        player:addMP(-drain)
                    end
                end
            end
        end,
    },

    -- All enemies hit significantly harder.
    EMPOWERED =
    {
        description = 'The enemies of the Rift are bolstered beyond their natural limits.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.DMG_MULTIPLIER, 100 + tier * 10)
        end,
        onBossInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.DMG_MULTIPLIER, 120 + tier * 10)
        end,
    },

    -- Enemies shrug off physical damage but crumble to magic.
    -- -50% PDT (capped), +50% MDT. Forces magic-heavy strategies.
    FORTIFIED =
    {
        description = 'The enemies of the Rift are encased in impenetrable physical armour, but burn bright with magical vulnerability.',
        onMobInit = function(mob, tier)
            mob:addMod(xi.mod.DMGPHYS,   -50) -- -50% physical damage taken (capped)
            mob:addMod(xi.mod.DMGMAGIC,   50) -- +50% magic damage taken
            mob:setMaxHP(math.floor(mob:getMaxHP() * 1.5))
            mob:restoreHP()
        end,
    },

    -- Enemies shrug off magic but buckle to physical pressure.
    -- -50% MDT (capped), +50% PDT. Forces melee-heavy strategies.
    WARDED =
    {
        description = 'Ancient wards repel all magical forces within the Rift, but leave the body exposed to physical ruin.',
        onMobInit = function(mob, tier)
            mob:addMod(xi.mod.DMGMAGIC,  -50) -- -50% magic damage taken (capped)
            mob:addMod(xi.mod.DMGPHYS,    50) -- +50% physical damage taken
        end,
    },

    -- TP builds faster on all enemies.
    ACCELERATED =
    {
        description = 'Enemies gain TP with unnatural speed.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.TP_MULTIPLIER, 150 + tier * 5)
        end,
    },

    -- Enemies take less of all damage types — a pure survival check.
    -- Uses uncapped mods so the reduction is meaningful at high tiers.
    UNYIELDING =
    {
        description = 'The enemies of the Rift resist all forms of harm.',
        onMobInit = function(mob, tier)
            local reduction = math.min(40, 20 + tier * 2) -- 22% T1, capped at 40%
            mob:addMod(xi.mod.UDMGPHYS,  -reduction)
            mob:addMod(xi.mod.UDMGMAGIC, -reduction)
        end,
        onBossInit = function(mob, tier)
            local reduction = math.min(50, 30 + tier * 2)
            mob:addMod(xi.mod.UDMGPHYS,  -reduction)
            mob:addMod(xi.mod.UDMGMAGIC, -reduction)
        end,
    },
}

-- Returns a list of active modifier entries for the current season.
function xi.rift.getSeasonModifiers()
    local active = {}
    for i = 1, 5 do
        local key = xi.serverVariable.get(string.format('RIFT_MOD_%d', i))
        if key and key ~= '' and key ~= '0' and xi.rift.MODIFIERS[key] then
            active[#active + 1] = xi.rift.MODIFIERS[key]
        end
    end
    return active
end

-- Apply mob-init modifiers. Call from inside onMobInitialize for regular mobs.
function xi.rift.applyMobModifiers(mob, tier)
    for _, mod in ipairs(xi.rift.getSeasonModifiers()) do
        if mod.onMobInit then
            mod.onMobInit(mob, tier)
        end
    end
end

-- Apply boss-init modifiers. Call from inside the boss's onMobInitialize.
function xi.rift.applyBossModifiers(mob, tier)
    for _, mod in ipairs(xi.rift.getSeasonModifiers()) do
        if mod.onBossInit then
            mod.onBossInit(mob, tier)
        elseif mod.onMobInit then
            mod.onMobInit(mob, tier)
        end
    end
end

-- Run tick modifiers. Call from onInstanceTimeUpdate each second.
function xi.rift.tickModifiers(instance, elapsed, tier)
    for _, mod in ipairs(xi.rift.getSeasonModifiers()) do
        if mod.onTick then
            mod.onTick(instance, elapsed, tier)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Entry NPC — Rift Surveyor in Xarcabard
--
-- Tier selection: player enters at the highest tier they have unlocked + 1.
-- First-time players need xi.rift.UNLOCK_ITEM in inventory.
-- On success the player is teleported to Walk of Echoes; onZoneIn there
-- completes the instance load and layer entry.
-- ---------------------------------------------------------------------------
-- Surveyor NPC trigger.
-- First trigger cycles the selected tier and shows it (wraps 1 → max available).
-- Triggering again within 5 seconds enters the rift at the selected tier.
-- Players can access any tier from 1 up to their highest cleared + 1.
function xi.rift.onSurveyorTrigger(player, npc)
    local cleared      = player:getCharVar(xi.rift.VAR_CLEARED)
    local maxAvailable = math.min(cleared + 1, xi.rift.MAX_TIER)

    -- First-time players need the unlock item.
    if cleared == 0 and not player:hasItem(xi.rift.UNLOCK_ITEM) then
        -- TODO: Replace with a rift-specific "you need the unlock item" message.
        player:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)
        return
    end

    if player:getInstance() then
        player:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)
        return
    end

    -- If a confirm is pending (player triggered within 5s), enter.
    if player:getLocalVar('RIFT_CONFIRMING') == 1 then
        player:setLocalVar('RIFT_CONFIRMING', 0)
        local tier = player:getLocalVar('RIFT_SELECTED_TIER')
        local sp   = xi.rift.SPAWN_POINTS[1]
        player:setLocalVar(xi.rift.VAR_PENDING, tier)
        for _, member in pairs(player:getParty()) do
            if member:getZoneID() == player:getZoneID() then
                member:setPos(sp[1], sp[2], sp[3], sp[4], xi.zone.WALK_OF_ECHOES)
            end
        end
        return
    end

    -- Cycle to the next available tier (wraps back to 1 after max).
    local current  = player:getLocalVar('RIFT_SELECTED_TIER')
    local next     = (current % maxAvailable) + 1
    player:setLocalVar('RIFT_SELECTED_TIER', next)
    player:setLocalVar('RIFT_CONFIRMING', 1)

    -- TODO: Replace with a real message e.g. "Tier X selected. Trigger again to enter."
    player:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)

    -- Cancel the confirm window after 5 seconds.
    player:timer(5000, function(p)
        p:setLocalVar('RIFT_CONFIRMING', 0)
    end)
end

-- ---------------------------------------------------------------------------
-- Walk of Echoes onZoneIn handler
-- Call this from Walk_of_Echoes/Zone.lua inside onZoneIn.
-- Creates the instance and enters the layer once the player arrives.
-- ---------------------------------------------------------------------------
function xi.rift.onZoneIn(player)
    local tier = player:getLocalVar(xi.rift.VAR_PENDING)
    if tier == 0 then return end

    player:setLocalVar(xi.rift.VAR_PENDING, 0)

    -- The party leader creates the instance; members join via onInstanceCreatedCallback.
    -- createInstance is async — use a timer to poll until it's ready then enter the layer.
    player:createInstance(xi.rift.INSTANCE_ID)
    player:setLocalVar('RIFT_REQUESTED', 1)

    -- Poll up to 10 seconds for the instance to load, then enter the layer.
    local function tryEnterLayer(p)
        local instance = p:getInstance()
        if instance then
            instance:setLocalVar('tier', tier)
            for _, member in pairs(p:getParty()) do
                if member:getZoneID() == xi.zone.WALK_OF_ECHOES and not member:getInstance() then
                    member:setInstance(instance)
                    member:enterInstanceLayer()
                end
            end
            -- Enter the requesting player last.
            if not p:getInstance() then
                p:setInstance(instance)
                p:enterInstanceLayer()
            end
            p:setLocalVar('RIFT_REQUESTED', 0)
            return
        end

        local attempts = p:getLocalVar('RIFT_REQUESTED')
        if attempts < 10 then
            p:setLocalVar('RIFT_REQUESTED', attempts + 1)
            p:timer(1000, tryEnterLayer)
        else
            -- Timed out — instance never loaded.
            p:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)
            p:setLocalVar('RIFT_REQUESTED', 0)
        end
    end

    player:timer(1000, tryEnterLayer)
end
