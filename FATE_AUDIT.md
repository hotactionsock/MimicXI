# MimicXI FATE Audit Checklist

**162 events across 34 zones.**

Each event has 7 items to clear before it is considered ship-ready.
Pre-populated from current Lua state — tick off as you go in-game.

### Checklist items
| # | Item | How to complete |
|---|------|----------------|
| 1 | **Area coords** | Stand in the centre of the fight area, run `!pos`, fill `area.x/y/z` |
| 2 | **Entry NPC pos** | Stand at the sign-up marker, run `!pos`, fill `entryPos` |
| 3 | **mapPos** | Read `<pos>` at the sign-up marker, set `mapPos = "X-Y"` |
| 4 | **mob_groups verified** | Confirm each `base = {zoneId, groupId}` spawns the right mob in DB |
| 5 | **Spawn points** | Survey each spawn point with `!pos`, fill in `spawnPoints` |
| 6 | **Loot confirmed** | No `TODO` comments in the event's loot table |
| 7 | **Tested in-game** | Run the event from spawn to resolution at least once |

### Legend
`[x]` = done / confirmed from Lua   `[ ]` = needs action

---

## Region: STARTER_ZULKHEIM
*Zones: E/W Ronfaure, E/W Sarutabaruta, N/S Gustaberg, La Theine, Valkurm, Konschtat, Tahrongi*

---

### East Ronfaure — Zone 101

#### ER_SCARAB_01 — "Scarab Emergence" | Lv8 | 600s | kill 10
`Mobs: Scarab Beetle×7, Forest Funguar×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_ORC_01 — "Orcish Raiding Party" | Lv10 | 600s | kill 8 | chains→ER_ORC_02
`Mobs: Orcish Fodder×5, Orcish Brawler×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_ORC_02 — "Orcish Advance Guard" | Lv12 | 480s | kill 5 | chain-only
`Mobs: Orcish Brawler×3, Orcish Hexer×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_BOSS_01 — "The Ronfaure Rampage" | Lv16 | 900s | kill 1 | ★
`Mobs: Orcish Tyrant×1 (boss), Orcish Grunt×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_BEETLE_01 — "Beetle Emergence" | Lv9 | 600s | kill 9
`Mobs: Scarab Beetle×5, Stag Beetle×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_WORM_01 — "Worm Surge" | Lv10 | 600s | kill 9 | chains→ER_WORM_02
`Mobs: Tunnel Worm×5, Carrion Worm×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_WORM_02 — "Worm Brood Mother" | Lv12 | 480s | kill 5 | chain-only
`Mobs: Tremor Worm×2, Carrion Worm×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_BOSS_02 — "The Ronfaure Ironhide" | Lv14 | 900s | kill 1 | ★
`Mobs: Ronfaure Beast×1 (boss), Wild Karakul×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ER_BOSS_03 — "The Dread Champion" | Lv20 | 1200s | kill 1 | ★
`Mobs: Dread Champion×1 (boss), Orcish Grunt×5`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

---

### West Ronfaure — Zone 100

#### WR_WORM_01 — "Worm Eruption" | Lv8 | 600s | kill 10
`Mobs: Tunnel Worm×6, Carrion Worm×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_ORC_01 — "Orcish Hunting Band" | Lv10 | 600s | kill 8 | chains→WR_ORC_02
`Mobs: Orcish Fodder×5, Orcish Brawler×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_ORC_02 — "Orcish Warfront" | Lv13 | 480s | kill 5 | chain-only
`Mobs: Orcish Brawler×3, Orcish Hexer×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_BOSS_01 — "The Funguarlord of Ronfaure" | Lv17 | 900s | kill 1 | ★
`Mobs: Funguarlord×1 (boss), Sporemate×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_FUNGUAR_01 — "Funguar Colony" | Lv9 | 600s | kill 9
`Mobs: Forest Funguar×5, Tunnel Worm×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_GOBLIN_01 — "Goblin Toll Collectors" | Lv11 | 600s | kill 8 | chains→WR_GOBLIN_02
`Mobs: Goblin Thug×5, Goblin Trader×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_GOBLIN_02 — "Goblin Ambush Crew" | Lv13 | 480s | kill 5 | chain-only
`Mobs: Goblin Smithy×3, Goblin Mugger×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_BOSS_02 — "The Ronfaure Wolfking" | Lv14 | 900s | kill 1 | ★
`Mobs: Wood Wolfking×1 (boss), Hill Wolf×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### WR_BOSS_03 — "The Ancient Oak Dryad" | Lv20 | 1200s | kill 1 | ★
`Mobs: Ancient Dryad×1 (boss), Forest Funguar×5`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

