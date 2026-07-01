# Nephalem Rift — Developer Design Document

## Overview

The Rift is custom instanced endgame content set in Walk of Echoes (zone 182), entered via an NPC in Xarcabard (zone 112). It uses the zone-layer instance system — players remain in the same zone without a client zone change, invisible to regular players and each other's instances.

There are 10 tiers at launch, expanding to 20. Each tier increases mob level, HP, mob count, and Treasure Hunter level. Players can repeat any tier they have previously cleared.

---

## File Structure

| File | Purpose |
|------|---------|
| `scripts/globals/rift.lua` | All shared logic — scaling, drop tables, modifier system, leaderboard, NPC flow, spawn helpers |
| `scripts/zones/Walk_of_Echoes/instances/Rift.lua` | Instance lifecycle hooks (spawn, tick, complete, fail) |
| `scripts/zones/Xarcabard/Zone.lua` | Dynamic NPC spawn (Rift Surveyor) |
| `scripts/zones/Walk_of_Echoes/Zone.lua` | `onZoneIn` hook that detects pending tier and enters layer |
| `sql/rift.sql` | `instance_list` row and `rift_leaderboard` table |

---

## Instance Entry Flow

1. Player talks to **Rift Surveyor** NPC in Xarcabard (spawned dynamically in `onInitialize` — no `npc_list` row required).
2. First trigger cycles the tier selection (1 → max available). Max available = highest cleared tier + 1, capped at `xi.rift.MAX_TIER`. Requires `xi.item.DARK_MATTER` in inventory for first access.
3. Triggering again within 5 seconds confirms the selection. The chosen tier is written to `RIFT_PENDING_TIER` charvar and the player is teleported to Walk of Echoes.
4. `onZoneIn` in Walk of Echoes detects the pending tier, calls `player:createInstance(xi.rift.INSTANCE_ID)`, and polls via `player:timer(1000, tryEnterLayer)` until the async load completes (up to 10 seconds).
5. Once ready, all party members are moved into the instance layer (`player:setInstance` → `player:enterInstanceLayer`).
6. `onInstanceCreated` fires: mobs are shuffled across spawn points and spawned via `instance:insertDynamicEntity`. No `instance_entities` SQL rows are needed.

---

## Scaling Per Tier

| Function | Formula | T1 | T10 |
|---------|---------|-----|-----|
| `mobLevel(tier)` | `75 + (tier-1) * 5` | 75 | 120 |
| `hpMult(tier)` | `1.0 + (tier-1) * 0.4` | 1.0x | 4.6x |
| `mobCount(tier)` | `4 + tier` | 5 | 14 |
| `thLevel(tier)` | `ceil(tier / 2)` | TH1 | TH5 |

The boss spawns after all regular mobs are killed. Boss level = `mobLevel + 5`, HP multiplier = `hpMult * 2`, flagged as NM via `MOBMOD_CHECK_AS_NM`.

---

## Drop System

All rates are out of 10,000. Shards drop from any mob; UR items are boss-only.

### Shard Rates (per mob kill)

Boss kills receive 2× multiplier on shard rates.

| Item | T1 | T10 | T20 |
|------|----|-----|-----|
| Nascent Shard | 2% | 11% | 18% |
| Tempered Shard | 0.5% | 4.5% | 8% |

### Ultra-Rare Pool (boss-only, one item per kill)

Roll once against `UR_RATES`. If successful, one item is selected at random from `xi.rift.UR_POOL`. Only one UR item can drop per boss kill.

| Tier | Rate | Chance |
|------|------|--------|
| T1 | 3/10000 | 0.03% |
| T10 | 100/10000 | 1% |
| T20 | 400/10000 | 4% |

**To add a new UR item**, append to `xi.rift.UR_POOL` in `rift.lua`:
```lua
{ item = xi.item.YOUR_ITEM, displayName = 'Display Name' },
```
No other changes required. Adding items dilutes the per-item rate proportionally.

---

## Seasonal Modifier System

Active modifiers are stored in server vars `RIFT_MOD_1` through `RIFT_MOD_5`. Values are string keys matching entries in `xi.rift.MODIFIERS`. Set via SQL:

```sql
UPDATE server_vars SET value = 'FORTIFIED' WHERE varname = 'RIFT_MOD_1';
UPDATE server_vars SET value = '0'         WHERE varname = 'RIFT_MOD_2'; -- clear slot
```

Up to 5 modifiers can be active simultaneously. Changes take effect on the next instance creation — existing runs are unaffected.

### Modifier Callbacks

Each modifier may define any combination of:

| Callback | When it fires |
|----------|--------------|
| `onMobInit(mob, tier)` | Inside every regular mob's `onMobInitialize` |
| `onBossInit(mob, tier)` | Inside the boss's `onMobInitialize` (falls back to `onMobInit` if absent) |
| `onTick(instance, elapsed, tier)` | Every second in `onInstanceTimeUpdate` |

### Built-in Modifiers

| Key | Effect |
|-----|--------|
| `ENRAGE` | Haste on all mobs (scales with tier); boss gets extra |
| `FORTIFIED` | -50% PDT, +50% MDT, +50% HP — rewards magic parties |
| `WARDED` | -50% MDT, +50% PDT — rewards melee parties |
| `UNYIELDING` | Uncapped damage reduction to all types, scales T1→T10 |
| `EMPOWERED` | Higher base damage on all mobs |
| `ACCELERATED` | Faster TP generation |
| `BLOODDRAIN` | Players lose HP every 3s (floor: 1 HP) |
| `MANADRAIN` | Players lose MP every 5s |

**To add a new modifier**, add an entry to `xi.rift.MODIFIERS` in `rift.lua` and activate it via server var. No instance script changes needed.

---

## Leaderboard & Announcements

Clears are written to `rift_leaderboard` (char_id, char_name, tier, clear_time, season). Season is read from server var `RIFT_SEASON`.

Speed records are stored in server vars `RIFT_RECORD_T{tier}_S{season}`. When a new record is set a server-wide announcement fires via `printToArea` on `xi.msg.area.SYSTEM` / `xi.msg.channel.SYSTEM_3`.

A server-wide announcement also fires when a UR item drops.

**Season reset**: increment `RIFT_SEASON` in `server_vars`. Records and leaderboard entries for the previous season are preserved under the old season number.

---

## Spawn Points

All spawn points are in `xi.rift.SPAWN_POINTS` as `{x, y, z, rot}` entries. The last entry is reserved as the boss arena. Regular mob positions are Fisher-Yates shuffled each run so placement varies. **All current coordinates are placeholder stubs** — replace with `/pos` readings in-game before going live.

---

## Extending to Tier 20

1. Update `xi.rift.MAX_TIER = 20` in `rift.lua`.
2. Add mob pool entries for tiers 11–20 in `xi.rift.MOB_POOLS` and boss entries in `xi.rift.BOSSES`.
3. Rate tables (`NASCENT_RATES`, `TEMPERED_RATES`, `UR_RATES`) already have T11–T20 entries.
4. TH level at T20 = `ceil(20/2)` = TH10 — within the engine hard cap of TH14.
