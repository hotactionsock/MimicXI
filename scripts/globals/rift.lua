-----------------------------------
-- Rift System — shared utilities
-- Instanced content in Walk of Echoes, entered from Xarcabard.
-----------------------------------

xi = xi or {}
xi.rift = xi.rift or {}

-- Item players must possess to unlock tier 1.
-- TODO: Replace with a custom rift unlock item once defined.
xi.rift.UNLOCK_ITEM = xi.item.DARK_MATTER

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

-- ---------------------------------------------------------------------------
-- Leaderboard write
-- Called from onInstanceComplete with the elapsed time in milliseconds.
-- ---------------------------------------------------------------------------
function xi.rift.recordClear(instance, elapsedMs)
    local tier    = instance:getLocalVar('tier')
    local seconds = math.floor(elapsedMs / 1000)
    local season  = xi.serverVariable.get('RIFT_SEASON') or 1

    for _, player in pairs(instance:getChars()) do
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
end

-- ---------------------------------------------------------------------------
-- Mob death handler — called from each dynamic mob's onMobDeath.
-- Tracks remaining mobs; completes the instance when the boss dies.
-- ---------------------------------------------------------------------------
function xi.rift.onMobDeath(mob, instance)
    if not instance then return end

    if instance:getLocalVar('bossSpawned') == 0 then
        -- Regular mob killed; increment kill counter.
        local kills    = instance:getLocalVar('kills') + 1
        local required = instance:getLocalVar('killsRequired')
        instance:setLocalVar('kills', kills)

        if kills >= required then
            -- All regular mobs down — spawn the boss.
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
        end,

        onMobDeath = function(mob, player, optParams)
            xi.rift.onMobDeath(mob, instance)
        end,
    })
end

-- ---------------------------------------------------------------------------
-- Entry NPC — Rift Surveyor in Xarcabard
--
-- Tier selection: player enters at the highest tier they have unlocked + 1.
-- First-time players need xi.rift.UNLOCK_ITEM in inventory.
-- On success the player is teleported to Walk of Echoes; onZoneIn there
-- completes the instance load and layer entry.
-- ---------------------------------------------------------------------------
function xi.rift.onSurveyorTrigger(player, npc)
    local cleared = player:getCharVar(xi.rift.VAR_CLEARED)
    local tier    = math.min(cleared + 1, xi.rift.MAX_TIER)

    -- First-time players need the unlock item.
    if cleared == 0 and not player:hasItem(xi.rift.UNLOCK_ITEM) then
        -- TODO: Replace with a proper message ID once rift text strings are defined.
        player:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)
        return
    end

    -- Block re-entry if already inside an instance.
    if player:getInstance() then
        player:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)
        return
    end

    -- Store the chosen tier so onZoneIn in Walk of Echoes can read it.
    player:setLocalVar(xi.rift.VAR_PENDING, tier)

    -- Teleport the party to Walk of Echoes.
    -- onZoneIn will detect VAR_PENDING and complete the instance load + layer entry.
    local sp = xi.rift.SPAWN_POINTS[1] -- WoE entry anchor
    for _, member in pairs(player:getParty()) do
        if member:getZoneID() == player:getZoneID() then
            member:setPos(sp[1], sp[2], sp[3], sp[4], xi.zone.WALK_OF_ECHOES)
        end
    end
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