---

### East Sarutabaruta — Zone 116

#### ES_CROW_01 — "Crow Conspiracy" | Lv8 | 600s | kill 10
`Mobs: Carrion Crow×6, Savanna Rarab×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_YAGUDO_01 — "Yagudo War Flock" | Lv11 | 600s | kill 8 | chains→ES_YAGUDO_02
`Mobs: Yagudo Novice×5, Yagudo Acolyte×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_YAGUDO_02 — "Yagudo Storm Front" | Lv13 | 480s | kill 5 | chain-only
`Mobs: Yagudo Scribe×3, Yagudo Acolyte×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_BOSS_01 — "Savanna Matriarch" | Lv16 | 900s | kill 1 | ★
`Mobs: Goobbue Queen×1 (boss), Wee Mandragora×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_RARAB_01 — "Rarab Stampede" | Lv9 | 600s | kill 9
`Mobs: Savanna Rarab×6, Hill Sapling×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_MANDRAGORA_01 — "Mandragora Rising" | Lv11 | 600s | kill 9 | chains→ES_MANDRAGORA_02
`Mobs: Wee Mandragora×6, Savanna Mandra×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_MANDRAGORA_02 — "Mandragora Elder Brood" | Lv13 | 480s | kill 5 | chain-only
`Mobs: Savanna Mandra×3, Old Mandragora×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_BOSS_02 — "The Flock Father" | Lv14 | 900s | kill 1 | ★
`Mobs: Flock Father×1 (boss), Yagudo Scribe×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### ES_BOSS_03 — "The Savanna Doomsayer" | Lv20 | 1200s | kill 1 | ★
`Mobs: Savanna Doomer×1 (boss), Yagudo Novice×5`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

---

### West Sarutabaruta — Zone 115

#### WS_MANDRAGORA_01 — "Mandragora March" | Lv8 | 600s | kill 10
`Mobs: Mandragora×6, Wee Mandragora×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### WS_YAGUDO_01 — "Yagudo Advance" | Lv10 | 600s | kill 8 | chains→WS_YAGUDO_02
`Mobs: Yagudo Novice×5, Yagudo Acolyte×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### WS_YAGUDO_02 — "Yagudo Crusade" | Lv12 | 480s | kill 5 | chains→WS_BOSS_02
`Mobs: Yagudo Scribe×3, Yagudo Acolyte×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### WS_BOSS_01 — "The Beehive Siegemaster" | Lv15 | 900s | kill 1 | ★
`Mobs: Beehive Master×1 (boss), Drone Bee×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### WS_BOSS_02 — "Yagudo Ascendency" | Lv17 | 480s | kill 1 | ★ | chain-only (from WS_YAGUDO_02)
`Mobs: Yagudo Deacon×1 (boss), Yagudo Acolyte×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### North Gustaberg — Zone 106

#### NG_HORNET_01 — "Hornet Swarm" | Lv10 | 600s | kill 9
`Mobs: Huge Hornet×5, Killer Hornet×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_QUADAV_01 — "Quadav Survey" | Lv12 | 600s | kill 8 | chains→NG_QUADAV_02
`Mobs: Young Quadav×5, Amber Quadav×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_QUADAV_02 — "Quadav Vanguard" | Lv14 | 480s | kill 5 | chain-only
`Mobs: Purple Quadav×3, Amber Quadav×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_BOSS_01 — "The Crumbling Colossus" | Lv18 | 900s | kill 1 | ★
`Mobs: Bedrock Titan×1 (boss), Agitated Newt×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_NEWT_01 — "Newt Frenzy" | Lv10 | 600s | kill 9
`Mobs: Agitated Newt×5, Hill Lizard×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_FUNGUAR_01 — "Funguar Bloom" | Lv12 | 600s | kill 9 | chains→NG_FUNGUAR_02
`Mobs: Forest Funguar×5, Amber Quadav×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_FUNGUAR_02 — "Quadav Spelunkers" | Lv14 | 480s | kill 5 | chain-only
`Mobs: Purple Quadav×3, Blue Quadav×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_BOSS_02 — "The Hollow King" | Lv15 | 900s | kill 1 | ★
`Mobs: Hollow King×1 (boss), Agitated Newt×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [x] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### NG_BOSS_03 — "The Primordial Crusher" | Lv22 | 1200s | kill 1 | ★
`Mobs: Primal Crusher×1 (boss), Purple Quadav×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [x] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### South Gustaberg — Zone 107

