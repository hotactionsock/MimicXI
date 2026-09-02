# MimicXI — Claude Instructions

MimicXI is a custom FFXI server emulator based on LandSandBoat. The codebase is C++20 (server engine) with Lua/LuaJIT scripting for all game content. MariaDB is used for data storage. This file covers the instanced fight system and the account bank system, and how to build content on top of them.

---

## Instanced Fight System

The engine supports multiple parties running the same content simultaneously, each in a fully isolated `CInstance`. Key properties:

- One `CInstance` per party — entity isolation is automatic via `PInstance` pointer routing
- Maximum **3 concurrent instances** of the same content (enforced in `instanceutils::CheckInstance`)
- Once a fight is **locked**, alive players cannot zone out — they are stuck until KO'd, or the fight ends
- Players who leave a locked instance (KO/disconnect) are **permanently barred from re-entering** that run
- `instance:complete()` and `instance:fail()` both automatically unlock the instance

### Relevant engine files

| File | Purpose |
|------|---------|
| `src/map/instance.h` / `.cpp` | `CInstance` — per-party fight state, lock, exited-char tracking |
| `src/map/zone_instance.h` / `.cpp` | `CZoneInstance` — routes all entity ops to correct instance, capacity check, zone-out lock |
| `src/map/utils/instanceutils.cpp` | Queue processing, capacity check, `OnInstanceCapacityReached` callback |
| `src/map/lua/lua_instance.h` / `.cpp` | Lua bindings for `CInstance` |
| `src/map/lua/luautils.cpp` | `OnInstanceCapacityReached` implementation |
| `scripts/globals/instance.lua` | `xi.instance` — shared Lua utilities for entry flow and party registration |

---

## Creating New Instanced Fight Content

### Step 1 — Database

Add to `instance_list`:
```sql
INSERT INTO instance_list
    (instanceid, instance_name, instance_zone, entrance_zone, time_limit,
     start_x, start_y, start_z, start_rot)
VALUES
    (<id>, '<script_name>', <instance_zone_id>, <entrance_zone_id>, <minutes>,
     <x>, <y>, <z>, <rot>);
```

Add every mob the fight could ever spawn to `instance_entities` (even ones only used on certain difficulties — they just won't be `SpawnMob`'d if not needed):
```sql
INSERT INTO instance_entities (instanceid, id) VALUES (<id>, <mobid>);
```

### Step 2 — Instance Script

Path: `scripts/zones/<zone_name>/instances/<script_name>.lua`

Minimal complete template:
```lua
local ID = zones[xi.zone.YOUR_ZONE]

local DIFFICULTY = { EASY = 1, MEDIUM = 2, HARD = 3 }

local rewards =
{
    [DIFFICULTY.EASY]   = xi.item.SOME_ITEM,
    [DIFFICULTY.MEDIUM] = xi.item.BETTER_ITEM,
    [DIFFICULTY.HARD]   = xi.item.BEST_ITEM,
}

local instanceObject = {}

-- Spawn mobs based on difficulty. Every mob referenced here must have
-- a row in instance_entities even if not used at all difficulties.
instanceObject.onInstanceCreated = function(instance)
    local difficulty = instance:getLocalVar('difficulty')

    if difficulty == DIFFICULTY.EASY then
        SpawnMob(ID.mob.BOSS, instance)
    elseif difficulty == DIFFICULTY.MEDIUM then
        SpawnMob(ID.mob.BOSS, instance)
        SpawnMob(ID.mob.ADD_1, instance)
    elseif difficulty == DIFFICULTY.HARD then
        SpawnMob(ID.mob.BOSS, instance)
        SpawnMob(ID.mob.ADD_1, instance)
        SpawnMob(ID.mob.ADD_2, instance)
    end
end

-- Registers all party members to this instance. Do not change this.
instanceObject.onInstanceCreatedCallback = function(player, instance)
    xi.instance.onInstanceCreatedCallback(player, instance)
end

-- Fires when a player first zones in. Good place for entry messages.
instanceObject.afterInstanceRegister = function(player)
    local instance = player:getInstance()
    -- player:messageSpecial(...) etc.
end

-- Fires every second. Handle locking, win conditions, and ejection here.
instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    -- Lock fight on first boss aggro
    if not instance:isLocked() then
        local boss = GetMobByID(ID.mob.BOSS, instance)
        if boss and boss:isEngaged() then
            instance:lock()
        end
    end

    -- Eject 10 seconds after completion
    if instance:completed() and elapsed >= instance:getLocalVar('ejectAt') then
        for _, player in pairs(instance:getChars()) do
            player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
        end
        return
    end

    xi.instance.updateInstanceTime(instance, elapsed, ID.text)
end

-- Give rewards and schedule ejection.
instanceObject.onInstanceComplete = function(instance)
    local difficulty = instance:getLocalVar('difficulty')
    for _, player in pairs(instance:getChars()) do
        player:addItem(rewards[difficulty])
    end
    instance:setLocalVar('ejectAt', elapsed + 10000)
end

-- Eject players on failure.
instanceObject.onInstanceFailure = function(instance)
    for _, player in pairs(instance:getChars()) do
        player:setPos(0, 0, 0, 0, instance:getEntranceZoneID())
    end
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
end

return instanceObject
```

