-----------------------------------
-- Rift System — shared utilities
-- Instanced content in Walk of Echoes, entered from Xarcabard.
-----------------------------------

xi = xi or {}
xi.rift = xi.rift or {}

-- Item players must possess to unlock tier 1.
-- TODO: Replace with a custom rift unlock item once defined.
xi.rift.UNLOCK_ITEM = xi.item.DARK_MATTER

-- Shard drops from rift mobs. Four tiers, each significantly rarer than the last.
-- Boss kills receive 2x multiplier on all shard rates.
xi.rift.NASCENT_SHARD  = xi.item.NASCENT_SHARD
xi.rift.TEMPERED_SHARD = xi.item.TEMPERED_SHARD
xi.rift.FORGED_SHARD   = xi.item.FORGED_SHARD
xi.rift.RESOLUTE_SHARD = xi.item.RESOLUTE_SHARD

-- Ultra-rare item pool (boss-only).
-- One item is chosen at random if the UR rate roll succeeds — never multiple per kill.
-- Add entries here as new UR items are introduced; displayName is used in the announcement.
xi.rift.UR_POOL =
{
    { item = xi.item.VOIDHEART_HAUBERGEON,   displayName = 'Voidheart Haubergeon'   },
    { item = xi.item.COVENANT_PLATE,         displayName = 'Covenant Plate'         },
    { item = xi.item.STARWEAVERS_ROBE,       displayName = "Starweaver's Robe"      },
    { item = xi.item.SAINTWOOD_STAFF,        displayName = 'Saintwood Staff'        },
    { item = xi.item.ECLIPSE_KATANA,         displayName = 'Eclipse Katana'         },
    { item = xi.item.ABYSSAL_TABAR,          displayName = 'Abyssal Tabar'          },
    { item = xi.item.FATEWEAVER_MANTLE,      displayName = "Fateweaver Mantle"      },
    { item = xi.item.REQUIEM_TORQUE,         displayName = 'Requiem Torque'         },
    { item = xi.item.SHADOWSTRIKE_RING,      displayName = 'Shadowstrike Ring'      },
    { item = xi.item.FERAL_WARDERS_CUIRASS,  displayName = "Feral Warder's Cuirass" },
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

-- Base mob level for a tier (75 at T1, 100 at T20).
-- Boss is always +5 on top of this value.
function xi.rift.mobLevel(tier)
    return math.floor(75 + (tier - 1) * 25 / 19)
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

-- All drop rates are out of 10000. Boss mobs receive 2x on all shard rates.
-- Each shard tier is significantly rarer than the previous.
-- Resolute is rarer than a UR item drop per run even at peak tier.
--
-- Tier         | T1 per mob | T10 per mob | T20 per mob | ~per run T10* | ~per run T20**
-- Nascent      |  2%        | 11%         | 18%         | ~166%         | ~460%
-- Tempered     |  0.5%      |  4.5%       |  8%         |  ~72%         | ~205%
-- Forged       |  0.1%      |  0.9%       |  1.8%       |  ~14%         |  ~46%
-- Resolute     |  0.01%     |  0.05%      |  0.15%      |   ~0.8%       |   ~3.9%
-- UR (boss)    |  0.03%     |  1%         |  4%         |   ~1%         |   ~4%
-- * T10 = 14 regular mobs + 1 boss (2x mult)   ** T20 = 24 regular + 1 boss

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

-- ~5x rarer than Tempered per mob. Meaningful but uncommon.
local FORGED_RATES =
{
    [1]  =   10, [2]  =   15, [3]  =   22, [4]  =   30, [5]  =   38,
    [6]  =   46, [7]  =   56, [8]  =   66, [9]  =   78, [10] =   90,
    [11] =  100, [12] =  110, [13] =  120, [14] =  130, [15] =  140,
    [16] =  150, [17] =  160, [18] =  170, [19] =  175, [20] =  180,
}

-- Rarer than a UR item drop per run even at T20. True prestige currency.
local RESOLUTE_RATES =
{
    [1]  =   1, [2]  =   1, [3]  =   2, [4]  =   2, [5]  =   3,
    [6]  =   3, [7]  =   4, [8]  =   4, [9]  =   4, [10] =   5,
    [11] =   6, [12] =   7, [13] =   8, [14] =   9, [15] =  10,
    [16] =  11, [17] =  12, [18] =  13, [19] =  14, [20] =  15,
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
    local nascentRate  = (NASCENT_RATES[tier]   or NASCENT_RATES[cap])  * mult
    local temperedRate = (TEMPERED_RATES[tier]  or TEMPERED_RATES[cap]) * mult
    local forgedRate   = (FORGED_RATES[tier]    or FORGED_RATES[cap])   * mult
    local resoluteRate = (RESOLUTE_RATES[tier]  or RESOLUTE_RATES[cap]) * mult
    local urRate       = (UR_RATES[tier] or UR_RATES[cap])

    if math.random(10000) <= nascentRate then
        player:addItem(xi.rift.NASCENT_SHARD)
    end

    if math.random(10000) <= temperedRate then
        player:addItem(xi.rift.TEMPERED_SHARD)
    end

    if math.random(10000) <= forgedRate then
        player:addItem(xi.rift.FORGED_SHARD)
    end

    if math.random(10000) <= resoluteRate then
        player:addItem(xi.rift.RESOLUTE_SHARD)
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

    -- Assign proc weaknesses now so they're stored before the entity is created.
    xi.rift.assignBossWeaknesses(instance)

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
            xi.rift.applyFloorBossModifiers(mob, instance, tier)

            -- Wire proc detection listeners.
            mob:addListener('MAGIC_TAKE', 'RIFT_YELLOW_PROC', function(m, caster, spell, action)
                xi.rift.checkMagicProc(m, instance, spell:getID())
            end)
            mob:addListener('WEAPONSKILL_TAKE', 'RIFT_BLUE_PROC', function(m, user, target, skill, spent, action)
                xi.rift.checkWSProc(m, instance, skill:getID())
            end)
            mob:addListener('ABILITY_TAKE', 'RIFT_RED_PROC', function(m, user, target, ability, action)
                xi.rift.checkJAProc(m, instance, ability:getID())
            end)
            -- Suppress the boss's next TP move when Yellow proc is pending.
            mob:addListener('WEAPONSKILL_BEFORE_USE', 'RIFT_YELLOW_INTERRUPT', function(m, wsid)
                if xi.rift.consumeYellowInterrupt(m) then
                    m:setLocalVar('BlockNextWS', 1)
                end
            end)
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
-- Boss proc system
--
-- Each boss spawned in a Rift run is assigned three weaknesses (Yellow/Blue/Red).
-- Hitting the correct spell, weapon skill, or job ability fires the matching
-- colored !! animation and applies a mechanical effect that helps the party.
-- If all three are triggered in a single run the boss enters White state.
--
-- Yellow (magic spell)  — spell element matches the current Vana'diel day.
--                         Effect: interrupt next TP move + brief MDT-down.
-- Blue   (weapon skill) — WS damage type assigned randomly at spawn.
--                         Effect: 12s PDT-down damage window.
-- Red    (job ability)  — random JA from a curated list filtered by party jobs.
--                         Effect: extended Terror + strip one buff + White counter++.
-- White  (all three)    — permanent PDT/MDT-down, boss stops TP, bonus shard drop.
--
-- Weaknesses are stored in instance local vars:
--   RIFT_YELLOW_WEAK  (spell ID)
--   RIFT_BLUE_WEAK    (WS ID)
--   RIFT_RED_WEAK     (ability ID)
--   RIFT_YELLOW_DONE / RIFT_BLUE_DONE / RIFT_RED_DONE  (0/1)
--   RIFT_WHITE_DONE   (0/1)
-- ---------------------------------------------------------------------------

-- Jobs that can cast offensive magic (for Yellow fallback check).
local MAGE_JOBS = { [xi.job.BLM]=true, [xi.job.RDM]=true, [xi.job.WHM]=true,
                    [xi.job.DRK]=true, [xi.job.BLU]=true, [xi.job.SCH]=true,
                    [xi.job.SMN]=true }

-- Yellow spell tables keyed by xi.day constant.
-- Only spells learnable by ≤75 BLM/RDM/WHM/DRK.
local YELLOW_BY_DAY =
{
    [xi.day.FIRESDAY]    = { xi.magic.spell.FIRE,     xi.magic.spell.FIRE_II,     xi.magic.spell.FIRE_III,     xi.magic.spell.FLARE    },
    [xi.day.ICEDAY]      = { xi.magic.spell.BLIZZARD, xi.magic.spell.BLIZZARD_II, xi.magic.spell.BLIZZARD_III, xi.magic.spell.FREEZE   },
    [xi.day.WINDSDAY]    = { xi.magic.spell.AERO,     xi.magic.spell.AERO_II,     xi.magic.spell.AERO_III,     xi.magic.spell.TORNADO  },
    [xi.day.EARTHSDAY]   = { xi.magic.spell.STONE,    xi.magic.spell.STONE_II,    xi.magic.spell.STONE_III,    xi.magic.spell.QUAKE    },
    [xi.day.LIGHTNINGDAY]= { xi.magic.spell.THUNDER,  xi.magic.spell.THUNDER_II,  xi.magic.spell.THUNDER_III,  xi.magic.spell.BURST    },
    [xi.day.WATERSDAY]   = { xi.magic.spell.WATER,    xi.magic.spell.WATER_II,    xi.magic.spell.WATER_III,    xi.magic.spell.FLOOD    },
    [xi.day.LIGHTSDAY]   = { xi.magic.spell.BANISH,   xi.magic.spell.BANISH_II,   xi.magic.spell.HOLY,         xi.magic.spell.DIA,     xi.magic.spell.DIA_II },
    [xi.day.DARKSDAY]    = { xi.magic.spell.BIO,      xi.magic.spell.BIO_II,      xi.magic.spell.DRAIN,        xi.magic.spell.ASPIR    },
}

-- Blue weapon skill tables by damage type, tagged with which main jobs can use them.
-- jobs = set of xi.job values (main job only).
local BLUE_PIERCING =
{
    { id = xi.weaponskill.PENTA_THRUST,   jobs = { [xi.job.DRG]=true } },
    { id = xi.weaponskill.VORPAL_THRUST,  jobs = { [xi.job.DRG]=true } },
    { id = xi.weaponskill.SKEWER,         jobs = { [xi.job.DRG]=true } },
    { id = xi.weaponskill.DANCING_EDGE,   jobs = { [xi.job.THF]=true, [xi.job.NIN]=true } },
    { id = xi.weaponskill.SHADOWSTITCH,   jobs = { [xi.job.THF]=true } },
    { id = xi.weaponskill.EVISCERATION,   jobs = { [xi.job.THF]=true, [xi.job.RDM]=true, [xi.job.NIN]=true, [xi.job.BRD]=true, [xi.job.DNC]=true } },
    { id = xi.weaponskill.PYRRHIC_KLEOS,  jobs = { [xi.job.DNC]=true } },
    { id = xi.weaponskill.EXENTERATOR,    jobs = { [xi.job.DNC]=true } },
    { id = xi.weaponskill.BLADE_EI,       jobs = { [xi.job.NIN]=true } },
    { id = xi.weaponskill.SIDEWINDER,     jobs = { [xi.job.RNG]=true } },
    { id = xi.weaponskill.NAMAS_ARROW,    jobs = { [xi.job.RNG]=true } },
    { id = xi.weaponskill.SLUG_SHOT,      jobs = { [xi.job.RNG]=true, [xi.job.COR]=true } },
    { id = xi.weaponskill.LAST_STAND,     jobs = { [xi.job.RNG]=true, [xi.job.COR]=true } },
    { id = xi.weaponskill.DETONATOR,      jobs = { [xi.job.COR]=true } },
}

local BLUE_SLASHING =
{
    { id = xi.weaponskill.FAST_BLADE,      jobs = { [xi.job.WAR]=true, [xi.job.PLD]=true, [xi.job.RDM]=true, [xi.job.DRK]=true, [xi.job.BRD]=true, [xi.job.BLU]=true, [xi.job.COR]=true, [xi.job.DNC]=true } },
    { id = xi.weaponskill.RED_LOTUS_BLADE, jobs = { [xi.job.WAR]=true, [xi.job.PLD]=true, [xi.job.RDM]=true, [xi.job.DRK]=true, [xi.job.BRD]=true, [xi.job.BLU]=true, [xi.job.COR]=true, [xi.job.DNC]=true } },
    { id = xi.weaponskill.VORPAL_BLADE,    jobs = { [xi.job.WAR]=true, [xi.job.PLD]=true, [xi.job.RDM]=true, [xi.job.DRK]=true, [xi.job.BRD]=true, [xi.job.BLU]=true, [xi.job.COR]=true, [xi.job.DNC]=true } },
    { id = xi.weaponskill.SAVAGE_BLADE,    jobs = { [xi.job.WAR]=true, [xi.job.PLD]=true, [xi.job.RDM]=true, [xi.job.DRK]=true, [xi.job.BRD]=true, [xi.job.BLU]=true, [xi.job.COR]=true, [xi.job.DNC]=true } },
    { id = xi.weaponskill.SPIRITS_WITHIN,  jobs = { [xi.job.PLD]=true } },
    { id = xi.weaponskill.TACHI_ENPI,      jobs = { [xi.job.SAM]=true } },
    { id = xi.weaponskill.TACHI_GOTEN,     jobs = { [xi.job.SAM]=true } },
    { id = xi.weaponskill.TACHI_YUKIKAZE,  jobs = { [xi.job.SAM]=true } },
    { id = xi.weaponskill.TACHI_GEKKO,     jobs = { [xi.job.SAM]=true } },
    { id = xi.weaponskill.TACHI_KASHA,     jobs = { [xi.job.SAM]=true } },
    { id = xi.weaponskill.BLADE_RETSU,     jobs = { [xi.job.NIN]=true } },
    { id = xi.weaponskill.BLADE_JIN,       jobs = { [xi.job.NIN]=true } },
    { id = xi.weaponskill.BLADE_HI,        jobs = { [xi.job.NIN]=true } },
    { id = xi.weaponskill.BLADE_METSU,     jobs = { [xi.job.NIN]=true } },
    { id = xi.weaponskill.GUILLOTINE,      jobs = { [xi.job.DRK]=true } },
    { id = xi.weaponskill.CROSS_REAPER,    jobs = { [xi.job.DRK]=true } },
    { id = xi.weaponskill.NIGHTMARE_SCYTHE,jobs = { [xi.job.DRK]=true } },
    { id = xi.weaponskill.SPINNING_SLASH,  jobs = { [xi.job.DRK]=true, [xi.job.WAR]=true } },
    { id = xi.weaponskill.RESOLUTION,      jobs = { [xi.job.DRK]=true, [xi.job.WAR]=true } },
    { id = xi.weaponskill.STEEL_CYCLONE,   jobs = { [xi.job.WAR]=true } },
    { id = xi.weaponskill.FELL_CLEAVE,     jobs = { [xi.job.WAR]=true } },
    { id = xi.weaponskill.RAGING_AXE,      jobs = { [xi.job.WAR]=true, [xi.job.BST]=true, [xi.job.DRK]=true } },
    { id = xi.weaponskill.GALE_AXE,        jobs = { [xi.job.WAR]=true, [xi.job.BST]=true, [xi.job.DRK]=true } },
    { id = xi.weaponskill.AVALANCHE_AXE,   jobs = { [xi.job.WAR]=true, [xi.job.BST]=true, [xi.job.DRK]=true } },
}

local BLUE_BLUNT =
{
    { id = xi.weaponskill.COMBO,        jobs = { [xi.job.MNK]=true, [xi.job.PUP]=true } },
    { id = xi.weaponskill.RAGING_FISTS, jobs = { [xi.job.MNK]=true, [xi.job.PUP]=true } },
    { id = xi.weaponskill.HOWLING_FIST, jobs = { [xi.job.MNK]=true, [xi.job.PUP]=true } },
    { id = xi.weaponskill.DRAGON_KICK,  jobs = { [xi.job.MNK]=true, [xi.job.PUP]=true } },
    { id = xi.weaponskill.HEXA_STRIKE,  jobs = { [xi.job.WHM]=true, [xi.job.PLD]=true, [xi.job.BLU]=true } },
    { id = xi.weaponskill.BLACK_HALO,   jobs = { [xi.job.WHM]=true, [xi.job.PLD]=true, [xi.job.BLU]=true } },
    { id = xi.weaponskill.RETRIBUTION,  jobs = { [xi.job.WHM]=true, [xi.job.BLM]=true, [xi.job.RDM]=true, [xi.job.SMN]=true, [xi.job.SCH]=true } },
    { id = xi.weaponskill.CATACLYSM,    jobs = { [xi.job.WHM]=true, [xi.job.BLM]=true, [xi.job.RDM]=true, [xi.job.SMN]=true, [xi.job.SCH]=true } },
    { id = xi.weaponskill.SHOCKWAVE,    jobs = { [xi.job.WAR]=true, [xi.job.DRK]=true, [xi.job.PLD]=true } },
}

-- Red job ability pool, tagged with which jobs have access (main OR sub job).
local RED_POOL =
{
    -- WAR
    { id = xi.ja.BERSERK,          jobs = { [xi.job.WAR]=true } },
    { id = xi.ja.WARCRY,           jobs = { [xi.job.WAR]=true } },
    { id = xi.ja.DEFENDER,         jobs = { [xi.job.WAR]=true } },
    { id = xi.ja.AGGRESSOR,        jobs = { [xi.job.WAR]=true } },
    { id = xi.ja.PROVOKE,          jobs = { [xi.job.WAR]=true } },
    -- MNK
    { id = xi.ja.BOOST,            jobs = { [xi.job.MNK]=true } },
    { id = xi.ja.CHAKRA,           jobs = { [xi.job.MNK]=true } },
    { id = xi.ja.FOCUS,            jobs = { [xi.job.MNK]=true } },
    { id = xi.ja.COUNTERSTANCE,    jobs = { [xi.job.MNK]=true } },
    { id = xi.ja.CHI_BLAST,        jobs = { [xi.job.MNK]=true } },
    -- WHM
    { id = xi.ja.AFFLATUS_SOLACE,  jobs = { [xi.job.WHM]=true } },
    { id = xi.ja.AFFLATUS_MISERY,  jobs = { [xi.job.WHM]=true } },
    -- BLM
    { id = xi.ja.ELEMENTAL_SEAL,   jobs = { [xi.job.BLM]=true } },
    -- RDM
    { id = xi.ja.COMPOSURE,        jobs = { [xi.job.RDM]=true } },
    { id = xi.ja.SABOTEUR,         jobs = { [xi.job.RDM]=true } },
    -- THF
    { id = xi.ja.SNEAK_ATTACK,     jobs = { [xi.job.THF]=true } },
    { id = xi.ja.TRICK_ATTACK,     jobs = { [xi.job.THF]=true } },
    { id = xi.ja.FEINT,            jobs = { [xi.job.THF]=true } },
    -- PLD
    { id = xi.ja.SENTINEL,         jobs = { [xi.job.PLD]=true } },
    { id = xi.ja.WEAPON_BASH,      jobs = { [xi.job.PLD]=true } },
    { id = xi.ja.RAMPART,          jobs = { [xi.job.PLD]=true } },
    { id = xi.ja.COVER,            jobs = { [xi.job.PLD]=true } },
    -- DRK
    { id = xi.ja.SOULEATER,        jobs = { [xi.job.DRK]=true } },
    { id = xi.ja.LAST_RESORT,      jobs = { [xi.job.DRK]=true } },
    { id = xi.ja.ARCANE_CIRCLE,    jobs = { [xi.job.DRK]=true } },
    { id = xi.ja.NETHER_VOID,      jobs = { [xi.job.DRK]=true } },
    -- BST
    { id = xi.ja.REWARD,           jobs = { [xi.job.BST]=true } },
    -- BRD
    { id = xi.ja.PIANISSIMO,       jobs = { [xi.job.BRD]=true } },
    { id = xi.ja.MARCATO,          jobs = { [xi.job.BRD]=true } },
    -- RNG
    { id = xi.ja.BARRAGE,          jobs = { [xi.job.RNG]=true } },
    { id = xi.ja.SHADOWBIND,       jobs = { [xi.job.RNG]=true } },
    { id = xi.ja.SHARPSHOT,        jobs = { [xi.job.RNG]=true } },
    -- SAM
    { id = xi.ja.MEDITATE,         jobs = { [xi.job.SAM]=true } },
    { id = xi.ja.THIRD_EYE,        jobs = { [xi.job.SAM]=true } },
    { id = xi.ja.SEKKANOKI,        jobs = { [xi.job.SAM]=true } },
    { id = xi.ja.BLADE_BASH,       jobs = { [xi.job.SAM]=true } },
    -- NIN
    { id = xi.ja.MIGAWARI,         jobs = { [xi.job.NIN]=true } },
    { id = xi.ja.INNIN,            jobs = { [xi.job.NIN]=true } },
    { id = xi.ja.YONIN,            jobs = { [xi.job.NIN]=true } },
    { id = xi.ja.FUTAE,            jobs = { [xi.job.NIN]=true } },
    -- DRG
    { id = xi.ja.JUMP,             jobs = { [xi.job.DRG]=true } },
    { id = xi.ja.HIGH_JUMP,        jobs = { [xi.job.DRG]=true } },
    { id = xi.ja.SPIRIT_JUMP,      jobs = { [xi.job.DRG]=true } },
    { id = xi.ja.ANGON,            jobs = { [xi.job.DRG]=true } },
    -- SMN
    { id = xi.ja.ELEMENTAL_SIPHON, jobs = { [xi.job.SMN]=true } },
    -- BLU
    { id = xi.ja.BURST_AFFINITY,   jobs = { [xi.job.BLU]=true } },
    { id = xi.ja.CHAIN_AFFINITY,   jobs = { [xi.job.BLU]=true } },
    -- COR
    { id = xi.ja.QUICK_DRAW,       jobs = { [xi.job.COR]=true } },
    -- PUP
    { id = xi.ja.VENTRILOQUY,      jobs = { [xi.job.PUP]=true } },
    { id = xi.ja.FINE_TUNE,        jobs = { [xi.job.PUP]=true } },
    -- DNC
    { id = xi.ja.QUICKSTEP,        jobs = { [xi.job.DNC]=true } },
    { id = xi.ja.VIOLENT_FLOURISH, jobs = { [xi.job.DNC]=true } },
    -- SCH
    { id = xi.ja.LIGHT_ARTS,       jobs = { [xi.job.SCH]=true } },
    { id = xi.ja.DARK_ARTS,        jobs = { [xi.job.SCH]=true } },
}

-- Universal fallbacks used when no party member qualifies for a given colour.
local FALLBACK_YELLOW = xi.magic.spell.STONE    -- any mage can cast
local FALLBACK_BLUE   = xi.weaponskill.FAST_BLADE        -- nearly universal sword WS
local FALLBACK_RED    = xi.ja.PROVOKE            -- nearly every job can sub WAR

-- ---------------------------------------------------------------------------
-- Weakness assignment
-- ---------------------------------------------------------------------------

-- Builds a set of { mainJob = true } and { mainJob = true, subJob = true } for
-- every player currently in the instance.
local function buildJobSets(instance)
    local mainJobs = {}
    local allJobs  = {}
    for _, player in pairs(instance:getChars()) do
        local mj = player:getMainJob()
        local sj = player:getSubJob()
        mainJobs[mj] = true
        allJobs[mj]  = true
        if sj and sj > 0 then
            allJobs[sj] = true
        end
    end
    return mainJobs, allJobs
end

-- Filters a list of { id, jobs } entries to only those usable by the given job set.
local function filterByJobs(pool, jobSet)
    local filtered = {}
    for _, entry in ipairs(pool) do
        for job in pairs(entry.jobs) do
            if jobSet[job] then
                filtered[#filtered + 1] = entry.id
                break
            end
        end
    end
    return filtered
end

-- Assigns Yellow/Blue/Red weaknesses for a boss and stores them in instance vars.
-- Call at the start of spawnBoss (before insertDynamicEntity).
function xi.rift.assignBossWeaknesses(instance)
    local mainJobs, allJobs = buildJobSets(instance)

    -- Yellow: pick a random spell from today's element list.
    local day     = VanadielDayOfTheWeek()
    local dayList = YELLOW_BY_DAY[day] or YELLOW_BY_DAY[xi.day.FIRESDAY]
    -- Check at least one mage is present; fall back to Stone if not.
    local hasMage = false
    for job in pairs(MAGE_JOBS) do
        if allJobs[job] then hasMage = true; break end
    end
    local yellowSpell = hasMage and dayList[math.random(#dayList)] or FALLBACK_YELLOW
    instance:setLocalVar('RIFT_YELLOW_WEAK', yellowSpell)

    -- Blue: pick a random damage type then filter that type's pool by main jobs.
    local allBlue    = {}
    for _, entry in ipairs(BLUE_PIERCING) do allBlue[#allBlue+1] = entry end
    for _, entry in ipairs(BLUE_SLASHING) do allBlue[#allBlue+1] = entry end
    for _, entry in ipairs(BLUE_BLUNT)    do allBlue[#allBlue+1] = entry end
    local bluePool   = filterByJobs(allBlue, mainJobs) -- main job only for WS
    local blueWS     = #bluePool > 0 and bluePool[math.random(#bluePool)] or FALLBACK_BLUE
    instance:setLocalVar('RIFT_BLUE_WEAK', blueWS)

    -- Red: filter the JA pool by main + sub jobs.
    local redPool = filterByJobs(RED_POOL, allJobs)
    local redJA   = #redPool > 0 and redPool[math.random(#redPool)] or FALLBACK_RED
    instance:setLocalVar('RIFT_RED_WEAK', redJA)

    -- Reset proc state.
    instance:setLocalVar('RIFT_YELLOW_DONE', 0)
    instance:setLocalVar('RIFT_BLUE_DONE',   0)
    instance:setLocalVar('RIFT_RED_DONE',    0)
    instance:setLocalVar('RIFT_WHITE_DONE',  0)
end

-- ---------------------------------------------------------------------------
-- Proc effects
-- ---------------------------------------------------------------------------

-- Sends the !! animation and applies the colour-specific effect.
-- color: 1=Red, 2=Yellow, 3=Blue (matches WeaknessType in C++).
local function fireBossProc(mob, instance, tier, color)
    mob:weaknessTrigger(color)

    if color == 2 then
        -- Yellow: interrupt next TP move + apply MDT-down debuff.
        mob:setLocalVar('RiftYellowProc', 1)
        local mdt = math.min(30, 10 + tier * 2) -- 12% T1 → 30% T10
        mob:addMod(xi.mod.DMGMAGIC, mdt)
        mob:timer(15000, function(m) m:delMod(xi.mod.DMGMAGIC, mdt) end)
        for _, p in pairs(instance:getChars()) do
            p:sys('[Rift] Yellow proc! The boss\'s next ability is suppressed and its magical defences weaken.')
        end

    elseif color == 3 then
        -- Blue: 12s PDT-down damage window.
        local pdt = math.min(40, 15 + tier * 3) -- 18% T1 → 45% T10
        mob:addMod(xi.mod.DMGPHYS, pdt)
        mob:timer(12000, function(m) m:delMod(xi.mod.DMGPHYS, pdt) end)
        for _, p in pairs(instance:getChars()) do
            p:sys('[Rift] Blue proc! The boss is exposed — damage window open for 12 seconds.')
        end

    elseif color == 1 then
        -- Red: extended Terror + strip one buff + increment White counter.
        local terrorDur = math.min(10000, 4000 + tier * 600)
        mob:addStatusEffect(xi.effect.TERROR, 0, 0, terrorDur / 1000)
        -- Strip the first dispellable status effect on the boss.
        local stripped = mob:dispelStatusEffect(xi.dispelType.MAGIC)
        for _, p in pairs(instance:getChars()) do
            if stripped then
                p:sys('[Rift] Red proc! The boss is staggered and loses a buff.')
            else
                p:sys('[Rift] Red proc! The boss is staggered.')
            end
        end

        -- Check if all three procs are now done → White.
        if  instance:getLocalVar('RIFT_YELLOW_DONE') == 1 and
            instance:getLocalVar('RIFT_BLUE_DONE')   == 1 and
            instance:getLocalVar('RIFT_WHITE_DONE')  == 0
        then
            instance:setLocalVar('RIFT_WHITE_DONE', 1)
            mob:weaknessTrigger(0) -- White !! animation (level 0)
            -- Permanent PDT/MDT-down for the rest of the fight.
            mob:addMod(xi.mod.UDMGPHYS,  20)
            mob:addMod(xi.mod.UDMGMAGIC, 20)
            mob:setLocalVar('RiftWhiteProc', 1)
            for _, p in pairs(instance:getChars()) do
                p:sys('[Rift] !! WHITE PROC !! The boss has been broken — its defences crumble!')
            end
        end
    end
end

-- Called from MAGIC_TAKE listener on the boss.
function xi.rift.checkMagicProc(mob, instance, spellId)
    if instance:getLocalVar('RIFT_YELLOW_DONE') == 1 then return end
    if spellId ~= instance:getLocalVar('RIFT_YELLOW_WEAK') then return end
    instance:setLocalVar('RIFT_YELLOW_DONE', 1)
    local tier = instance:getLocalVar('tier')
    fireBossProc(mob, instance, tier, 2)
end

-- Called from WEAPONSKILL_TAKE listener on the boss.
function xi.rift.checkWSProc(mob, instance, wsId)
    if instance:getLocalVar('RIFT_BLUE_DONE') == 1 then return end
    if wsId ~= instance:getLocalVar('RIFT_BLUE_WEAK') then return end
    instance:setLocalVar('RIFT_BLUE_DONE', 1)
    local tier = instance:getLocalVar('tier')
    fireBossProc(mob, instance, tier, 3)
end

-- Called from ABILITY_TAKE listener on the boss.
function xi.rift.checkJAProc(mob, instance, abilityId)
    if instance:getLocalVar('RIFT_RED_DONE') == 1 then return end
    if abilityId ~= instance:getLocalVar('RIFT_RED_WEAK') then return end
    instance:setLocalVar('RIFT_RED_DONE', 1)
    local tier = instance:getLocalVar('tier')
    fireBossProc(mob, instance, tier, 1)
end

-- Returns true if the Yellow proc is pending — checked before a TP move fires.
function xi.rift.consumeYellowInterrupt(mob)
    if mob:getLocalVar('RiftYellowProc') == 1 then
        mob:setLocalVar('RiftYellowProc', 0)
        return true
    end
    return false
end

-- Called from onInstanceComplete — grants bonus shard drop if White was achieved.
function xi.rift.procBonusDrop(instance, tier)
    if instance:getLocalVar('RIFT_WHITE_DONE') ~= 1 then return end
    for _, player in pairs(instance:getChars()) do
        xi.rift.rollDrops(player, tier, true) -- extra boss-quality shard roll
    end
end

-- ---------------------------------------------------------------------------
-- Per-floor randomised modifiers
--
-- Rolled at instance creation from xi.rift.FLOOR_MODIFIER_POOL and stored in
-- instance local vars RIFT_FMOD_1 .. RIFT_FMOD_N (numeric key index).
-- Higher tiers guarantee more modifier slots and draw from a harder sub-pool.
--
-- Modifier count by tier:
--   T1-3  : 0 guaranteed; 10 % chance of 1
--   T4-6  : 20 % chance of 1; 10 % chance of 2
--   T7-9  : 1 guaranteed; 30 % chance of 2nd
--   T10   : 2 guaranteed; 40 % chance of 3rd
-- ---------------------------------------------------------------------------

-- Numeric key index → modifier definition.
-- Each entry may define onMobInit(mob,tier), onBossInit(mob,tier), onTick(instance,elapsed,tier).
xi.rift.FLOOR_MODIFIER_POOL =
{
    -- 1: Double Attack — enemies strike twice frequently.
    {
        key         = 'DOUBLE_ATTACK',
        description = 'Enemies strike with uncanny speed, landing double blows.',
        onMobInit = function(mob, tier)
            mob:addMod(xi.mod.DOUBLE_ATTACK, 20 + tier * 3) -- 23 % T1 → 50 % T10
        end,
        onBossInit = function(mob, tier)
            mob:addMod(xi.mod.DOUBLE_ATTACK, 35 + tier * 3)
        end,
    },

    -- 2: Triple Attack — enemies sometimes land a triple strike.
    {
        key         = 'TRIPLE_ATTACK',
        description = 'Enemies unleash a flurry of three blows in rapid succession.',
        onMobInit = function(mob, tier)
            mob:addMod(xi.mod.TRIPLE_ATTACK, 10 + tier * 2) -- 12 % T1 → 30 % T10
        end,
        onBossInit = function(mob, tier)
            mob:addMod(xi.mod.TRIPLE_ATTACK, 20 + tier * 2)
        end,
    },

    -- 3: High Magic Accuracy — spells land more reliably.
    {
        key         = 'HIGH_MACC',
        description = 'Arcane forces within the Rift sharpen the magical precision of all enemies.',
        onMobInit = function(mob, tier)
            mob:addMod(xi.mod.MACC, 20 + tier * 5) -- +25 T1 → +70 T10
        end,
        onBossInit = function(mob, tier)
            mob:addMod(xi.mod.MACC, 40 + tier * 5)
        end,
    },

    -- 4: Quickened — attack delay is reduced.
    {
        key         = 'QUICKENED',
        description = 'Enemies move with preternatural swiftness; their blows fall without pause.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.HASTE, 15 + tier * 2)
        end,
        onBossInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.HASTE, 25 + tier * 2)
        end,
    },

    -- 5: Bloodlust — each kill heals the remaining enemies.
    {
        key         = 'BLOODLUST',
        description = 'Each fallen ally invigorates the remaining enemies.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.REGEN, 5 + tier * 2)
        end,
    },

    -- 6: Spellbound — enemies cast spells at elevated frequency.
    {
        key         = 'SPELLBOUND',
        description = 'The Rift resonates with magical energy, driving enemies to cast without restraint.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.MAGIC_COOL, math.max(10, 60 - tier * 5)) -- shorter recast
        end,
        onBossInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.MAGIC_COOL, math.max(5, 40 - tier * 4))
        end,
    },

    -- 7: TP Surge — enemies build TP rapidly and weaponskill often.
    {
        key         = 'TP_SURGE',
        description = 'Enemies pulse with battle energy, readying their deadliest attacks with haste.',
        onMobInit = function(mob, tier)
            mob:setMobMod(xi.mobMod.TP_MULTIPLIER, 130 + tier * 8)
        end,
    },

    -- 8: Ironhide — enemies shrug off a portion of all damage.
    {
        key         = 'IRONHIDE',
        description = 'A thick hide of crystallised void-energy makes these enemies difficult to bring down.',
        onMobInit = function(mob, tier)
            local dr = math.min(30, 10 + tier * 2)
            mob:addMod(xi.mod.UDMGPHYS,  -dr)
            mob:addMod(xi.mod.UDMGMAGIC, -dr)
        end,
        onBossInit = function(mob, tier)
            local dr = math.min(40, 20 + tier * 2)
            mob:addMod(xi.mod.UDMGPHYS,  -dr)
            mob:addMod(xi.mod.UDMGMAGIC, -dr)
        end,
    },
}

-- Build a lookup by numeric index for storage in instance local vars.
-- Keys 1-N map to entries in FLOOR_MODIFIER_POOL.

-- Rolls floor modifiers for a new instance and stores them in instance local vars.
-- Returns the list of active definitions so onInstanceCreated can announce them.
function xi.rift.rollFloorModifiers(instance, tier)
    -- Determine the number of modifier slots for this tier.
    local slots = 0
    if tier >= 10 then
        slots = 2
        if math.random(100) <= 40 then slots = 3 end
    elseif tier >= 7 then
        slots = 1
        if math.random(100) <= 30 then slots = 2 end
    elseif tier >= 4 then
        local roll = math.random(100)
        if     roll <= 10 then slots = 2
        elseif roll <= 30 then slots = 1
        end
    else -- T1-3
        if math.random(100) <= 10 then slots = 1 end
    end

    -- Pick `slots` distinct modifiers at random.
    local pool    = xi.rift.FLOOR_MODIFIER_POOL
    local indices = {}
    for i = 1, #pool do indices[i] = i end

    -- Shuffle (Fisher-Yates partial, stopping after `slots` picks).
    local chosen = {}
    for s = 1, slots do
        local remaining = #pool - s + 1
        local r = math.random(remaining)
        table.insert(chosen, pool[indices[r]])
        indices[r] = indices[remaining]
    end

    -- Store numeric IDs in instance local vars (1-indexed).
    for i, entry in ipairs(chosen) do
        -- Store the index in FLOOR_MODIFIER_POOL for reconstruction at mob-spawn time.
        -- We store the 1-based position of `entry` in the pool.
        for poolIdx, poolEntry in ipairs(pool) do
            if poolEntry == entry then
                instance:setLocalVar('RIFT_FMOD_' .. i, poolIdx)
                break
            end
        end
    end
    instance:setLocalVar('RIFT_FMOD_COUNT', slots)

    return chosen
end

-- Returns the list of active floor modifier definitions for an instance.
function xi.rift.getFloorModifiers(instance)
    local count = instance:getLocalVar('RIFT_FMOD_COUNT')
    local pool  = xi.rift.FLOOR_MODIFIER_POOL
    local result = {}
    for i = 1, count do
        local idx = instance:getLocalVar('RIFT_FMOD_' .. i)
        if idx > 0 and pool[idx] then
            result[#result + 1] = pool[idx]
        end
    end
    return result
end

-- Apply floor modifier mob-init hooks. Call alongside applyMobModifiers.
function xi.rift.applyFloorMobModifiers(mob, instance, tier)
    for _, mod in ipairs(xi.rift.getFloorModifiers(instance)) do
        if mod.onMobInit then
            mod.onMobInit(mob, tier)
        end
    end
end

-- Apply floor modifier boss-init hooks. Call alongside applyBossModifiers.
function xi.rift.applyFloorBossModifiers(mob, instance, tier)
    for _, mod in ipairs(xi.rift.getFloorModifiers(instance)) do
        if mod.onBossInit then
            mod.onBossInit(mob, tier)
        elseif mod.onMobInit then
            mod.onMobInit(mob, tier)
        end
    end
end

-- Run floor modifier tick hooks. Call alongside tickModifiers.
function xi.rift.tickFloorModifiers(instance, elapsed, tier)
    for _, mod in ipairs(xi.rift.getFloorModifiers(instance)) do
        if mod.onTick then
            mod.onTick(instance, elapsed, tier)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Rift Purveyor — shard storage and exchange
--
-- Shards are stored in player charvars rather than the actual inventory.
-- The player trades physical shard items to the Purveyor who adds them to
-- their stored balance. Trade-down and shop spend from this balance.
-- ---------------------------------------------------------------------------

xi.rift.PURVEYOR_VAR =
{
    [xi.rift.NASCENT_SHARD]  = 'RIFT_PURVEYOR_NASCENT',
    [xi.rift.TEMPERED_SHARD] = 'RIFT_PURVEYOR_TEMPERED',
    [xi.rift.FORGED_SHARD]   = 'RIFT_PURVEYOR_FORGED',
    [xi.rift.RESOLUTE_SHARD] = 'RIFT_PURVEYOR_RESOLUTE',
}

-- Friendly names used in NPC dialogue.
xi.rift.SHARD_NAME =
{
    [xi.rift.NASCENT_SHARD]  = 'Nascent Shard',
    [xi.rift.TEMPERED_SHARD] = 'Tempered Shard',
    [xi.rift.FORGED_SHARD]   = 'Forged Shard',
    [xi.rift.RESOLUTE_SHARD] = 'Resolute Shard',
}

-- Returns how many stored shards of a given item type the player has.
function xi.rift.getPurveyorBalance(player, itemId)
    local var = xi.rift.PURVEYOR_VAR[itemId]
    if not var then return 0 end
    return player:getCharVar(var)
end

-- Adds (or subtracts) stored shards of a given item type for the player.
function xi.rift.addPurveyorShards(player, itemId, amount)
    local var = xi.rift.PURVEYOR_VAR[itemId]
    if not var then return end
    local current = player:getCharVar(var)
    player:setCharVar(var, math.max(0, current + amount))
end

-- Trade-down rates: spending one higher shard produces this many lower shards.
-- 1 Resolute → 2 Forged, 1 Forged → 3 Tempered, 1 Tempered → 3 Nascent.
xi.rift.TRADE_DOWN =
{
    { from = xi.rift.RESOLUTE_SHARD, to = xi.rift.FORGED_SHARD,   ratio = 2 },
    { from = xi.rift.FORGED_SHARD,   to = xi.rift.TEMPERED_SHARD, ratio = 3 },
    { from = xi.rift.TEMPERED_SHARD, to = xi.rift.NASCENT_SHARD,  ratio = 3 },
}

-- Shop catalogue — items purchasable from the Purveyor, grouped by currency tier.
-- Each entry: { name = 'Display Name', item = xi.item.ID, cost = qty }
-- The currency used is implied by the sub-table key (nascent/tempered/forged).
-- Add entries to the relevant tier; no other changes needed.
xi.rift.PURVEYOR_SHOP =
{
    nascent =
    {
        { name = 'Keen Earring',      item = xi.item.KEEN_EARRING,      cost = 50 },
        { name = "Soldier's Ring",    item = xi.item.SOLDIERS_RING,     cost = 40 },
        { name = "Scholar's Collar",  item = xi.item.SCHOLARS_COLLAR,   cost = 50 },
        { name = "Tracker's Mantle",  item = xi.item.TRACKERS_MANTLE,   cost = 60 },
    },
    tempered =
    {
        { name = 'Fleetfoot Sollerets', item = xi.item.FLEETFOOT_SOLLERETS, cost = 30 },
        { name = 'Ironweave Cuisses',   item = xi.item.IRONWEAVE_CUISSES,   cost = 25 },
        { name = 'Ironguard Hauberk',   item = xi.item.IRONGUARD_HAUBERK,   cost = 35 },
        { name = "Duelist's Chain",     item = xi.item.DUELISTS_CHAIN,      cost = 30 },
    },
    forged =
    {
        { name = 'Ironveil Gauntlets', item = xi.item.IRONVEIL_GAUNTLETS, cost = 20 },
        { name = "Ranger's Surcoat",   item = xi.item.RANGERS_SURCOAT,    cost = 15 },
        { name = 'Hexweave Obi',       item = xi.item.HEXWEAVE_OBI,       cost = 18 },
    },
}

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