#### SG_GOBLIN_01 — "Goblin Assault" | Lv8 | 600s | kill 8 | chains→SG_GOBLIN_02
`Mobs: Goblin Thug×6, Goblin Weaver×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_GOBLIN_02 — "Goblin War Party" | Lv10 | 480s | kill 4 | chain-only
`Mobs: Goblin Digger×2, Goblin Fisher×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_QUADAV_01 — "Quadav Incursion" | Lv12 | 720s | kill 10
`Mobs: Young Quadav×6, Purple Quadav×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_BOSS_01 — "Full Ram Ahead" | Lv16 | 900s | kill 1 | ★
`Mobs: Rampaging Ram×1 (boss), Ornery Sheep×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_WORM_01 — "A Can of Worms" | Lv5 | 600s | kill 8
`Mobs: Tunnel Worm×5, Carrion Worm×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_QUADAV_02 — "Quadav Patrol" | Lv11 | 600s | kill 8 | chains→SG_QUADAV_03
`Mobs: Young Quadav×5, Purple Quadav×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_QUADAV_03 — "Quadav War Column" | Lv13 | 480s | kill 5 | chain-only
`Mobs: Purple Quadav×3, Sapphire Quadav×2`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

#### SG_BOSS_02 — "The Iron Shell" | Lv12 | 900s | kill 1 | ★
`Mobs: Ironshell×1 (boss), Purple Quadav×3`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

Damage/HP to be Investigated

#### SG_BOSS_03 — "The Adamantine Juggernaut" | Lv20 | 1200s | kill 1 | ★
`Mobs: Adamantine Juggernaut×1 (boss)`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [x] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [x] Tested in-game

Damage/HP to be Investigated
---

### La Theine Plateau — Zone 102

#### LT_ORC_01 — "Orcish War Band" | Lv22 | 600s | kill 10 | chains→LT_ORC_02
`Mobs: Orcish Golem×6, Orcish Fighter×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_ORC_02 — "Orcish Rearguard" | Lv25 | 480s | kill 5 | chain-only
`Mobs: Orcish Curser×3, Orcish Hexer×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_BOSS_01 — "The Plateau Terror" | Lv28 | 900s | kill 1 | ★
`Mobs: Plateau Coeurl×1 (boss), Highland Ram×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_RAM_01 — "Ram Rampage" | Lv20 | 600s | kill 9 | chains→LT_RAM_02
`Mobs: Highland Ram×5, Wailing Ram×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_RAM_02 — "Ram Lead Stag" | Lv23 | 480s | kill 4 | chain-only
`Mobs: Wailing Ram×2, Rampaging Ram×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_COEURL_01 — "Coeurl Hunt" | Lv24 | 600s | kill 8
`Mobs: Plateau Coeurl×5, Hill Funguar×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_BOSS_02 — "The Davoi Warmaster" | Lv26 | 900s | kill 1 | ★
`Mobs: Davoi Master×1 (boss), Orcish Golem×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LT_BOSS_03 — "The Ancient Stalker" | Lv32 | 1200s | kill 1 | ★
`Mobs: Elder Stalker×1 (boss), Plateau Coeurl×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Valkurm Dunes — Zone 103