### Step 3 — Boss Mob Script

Path: `scripts/zones/<zone_name>/mobs/<Mob_Name>.lua`

```lua
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    local instance = mob:getInstance()
    if instance then
        instance:complete()
    end
end

return entity
```

If the fight requires all mobs dead (not just the boss), track kills via a local var:
```lua
entity.onMobDeath = function(mob, player, optParams)
    local instance = mob:getInstance()
    if not instance then return end

    local kills = instance:getLocalVar('kills') + 1
    instance:setLocalVar('kills', kills)
    if kills >= instance:getLocalVar('killsRequired') then
        instance:complete()
    end
end
```

Set `killsRequired` in `onInstanceCreated` based on difficulty.

### Step 4 — Entry NPC Script

Path: `scripts/zones/<zone_name>/npcs/<NPC_Name>.lua`

```lua
local INSTANCE_ID = <your_instanceid>

local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(<difficulty_select_csid>)
end

entity.onEventUpdate = function(player, csid, option, npc)
    if option == 3 then  -- cancel
        player:release()
        return false
    end

    player:setLocalVar('FIGHT_DIFFICULTY', option + 1)

    if player:getLocalVar('INSTANCE_REQUESTED') == 0 then
        player:createInstance(INSTANCE_ID)
        player:setLocalVar('INSTANCE_REQUESTED', 1)
    end

    if
        player:getInstance() ~= nil or
        (player:getLocalVar('INSTANCE_REQUESTED') > 0 and
         player:getLocalVar('INSTANCE_REQUESTED') < 10)
    then
        player:setLocalVar('INSTANCE_REQUESTED', player:getLocalVar('INSTANCE_REQUESTED') + 1)
        return true
    end

    return false
end

entity.onEventFinish = function(player, csid, option, npc)
    local instance = player:getInstance()
    if not instance then return end

    instance:setLocalVar('difficulty', player:getLocalVar('FIGHT_DIFFICULTY'))
    player:setLocalVar('FIGHT_DIFFICULTY', 0)
    player:setLocalVar('INSTANCE_REQUESTED', 0)

    for _, member in pairs(player:getParty()) do
        member:setPos(0, 0, 0, 0, instance:getZone():getID())
    end
end

return entity
```

### Step 5 — Handle Capacity Full (optional)

In `scripts/globals/instance.lua`, add:
```lua
xi.instance.onInstanceCapacityReached = function(player)
    -- notify the player that all slots are currently in use
    player:messageBasic(xi.msg.basic.CANNOT_BE_PROCESSED)
end
```

---

## Lua API Reference — Instance Object

### State & Info
```lua
instance:getID()                  -- instance definition ID (matches instance_list)
instance:getName()                -- instance script name string
instance:getZone()                -- zone object
instance:getEntranceZoneID()      -- zone ID of the entrance area
instance:getTimeLimit()           -- time limit in minutes
instance:getProgress()            -- uint32 progress value
instance:getStage()               -- uint32 stage value
instance:getWipeTime()            -- ms elapsed when wipe was recorded
instance:getLocalVar('key')       -- read a named variable (uint64)
instance:setLocalVar('key', val)  -- write a named variable
instance:getLevelCap()            -- level cap (0 = none)
instance:setLevelCap(level)
instance:setTimeLimit(seconds)
instance:setProgress(val)
instance:setStage(val)
```

### Entity Access
```lua
instance:getChars()               -- all players currently in instance
instance:getMobs()                -- all mobs
instance:getNpcs()                -- all NPCs
instance:getPets()                -- all pets
instance:getAllies()              -- all ally mobs
instance:getEntity(targid, filter)
```

### Fight Control (new)
```lua
instance:lock()                   -- prevent alive players from zoning out
instance:unlock()                 -- re-allow zoning (called automatically by complete/fail)
instance:isLocked()               -- returns bool
instance:hasExited(player)        -- returns true if player left after lock
```

### Lifecycle
```lua
instance:complete()               -- mark won, fire onInstanceComplete, unlock
instance:fail()                   -- mark failed, fire onInstanceFailure, unlock
instance:completed()              -- returns bool
instance:failed()                 -- returns bool
```

---

## Loot Patterns

**Flat reward per difficulty:**
```lua
local rewards = { [1] = xi.item.A, [2] = xi.item.B, [3] = xi.item.C }
player:addItem(rewards[instance:getLocalVar('difficulty')])
```

