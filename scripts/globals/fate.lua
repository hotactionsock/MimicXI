-----------------------------------
-- FATE System Engine
-- Global namespace: xi.fate
-- State is keyed by (zoneID, eventIdx) to support multiple concurrent FATEs per zone.
-----------------------------------
require('scripts/globals/npc_util')

xi      = xi      or {}
xi.fate = xi.fate or {}

-----------------------------------
-- Settings
-----------------------------------
xi.fate.settings =
{
    CHEST_DURATION   = 300,   -- seconds chest persists after resolution
    SCHEDULER_PERIOD = 60,    -- minimum seconds between scheduler ticks per zone
    DEFAULT_CHANCE   = 0.30,  -- default per-tick spawn probability
    DEFAULT_COOLDOWN = 600,   -- default seconds between FATEs in a zone
}

-- Zone event definitions — populated by fate_zones/ files
xi.fate.zones = {}

-- In-memory participant registry: [zoneID][eventIdx] = { [playerID] = true }
xi.fate.participants = {}

-- Players who have the FATETracker addon: [playerID] = true
-- Populated by !fateaddon register; cleared on zone-out / logout.
xi.fate.addonUsers = {}

-- Entry NPC entity references: [zoneID][eventIdx] = entity
xi.fate.entryNPCs = {}

-- Chest NPC entity references: [zoneID][eventIdx] = entity
xi.fate.chestNPCs = {}

-- Mob entity references: [zoneID][eventIdx] = { {entity, spawnPt}, ... }
xi.fate.mobEntities = {}

-- Scheduler rate limiter: [zoneID] = last tick unix timestamp
xi.fate.lastTick = {}

-- Leash rate limiter: [zoneID] = last leash check unix timestamp
xi.fate.lastLeashTick = {}

-- Superboss tombstone data (in-memory, lives as long as the tombstone NPC): [eventID] = data table
xi.fate.tombstones = {}

-- Collection-point NPC entity references: [zoneID][eventIdx] = { npc, npc, ... }
xi.fate.collectNPCs = {}

-----------------------------------
-- Internal constants
-----------------------------------
local STATE_IDLE     = 0
local STATE_ACTIVE   = 1
local STATE_COOLDOWN = 2
local STATE_PENDING  = 3  -- boss event selected, pre-announce timers running

local SCORE_MELEE   = 2
local SCORE_MAGIC   = 3
local SCORE_WS      = 5
local SCORE_ABILITY = 4
local SCORE_KILL    = 5

local BRONZE_THRESHOLD = 10
local SILVER_THRESHOLD = 40
local GOLD_THRESHOLD   = 100

local FATE_AREA_ID_BASE = 100

-----------------------------------
-- Server / char variable key helpers — all keyed by (zoneID, eventIdx)
-----------------------------------
local function stateKey(zoneID, eventIdx)    return string.format("[FATE][%d][%d]State",       zoneID, eventIdx) end
local function startKey(zoneID, eventIdx)    return string.format("[FATE][%d][%d]StartTime",   zoneID, eventIdx) end
local function killKey(zoneID, eventIdx)     return string.format("[FATE][%d][%d]KillCount",   zoneID, eventIdx) end
local function cooldownKey(zoneID, eventIdx) return string.format("[FATE][%d][%d]CooldownEnd", zoneID, eventIdx) end
local function victoryKey(zoneID, eventIdx)  return string.format("[FATE][%d][%d]Victory",     zoneID, eventIdx) end
local function regKey(zoneID, eventIdx)      return string.format("[FATE][%d][%d]Registered",  zoneID, eventIdx) end
local function scoreKey(zoneID, eventIdx)    return string.format("[FATE][%d][%d]Score",       zoneID, eventIdx) end
local function bandKey(zoneID, eventIdx)     return string.format("[FATE][%d][%d]Band",        zoneID, eventIdx) end
local function lootedKey(zoneID, eventIdx)   return string.format("[FATE][%d][%d]Looted",      zoneID, eventIdx) end
local function progressKey(id)               return string.format("[FATE][%d]Progress",        id) end  -- per-zone cumulative
local function scaleKey(zoneID, eventIdx)    return string.format("[FATE][%d][%d]ScaleN",      zoneID, eventIdx) end

local MAX_LOOT_SLOTS = 5
local function lootCountKey(zoneID, eventIdx)      return string.format("[FATE][%d][%d]LootN",   zoneID, eventIdx) end
local function lootIdxKey(zoneID, eventIdx)        return string.format("[FATE][%d][%d]LootIdx",  zoneID, eventIdx) end
local function lootSlotKey(zoneID, eventIdx, slot) return string.format("[FATE][%d][%d]Loot%d",   zoneID, eventIdx, slot) end

-----------------------------------
-- Superboss server-variable keys
-----------------------------------
local function sbGlobalCoolKey(id)   return string.format("[SBOSS][%s]LastKill",      id)       end  -- server var
local function sbPrereqKey(id)       return string.format("[FATE][%s]LastComplete",   id)       end  -- server var, also set for regular FATE bosses
local function sbEnrageStartKey(z,i) return string.format("[SBOSS][%d][%d]EnrStart",  z, i)    end  -- server var, 0 = not started
local function sbEnragedKey(z,i)     return string.format("[SBOSS][%d][%d]Enraged",   z, i)    end  -- server var
local function sbWaveKey(z,i)        return string.format("[SBOSS][%d][%d]Wave",       z, i)    end  -- volatile, current wave index
local function sbRageKey(z,i)        return string.format("[SBOSS][%d][%d]Rage",       z, i)    end  -- volatile, rage stack count
local function sbPersonalCoolKey(id) return string.format("[SBOSS][%s]Personal",      id)      end  -- char var, last loot timestamp

local function momentumKey(z)        return string.format("[FATE][%d]Streak",          z)        end  -- server var, consecutive victories
local function dynDiffKey(z, i)      return string.format("[FATE][%d][%d]DynDiff",     z, i)     end  -- server var, dynamic difficulty tier
local function collectCountKey(z, i) return string.format("[FATE][%d][%d]CollectN",    z, i)     end  -- char var, personal collection count

-----------------------------------
-- Scaling
-- hpPct / dmgPct passed directly to HP_SCALE and BASE_DAMAGE_MULTIPLIER mob mods.
-- HP_SCALE: (value/100) * base maxHP.  100=1x, 150=1.5x, 200=2x.
-- BASE_DAMAGE_MULTIPLIER: (value/100) * base damage.  100=1x, 115=1.15x.
-----------------------------------
local SCALE_CAP = 6  -- clamp participant count so scaling doesn't spiral

xi.fate.getScaleN = function(zoneID, eventIdx)
    return math.max(1, math.min(SCALE_CAP, GetServerVariable(scaleKey(zoneID, eventIdx))))
end

-- Returns the EXP bonus multiplier (0.0–0.30) from the zone's consecutive-victory streak.
xi.fate.getMomentumBonus = function(zoneID)
    local streak = GetServerVariable(momentumKey(zoneID))
    if     streak >= 8 then return 0.30
    elseif streak >= 5 then return 0.20
    elseif streak >= 3 then return 0.10
    else                     return 0
    end
end

-----------------------------------
-- State queries
-----------------------------------
xi.fate.isActive = function(zoneID, eventIdx)
    return GetServerVariable(stateKey(zoneID, eventIdx)) == STATE_ACTIVE
end

-- Returns the eventDef table for a given slot (direct lookup, no server var needed).
xi.fate.getEventDef = function(zoneID, eventIdx)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return nil end
    return zoneData.events[eventIdx]
end