#### VD_LIZARD_01 — "Lizard Stampede" | Lv20 | 600s | kill 10
`Mobs: Dune Lizard×6, Sand Lizard×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### VD_GOBLIN_01 — "Goblin Beachhead" | Lv18 | 600s | kill 9 | chains→VD_GOBLIN_02
`Mobs: Goblin Gambler×5, Goblin Trader×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### VD_GOBLIN_02 — "Goblin Strike Force" | Lv21 | 480s | kill 5 | chain-only
`Mobs: Goblin Smithy×3, Goblin Mugger×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### VD_LEECH_01 — "Leech Tide" | Lv19 | 600s | kill 10
`Mobs: Sea Leech×6, Dune Fly×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### VD_BOSS_01 — "The Dune Emperor" | Lv26 | 900s | kill 1 | ★
`Mobs: Dunes Emperor×1 (boss), Dune Fly×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### VD_BOSS_02 — "The Dune Scourge" | Lv23 | 900s | kill 1 | ★
`Mobs: Dune Scourge×1 (boss), Sea Leech×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### VD_BOSS_03 — "The Eternal Hunger" | Lv30 | 1200s | kill 1 | ★
`Mobs: Eternal Hunger×1 (boss), Sand Lizard×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Konschtat Highlands — Zone 108

#### KH_CRAWLER_01 — "Crawler Infestation" | Lv22 | 600s | kill 10 | chains→KH_CRAWLER_02
`Mobs: Hill Crawler×6, Dew Glider×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_CRAWLER_02 — "Crawler Surge" | Lv25 | 480s | kill 5 | chain-only
`Mobs: Gliding Lizard×3, Giant Crawler×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_QUADAV_01 — "Quadav Prospectors" | Lv22 | 600s | kill 9 | chains→KH_QUADAV_02
`Mobs: Quadav Miner×5, Blue Quadav×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_QUADAV_02 — "Quadav Honour Guard" | Lv25 | 480s | kill 5 | chain-only
`Mobs: Ruby Quadav×3, Shield Quadav×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_RAM_01 — "Ram Stampede" | Lv22 | 600s | kill 9
`Mobs: Wailing Ram×5, Ornery Sheep×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_BOSS_01 — "Wandering Colossus" | Lv28 | 900s | kill 1 | ★
`Mobs: Stone Colossus×1 (boss), Konschtat Bat×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_BOSS_02 — "The Konschtat Warlord" | Lv26 | 900s | kill 1 | ★
`Mobs: Stone Warlord×1 (boss), Blue Quadav×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### KH_BOSS_03 — "The Konschtat Behemoth" | Lv32 | 1200s | kill 1 | ★
`Mobs: Stone Behemoth×1 (boss), Konschtat Bat×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Tahrongi Canyon — Zone 117

#### TC_GOBLIN_01 — "Goblin Poachers" | Lv20 | 600s | kill 10
`Mobs: Goblin Poacher×6, Goblin Tinker×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_DHALMEL_01 — "Dhalmel Frenzy" | Lv18 | 600s | kill 8
`Mobs: Canyon Dhalmel×5, Canyon Lizard×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_MANDRAGORA_01 — "Mandragora Uprising" | Lv20 | 600s | kill 10 | chains→TC_MANDRAGORA_02
`Mobs: Canyon Mandra×6, Flytrap×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_MANDRAGORA_02 — "Mandragora Elder Choir" | Lv22 | 480s | kill 5 | chain-only
`Mobs: Old Mandragora×3, Canyon Funguar×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_GOBLIN_02 — "Goblin Black Market" | Lv22 | 600s | kill 8
`Mobs: Goblin Tinker×5, Goblin Gambler×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_BOSS_01 — "The Canyon Tyrant" | Lv24 | 900s | kill 1 | ★
`Mobs: Canyon Tyrant×1 (boss), Crawlerling×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_BOSS_02 — "The Canyon Empress" | Lv22 | 900s | kill 1 | ★
`Mobs: Canyon Empress×1 (boss), Canyon Lizard×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### TC_BOSS_03 — "The Eternal Sentinel" | Lv28 | 1200s | kill 1 | ★
`Mobs: Stone Sentinel×1 (boss), Crawlerling×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: DERFLAND_ARAGONEU
*Zones: Pashhow, Rolanberry, Buburimu, Meriphataud*

---

### Pashhow Marshlands — Zone 109

#### PM_QUADAV_01 — "Quadav Survey Party" | Lv25 | 600s | kill 10 | chains→PM_QUADAV_02
`Mobs: Quadav Miner×6, Purple Quadav×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_QUADAV_02 — "Quadav Assault Force" | Lv28 | 480s | kill 5 | chain-only
`Mobs: Ruby Quadav×3, Shield Quadav×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_LEECH_01 — "Leech Rising" | Lv22 | 600s | kill 12
`Mobs: Marsh Leech×12`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_FUNGUAR_01 — "Funguar Bloom" | Lv25 | 600s | kill 10 | chains→PM_FUNGUAR_02
`Mobs: Marsh Funguar×7, Spore Funguar×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_FUNGUAR_02 — "Spore Tide" | Lv28 | 480s | kill 5 | chain-only
`Mobs: Elder Funguar×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_BOSS_01 — "The Bog Sovereign" | Lv32 | 900s | kill 1 | ★
`Mobs: Bog Sovereign×1 (boss), Marsh Clot×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_BOSS_02 — "The Stenchmaster" | Lv30 | 900s | kill 1 | ★
`Mobs: Stenchmaster×1 (boss), Marsh Malboro×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### PM_BOSS_03 — "The Fetid Empress" | Lv40 | 1200s | kill 1 | ★
`Mobs: Fetid Empress×1 (boss)`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Rolanberry Fields — Zone 110

#### RF_QUADAV_01 — "Quadav Work Party" | Lv32 | 600s | kill 10
`Mobs: Gem Quadav×6, Blue Quadav×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RF_BEETLE_01 — "Beetle Blight" | Lv29 | 600s | kill 12
`Mobs: Field Beetle×12`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RF_QUADAV_02 — "Quadav Supply Run" | Lv31 | 600s | kill 10 | chains→RF_QUADAV_03
`Mobs: Diamond Quadav×6, Quadav Sniper×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RF_QUADAV_03 — "Quadav Vanguard" | Lv34 | 480s | kill 5 | chain-only
`Mobs: Veteran Quadav×3, Quadav Warlord×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RF_BOSS_01 — "The Fieldcrawler Queen" | Lv36 | 900s | kill 1 | ★
`Mobs: Crawler Queen×1 (boss), Guard Crawler×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RF_BOSS_02 — "The Rolanberry Goobbue" | Lv35 | 900s | kill 1 | ★
`Mobs: Berry Goobbue×1 (boss), Field Goobbue×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RF_BOSS_03 — "The Ancient Cultivator" | Lv44 | 1200s | kill 1 | ★
`Mobs: Old Cultivator×1 (boss)`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Buburimu Peninsula — Zone 118