**Weighted pool per difficulty:**
```lua
local function rollLoot(pool)
    local total = 0
    for _, e in ipairs(pool) do total = total + e.weight end
    local roll, cumulative = math.random(total), 0
    for _, e in ipairs(pool) do
        cumulative = cumulative + e.weight
        if roll <= cumulative then return e.item end
    end
end

local pools =
{
    [1] = { { item = xi.item.A, weight = 80 }, { item = xi.item.B, weight = 20 } },
    [2] = { { item = xi.item.B, weight = 60 }, { item = xi.item.C, weight = 40 } },
    [3] = { { item = xi.item.C, weight = 50 }, { item = xi.item.D, weight = 50 } },
}

player:addItem(rollLoot(pools[instance:getLocalVar('difficulty')]))
```

---

## Key Rules

- Every mob referenced in `onInstanceCreated` must have a row in `instance_entities`
- `difficulty` is set by the entry NPC via `instance:setLocalVar('difficulty', n)` before players zone in
- `instance:lock()` is typically called in `onInstanceTimeUpdate` when the boss first aggros
- `instance:complete()` and `instance:fail()` call `unlock()` automatically — do not unlock manually
- Players who exit a locked instance cannot return — `instance:hasExited(player)` lets you check this from Lua
- The capacity cap (3 concurrent instances) is enforced engine-side — handle the `onInstanceCapacityReached` callback to notify the player
- Ejection is always done in Lua — set a local var for the eject timestamp in `onInstanceComplete` and check it in `onInstanceTimeUpdate`

---

## Account Bank System

An account-wide item bank: unlike every other container (`CItemContainer` / `LOC_*`, all `charid`-keyed with a fixed slot count and per-item stack cap), the bank is keyed by **account ID** (`accid`), shared by every character on the account, and has **no slot limit and no per-item stack cap**. It is *not* a `CItemContainer` and has no `CONTAINER_ID` — see `src/map/utils/bankutils.h` for why.

There is no in-world NPC for this feature. Every action is a chat command, and a companion Ashita v4 addon (`tools/ashita-addons/mimicxi_bank/`) is the intended UI — it just fires the same commands from a window instead of the command line.

### Scope (v1)

Only plain stackable, non-equipment items are bankable (`bankutils::IsBankable`). Equipment/weapons — augmented gear especially — are rejected: the bank table merges rows on `(accid, itemid)` alone, and a unique augmented item can't merge with another. Supporting equipment would mean keying rows on their augment data too (the `extra` blob), which is intentionally left as a future extension.

### Relevant files

| File | Purpose |
|------|---------|
| `sql/account_bank.sql` | `account_bank` table — `(accid, itemid)` → `quantity`, uncapped |
| `src/map/utils/bankutils.h` / `.cpp` | Core logic: deposit/withdraw/list, bankable-type checks |
| `src/map/packets/s2c/0x1f0_bank_list.h` / `.cpp` | Non-retail `GP_SERV_COMMAND_BANK_LIST` packet (opcode `0x1F0`) pushed to the client after every bank action, for the Ashita addon |
| `src/map/lua/lua_baseentity.cpp` | Lua bindings: `getAccountID`, `depositToBank`, `depositAllToBank`, `withdrawFromBank`, `getBankItems`, `getBankItemCount`, `sendBankList` |
| `scripts/commands/bankdeposit.lua`, `bankdepositall.lua`, `bankwithdraw.lua`, `banklist.lua` | Player-usable (`permission = 0`) chat commands (`!bankdeposit`, `!bankdepositall`, `!bankwithdraw`, `!banklist`) |
| `tools/ashita-addons/mimicxi_bank/mimicxi_bank.lua` | Client-side Ashita v4 addon UI (`/mimicxibank` to toggle) |

### The non-retail packet

`GP_SERV_COMMAND_BANK_LIST` (opcode `0x1F0`) exists purely for the addon — the retail client has no handler for it. It is safe **only because** the addon's `packet_in` hook intercepts and blocks it (`e.blocked = true`) before the game engine ever sees it. The opcode was chosen well clear of every opcode this fork currently sends (highest in use is `0x11E`); if a future core update starts using `0x1F0` for something real, bump it in both `src/map/enums/packet_s2c.h` and the addon.

The payload is a fixed-size array of `GP_SERV_COMMAND_BANK_LIST::MAX_ENTRIES` (currently 24) `{itemId, category, quantity}` entries — not paginated. `truncated` is set if the bank holds more distinct items than that. The addon's byte-offset parsing must be kept in sync with the C++ struct by hand; there's no shared schema between the two languages. **This wire format has not been verified against a live client** — if the addon shows blank or garbled data, check the offsets in `mimicxi_bank.lua` against `0x1f0_bank_list.h` first.

### Categories

Categories are computed server-side from the existing `ITEM_TYPE` bitmask (`src/map/items/item.h`) — there's no separate classification table:

```
1 = General   (ITEM_GENERAL)
2 = Usable    (ITEM_USABLE)
3 = Currency  (ITEM_CURRENCY)
4 = Other     (anything else bankable)
```

### Adding a new bank command

Follow the pattern in `scripts/commands/bankwithdraw.lua`: `permission = 0` (player-usable), call the relevant `CLuaBaseEntity` binding, then call `player:sendBankList()` so the addon's view stays in sync (the existing deposit/withdraw bindings already do this internally).