xi.fate.getLevel = function(zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    return def and def.level or 0
end

xi.fate.getRemaining = function(zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return 0 end
    local elapsed = GetSystemTime() - GetServerVariable(startKey(zoneID, eventIdx))
    return math.max(0, def.duration - elapsed)
end

-----------------------------------
-- Job weight table
-----------------------------------
xi.fate.jobWeights =
{
    [xi.job.WAR] = { melee = 2.0, ws = 2.0, magic = 0.5, ability = 1.0, heal = 0.3 },
    [xi.job.MNK] = { melee = 2.5, ws = 2.0, magic = 0.3, ability = 1.5, heal = 0.3 },
    [xi.job.WHM] = { melee = 0.3, ws = 0.5, magic = 1.5, ability = 1.5, heal = 3.0 },
    [xi.job.BLM] = { melee = 0.2, ws = 0.5, magic = 3.0, ability = 1.0, heal = 0.2 },
    [xi.job.RDM] = { melee = 0.8, ws = 1.0, magic = 2.0, ability = 1.5, heal = 1.5 },
    [xi.job.THF] = { melee = 1.5, ws = 2.5, magic = 0.5, ability = 2.0, heal = 0.2 },
    [xi.job.PLD] = { melee = 1.5, ws = 1.5, magic = 0.8, ability = 1.5, heal = 0.5 },
    [xi.job.DRK] = { melee = 1.8, ws = 2.0, magic = 1.0, ability = 1.5, heal = 0.2 },
    [xi.job.BST] = { melee = 1.0, ws = 1.0, magic = 0.5, ability = 2.0, heal = 0.3 },
    [xi.job.BRD] = { melee = 0.5, ws = 0.8, magic = 1.0, ability = 2.5, heal = 1.0 },
    [xi.job.RNG] = { melee = 1.0, ws = 2.5, magic = 0.5, ability = 1.5, heal = 0.2 },
    [xi.job.SAM] = { melee = 1.8, ws = 2.5, magic = 0.3, ability = 1.5, heal = 0.2 },
    [xi.job.NIN] = { melee = 1.8, ws = 2.0, magic = 1.0, ability = 2.0, heal = 0.2 },
    [xi.job.DRG] = { melee = 2.0, ws = 2.0, magic = 0.3, ability = 1.5, heal = 0.3 },
    [xi.job.SMN] = { melee = 0.3, ws = 0.5, magic = 2.5, ability = 2.0, heal = 0.5 },
    [xi.job.BLU] = { melee = 1.5, ws = 1.5, magic = 2.0, ability = 1.5, heal = 0.5 },
    [xi.job.COR] = { melee = 0.8, ws = 1.5, magic = 0.5, ability = 2.5, heal = 0.3 },
    [xi.job.PUP] = { melee = 1.0, ws = 1.5, magic = 0.5, ability = 2.5, heal = 0.3 },
    [xi.job.DNC] = { melee = 1.8, ws = 1.8, magic = 0.3, ability = 2.0, heal = 1.0 },
    [xi.job.SCH] = { melee = 0.3, ws = 0.5, magic = 2.5, ability = 2.0, heal = 2.0 },
    [xi.job.GEO] = { melee = 0.3, ws = 0.5, magic = 2.0, ability = 2.5, heal = 0.5 },
    [xi.job.RUN] = { melee = 1.5, ws = 1.5, magic = 1.0, ability = 2.0, heal = 0.5 },
}

local defaultWeights = { melee = 1.0, ws = 1.0, magic = 1.0, ability = 1.0, heal = 1.0 }

local function getWeight(player, actionType)
    local w = xi.fate.jobWeights[player:getMainJob()] or defaultWeights
    return w[actionType] or 1.0
end

-----------------------------------
-- Contribution scoring
-----------------------------------
xi.fate.addScore = function(player, zoneID, eventIdx, actionType, basePoints)
    if not xi.fate.isActive(zoneID, eventIdx) then return end
    if player:getCharVar(regKey(zoneID, eventIdx)) == 0 then return end
    local points = math.max(1, math.floor(basePoints * getWeight(player, actionType)))
    player:incrementCharVar(scoreKey(zoneID, eventIdx), points)
end

xi.fate.onMagic   = function(caster, spell, zoneID, eventIdx)   if caster:isPC() then xi.fate.addScore(caster, zoneID, eventIdx, "magic",   SCORE_MAGIC)   end end
xi.fate.onAbility = function(player, ability, zoneID, eventIdx)  xi.fate.addScore(player, zoneID, eventIdx, "ability", SCORE_ABILITY) end
xi.fate.onWS      = function(player, wsID, zoneID, eventIdx)     xi.fate.addScore(player, zoneID, eventIdx, "ws",      SCORE_WS)      end
xi.fate.onMelee   = function(target, zoneID, eventIdx)           end

xi.fate.calcBand = function(score)
    if score >= GOLD_THRESHOLD   then return 3 end
    if score >= SILVER_THRESHOLD then return 2 end
    if score >= BRONZE_THRESHOLD then return 1 end
    return 0
end

-----------------------------------
-- Registration
-----------------------------------
-- Wire format: FJOIN|eventID
-- Sent once, right after a successful registration. This is a hidden marker,
-- not a chat message for players to read — the FatePopup Ashita4 addon
-- intercepts and blocks it before it reaches the chat log, then renders a
-- custom banner. Players without the addon will simply see this raw line in
-- their SYSTEM_3 chat, same tradeoff as the existing FSYNC marker below.
xi.fate.announceJoin = function(player, zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return end
    player:printToPlayer(string.format("[FATE] You have joined %s!", def.name), xi.msg.channel.SYSTEM_3)
    player:printToPlayer(string.format('FJOIN|%s', def.id), xi.msg.channel.SYSTEM_3)
end

-- Wire format: FCOMPLETE|eventID
-- Hidden marker, same pattern as FJOIN above. Sent once per registered
-- participant when their FATE resolves in victory (see xi.fate.resolve()) —
-- the FatePopup addon intercepts it, blocks it from chat, and plays a
-- completion banner + sound instead.
xi.fate.announceComplete = function(player, def)
    player:printToPlayer(string.format('FCOMPLETE|%s', def.id), xi.msg.channel.SYSTEM_3)
end

-- Wire format: FFAIL|eventID
-- Hidden marker, same pattern as FCOMPLETE above. Sent once per registered
-- participant when their FATE resolves in failure.
xi.fate.announceFailure = function(player, def)
    player:printToPlayer(string.format('FFAIL|%s', def.id), xi.msg.channel.SYSTEM_3)
end

xi.fate.register = function(player, zoneID, eventIdx)
    if player:getCharVar(regKey(zoneID, eventIdx)) == 1 then return false end
    player:setCharVar(regKey(zoneID, eventIdx), 1)
    xi.fate.participants[zoneID]                              = xi.fate.participants[zoneID] or {}
    xi.fate.participants[zoneID][eventIdx]                    = xi.fate.participants[zoneID][eventIdx] or {}
    xi.fate.participants[zoneID][eventIdx][player:getID()]    = true

    -- Persistent participation tracking
    player:incrementCharVar('[FATE]Participated', 1)
    player:incrementCharVar(string.format('[FATE][%d]Participated', zoneID), 1)
    if player:getCharVar('[FATE]FirstDate') == 0 then
        player:setCharVar('[FATE]FirstDate', GetSystemTime())
    end

    xi.fate.applySync(player, zoneID, eventIdx)
    xi.fate.sendEventSync(player, zoneID, eventIdx)
    xi.fate.announceJoin(player, zoneID, eventIdx)
    return true
end

xi.fate.findRegisteredPlayer = function(zoneID, eventIdx)
    local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx]
    for playerID in pairs(pool or {}) do
        if PlayerHasValidSession(playerID) then
            local p = GetPlayerByID(playerID)
            if p then return p end
        end
    end
    return nil
end

-----------------------------------
-- Level sync
-----------------------------------
xi.fate.applySync = function(player, zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if def and def.noSync then return end  -- superboss: open to all levels, no restriction
    local level = xi.fate.getLevel(zoneID, eventIdx)
    -- Use >= so players signing up exactly at the cap are also restricted.
    -- If they were already at level N the restriction has no effect on stats,
    -- but it prevents the engine from letting them play above N if they gain EXP mid-fight.
    if level > 0 and player:getMainLvl() >= level then
        player:addStatusEffect(xi.effect.LEVEL_RESTRICTION, { power = level, origin = player })
    end
end

xi.fate.removeSync = function(player)
    if player:hasStatusEffect(xi.effect.LEVEL_RESTRICTION) then
        player:delStatusEffect(xi.effect.LEVEL_RESTRICTION)
        player:printToPlayer("Your level is no longer restricted.", xi.msg.channel.SYSTEM_3)
    end
end

xi.fate.checkSyncOnZoneIn = function(player)
    local zoneID   = player:getZoneID()
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx = 1, #zoneData.events do
        if xi.fate.isActive(zoneID, eventIdx) and player:getCharVar(regKey(zoneID, eventIdx)) == 1 then
            xi.fate.applySync(player, zoneID, eventIdx)
            return
        end
    end
end

-----------------------------------
-- Trigger area callbacks
-----------------------------------
xi.fate.onAreaEnter = function(player, triggerArea, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    local areaID = triggerArea:getTriggerAreaID()
    for eventIdx, eventDef in ipairs(zoneData.events) do
        if eventDef.triggerAreaID == areaID then
            if xi.fate.isActive(zoneID, eventIdx) then
                -- Only re-apply sync for players who already signed up (e.g. left and returned).
                -- New players must sign up via the herald NPC; do NOT auto-register here.
                if player:getCharVar(regKey(zoneID, eventIdx)) == 1 then
                    xi.fate.applySync(player, zoneID, eventIdx)
                end
            end
            return
        end
    end
end

xi.fate.onAreaLeave = function(player, triggerArea, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    local areaID = triggerArea:getTriggerAreaID()
    for _, eventDef in ipairs(zoneData.events) do
        if eventDef.triggerAreaID == areaID then
            xi.fate.removeSync(player)
            return
        end
    end
end

xi.fate.isInArea = function(player, zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return false end
    local dx = player:getXPos() - def.area[1]
    local dz = player:getZPos() - def.area[3]
    return (dx * dx + dz * dz) <= (def.area[4] * def.area[4])
end

-----------------------------------
-- Addon user registry
-----------------------------------
xi.fate.registerAddonUser = function(player)
    xi.fate.addonUsers[player:getID()] = true
    xi.fate.sendAddonSync(player, player:getZoneID())
end

xi.fate.unregisterAddonUser = function(playerID)
    xi.fate.addonUsers[playerID] = nil
end

-- Sends FSYNC|eventIdx to every registered addon user currently in zoneID.
xi.fate.broadcastEventSync = function(zoneID, eventIdx)
    for charID in pairs(xi.fate.addonUsers) do
        local target = GetPlayerByID(charID)
        if target and target:getZoneID() == zoneID then
            xi.fate.sendEventSync(target, zoneID, eventIdx)
        end
    end
end

-----------------------------------
-- Addon sync (FATETracker Ashita4 addon)
-- Sends a machine-readable FSYNC| line to the player via SYSTEM_3.
-- The addon intercepts and blocks these before they reach the chat window.
-- Wire format: FSYNC|zoneID|eventIdx|state|remaining|kills|target|registered|band
-----------------------------------
local function buildFSYNCMsg(player, zoneID, eventIdx)
    local def   = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return nil end
    local state = GetServerVariable(stateKey(zoneID, eventIdx))
    local kills = GetVolatileServerVariable(killKey(zoneID, eventIdx))
    local target = def.objective and def.objective.count or 0
    local reg    = player:getCharVar(regKey(zoneID, eventIdx))
    local band   = player:getCharVar(bandKey(zoneID, eventIdx))
    local remaining = 0
    if state == STATE_ACTIVE then
        remaining = xi.fate.getRemaining(zoneID, eventIdx)
    elseif state == STATE_COOLDOWN then
        remaining = math.max(0, GetServerVariable(cooldownKey(zoneID, eventIdx)) - GetSystemTime())
    end
    return string.format('FSYNC|%d|%d|%d|%d|%d|%d|%d|%d',
        zoneID, eventIdx, state, remaining, kills, target, reg, band)
end

xi.fate.sendEventSync = function(player, zoneID, eventIdx)
    local msg = buildFSYNCMsg(player, zoneID, eventIdx)
    if msg then
        player:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
    end
end

xi.fate.sendAddonSync = function(player, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx = 1, #zoneData.events do
        xi.fate.sendEventSync(player, zoneID, eventIdx)
    end
end

-- Sends FDEFZ + one FDEF per event to a single player.
-- Wire formats:
--   FDEFZ|zoneID|zoneName
--   FDEF|zoneID|eventIdx|level|chainOnly|entryX|entryY|entryZ|name
xi.fate.sendAddonDef = function(player, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    player:printToPlayer(string.format('FDEFZ|%d|%s', zoneID, zoneData.zoneName), xi.msg.channel.SYSTEM_3)
    for eventIdx, def in ipairs(zoneData.events) do
        player:printToPlayer(string.format('FDEF|%d|%d|%d|%d|%.3f|%.3f|%.3f|%s',
            zoneID, eventIdx, def.level, def.chainOnly and 1 or 0,
            def.entryPos[1], def.entryPos[2], def.entryPos[3], def.name),
            xi.msg.channel.SYSTEM_3)
    end
end

-----------------------------------
-- Notification
-----------------------------------
xi.fate.notify = function(zone, eventDef, zoneID, eventIdx)
    local n         = xi.fate.getScaleN(zoneID, eventIdx)
    local scaleStr  = n > 1 and string.format(" [%dp scale]", n) or ""
    local stars   = eventDef.superboss and 5 or (eventDef.isBoss and (eventDef.bossStars or 1) or 0)
    local bossStr = stars > 0 and (string.rep(string.char(0x81, 0x9A), stars) .. " ") or ""
    local posStr = eventDef.mapPos and string.format(" at (%s)", eventDef.mapPos) or ""
    local msg = string.format("[FATE] %s%s (Lv%d)%s has begun! Approach the marker%s to participate.", bossStr, eventDef.name, eventDef.level, scaleStr, posStr)
    for _, player in pairs(zone:getPlayers()) do
        player:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
    end
    SetVolatileServerVariable(string.format("[FATE][%d][%d]Notify", zoneID, eventIdx), GetSystemTime())
end

-----------------------------------
-- Mob entity name helper
-----------------------------------
local function mobEntityName(eventID, groupIdx, mobIdx)
    return string.format("FATE_%s_%d_%d", eventID, groupIdx, mobIdx)
end

-----------------------------------
-- Mob management
-----------------------------------
xi.fate.spawnMobs = function(zoneID, eventIdx)
    local mobs = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not mobs then return end
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return end
    local n      = xi.fate.getScaleN(zoneID, eventIdx)
    local hpPct  = 100 + (n - 1) * 50
    local dmgPct = 100 + (n - 1) * 15

    if def.isBoss then
        local stars = def.bossStars or 1
        if stars == 2 then
            hpPct  = math.floor(hpPct  * 2)
            dmgPct = math.floor(dmgPct * 1.9)
        elseif stars >= 3 then
            hpPct  = math.floor(hpPct  * 3)
            dmgPct = math.floor(dmgPct * 2.5)
        end
    end

    if def.dynamicDifficulty then
        local tier = GetServerVariable(dynDiffKey(zoneID, eventIdx))
        if tier > 0 then
            hpPct  = math.min(hpPct  + tier * 20, 400)
            dmgPct = math.min(dmgPct + tier * 15, 300)
        end
    end

    -- Re-randomize shared spawn point assignments each activation so mob placement
    -- varies between runs of the same event.
    if def.sharedSpawnPoints and #def.sharedSpawnPoints > 0 then
        local pool = {}
        for _, pt in ipairs(def.sharedSpawnPoints) do
            pool[#pool + 1] = pt
        end
        for j = #pool, 2, -1 do
            local k = math.random(j)
            pool[j], pool[k] = pool[k], pool[j]
        end
        for mobIdx, entry in ipairs(mobs) do
            entry.spawnPt = pool[((mobIdx - 1) % #pool) + 1]
        end
    end

    for _, entry in ipairs(mobs) do
        xi.fate.spawnMobEntry(entry, hpPct, dmgPct, eventIdx, zoneID, def)
    end
end

-- Spawn a single mob entry with the given scaling percentages.
-- Shared by spawnMobs (regular FATEs) and spawnWave (superboss waves).
xi.fate.spawnMobEntry = function(entry, hpPct, dmgPct, eventIdx, zoneID, def)
    local mob = entry.entity
    if not mob or mob:isSpawned() then return end

    -- targetHP/targetDmg express desired stats at 1-player 1-star baseline;
    -- hpPct/dmgPct (which already fold in star multipliers and player count)
    -- are applied on top so scaling behaves identically to the multiplier path.
    local hpScale, dmgScale
    if entry.targetHP and entry.nativeHP and entry.nativeHP > 0 then
        hpScale = math.max(1, math.floor(entry.targetHP * hpPct / entry.nativeHP))
    else
        hpScale = hpPct * (entry.hpMultiplier or 1)
    end
    if entry.targetDmg then
        dmgScale = math.max(1, math.floor(entry.targetDmg * dmgPct / 100))
    else
        dmgScale = dmgPct * (entry.dmgMultiplier or 1)
    end

    mob:setMobMod(xi.mobMod.HP_SCALE,               hpScale)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, dmgScale)
    mob:setSpawn(entry.spawnPt[1], entry.spawnPt[2], entry.spawnPt[3], entry.spawnPt[4] or 0)
    mob:setDropID(0)
    DisallowRespawn(mob:getID(), false)
    mob:spawn()
    mob:setLocalVar("fateEventIdx", eventIdx)
    mob:setLocalVar("fateZoneID",   zoneID)
    mob:setMobLevel(def.level)
    mob:setLocalVar("NO_CASKET", 1)
    mob:setCallForHelpBlocked(true)
    mob:setRespawnTime(30)
    mob:setHP(mob:getMaxHP())
    mob:updateHealth()

    if entry.isBoss and def.superboss then
        mob:setLocalVar("sbPhase", 0)
    end
end

-- Spawn all mob entries belonging to a specific wave index.
-- Called by activate() for wave 1 and by checkWaveCleared() for subsequent waves.
xi.fate.spawnWave = function(zoneID, eventIdx, waveIdx)
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    local def     = xi.fate.getEventDef(zoneID, eventIdx)
    if not entries or not def then return end

    SetVolatileServerVariable(sbWaveKey(zoneID, eventIdx), waveIdx)

    local waves = def.waves
    if waves and waves[waveIdx] and waves[waveIdx].announcement then
        local zone = GetZone(zoneID)
        if zone then
            for _, p in pairs(zone:getPlayers()) do
                p:printToPlayer("[FATE] " .. waves[waveIdx].announcement, xi.msg.channel.SYSTEM_3)
            end
        end
    end

    local n      = xi.fate.getScaleN(zoneID, eventIdx)
    local hpPct  = 100 + (n - 1) * 50
    local dmgPct = 100 + (n - 1) * 15

    for _, entry in ipairs(entries) do
        if entry.waveIdx == waveIdx then
            xi.fate.spawnMobEntry(entry, hpPct, dmgPct, eventIdx, zoneID, def)
        end
    end
end

-- Called when all non-boss mobs of waveIdx are dead; advances to the next wave.
xi.fate.checkWaveCleared = function(zoneID, eventIdx, waveIdx)
    if not waveIdx then return end
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not entries then return end
    for _, entry in ipairs(entries) do
        if entry.waveIdx == waveIdx and not entry.isBoss and entry.entity:isSpawned() then
            return  -- wave still has live mobs
        end
    end
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if def and def.waves and waveIdx < #def.waves then
        xi.fate.spawnWave(zoneID, eventIdx, waveIdx + 1)
    end
end

xi.fate.sweepMobs = function(zoneID, eventIdx)
    local mobs = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not mobs then return end
    for _, entry in ipairs(mobs) do
        local mob = entry.entity
        if mob and mob:isSpawned() then
            DisallowRespawn(mob:getID(), true)
            DespawnMob(mob:getID())
        end
    end
end

xi.fate.leashMobs = function(zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end

    for eventIdx, def in ipairs(zoneData.events) do
        if not xi.fate.isActive(zoneID, eventIdx) then goto continue end

        local mobs = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
        if not mobs then goto continue end

        local area = def.area
        local r2   = area[4] * area[4]

        for _, entry in ipairs(mobs) do
            local mob = entry.entity
            if mob and mob:isSpawned() then
                local dx = mob:getXPos() - area[1]
                local dz = mob:getZPos() - area[3]
                if (dx * dx + dz * dz) > r2 then
                    local sp = entry.spawnPt
                    DisallowRespawn(mob:getID(), true)
                    DespawnMob(mob:getID())
                    mob:setSpawn(sp[1], sp[2], sp[3], sp[4] or 0)
                    mob:timer(3000, function(m)
                        local zID = m:getLocalVar("fateZoneID")
                        local i   = m:getLocalVar("fateEventIdx")
                        if not xi.fate.isActive(zID, i) then return end
                        DisallowRespawn(m:getID(), false)
                        m:spawn()
                        m:setHP(m:getMaxHP())
                        m:updateHealth()
                    end)
                end
            end
        end

        ::continue::
    end
end

-- Quickly respawn a mob at a random spawn point in its event pool.
-- Used for non-counting kills so the FATE pool stays full for registered players.
xi.fate.quickRespawn = function(mob, zoneID, eventIdx)
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if entries and #entries > 0 then
        local pt = entries[math.random(#entries)].spawnPt
        mob:setSpawn(pt[1], pt[2], pt[3], pt[4] or 0)
    end
    mob:timer(20000, function(m)
        local zID = m:getLocalVar("fateZoneID")
        local i   = m:getLocalVar("fateEventIdx")
        if not xi.fate.isActive(zID, i) then return end
        local def = xi.fate.getEventDef(zID, i)
        m:spawn()
        m:setLocalVar("fateEventIdx", i)
        m:setLocalVar("fateZoneID",   zID)
        m:setDropID(0)
        m:setLocalVar("NO_CASKET", 1)
        m:setCallForHelpBlocked(true)
        DisallowRespawn(m:getID(), false)
        if def then m:setMobLevel(def.level) end
        m:setHP(m:getMaxHP())
        m:updateHealth()
    end)
end

xi.fate.onKill = function(mob, player, zoneID, eventIdx)
    if not xi.fate.isActive(zoneID, eventIdx) then return end

    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return end

    -- EXP is credited by the engine before onMobDeath fires, so check here
    -- for any participant who just levelled up over the FATE cap and lock them.
    local fateLevel = def.level
    if fateLevel > 0 then
        local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx]
        for playerID in pairs(pool or {}) do
            if PlayerHasValidSession(playerID) then
                local p = GetPlayerByID(playerID)
                if p and p:getMainLvl() >= fateLevel and not p:hasStatusEffect(xi.effect.LEVEL_RESTRICTION) then
                    p:addStatusEffect(xi.effect.LEVEL_RESTRICTION, { power = fateLevel, origin = p })
                    p:printToPlayer(
                        string.format("[FATE] Your level has been restricted to %d for this FATE.", fateLevel),
                        xi.msg.channel.SYSTEM_3
                    )
                end
            end
        end
    end

    local kills = GetVolatileServerVariable(killKey(zoneID, eventIdx)) + 1
    SetVolatileServerVariable(killKey(zoneID, eventIdx), kills)

    xi.fate.addScore(player, zoneID, eventIdx, "ws", SCORE_KILL)

    local target = def.objective.count
    xi.fate.broadcastEventSync(zoneID, eventIdx)
    local zone   = GetZone(zoneID)
    if zone then
        local prev = kills - 1
        for _, pct in ipairs({ 25, 50, 75 }) do
            local threshold = math.max(1, math.floor(target * pct / 100))
            if prev < threshold and kills >= threshold then
                local msg = string.format("[FATE] %s - %d%% complete! (%d/%d)", def.name, pct, kills, target)
                for _, p in pairs(zone:getPlayers()) do
                    p:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
                end
                break
            end
        end
    end

    -- Collect FATEs run for their full duration regardless of mob kills.
    local objType = def.objective and def.objective.type or "kill"
    if kills >= target and objType ~= "collect" then
        xi.fate.resolve(zoneID, eventIdx, true)
    end
end

-----------------------------------
-- Collection FATE handler
-----------------------------------
xi.fate.onCollect = function(player, npc, zoneID, eventIdx)
    if not xi.fate.isActive(zoneID, eventIdx) then return end
    if npc:getLocalVar("fateCollected") == 1 then return end

    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return end

    -- Auto-register on first interaction (collect FATEs are open-world).
    if player:getCharVar(regKey(zoneID, eventIdx)) ~= 1 then
        xi.fate.register(player, zoneID, eventIdx)
    end

    -- Mark this point as taken; it will respawn after 15 seconds.
    npc:setLocalVar("fateCollected", 1)
    npc:setStatus(xi.status.DISAPPEAR)

    -- Give the collection item directly to the player.
    if def.collectItem then
        if player:getFreeSlotsCount() > 0 then
            npcUtil.giveItem(player, def.collectItem)
        else
            player:printToPlayer("[FATE] Your inventory is full — collection item lost!", xi.msg.channel.SYSTEM_3)
        end
    end

    -- Track each player's personal collection count (determines their tier at resolution).
    player:incrementCharVar(collectCountKey(zoneID, eventIdx), 1)
    local personal = player:getCharVar(collectCountKey(zoneID, eventIdx))

    xi.fate.addScore(player, zoneID, eventIdx, "ws", SCORE_KILL)
    xi.fate.broadcastEventSync(zoneID, eventIdx)

    -- Show this player their personal progress and current tier standing.
    local tiers = def.collectTiers or { gold = 10, silver = 5, bronze = 1 }
    local tier
    if     personal >= tiers.gold   then tier = "Gold"
    elseif personal >= tiers.silver then tier = "Silver"
    elseif personal >= tiers.bronze then tier = "Bronze"
    end
    if tier then
        player:printToPlayer(
            string.format("[FATE] %s recovered — %d collected. Tier: %s!", def.collectName or "Item", personal, tier),
            xi.msg.channel.SYSTEM_3)
    else
        player:printToPlayer(
            string.format("[FATE] %s recovered — %d collected. Reach %d for Bronze.",
                def.collectName or "Item", personal, tiers.bronze),
            xi.msg.channel.SYSTEM_3)
    end

    -- Respawn this collection point after 15 seconds (if FATE still active).
    npc:timer(15000, function(n)
        local zID = n:getLocalVar("fateZoneID")
        local i   = n:getLocalVar("fateEventIdx")
        if xi.fate.isActive(zID, i) then
            n:setLocalVar("fateCollected", 0)
            n:setStatus(xi.status.NORMAL)
        end
    end)
end

-----------------------------------
-- Loot chest
-----------------------------------
xi.fate.openChest = function(player, npc)
    local zoneID   = player:getZoneID()
    local eventIdx = npc:getLocalVar("fateEventIdx")

    if npc:getLocalVar("fateActive") ~= 1 then
        player:printToPlayer("There is nothing here for you.", xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getCharVar(regKey(zoneID, eventIdx)) == 0 then
        player:printToPlayer("You did not participate in this FATE.", xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getCharVar(lootedKey(zoneID, eventIdx)) == 1 then
        player:printToPlayer("You have already claimed your reward.", xi.msg.channel.SYSTEM_3)
        return
    end

    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return end

    -- Superboss personal kill cooldown: participation and EXP are still awarded but loot is gated.
    if def.superboss and def.killCooldown then
        local lastKill = player:getCharVar(sbPersonalCoolKey(def.id))
        if lastKill > 0 and GetSystemTime() - lastKill < def.killCooldown then
            local days = math.ceil((def.killCooldown - (GetSystemTime() - lastKill)) / 86400)
            player:printToPlayer(string.format("[FATE] You may not claim spoils from %s again for %d day(s).", def.name, days), xi.msg.channel.SYSTEM_3)
            return
        end
    end

    npc:setAnimation(xi.anim.OPEN_DOOR)

    -- Items are rolled exactly once on first open and stored in char vars.
    -- Re-opens after a full inventory resume from the next pending slot.
    local stored = player:getCharVar(lootCountKey(zoneID, eventIdx))
    if stored == 0 then
        local band    = player:getCharVar(bandKey(zoneID, eventIdx))
        local victory = npc:getLocalVar("fateVictory") == 1
        local rolled  = {}

        if def.loot then
            local pools = victory and def.loot.victory or def.loot.fail
            if pools then
                for _, itemID in ipairs(pools.guaranteed or {}) do
                    table.insert(rolled, itemID)
                end
                local mults     = xi.mimic.bonus.getMultipliers()
                local dropBase  = math.floor(mults.drop)
                local dropFrac  = mults.drop - dropBase
                local function rollInto(pool)
                    for _, entry in ipairs(pool) do
                        local passes = dropBase + (math.random() < dropFrac and 1 or 0)
                        for _ = 1, passes do
                            if math.random(1, 1000) <= entry[2] then
                                table.insert(rolled, entry[1])
                            end
                        end
                    end
                end
                if band >= 1 then rollInto(pools.bronze or {}) end
                if band >= 2 then rollInto(pools.silver or {}) end
                if band >= 3 then rollInto(pools.gold   or {}) end

                -- Merge regional loot on top of per-event loot (victory only)
                if victory and band >= 1 then
                    local zoneData = xi.fate.zones[zoneID]
                    local regionPool = zoneData and zoneData.region and xi.fate.regions and xi.fate.regions[zoneData.region]
                    if regionPool and regionPool.loot and regionPool.loot.victory then
                        local rp = regionPool.loot.victory
                        if band >= 1 then rollInto(rp.bronze or {}) end
                        if band >= 2 then rollInto(rp.silver or {}) end
                        if band >= 3 then rollInto(rp.gold   or {}) end
                    end
                end

                if #rolled == 0 then
                    local fallback
                    if     band >= 3 and pools.gold   and #pools.gold   > 0 then fallback = pools.gold
                    elseif band >= 2 and pools.silver and #pools.silver > 0 then fallback = pools.silver
                    elseif                pools.bronze and #pools.bronze > 0 then fallback = pools.bronze
                    end
                    if fallback then
                        table.insert(rolled, fallback[math.random(#fallback)][1])
                    end
                end
            end
        end

        if #rolled == 0 then
            player:setCharVar(lootedKey(zoneID, eventIdx), 1)
            player:printToPlayer("This chest is empty. Better luck next time!", xi.msg.channel.SYSTEM_3)
            return
        end

        stored = math.min(#rolled, MAX_LOOT_SLOTS)
        for s = 1, stored do
            player:setCharVar(lootSlotKey(zoneID, eventIdx, s), rolled[s])
        end
        player:setCharVar(lootCountKey(zoneID, eventIdx), stored)
        player:setCharVar(lootIdxKey(zoneID, eventIdx),   1)
    end

    local nextSlot = math.max(1, player:getCharVar(lootIdxKey(zoneID, eventIdx)))
    for s = nextSlot, stored do
        local itemID = player:getCharVar(lootSlotKey(zoneID, eventIdx, s))
        if not npcUtil.giveItem(player, itemID) then
            player:printToPlayer("Your inventory is full. Make room and try again.", xi.msg.channel.SYSTEM_3)
            return
        end
        player:setCharVar(lootIdxKey(zoneID, eventIdx), s + 1)
    end

    player:setCharVar(lootedKey(zoneID, eventIdx), 1)
    if def.superboss and def.killCooldown then
        player:setCharVar(sbPersonalCoolKey(def.id), GetSystemTime())
    end
end

xi.fate.spawnChest = function(zone, eventDef, zoneID, eventIdx, victory)
    local chest = xi.fate.chestNPCs[zoneID] and xi.fate.chestNPCs[zoneID][eventIdx]
    if not chest then return end

    chest:setLocalVar("fateEventIdx", eventIdx)
    chest:setLocalVar("fateActive",   1)
    chest:setLocalVar("fateVictory",  victory and 1 or 0)
    chest:setPos(eventDef.entryPos[1], eventDef.entryPos[2], eventDef.entryPos[3], 0)
    chest:setStatus(xi.status.NORMAL)

    chest:timer(xi.fate.settings.CHEST_DURATION * 1000, function(c)
        c:setLocalVar("fateActive", 0)
        c:setStatus(xi.status.DISAPPEAR)
    end)
end

-----------------------------------
-- Resolution
-----------------------------------
local function assignBandsAndRewards(zoneID, eventIdx, eventDef, victory)
    if not eventDef.rewards then return end
    local pools = victory and eventDef.rewards.victory or eventDef.rewards.fail
    if not pools then return end

    local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx]
    for playerID in pairs(pool or {}) do
        if PlayerHasValidSession(playerID) then
            local player = GetPlayerByID(playerID)
            if player then
                local band
                if eventDef.objective and eventDef.objective.type == "collect" then
                    -- Collect FATEs: band is determined by each player's personal item count.
                    local count  = player:getCharVar(collectCountKey(zoneID, eventIdx))
                    local tiers  = eventDef.collectTiers or { gold = 10, silver = 5, bronze = 1 }
                    if     count >= tiers.gold   then band = 3
                    elseif count >= tiers.silver then band = 2
                    elseif count >= tiers.bronze then band = 1
                    else                              band = 0
                    end
                else
                    local score = player:getCharVar(scoreKey(zoneID, eventIdx))
                    band = xi.fate.calcBand(score)
                end
                player:setCharVar(bandKey(zoneID, eventIdx), band)

                local tierNames = { "Bronze", "Silver", "Gold" }
                if band > 0 then
                    player:printToPlayer(string.format("[FATE] %s - %s tier! (%d pts)", eventDef.name, tierNames[band], score), xi.msg.channel.SYSTEM_3)

                    local exp = 0
                    if     band == 3 and pools.gold   then exp = pools.gold.exp   or 0
                    elseif band == 2 and pools.silver then exp = pools.silver.exp or 0
                    elseif pools.bronze               then exp = pools.bronze.exp or 0
                    end
                    if exp > 0 then
                        local mults    = xi.mimic.bonus.getMultipliers()
                        local momentum = xi.fate.getMomentumBonus(zoneID)
                        player:addExp(math.floor(exp * mults.exp * (1 + momentum)))
                    end
                end

                if victory and band > 0 then
                    player:incrementCharVar(progressKey(zoneID), eventDef.progressVal or 1)

                    -- Persistent band/completion tracking
                    local bandVarNames = { '[FATE]Bronze', '[FATE]Silver', '[FATE]Gold' }
                    player:incrementCharVar(bandVarNames[band], 1)
                    local bestKey = string.format('[FATE][%d]BestBand', zoneID)
                    if band > player:getCharVar(bestKey) then
                        player:setCharVar(bestKey, band)
                    end

                    -- Regional vendor weekly FATE tally.
                    local region = (xi.fate.zones[zoneID] or {}).region
                    if region and xi.fate.vendor and xi.fate.vendor.onFateComplete then
                        xi.fate.vendor.onFateComplete(player, region)
                    end
                end
            end
        end
    end
end

xi.fate.resolve = function(zoneID, eventIdx, victory, silent)
    if not xi.fate.isActive(zoneID, eventIdx) then return end

    local zone = GetZone(zoneID)
    if not zone then return end

    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def then return end

    SetServerVariable(stateKey(zoneID, eventIdx),  STATE_COOLDOWN)
    SetServerVariable(victoryKey(zoneID, eventIdx), victory and 1 or 0)

    xi.fate.sweepMobs(zoneID, eventIdx)

    local entry = xi.fate.entryNPCs[zoneID] and xi.fate.entryNPCs[zoneID][eventIdx]
    if entry then entry:setStatus(xi.status.DISAPPEAR) end

    if not silent then
        local outcomeMsg = victory and "FATE complete! A chest has appeared." or "FATE failed."
        for _, player in pairs(zone:getPlayers()) do
            player:printToPlayer(string.format("[FATE] %s - %s", def.name, outcomeMsg), xi.msg.channel.SYSTEM_3)
            if player:getCharVar(regKey(zoneID, eventIdx)) == 1 then
                xi.fate.removeSync(player)
                if victory then
                    xi.fate.announceComplete(player, def)
                else
                    xi.fate.announceFailure(player, def)
                end
            end
        end
        assignBandsAndRewards(zoneID, eventIdx, def, victory)
        xi.fate.spawnChest(zone, def, zoneID, eventIdx, victory)
    else
        for _, player in pairs(zone:getPlayers()) do
            if player:getCharVar(regKey(zoneID, eventIdx)) == 1 then
                xi.fate.removeSync(player)
            end
        end
    end

    -- Record completion timestamp so superboss prereq checks can verify recency.
    if victory then
        SetServerVariable(sbPrereqKey(def.id), GetSystemTime())
    end

    if def.superboss then
        -- Stamp global kill cooldown so this superboss can't re-trigger for globalCooldown seconds.
        if victory then
            SetServerVariable(sbGlobalCoolKey(def.id), GetSystemTime())
        end
        -- Clear runtime state.
        SetServerVariable(sbEnrageStartKey(zoneID, eventIdx),  0)
        SetServerVariable(sbEnragedKey(zoneID, eventIdx),      0)
        SetVolatileServerVariable(sbRageKey(zoneID, eventIdx), 0)
        SetVolatileServerVariable(sbWaveKey(zoneID, eventIdx), 0)
        -- World-state callbacks.
        if victory and def.onVictory then
            def.onVictory(zoneID)
        elseif not victory and def.onFailure then
            def.onFailure(zoneID)
        end
        -- Participation trophy: every registered player gets this item regardless of score band.
        if def.participationItem then
            local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx]
            for playerID in pairs(pool or {}) do
                if PlayerHasValidSession(playerID) then
                    local p = GetPlayerByID(playerID)
                    if p then npcUtil.giveItem(p, def.participationItem) end
                end
            end
        end
    end

    -- Defense FATE: clear wave tracker on resolution.
    if def.objective and def.objective.type == "defend" then
        SetVolatileServerVariable(sbWaveKey(zoneID, eventIdx), 0)
    end

    -- Collect FATE: hide any uncollected NPCs and reset their state.
    if def.objective and def.objective.type == "collect" then
        local cnpcs = xi.fate.collectNPCs[zoneID] and xi.fate.collectNPCs[zoneID][eventIdx]
        if cnpcs then
            for _, c in ipairs(cnpcs) do
                c:setStatus(xi.status.DISAPPEAR)
                c:setLocalVar("fateCollected", 0)
            end
        end
    end

    -- Zone momentum: consecutive victories stack an EXP bonus; any failure resets the streak.
    if not def.chainOnly then
        if victory then
            local streak = GetServerVariable(momentumKey(zoneID)) + 1
            SetServerVariable(momentumKey(zoneID), streak)
            local bonus = xi.fate.getMomentumBonus(zoneID)
            if streak == 3 or streak == 5 or streak == 8 then
                local pct = math.floor(bonus * 100)
                local msg = string.format("[FATE] Zone momentum! %d consecutive victories — +%d%% EXP bonus now active.", streak, pct)
                for _, p in pairs(zone:getPlayers()) do
                    p:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
                end
            end
        else
            if GetServerVariable(momentumKey(zoneID)) > 0 then
                SetServerVariable(momentumKey(zoneID), 0)
                for _, p in pairs(zone:getPlayers()) do
                    p:printToPlayer("[FATE] Zone momentum lost — win streak broken.", xi.msg.channel.SYSTEM_3)
                end
            end
        end
    end

    -- Dynamic difficulty: fast clears increase the difficulty tier; slow/failed clears reset it.
    if def.dynamicDifficulty then
        if victory then
            local elapsed  = GetSystemTime() - GetServerVariable(startKey(zoneID, eventIdx))
            local halfDur  = math.floor((def.duration or 600) / 2)
            if elapsed < halfDur then
                local tier = GetServerVariable(dynDiffKey(zoneID, eventIdx)) + 1
                SetServerVariable(dynDiffKey(zoneID, eventIdx), tier)
                if tier >= 2 then
                    local msg = string.format("[FATE] The enemy has adapted. Difficulty increases (tier %d).", tier)
                    for _, p in pairs(zone:getPlayers()) do p:printToPlayer(msg, xi.msg.channel.SYSTEM_3) end
                end
            else
                SetServerVariable(dynDiffKey(zoneID, eventIdx), 0)
            end
        else
            SetServerVariable(dynDiffKey(zoneID, eventIdx), 0)
        end
    end

    local zoneData = xi.fate.zones[zoneID]
    local cooldown = def.minCooldown or (zoneData and zoneData.minCooldown) or xi.fate.settings.DEFAULT_COOLDOWN
    SetServerVariable(cooldownKey(zoneID, eventIdx), GetSystemTime() + cooldown)

    -- Persist participant count for next spawn's scaling (victory keeps count, failure resets to 1)
    do
        local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx]
        local count = 0
        for _ in pairs(pool or {}) do count = count + 1 end
        SetServerVariable(scaleKey(zoneID, eventIdx), victory and math.max(1, count) or 1)
    end

    xi.fate.participants[zoneID]           = xi.fate.participants[zoneID] or {}
    xi.fate.participants[zoneID][eventIdx] = {}

    xi.fate.broadcastEventSync(zoneID, eventIdx)

    if victory and def.chainOnWin then
        if entry then
            entry:timer(30000, function(npc)
                local i   = npc:getLocalVar("fateEventIdx")
                local zID = npc:getLocalVar("fateZoneID")
                local chainDef = xi.fate.getEventDef(zID, i)
                if chainDef and chainDef.chainOnWin then
                    xi.fate.activateByID(zID, chainDef.chainOnWin)
                end
            end)
        end
    end
end

-----------------------------------
-- Boss pre-announce (10-min lead-up)
-----------------------------------
xi.fate.preannounce = function(zone, eventDef, zoneID, eventIdx)
    SetServerVariable(stateKey(zoneID, eventIdx), STATE_PENDING)

    local isSuperBoss = eventDef.superboss == true

    local function broadcastMsg(msg)
        if isSuperBoss then
            xi.fate.broadcastToFateZones(msg)
        else
            for _, player in pairs(zone:getPlayers()) do
                player:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
            end
        end
    end

    local warnings = eventDef.bossWarnings or {}
    local msg1 = warnings[1] or (isSuperBoss and "[FATE] ★★★★★ An ancient terror awakens. All adventurers — prepare yourselves." or "[FATE] A powerful creature stirs...")
    broadcastMsg(msg1)

    local entry = xi.fate.entryNPCs[zoneID] and xi.fate.entryNPCs[zoneID][eventIdx]
    if not entry then
        xi.fate.activate(zone, eventDef, zoneID, eventIdx)
        return
    end

    entry:timer(300000, function(e)
        local zID = e:getLocalVar("fateZoneID")
        local i   = e:getLocalVar("fateEventIdx")
        if GetServerVariable(stateKey(zID, i)) ~= STATE_PENDING then return end
        local z   = GetZone(zID)
        local def = xi.fate.getEventDef(zID, i)
        if not z or not def then return end

        local isSuper2 = def.superboss == true
        local function broadcastMsg2(msg)
            if isSuper2 then
                xi.fate.broadcastToFateZones(msg)
            else
                for _, player in pairs(z:getPlayers()) do
                    player:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
                end
            end
        end

        local w    = def.bossWarnings or {}
        local msg2 = w[2] or (isSuper2 and "[FATE] ★★★★★ The ground trembles. This is your final warning." or "[FATE] The creature draws near...")
        broadcastMsg2(msg2)

        if (def.bossStars or 1) >= 3 or isSuper2 then
            -- 3-star bosses get an extra 5-minute warning step (15-min total lead).
            e:timer(300000, function(e2)
                local zID2 = e2:getLocalVar("fateZoneID")
                local i2   = e2:getLocalVar("fateEventIdx")
                if GetServerVariable(stateKey(zID2, i2)) ~= STATE_PENDING then return end
                local z2   = GetZone(zID2)
                local def2 = xi.fate.getEventDef(zID2, i2)
                if not z2 or not def2 then return end
                local w2      = def2.bossWarnings or {}
                local isSuper3 = def2.superboss == true
                local msg3    = w2[3] or (isSuper3 and "[FATE] ★★★★★ Its arrival is imminent. Rally now." or "[FATE] An overwhelming presence descends upon you...")
                if isSuper3 then
                    xi.fate.broadcastToFateZones(msg3)
                else
                    for _, player in pairs(z2:getPlayers()) do
                        player:printToPlayer(msg3, xi.msg.channel.SYSTEM_3)
                    end
                end
                e2:timer(300000, function(e3)
                    local zID3 = e3:getLocalVar("fateZoneID")
                    local i3   = e3:getLocalVar("fateEventIdx")
                    if GetServerVariable(stateKey(zID3, i3)) ~= STATE_PENDING then return end
                    local z3   = GetZone(zID3)
                    local def3 = xi.fate.getEventDef(zID3, i3)
                    if not z3 or not def3 then return end
                    xi.fate.activate(z3, def3, zID3, i3)
                end)
            end)
        else
            e:timer(300000, function(e2)
                local zID2 = e2:getLocalVar("fateZoneID")
                local i2   = e2:getLocalVar("fateEventIdx")
                if GetServerVariable(stateKey(zID2, i2)) ~= STATE_PENDING then return end
                local z2   = GetZone(zID2)
                local def2 = xi.fate.getEventDef(zID2, i2)
                if not z2 or not def2 then return end
                xi.fate.activate(z2, def2, zID2, i2)
            end)
        end
    end)
end

-----------------------------------
-- Activation
-----------------------------------
xi.fate.activateByID = function(zoneID, eventID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx, def in ipairs(zoneData.events) do
        if def.id == eventID then
            local zone = GetZone(zoneID)
            if zone then xi.fate.activate(zone, def, zoneID, eventIdx) end
            return
        end
    end
end

xi.fate.activate = function(zone, eventDef, zoneID, eventIdx)
    ClearCharVarFromAll(regKey(zoneID, eventIdx))
    ClearCharVarFromAll(scoreKey(zoneID, eventIdx))
    ClearCharVarFromAll(bandKey(zoneID, eventIdx))
    ClearCharVarFromAll(lootedKey(zoneID, eventIdx))
    ClearCharVarFromAll(lootCountKey(zoneID, eventIdx))
    ClearCharVarFromAll(lootIdxKey(zoneID, eventIdx))
    ClearCharVarFromAll(collectCountKey(zoneID, eventIdx))
    for s = 1, MAX_LOOT_SLOTS do
        ClearCharVarFromAll(lootSlotKey(zoneID, eventIdx, s))
    end

    xi.fate.participants[zoneID]           = xi.fate.participants[zoneID] or {}
    xi.fate.participants[zoneID][eventIdx] = {}

    SetServerVariable(stateKey(zoneID, eventIdx), STATE_ACTIVE)
    SetServerVariable(startKey(zoneID, eventIdx), GetSystemTime())
    SetVolatileServerVariable(killKey(zoneID, eventIdx), 0)

    if eventDef.superboss then
        -- Reset all superboss runtime state.
        SetServerVariable(sbEnrageStartKey(zoneID, eventIdx),  0)
        SetServerVariable(sbEnragedKey(zoneID, eventIdx),      0)
        SetVolatileServerVariable(sbRageKey(zoneID, eventIdx), 0)
        SetVolatileServerVariable(sbWaveKey(zoneID, eventIdx), 0)
        -- Auto-register every player currently in the zone.
        for _, p in pairs(zone:getPlayers()) do
            xi.fate.register(p, zoneID, eventIdx)
        end
        -- Server-wide broadcast across all active FATE zones.
        if eventDef.worldBroadcast then
            xi.fate.broadcastToFateZones(eventDef.worldBroadcast)
        end
        -- Kick off wave 1 instead of the normal flat spawn.
        xi.fate.spawnWave(zoneID, eventIdx, 1)
    elseif eventDef.objective and eventDef.objective.type == "defend" then
        -- Defense FATEs use time-gated waves; spawn wave 1 now and let tickDefenseFATEs handle the rest.
        SetVolatileServerVariable(sbWaveKey(zoneID, eventIdx), 1)
        xi.fate.spawnWave(zoneID, eventIdx, 1)
    elseif eventDef.objective and eventDef.objective.type == "collect" then
        -- Reveal all collection-point NPCs.
        local cnpcs = xi.fate.collectNPCs[zoneID] and xi.fate.collectNPCs[zoneID][eventIdx]
        if cnpcs then
            for _, c in ipairs(cnpcs) do
                c:setLocalVar("fateCollected", 0)
                c:setStatus(xi.status.NORMAL)
            end
        end
        -- Spawn optional atmosphere/guard mobs if defined alongside the collect points.
        if eventDef.mobs then
            xi.fate.spawnMobs(zoneID, eventIdx)
        end
    else
        xi.fate.spawnMobs(zoneID, eventIdx)
    end

    local entry = xi.fate.entryNPCs[zoneID] and xi.fate.entryNPCs[zoneID][eventIdx]
    if entry then
        entry:setPos(eventDef.entryPos[1], eventDef.entryPos[2], eventDef.entryPos[3], eventDef.entryPos[4] or 0)
        entry:setStatus(xi.status.NORMAL)
        entry:timer(eventDef.duration * 1000, function(npc)
            local i   = npc:getLocalVar("fateEventIdx")
            local zID = npc:getLocalVar("fateZoneID")
            if xi.fate.isActive(zID, i) then
                local d         = xi.fate.getEventDef(zID, i)
                local isCollect = d and d.objective and d.objective.type == "collect"
                xi.fate.resolve(zID, i, isCollect == true)
            end
        end)
    end

    xi.fate.notify(zone, eventDef, zoneID, eventIdx)
    xi.fate.broadcastEventSync(zoneID, eventIdx)
end

-----------------------------------
-- Superboss system
-----------------------------------

-- Broadcast a message to every player currently in any registered FATE zone.
xi.fate.broadcastToFateZones = function(message)
    for zID in pairs(xi.fate.zones) do
        local z = GetZone(zID)
        if z then
            for _, p in pairs(z:getPlayers()) do
                p:printToPlayer(message, xi.msg.channel.SYSTEM_3)
            end
        end
    end
end

-- Auto-register players who zone in while a superboss is active.
xi.fate.superbossCheckZoneIn = function(player, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx, def in ipairs(zoneData.events) do
        if def.superboss and xi.fate.isActive(zoneID, eventIdx) then
            xi.fate.register(player, zoneID, eventIdx)
        end
    end
end

-- Returns the eventIdx of any currently active superboss in this zone, or nil.
xi.fate.getActiveSuperbossIdx = function(zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return nil end
    for eventIdx, def in ipairs(zoneData.events) do
        if def.superboss and xi.fate.isActive(zoneID, eventIdx) then
            return eventIdx
        end
    end
    return nil
end

-- Returns true if the superboss event is eligible to activate (cooldown clear, all prereqs met).
xi.fate.superbossEligible = function(zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def or not def.superboss then return false end
    local now = GetSystemTime()
    local lastKill = GetServerVariable(sbGlobalCoolKey(def.id))
    if lastKill > 0 and now - lastKill < (def.globalCooldown or 259200) then return false end
    if def.prereqs then
        local window = def.prereqWindow or 172800
        for _, prereqID in ipairs(def.prereqs) do
            local lastComplete = GetServerVariable(sbPrereqKey(prereqID))
            if lastComplete == 0 or now - lastComplete > window then return false end
        end
    end
    return true
end

-- Rage: increment stack counter and raise the boss's damage multiplier live.
xi.fate.addRage = function(zoneID, eventIdx, amount)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def or not def.superboss then return end
    local current = GetVolatileServerVariable(sbRageKey(zoneID, eventIdx))
    local new     = math.min(current + (amount or 1), def.rageCap or 60)
    if new == current then return end
    SetVolatileServerVariable(sbRageKey(zoneID, eventIdx), new)
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not entries then return end
    local n      = xi.fate.getScaleN(zoneID, eventIdx)
    local dmgPct = 100 + (n - 1) * 15
    for _, entry in ipairs(entries) do
        if entry.isBoss and entry.entity:isSpawned() then
            local base = entry.targetDmg and math.floor(entry.targetDmg * dmgPct / 100)
                         or dmgPct * (entry.dmgMultiplier or 1)
            local rageBonus = new * (def.ragePerDeath or 3)
            entry.entity:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, math.floor(base * (100 + rageBonus) / 100))
        end
    end
    if new % 5 == 0 then
        local zone = GetZone(zoneID)
        if zone then
            local bonus = new * (def.ragePerDeath or 3)
            for _, p in pairs(zone:getPlayers()) do
                p:printToPlayer(string.format("[FATE] %s grows stronger from your losses! (+%d%% damage)", def.name, bonus), xi.msg.channel.SYSTEM_3)
            end
        end
    end
end

-- Called from zone onPlayerDeath; triggers event-level ragePerDeath and per-boss callbacks.
xi.fate.onPlayerDeath = function(player, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx, def in ipairs(zoneData.events) do
        if not def.superboss or not xi.fate.isActive(zoneID, eventIdx) then goto sbNextEvt end
        if player:getCharVar(regKey(zoneID, eventIdx)) == 0 then goto sbNextEvt end
        if def.ragePerDeath then xi.fate.addRage(zoneID, eventIdx, 1) end
        local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
        for _, entry in ipairs(entries or {}) do
            if entry.isBoss and entry.onPlayerDeath then
                entry.onPlayerDeath(player, zoneID, eventIdx)
            end
        end
        ::sbNextEvt::
    end
end

-- Check and fire HP-threshold phases for the superboss. Called from onMobFight.
xi.fate.checkSuperBossPhases = function(mob, zoneID, eventIdx)
    local def = xi.fate.getEventDef(zoneID, eventIdx)
    if not def or not def.phases then return end
    local currentPhase = mob:getLocalVar("sbPhase")
    if currentPhase >= #def.phases then return end
    local maxHP = mob:getMaxHP()
    if maxHP == 0 then return end
    local hpPct = mob:getHP() * 100 / maxHP
    for phaseIdx = currentPhase + 1, #def.phases do
        if hpPct <= def.phases[phaseIdx].hpPct then
            mob:setLocalVar("sbPhase", phaseIdx)
            def.phases[phaseIdx].onTrigger(mob, zoneID, eventIdx)
            break
        end
    end
end

-- Make the boss effectively unkillable and notify the zone.
xi.fate.triggerSuperBossEnrage = function(zoneID, eventIdx)
    local def     = xi.fate.getEventDef(zoneID, eventIdx)
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not def or not entries then return end
    SetServerVariable(sbEnragedKey(zoneID, eventIdx), 1)
    local zone = GetZone(zoneID)
    for _, entry in ipairs(entries) do
        if entry.isBoss and entry.entity:isSpawned() then
            -- Extreme damage so players cannot survive; combined with wipe-reset this keeps fight alive.
            entry.entity:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, 99999)
            if def.onEnrage then def.onEnrage(entry.entity, zoneID, eventIdx) end
        end
    end
    if zone then
        for _, p in pairs(zone:getPlayers()) do
            p:printToPlayer(string.format("[FATE] %s — ENRAGE! The beast is beyond stopping!", def.name), xi.msg.channel.SYSTEM_3)
        end
    end
end

-- After an enrage wipe, respawn the boss at full HP with all state reset.
xi.fate.resetSuperBoss = function(zoneID, eventIdx)
    local def     = xi.fate.getEventDef(zoneID, eventIdx)
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not def or not entries then return end
    SetServerVariable(sbEnrageStartKey(zoneID, eventIdx),  0)
    SetServerVariable(sbEnragedKey(zoneID, eventIdx),      0)
    SetVolatileServerVariable(sbRageKey(zoneID, eventIdx), 0)
    -- Despawn all remaining mobs and reschedule the boss wave spawn.
    local bossWave = nil
    for _, entry in ipairs(entries) do
        local mob = entry.entity
        if mob:isSpawned() then
            DisallowRespawn(mob:getID(), true)
            DespawnMob(mob:getID())
        end
        if entry.isBoss then bossWave = entry.waveIdx end
    end
    local zone = GetZone(zoneID)
    if zone then
        for _, p in pairs(zone:getPlayers()) do
            p:printToPlayer("[FATE] The beast loses its prey and resets. The hard cap is still ticking.", xi.msg.channel.SYSTEM_3)
        end
    end
    if bossWave then
        -- Small delay before respawn so players can regroup.
        local entry = xi.fate.entryNPCs[zoneID] and xi.fate.entryNPCs[zoneID][eventIdx]
        local npcRef = entry
        if npcRef then
            npcRef:timer(15000, function(npc)
                local zID = npc:getLocalVar("fateZoneID")
                local i   = npc:getLocalVar("fateEventIdx")
                if xi.fate.isActive(zID, i) then
                    xi.fate.spawnWave(zID, i, bossWave)
                end
            end)
        end
    end
end

-- Per-tick superboss maintenance: enrage check, wipe-reset detection.
xi.fate.superbossTick = function(zone, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx, def in ipairs(zoneData.events) do
        if not def.superboss or not xi.fate.isActive(zoneID, eventIdx) then goto sbTick end
        local now         = GetSystemTime()
        local enrageStart = GetServerVariable(sbEnrageStartKey(zoneID, eventIdx))
        if enrageStart == 0 then goto sbTick end  -- nobody has pulled yet
        local enraged = GetServerVariable(sbEnragedKey(zoneID, eventIdx))
        if enraged == 0 then
            if now - enrageStart >= (def.enrageTime or 1800) then
                xi.fate.triggerSuperBossEnrage(zoneID, eventIdx)
            end
        else
            -- Enraged: if boss is spawned but has no enmity, it's a wipe — reset.
            local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
            for _, entry in ipairs(entries or {}) do
                if entry.isBoss and entry.entity:isSpawned() and not entry.entity:isEngaged() then
                    xi.fate.resetSuperBoss(zoneID, eventIdx)
                    break
                end
            end
        end
        ::sbTick::
    end
end

-- Death handler for mobs belonging to a superboss event.
xi.fate.onSuperBossMobDeath = function(mob, player, optParams, zoneID, eventIdx)
    if not xi.fate.isActive(zoneID, eventIdx) then return end
    local entries = xi.fate.mobEntities[zoneID] and xi.fate.mobEntities[zoneID][eventIdx]
    if not entries then return end
    local thisEntry
    for _, e in ipairs(entries) do
        if e.entity:getID() == mob:getID() then thisEntry = e break end
    end
    if not thisEntry then return end
    local killer = optParams.isKiller and player
    if not killer and optParams.noKiller then killer = xi.fate.findRegisteredPlayer(zoneID, eventIdx) end
    if killer and killer:getCharVar(regKey(zoneID, eventIdx)) > 0 then
        xi.fate.addScore(killer, zoneID, eventIdx, "ws", SCORE_KILL)
    end
    DisallowRespawn(mob:getID(), true)
    if thisEntry.isBoss then
        local killerName = killer and killer:getName() or "Unknown"
        xi.fate.onSuperBossVictory(mob, killerName, zoneID, eventIdx)
    else
        xi.fate.checkWaveCleared(zoneID, eventIdx, thisEntry.waveIdx)
    end
end

-- Snapshot leaderboard data and create tombstone NPC at boss's death position.
xi.fate.onSuperBossVictory = function(mob, killerName, zoneID, eventIdx)
    local def  = xi.fate.getEventDef(zoneID, eventIdx)
    local zone = GetZone(zoneID)
    if not def then return end

    if def.tombstone and zone then
        -- Snapshot participant scores.
        local data = { killedAt = os.time(), killedBy = killerName, participants = {} }
        local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx] or {}
        for playerID in pairs(pool) do
            if PlayerHasValidSession(playerID) then
                local p = GetPlayerByID(playerID)
                if p then
                    local score = p:getCharVar(scoreKey(zoneID, eventIdx))
                    local band  = xi.fate.calcBand(score)
                    local tiers = { "Bronze", "Silver", "Gold" }
                    table.insert(data.participants, { name = p:getName(), score = score, tier = band > 0 and tiers[band] or "—", tierNum = band })
                end
            end
        end
        table.sort(data.participants, function(a, b) return a.score > b.score end)
        xi.fate.tombstones[def.id] = data

        local tombNPC = zone:insertDynamicEntity({
            objtype   = xi.objType.NPC,
            name      = "Mark of Battle",
            look      = 1402,
            x = mob:getXPos(), y = mob:getYPos(), z = mob:getZPos(), rotation = 0,
            widescan  = 0,
            onTrigger = function(p, npc)
                local zID2 = npc:getLocalVar("fateZoneID")
                local i2   = npc:getLocalVar("fateEventIdx")
                local d    = xi.fate.getEventDef(zID2, i2)
                if d then xi.fate.displayTombstone(p, d.id) end
            end,
        })
        if tombNPC then
            tombNPC:setLocalVar("fateZoneID",   zoneID)
            tombNPC:setLocalVar("fateEventIdx", eventIdx)
            tombNPC:timer(3600000, function(npc) npc:setStatus(xi.status.DISAPPEAR) end)
        end
    end

    xi.fate.resolve(zoneID, eventIdx, true)
end

-- Display the leaderboard stored for a superboss event to a player.
xi.fate.displayTombstone = function(player, eventID)
    local data = xi.fate.tombstones[eventID]
    if not data then
        player:printToPlayer("The stone is weathered and silent.", xi.msg.channel.SYSTEM_3)
        return
    end
    player:printToPlayer(string.format("Defeated: %s  |  Killing blow: %s", os.date("%Y-%m-%d %H:%M", data.killedAt), data.killedBy), xi.msg.channel.SYSTEM_3)
    player:printToPlayer("─────────────────────────────────────────────", xi.msg.channel.SYSTEM_3)
    for rank, entry in ipairs(data.participants) do
        if rank > 20 then break end
        player:printToPlayer(string.format("  %2d. %-20s %-7s (%d pts)", rank, entry.name, entry.tier, entry.score), xi.msg.channel.SYSTEM_3)
    end
    player:printToPlayer(string.format("  %d participants total.", #data.participants), xi.msg.channel.SYSTEM_3)
end

-----------------------------------
-- Zone initialization helpers
--
-- !! LSB CLOSURE CAPTURE BUG — READ BEFORE EDITING !!
-- This runtime shares upvalue slots across ALL calls to the same function,
-- including function parameters. ANY local captured in a deferred callback
-- (timer, onTrigger, onMobDeath, etc.) will hold the value from the MOST
-- RECENT call to that function, not the call that created the closure.
--
-- Rule: deferred callbacks must NEVER reference zoneID or eventIdx (idx)
-- from the enclosing scope. Instead, store them on the entity as local vars
-- and read them back inside the callback:
--   entity:setLocalVar("fateZoneID",   zoneID)   -- integer, always safe
--   entity:setLocalVar("fateEventIdx", idx)       -- integer, always safe
--   local zID = entity:getLocalVar("fateZoneID")
--   local i   = entity:getLocalVar("fateEventIdx")
-----------------------------------
local function initFATEEvent(zone, zoneID, idx, eventDef, areaID)
    eventDef.triggerAreaID = areaID
    zone:registerCylindricalTriggerArea(areaID, eventDef.area[1], eventDef.area[3], eventDef.area[4])

    local entryEntity = zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = "Fate Herald",
        look      = 1402,
        x = 0, y = 0, z = 0, rotation = 0,
        widescan  = 0,
        onTrigger = function(player, npc)
            xi.fate.onEntryTrigger(player, npc, npc:getLocalVar("fateZoneID"), npc:getLocalVar("fateEventIdx"))
        end,
    })
    if entryEntity then
        entryEntity:setStatus(xi.status.DISAPPEAR)
        entryEntity:setLocalVar("fateEventIdx", idx)
        entryEntity:setLocalVar("fateZoneID",   zoneID)
        xi.fate.entryNPCs[zoneID]      = xi.fate.entryNPCs[zoneID] or {}
        xi.fate.entryNPCs[zoneID][idx] = entryEntity
    end

    local chestEntity = zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name       = "FATE_Chest_" .. idx,
        packetName = "Treasure",
        look       = 969,
        namevis    = 64,
        x = eventDef.entryPos[1], y = eventDef.entryPos[2], z = eventDef.entryPos[3], rotation = 0,
        widescan   = 0,
        onTrigger  = function(player, npc)
            xi.fate.openChest(player, npc)
        end,
    })
    if chestEntity then
        chestEntity:setStatus(xi.status.DISAPPEAR)
        chestEntity:hideHP(true)
        chestEntity:setLocalVar("fateEventIdx", idx)
        xi.fate.chestNPCs[zoneID]      = xi.fate.chestNPCs[zoneID] or {}
        xi.fate.chestNPCs[zoneID][idx] = chestEntity
    end

    xi.fate.mobEntities[zoneID]      = xi.fate.mobEntities[zoneID] or {}
    xi.fate.mobEntities[zoneID][idx] = {}

    -- Build a shuffled shared pool for events that declare sharedSpawnPoints so that
    -- mobs from different groups spread across the full set of points at init time.
    local sharedPool    = nil
    local sharedPoolIdx = 0
    if eventDef.sharedSpawnPoints and #eventDef.sharedSpawnPoints > 0 then
        sharedPool = {}
        for _, pt in ipairs(eventDef.sharedSpawnPoints) do
            sharedPool[#sharedPool + 1] = pt
        end
        for j = #sharedPool, 2, -1 do
            local k = math.random(j)
            sharedPool[j], sharedPool[k] = sharedPool[k], sharedPool[j]
        end
    end

    -- Initialise collection-point NPCs if this is a collect-type event.
    if eventDef.objective and eventDef.objective.type == "collect" and eventDef.collectPoints then
        xi.fate.collectNPCs[zoneID]      = xi.fate.collectNPCs[zoneID] or {}
        xi.fate.collectNPCs[zoneID][idx] = {}
        for cIdx, pt in ipairs(eventDef.collectPoints) do
            local cNPC = zone:insertDynamicEntity({
                objtype   = xi.objType.NPC,
                name      = eventDef.collectName or "Collection Point",
                look      = 969,
                x         = pt[1], y = pt[2], z = pt[3],
                rotation  = pt[4] or 0,
                widescan  = 0,
                onTrigger = function(player, npc)
                    xi.fate.onCollect(player, npc, npc:getLocalVar("fateZoneID"), npc:getLocalVar("fateEventIdx"))
                end,
            })
            if cNPC then
                cNPC:setStatus(xi.status.DISAPPEAR)
                cNPC:setLocalVar("fateZoneID",    zoneID)
                cNPC:setLocalVar("fateEventIdx",  idx)
                cNPC:setLocalVar("fateCollectIdx", cIdx)
                xi.fate.collectNPCs[zoneID][idx][cIdx] = cNPC
            end
        end
    end

    -- Flatten mob groups from waves (wave-based events) or the regular mobs array.
    -- Each entry carries a waveIdx (nil for flat-spawn events).
    local flatGroups = {}
    if eventDef.waves then
        for wIdx, wave in ipairs(eventDef.waves) do
            for _, mg in ipairs(wave.mobs or {}) do
                table.insert(flatGroups, { group = mg, waveIdx = wIdx })
            end
        end
    else
        for _, mg in ipairs(eventDef.mobs or {}) do
            table.insert(flatGroups, { group = mg, waveIdx = nil })
        end
    end

    for _, item in ipairs(flatGroups) do
        local mobGroup = item.group
        local waveIdx  = item.waveIdx
        local aggroType = mobGroup.aggroType  -- captured per-group before inner loop; nil = keep template default
        for n = 1, mobGroup.count do
            local spawnPt
            if sharedPool then
                sharedPoolIdx = sharedPoolIdx + 1
                spawnPt = sharedPool[((sharedPoolIdx - 1) % #sharedPool) + 1]
            else
                spawnPt = mobGroup.spawnPoints[((n - 1) % #mobGroup.spawnPoints) + 1]
            end

            local mobEntity = zone:insertDynamicEntity({
                objtype         = xi.objType.MOB,
                name            = mobGroup.name,
                groupId         = mobGroup.base[2],
                groupZoneId     = mobGroup.base[1],
                minLevel        = mobGroup.isBoss and eventDef.level or math.max(1, eventDef.level - 2),
                maxLevel        = mobGroup.isBoss and eventDef.level or math.max(1, eventDef.level - 2),
                isAggroable     = true,
                modelSize       = mobGroup.size,
                modelHitboxSize = mobGroup.hitbox,
                x = spawnPt[1], y = spawnPt[2], z = spawnPt[3],
                rotation        = spawnPt[4] or 0,

                onMobInitialize = function(mob)
                    mob:setMobMod(xi.mobMod.CLAIM_TYPE,  xi.claimType.NON_EXCLUSIVE)
                    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
                    mob:setMobMod(xi.mobMod.CHARMABLE,   0)
                    mob:setMobMod(xi.mobMod.ALLI_HATE,   30)
                    -- Force aggro and targetability regardless of mob_groups template flags.
                    -- m_Aggro and entityFlags are copied verbatim from the base template zone
                    -- and are never overridden by insertDynamicEntity, so a non-aggro or
                    -- untargetable template (e.g. a dormant NM, totem, or event mob) would
                    -- produce a FATE mob that stands idle and cannot be engaged.
                    mob:setAggressive(true)
                    mob:setUntargetable(false)
                    if aggroType then
                        mob:setMobMod(xi.mobMod.DETECTION, aggroType)
                    end
                end,

                onMobEngage = function(mob, target)
                    local i   = mob:getLocalVar("fateEventIdx")
                    local zID = mob:getLocalVar("fateZoneID")
                    if target:isPC() and target:getCharVar(regKey(zID, i)) == 0 then
                        local valid = xi.fate.findRegisteredPlayer(zID, i)
                        if valid then mob:updateClaim(valid) end
                    end
                    local def = xi.fate.getEventDef(zID, i)
                    -- Superboss: start the enrage countdown on the very first pull of any mob.
                    if def and def.superboss then
                        if GetServerVariable(sbEnrageStartKey(zID, i)) == 0 then
                            SetServerVariable(sbEnrageStartKey(zID, i), GetSystemTime())
                            local zone = GetZone(zID)
                            if zone then
                                local mins = math.floor((def.enrageTime or 1800) / 60)
                                for _, p in pairs(zone:getPlayers()) do
                                    p:printToPlayer(string.format("[FATE] The battle has begun! Enrage in %d minutes.", mins), xi.msg.channel.SYSTEM_3)
                                end
                            end
                        end
                    end
                    if def and def.onMobEngage then
                        def.onMobEngage(mob, target, zID, i)
                    end
                end,

                onMobDisengage = function(mob)
                end,

                onMobDeath = function(mob, player, optParams)
                    local i   = mob:getLocalVar("fateEventIdx")
                    local zID = mob:getLocalVar("fateZoneID")
                    -- Superboss wave-aware death handling — fully replaces the regular path.
                    do
                        local def = xi.fate.getEventDef(zID, i)
                        if def and def.superboss then
                            xi.fate.onSuperBossMobDeath(mob, player, optParams, zID, i)
                            return
                        end
                    end
                    local entries = xi.fate.mobEntities[zID] and xi.fate.mobEntities[zID][i]
                    if entries then
                        for _, entry in ipairs(entries) do
                            if entry.entity:getID() == mob:getID() and entry.noCount then
                                -- Score the kill without counting toward the objective
                                if optParams.isKiller and player and player:getCharVar(regKey(zID, i)) > 0 then
                                    xi.fate.addScore(player, zID, i, "ws", SCORE_KILL)
                                elseif optParams.noKiller then
                                    local credited = xi.fate.findRegisteredPlayer(zID, i)
                                    if credited then xi.fate.addScore(credited, zID, i, "ws", SCORE_KILL) end
                                end
                                xi.fate.quickRespawn(mob, zID, i)
                                return
                            end
                        end
                    end
                    if optParams.isKiller then
                        local registered = player and player:getCharVar(regKey(zID, i)) > 0
                        if registered and xi.fate.isInArea(player, zID, i) then
                            xi.fate.onKill(mob, player, zID, i)
                            DisallowRespawn(mob:getID(), true)
                        else
                            xi.fate.quickRespawn(mob, zID, i)
                        end
                    elseif optParams.noKiller then
                        local credited = xi.fate.findRegisteredPlayer(zID, i)
                        if credited then
                            xi.fate.onKill(mob, credited, zID, i)
                            DisallowRespawn(mob:getID(), true)
                        else
                            xi.fate.quickRespawn(mob, zID, i)
                        end
                    end
                end,

                onMagicHit = function(caster, target, spell)
                    local zID = target:getLocalVar("fateZoneID")
                    local i   = target:getLocalVar("fateEventIdx")
                    xi.fate.onMagic(caster, spell, zID, i)
                    -- Dispatch per-mob onSpellHit callback (used for custom rage triggers, e.g. fire damage).
                    local entries = xi.fate.mobEntities[zID] and xi.fate.mobEntities[zID][i]
                    if entries then
                        for _, entry in ipairs(entries) do
                            if entry.entity:getID() == target:getID() and entry.onSpellHit then
                                entry.onSpellHit(target, caster, spell, zID, i)
                                break
                            end
                        end
                    end
                end,

                onPlayerAbilityUse = function(mob, player, ability)
                    xi.fate.onAbility(player, ability, mob:getLocalVar("fateZoneID"), mob:getLocalVar("fateEventIdx"))
                end,

                onWeaponskillHit = function(mob, attacker, wsID)
                    xi.fate.onWS(attacker, wsID, mob:getLocalVar("fateZoneID"), mob:getLocalVar("fateEventIdx"))
                end,

                onMobFight = function(mob, target)
                    local zID = mob:getLocalVar("fateZoneID")
                    local i   = mob:getLocalVar("fateEventIdx")
                    xi.fate.onMelee(target, zID, i)
                    -- Superboss boss: check HP phase thresholds each melee round.
                    if mob:getLocalVar("sbPhase") ~= nil then
                        xi.fate.checkSuperBossPhases(mob, zID, i)
                    end
                end,
            })
            if mobEntity then
                mobEntity:setLocalVar("fateEventIdx", idx)
                mobEntity:setLocalVar("fateZoneID",   zoneID)
                DisallowRespawn(mobEntity:getID(), true)
                -- Read native HP before despawn so targetHP can compute the correct HP_SCALE later.
                local nativeHP = mobEntity:isSpawned() and mobEntity:getMaxHP() or nil
                if mobEntity:isSpawned() then
                    DespawnMob(mobEntity:getID())
                end
                table.insert(xi.fate.mobEntities[zoneID][idx], {
                    entity        = mobEntity,
                    spawnPt       = spawnPt,
                    waveIdx       = waveIdx,
                    isBoss        = mobGroup.isBoss        or false,
                    noCount       = mobGroup.noCount       or false,
                    hpMultiplier  = mobGroup.hpMultiplier  or 1,
                    dmgMultiplier = mobGroup.dmgMultiplier or 1,
                    targetHP      = mobGroup.targetHP,
                    targetDmg     = mobGroup.targetDmg,
                    nativeHP      = nativeHP,
                    onPlayerDeath = mobGroup.onPlayerDeath,
                    onSpellHit    = mobGroup.onSpellHit,
                })
            end
        end
    end
end

-----------------------------------
-- Zone initialization
-----------------------------------
xi.fate.onZoneInitialize = function(zone, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end

    local areaID = FATE_AREA_ID_BASE
    for eventIdx, eventDef in ipairs(zoneData.events) do
        initFATEEvent(zone, zoneID, eventIdx, eventDef, areaID)
        areaID = areaID + 1
    end
end

-----------------------------------
-- Entry NPC interaction
-----------------------------------
xi.fate.onEntryTrigger = function(player, npc, zoneID, eventIdx)
    if not xi.fate.isActive(zoneID, eventIdx) then
        player:printToPlayer("There is no active FATE at this time.", xi.msg.channel.SYSTEM_3)
        return
    end

    local def       = xi.fate.getEventDef(zoneID, eventIdx)
    local remaining = xi.fate.getRemaining(zoneID, eventIdx)
    local mins      = math.floor(remaining / 60)
    local secs      = remaining % 60

    if remaining <= 0 then
        player:printToPlayer("This FATE has already concluded.", xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getCharVar(regKey(zoneID, eventIdx)) == 1 then
        player:printToPlayer(
            string.format("[FATE] %s - Already participating. %dm %ds remaining.", def.name, mins, secs),
            xi.msg.channel.SYSTEM_3
        )
        return
    end

    if player:getLocalVar("[FATE]Blocking") == 1 then return end
    player:setLocalVar("[FATE]Blocking",    1)
    player:setLocalVar("[FATE]PendingZone", zoneID)
    player:setLocalVar("[FATE]PendingEvt",  eventIdx)

    player:timer(100, function(p)
        local zID = p:getLocalVar("[FATE]PendingZone")
        local i   = p:getLocalVar("[FATE]PendingEvt")
        p:setLocalVar("[FATE]Blocking", 0)
        local d   = xi.fate.getEventDef(zID, i)
        local rem = xi.fate.getRemaining(zID, i)
        local m   = math.floor(rem / 60)
        local s   = rem % 60
        p:printToPlayer(
            string.format("[FATE] %s (Lv%d) | %dm %ds remaining", d.name, d.level, m, s),
            xi.msg.channel.SYSTEM_3
        )
        p:customMenu({
            title   = "Join this FATE?",
            options =
            {
                {
                    "Not right now.",
                    function() end,
                },
                {
                    "Join FATE.",
                    function()
                        local zID2 = p:getLocalVar("[FATE]PendingZone")
                        local i2   = p:getLocalVar("[FATE]PendingEvt")
                        if xi.fate.register(p, zID2, i2) then
                            local d2 = xi.fate.getEventDef(zID2, i2)
                            p:printToPlayer(
                                string.format("You have joined: %s.", d2 and d2.name or "FATE"),
                                xi.msg.channel.SYSTEM_3
                            )
                        end
                    end,
                },
            },
        })
    end)
end

-----------------------------------
-- Defense FATE wave timer
-- Runs every 10s alongside the leash check. Spawns the next wave once enough
-- time has elapsed since the event started, regardless of whether the previous
-- wave has been cleared (time-gated, not kill-gated).
-----------------------------------
xi.fate.tickDefenseFATEs = function(zone, zoneID, now)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx, def in ipairs(zoneData.events) do
        if def.objective and def.objective.type == "defend" and def.waves
            and xi.fate.isActive(zoneID, eventIdx)
        then
            local numWaves    = #def.waves
            local currentWave = GetVolatileServerVariable(sbWaveKey(zoneID, eventIdx))
            if currentWave < numWaves then
                local interval = def.waveInterval or 90
                local elapsed  = now - GetServerVariable(startKey(zoneID, eventIdx))
                local nextDue  = currentWave * interval
                if elapsed >= nextDue then
                    local nextWave = currentWave + 1
                    SetVolatileServerVariable(sbWaveKey(zoneID, eventIdx), nextWave)
                    xi.fate.spawnWave(zoneID, eventIdx, nextWave)
                    for _, p in pairs(zone:getPlayers()) do
                        p:printToPlayer(string.format("[FATE] %s — Wave %d incoming!", def.name, nextWave), xi.msg.channel.SYSTEM_3)
                    end
                end
            end
        end
    end
end

-----------------------------------
-- Proximity alert on zone-in
-- Informs players arriving mid-FATE what is currently underway.
-----------------------------------
xi.fate.notifyActiveOnZoneIn = function(player, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end
    for eventIdx, def in ipairs(zoneData.events) do
        if xi.fate.isActive(zoneID, eventIdx) then
            local remaining = xi.fate.getRemaining(zoneID, eventIdx)
            local mins      = math.max(1, math.ceil(remaining / 60))
            local collected = GetVolatileServerVariable(killKey(zoneID, eventIdx))
            local target    = def.objective and def.objective.count or 0
            local objType   = def.objective and def.objective.type  or "kill"
            local progress
            if objType == "collect" then
                progress = string.format("%d/%d recovered", collected, target)
            elseif objType == "defend" then
                local wave    = GetVolatileServerVariable(sbWaveKey(zoneID, eventIdx))
                local numWave = def.waves and #def.waves or 1
                progress = string.format("wave %d/%d underway", wave, numWave)
            else
                progress = string.format("%d/%d defeated", collected, target)
            end
            local dynTier = def.dynamicDifficulty and GetServerVariable(dynDiffKey(zoneID, eventIdx)) or 0
            local tierStr = dynTier > 0 and string.format(" [Difficulty +%d]", dynTier) or ""
            player:printToPlayer(
                string.format("[FATE] %s is underway! (%s, %dm remaining%s) — speak to the herald to join.",
                    def.name, progress, mins, tierStr),
                xi.msg.channel.SYSTEM_3
            )
        end
    end
end

-----------------------------------
-- Scheduler (called from onZoneTick override)
-- Each non-chain event runs its own independent state machine.
-----------------------------------
xi.fate.tick = function(zone, zoneID)
    local zoneData = xi.fate.zones[zoneID]
    if not zoneData then return end

    local now = GetSystemTime()
    if (xi.fate.lastLeashTick[zoneID] or 0) + 10 <= now then
        xi.fate.lastLeashTick[zoneID] = now
        xi.fate.leashMobs(zoneID)
        xi.fate.tickDefenseFATEs(zone, zoneID, now)
    end

    -- Always run superboss maintenance (enrage, wipe-reset, phases) regardless of scheduler throttle.
    xi.fate.superbossTick(zone, zoneID)

    -- Suppress the regular FATE scheduler while a superboss is active in this zone.
    if xi.fate.getActiveSuperbossIdx(zoneID) then return end

    if (xi.fate.lastTick[zoneID] or 0) + xi.fate.settings.SCHEDULER_PERIOD > now then
        return
    end
    xi.fate.lastTick[zoneID] = now

    local eligible = {}

    for eventIdx, def in ipairs(zoneData.events) do
        if not def.chainOnly then
            local state = GetServerVariable(stateKey(zoneID, eventIdx))

            if state == STATE_ACTIVE then
                xi.fate.onHealTickForEvent(zoneID, eventIdx)
                if xi.fate.getRemaining(zoneID, eventIdx) <= 0 then
                    local isCollect = def.objective and def.objective.type == "collect"
                    if isCollect then
                        xi.fate.resolve(zoneID, eventIdx, true,  false)  -- collect: always victory
                    else
                        xi.fate.resolve(zoneID, eventIdx, false, true)   -- others: silent fail
                    end
                end
            elseif state == STATE_COOLDOWN then
                if now >= GetServerVariable(cooldownKey(zoneID, eventIdx)) then
                    SetServerVariable(stateKey(zoneID, eventIdx), STATE_IDLE)
                    table.insert(eligible, { idx = eventIdx, def = def })
                end
            elseif state == STATE_PENDING then
                -- pre-announce timers running; skip
            else
                table.insert(eligible, { idx = eventIdx, def = def })
            end
        end
    end

    if #eligible == 0 then return end

    local passed = {}
    for _, e in ipairs(eligible) do
        -- Superboss events require all prereqs to be met within their window.
        if e.def.superboss and not xi.fate.superbossEligible(zoneID, e.idx) then
            goto nextEligible
        end
        local chance = e.def.spawnChance or zoneData.spawnChance or xi.fate.settings.DEFAULT_CHANCE
        if math.random() <= chance then
            table.insert(passed, e)
        end
        ::nextEligible::
    end
    if #passed == 0 then return end

    local pick = passed[math.random(#passed)]
    if pick.def.isBoss or pick.def.superboss then
        xi.fate.preannounce(zone, pick.def, zoneID, pick.idx)
    else
        xi.fate.activate(zone, pick.def, zoneID, pick.idx)
    end
end

-----------------------------------
-- Healer contribution approximation
-----------------------------------
xi.fate.onHealTickForEvent = function(zoneID, eventIdx)
    local pool = xi.fate.participants[zoneID] and xi.fate.participants[zoneID][eventIdx]
    for playerID in pairs(pool or {}) do
        if PlayerHasValidSession(playerID) then
            local player = GetPlayerByID(playerID)
            if player then
                local mp     = player:getMP()
                local prevMP = player:getLocalVar("[FATE]PrevMP")
                if prevMP > 0 and mp < prevMP then
                    local spent = prevMP - mp
                    xi.fate.addScore(player, zoneID, eventIdx, "heal", math.max(1, math.floor(spent / 10)))
                end
                player:setLocalVar("[FATE]PrevMP", mp)
            end
        end
    end
end

-----------------------------------
-- Progress tier lookup
-----------------------------------
xi.fate.getTier = function(player, zoneID)
    local p = player:getCharVar(progressKey(zoneID))
    if     p >= 15 then return 4
    elseif p >= 9  then return 3
    elseif p >= 5  then return 2
    else                return 1
    end
end