#### BP_GOBLIN_01 — "Goblin Shore Raid" | Lv35 | 600s | kill 10
`Mobs: Goblin Leecher×6, Goblin Mugger×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_GOBLIN_02 — "Goblin Hecklers" | Lv33 | 600s | kill 8
`Mobs: Goblin Heckler×8`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_LEECH_01 — "Sea Leech Swarm" | Lv31 | 600s | kill 12
`Mobs: Sea Leech×12`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_SNIPPER_01 — "Snipper Skirmish" | Lv33 | 600s | kill 10 | chains→BP_SNIPPER_02
`Mobs: Shore Snipper×10`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_SNIPPER_02 — "Giant Snipper Advance" | Lv36 | 480s | kill 5 | chain-only
`Mobs: Giant Snipper×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_BOSS_01 — "Peninsula Predator" | Lv42 | 900s | kill 1 | ★
`Mobs: Shore Coeurl×1 (boss), Buburimu Roc×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_BOSS_02 — "The Tidal Crusher" | Lv38 | 900s | kill 1 | ★
`Mobs: Tidal Crusher×1 (boss), Buburimu Crab×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BP_BOSS_03 — "The Devourer of Tides" | Lv50 | 1200s | kill 1 | ★
`Mobs: Tide Devourer×1 (boss)`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Meriphataud Mountains — Zone 119

#### MM_YAGUDO_01 — "Yagudo Pilgrimage Guard" | Lv28 | 600s | kill 9 | chains→MM_YAGUDO_02
`Mobs: Yagudo Zealot×5, Yagudo Priest×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_YAGUDO_02 — "Yagudo Choir of Wrath" | Lv32 | 480s | kill 5 | chain-only
`Mobs: Yagudo Votary×3, Yagudo Scribe×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_RAPTOR_01 — "Raptor Pack" | Lv27 | 600s | kill 10
`Mobs: Mount Raptor×7, Peak Raptor×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_BOMB_01 — "Bomb Uprising" | Lv29 | 600s | kill 10 | chains→MM_BOMB_02
`Mobs: Trail Bomb×7, Magma Bomb×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_BOMB_02 — "Inferno Wave" | Lv32 | 480s | kill 5 | chain-only
`Mobs: Volcanic Bomb×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_BOSS_01 — "The Mountain Detonator" | Lv35 | 900s | kill 1 | ★
`Mobs: Peak Detonator×1 (boss), Mountain Bomb×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_BOSS_02 — "The Talon of Oztroja" | Lv34 | 900s | kill 1 | ★
`Mobs: Oztroja Talon×1 (boss), Yagudo Devotee×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MM_BOSS_03 — "The Summit Predator" | Lv44 | 1200s | kill 1 | ★
`Mobs: Peak Predator×1 (boss)`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: NORVALLEN_QUFIM
*Zones: Batallia, Jugner, Qufim, Sauromugue*

---

### Batallia Downs — Zone 105

#### BD_ORC_01 — "Orcish Skirmish Line" | Lv34 | 600s | kill 10
`Mobs: Orcish Warrior×6, Orcish Veteran×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BD_BOSS_01 — "The Downs Ravager" | Lv38 | 900s | kill 1 | ★
`Mobs: Downs Ravager×1 (boss), Downs Raptor×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Jugner Forest — Zone 104

#### JF_ORC_01 — "Orcish Forest Patrol" | Lv30 | 600s | kill 10
`Mobs: Orcish Golem×6, Orcish Curser×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### JF_BOSS_01 — "The Ancient Sapling" | Lv38 | 900s | kill 1 | ★
`Mobs: Elder Sapling×1 (boss), Forest Sapling×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Qufim Island — Zone 126

#### QI_GIGAS_01 — "Gigas Shore Party" | Lv35 | 600s | kill 9
`Mobs: Gigas Bhikkhu×5, Gigas Pickman×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### QI_BOSS_01 — "The Qufim Leviathan" | Lv42 | 900s | kill 1 | ★
`Mobs: Sea Leviathan×1 (boss), Island Wight×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Sauromugue Champaign — Zone 120

#### SC_ORC_01 — "Orcish Field Operations" | Lv40 | 600s | kill 10 | chains→SC_ORC_02
`Mobs: Orcish Hexer×5, Orcish Trooper×5`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### SC_ORC_02 — "Orcish Blitz Vanguard" | Lv44 | 480s | kill 5 | chain-only
`Mobs: Orcish Warden×3, Orcish Captain×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### SC_BOSS_01 — "The Champaign Warlord" | Lv48 | 900s | kill 1 | ★
`Mobs: Plains Warlord×1 (boss), Orcish Elite×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: NORTHLANDS
*Zones: Beaucedine Glacier, Xarcabard*

---

### Beaucedine Glacier — Zone 111

#### BG_GIGAS_01 — "Gigas Hunting Pack" | Lv52 | 600s | kill 9 | chains→BG_GIGAS_02
`Mobs: Gigas Bhikkhu×5, Gigas Flagman×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BG_GIGAS_02 — "Glacial Vanguard" | Lv56 | 480s | kill 5 | chain-only
`Mobs: Gigas Shaman×3, Gigas Jarl×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BG_BOSS_01 — "The Glacier Titan" | Lv58 | 900s | kill 1 | ★
`Mobs: Glacier Titan×1 (boss), Glacial Wolf×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Xarcabard — Zone 112

#### XC_SHADOW_01 — "Shadow Infestation" | Lv58 | 600s | kill 8
`Mobs: Xarc Shadow×5, Dark Corse×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### XC_BOSS_01 — "The Chaos Shade" | Lv62 | 900s | kill 1 | ★
`Mobs: Chaos Shade×1 (boss), Shade Wraith×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: KOLSHUSHU_ELSHIMO
*Zones: Bibiki Bay, Cape Teriggan, Yuhtunga, Yhoator*

---

### Bibiki Bay — Zone 4

#### BB_SAHAGIN_01 — "Sahagin Tidal Raid" | Lv52 | 600s | kill 9 | chains→BB_SAHAGIN_02
`Mobs: Sahagin Diver×5, Sahagin Priest×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BB_SAHAGIN_02 — "Sahagin Strike Force" | Lv56 | 480s | kill 5 | chain-only
`Mobs: Sahagin Raider×3, Bay Marshal×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BB_BOSS_01 — "The Bay Kraken" | Lv62 | 900s | kill 1 | ★
`Mobs: Bay Kraken×1 (boss), Bibiki Sahagin×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Cape Teriggan — Zone 113

#### CT_GOBLIN_01 — "Goblin Excavation Crew" | Lv55 | 600s | kill 9
`Mobs: Goblin Bondman×5, Goblin Herder×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### CT_BOSS_01 — "The Cape Terror" | Lv62 | 900s | kill 1 | ★
`Mobs: Cape Terror×1 (boss), Teriggan Tiger×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Yuhtunga Jungle — Zone 123

#### YJ_TONBERRY_01 — "Tonberry Procession" | Lv50 | 600s | kill 8
`Mobs: Berry Initiate×5, Berry Stalker×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### YJ_BOSS_01 — "The Jungle Sovereign" | Lv58 | 900s | kill 1 | ★
`Mobs: Jungle Tyrant×1 (boss), Jungle Sapling×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Yhoator Jungle — Zone 124

#### YHO_TONBERRY_01 — "Tonberry Elder Conclave" | Lv55 | 600s | kill 8 | chains→YHO_TONBERRY_02
`Mobs: Tonberry Elder×5, Berry Assassin×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### YHO_TONBERRY_02 — "Tonberry High Council" | Lv59 | 480s | kill 5 | chain-only
`Mobs: Berry Priest×3, Tonberry King×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### YHO_BOSS_01 — "The Yhoator Deathbringer" | Lv63 | 900s | kill 1 | ★
`Mobs: Yhoator Slayer×1 (boss), Berry Warlock×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: LI'TELOR
*Zones: Ro'Maeve, Sanctuary of Zi'Tah*

---

### Ro'Maeve — Zone 122

#### RM_UNDEAD_01 — "Undead Convergence" | Lv60 | 600s | kill 9 | chains→RM_UNDEAD_02
`Mobs: Maeve Skeleton×5, Ro'Maeve Ghost×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RM_UNDEAD_02 — "Ancient Guardian Host" | Lv64 | 480s | kill 5 | chain-only
`Mobs: Ro'Maeve Wight×3, Maeve Spectre×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RM_BOSS_01 — "The Eternal Sentry" | Lv68 | 900s | kill 1 | ★
`Mobs: Eternal Sentry×1 (boss), Stone Revenant×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### The Sanctuary of Zi'Tah — Zone 121

#### SZ_MANDRAGORA_01 — "Mandragora Uprising" | Lv58 | 600s | kill 9
`Mobs: Grove Mandra×5, Zi'Tah Sapling×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### SZ_BOSS_01 — "The Grove Devourer" | Lv66 | 900s | kill 1 | ★
`Mobs: Grove Devourer×1 (boss), Grove Sapling×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: SKY / SEA / HIGH-END
*Zones: Al'Taieu, Attohwa Chasm, Ru'Aun Gardens, Uleguerand Range*

---

### Al'Taieu — Zone 33

#### AT_PHUABO_01 — "Phuabo Emergence" | Lv70 | 600s | kill 8
`Mobs: Taieu Phuabo×5, Taieu Xzomit×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### AT_BOSS_01 — "The Ix'aern Arbiter" | Lv75 | 900s | kill 1 | ★
`Mobs: Ix'aern Judge×1 (boss), Taieu Zphar×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Attohwa Chasm — Zone 7

#### AC_BUGARD_01 — "Bugard Stampede" | Lv68 | 600s | kill 8
`Mobs: Attohwa Bugard×5, Chasm Antlion×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### AC_BOSS_01 — "The Chasm Sovereign" | Lv75 | 900s | kill 1 | ★
`Mobs: Sovereign×1 (boss), Dusk Antlion×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Ru'Aun Gardens — Zone 130

#### RG_KINDRED_01 — "Kindred Patrol" | Lv68 | 600s | kill 8 | chains→RG_KINDRED_02
`Mobs: Kindred Cleric×4, Kindred Tamer×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RG_KINDRED_02 — "Kindred Vanguard" | Lv72 | 480s | kill 5 | chain-only
`Mobs: Kindred Mage×3, Kindred Shadow×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### RG_BOSS_01 — "The Garden Destroyer" | Lv75 | 900s | kill 1 | ★
`Mobs: Sky Destroyer×1 (boss), Kindred Elite×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Uleguerand Range — Zone 5

#### UR_DRAKE_01 — "Icedrake Rampage" | Lv65 | 600s | kill 8
`Mobs: Range Icedrake×5, Range Wyvern×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### UR_BOSS_01 — "The Range Leviathan" | Lv72 | 900s | kill 1 | ★
`Mobs: Ice Leviathan×1 (boss), Range Buffalo×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: TREASURES OF AHT URHGAN
*Zones: Bhaflau Thickets, Caedarva Mire, Mount Zhayolm*

---

### Bhaflau Thickets — Zone 52

#### BT_MAMOOL_01 — "Mamool Ja Incursion" | Lv60 | 600s | kill 9 | chains→BT_MAMOOL_02
`Mobs: Mamool Mimic×5, Mamool Slayer×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BT_MAMOOL_02 — "Mamool Ja Taskforce" | Lv64 | 480s | kill 5 | chain-only
`Mobs: Mamool Sophist×3, Mamool Warlord×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### BT_BOSS_01 — "The Thicket Monarch" | Lv68 | 900s | kill 1 | ★
`Mobs: Thicket King×1 (boss), Bhaflau Troll×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Caedarva Mire — Zone 79

#### CM_LAMIA_01 — "Lamia Ask You A Question" | Lv58 | 600s | kill 9
`Mobs: Lamia Dancer×5, Lamia Bowyer×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### CM_BOSS_01 — "The Mire Colossus" | Lv66 | 900s | kill 1 | ★
`Mobs: Mire Colossus×1 (boss), Caedarva Lamia×4`
- [x] Area coords surveyed
- [x] Entry NPC position surveyed
- [x] mapPos recorded
- [ ] mob_groups verified
- [x] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Mount Zhayolm — Zone 61

#### MZ_SOULFLAYER_01 — "Soulflayer Surge" | Lv65 | 600s | kill 8
`Mobs: Zhayolm Flayer×5, Mount Poroggo×3`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MZ_BOSS_01 — "The Volcano Lord" | Lv73 | 900s | kill 1 | ★
`Mobs: Volcano Lord×1 (boss), Zhayolm Troll×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Region: LUFAISE / MISAREAUX
*Zones: Lufaise Meadows, Misareaux Coast*

---

### Lufaise Meadows — Zone 24

#### LM_OPOPO_01 — "Opo-opo Troop Assault" | Lv45 | 600s | kill 10
`Mobs: Meadow Opo-opo×6, Meadows Ram×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### LM_BOSS_01 — "The Meadow Titan" | Lv52 | 900s | kill 1 | ★
`Mobs: Meadow Titan×1 (boss), Lufaise Ram×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

### Misareaux Coast — Zone 25

#### MC_GIGAS_01 — "Gigas Coastal Landing" | Lv48 | 600s | kill 10 | chains→MC_GIGAS_02
`Mobs: Gigas Bhikkhu×6, Gigas Reaver×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MC_GIGAS_02 — "Gigas Warband" | Lv52 | 480s | kill 5 | chain-only
`Mobs: Gigas Shaman×3, Gigas Jarl×2`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

#### MC_BOSS_01 — "The Coastal Ravager" | Lv56 | 900s | kill 1 | ★
`Mobs: Shore Ravager×1 (boss), Coast Bugard×4`
- [ ] Area coords surveyed
- [ ] Entry NPC position surveyed
- [ ] mapPos recorded
- [ ] mob_groups verified
- [ ] Spawn points surveyed
- [x] Loot confirmed
- [ ] Tested in-game

---

## Outstanding issues (not event-specific)

### Regional loot pool — 18 weapon items missing from ShiningFantasia DB
These items need to be created before their loot slots will deliver anything. All currently have placeholder 297xx IDs in `regions.lua`.

| Region pool | Item | Level | Placeholder ID |
|---|---|---|---|
| STARTER_ZULKHEIM | Apprentice's Rod | 16 | 29887 |
| STARTER_ZULKHEIM | Thornwood Shortbow | 18 | 29901 |
| STARTER_ZULKHEIM | Foxfire Katana | 24 | 29875 |
| DERFLAND_ARAGONEU | Ashbane Foil | 28 | 29852 |
| DERFLAND_ARAGONEU | Venom Fang | 32 | 29893 |
| DERFLAND_ARAGONEU | Redrock Chopper | 38 | 29861 |
| NORVALLEN_QUFIM | Ironcleft Claymore | 22 | 29857 |
| NORVALLEN_QUFIM | Embervein Staff | 35 | 29888 |
| NORVALLEN_QUFIM | Emberthorn Spear | 40 | 29872 |
| NORVALLEN_QUFIM | Temple Fists | 40 | 29898 |
| NORTHLANDS | Colossus Axe | 45 | 29864 |
| NORTHLANDS | Verdant Saber | 48 | 29853 |
| NORTHLANDS | Spellbinder's Cudgel | 45 | 29884 |
| NORTHLANDS | Bloodmire Scythe | 50 | 29868 |
| NORTHLANDS | Ironstring Longbow | 50 | 29902 |
| KOLSHUSHU_ELSHIMO | Bronzelock Rifle | 48 | 29906 |
| KOLSHUSHU_ELSHIMO | Bloodpetal Blade | 42 | 29876 |
| KOLSHUSHU_ELSHIMO / TOAU | Dawnreach Tachi | 55 | 29880 |

- [ ] All 18 items created in ShiningFantasia and pushed to DB
- [ ] Placeholder IDs in `regions.lua` updated to real IDs once created
