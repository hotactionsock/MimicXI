# MimicXI — Sessions Design Document

> Living document tracking completed work, in-progress systems, and the development pipeline for MimicXI — a personal FFXI server fork of LandSandBoat.

**Last updated:** 2026-05-26  
**Base branch:** `base` (forked from LandSandBoat/server)

---

## Project Goals

MimicXI is a personal FFXI server built on LandSandBoat with the following design pillars:

- **Lv75 cap era feel** — content and balance targeting the "era" experience up to Wings of the Goddess / Chains of Promathia
- **Custom content** — original systems (Casket Mimic, job balance mechanics, ecosystem resistances) layered on top of retail accuracy
- **Accessibility** — faster progression, web-based account/character creation, and quality-of-life improvements without destroying challenge
- **Modularity** — all custom content via the module system (`modules/`) so it can be toggled, debugged, and removed cleanly

---

## Pipeline Status at a Glance

| Session / System | Status | Branch |
|---|---|---|
| Fully rebalanced damage/combat | **Merged** | `base` |
| Flattened XP curve | **Merged** | `base` |
| Full job balance pass | **Merged** | `base` |
| Casket System — Augments/Mimics | **Merged** | `base` |
| New Trust Implementations | **Merged** | `base` |
| Fully bespoke Website & Launcher | **Merged + local** | `base` |
| New Armor, Weapons and Items | **Built — not merged** | `claude/design-new-items-hecdW` |
| Weapon Augment Crafting System | **Built — not merged** | `claude/augment-crafting-system-1I7Eh` |
| New Levelling Incentives | **Built — not merged** | `claude/leveling-incentive-systems-yXQU2` |
| Treasure Hunter Changes | **Planned** (design: Key Items, not THF) | — |
| Levelling System Alternatives — Hunt Board | **Planned** | — |
| Daily Login Rewards & New NPC Shops | **Planned** | — |
| Incremental Weapon Augmentation System | **Planned** | — |
| Modular Endgame System | **Planned** | — |

---

## Completed & Merged Sessions

### Session 1 — Initial Fork & Vibes Setup
**PRs:** #1, #2 | **Date:** 2026-04-22  
**Branch:** `vibes`

Initial setup of the MimicXI fork from LandSandBoat. Established `base` as the main development branch and `vibes` as a staging/experimental area.

**Deliverables:**
- Repository forked, base branch established
- Vibes branch created as staging area

---

### Session 2 — Fully Rebalanced Damage/Combat
**PRs:** #3, #5 | **Date:** 2026-04-23–24  
**Branch:** `claude/rebalance-combat-damage-types-7Oa6r`  
**Session:** `session_016edVohyjzzdCL5Zw78FGAB`

Global ecosystem-based resistance system giving every mob family meaningful damage type weaknesses and resistances, making weapon and spell choice feel strategic rather than cosmetic.

**Deliverables:**
- `scripts/globals/mob_family_resistances.lua` — SDT (Specific Damage Taken) mods at spawn for all 21 ecosystems
- `xi.mob.onMobSpawn` global hook in `scripts/globals/mobs.lua` — runs before per-mob scripts, individual overrides still work
- C++ `luautils::OnMobSpawn` calls global hook first
- Tuning pass: May 18 follow-up adjusted SDT values after initial playtesting

**Ecosystem coverage:**

| Family | Resistances | Weaknesses |
|---|---|---|
| AMORPH | Physical ×4 | Fire, Ice, Thunder |
| AQUAN | Fire, Earth | Thunder, Ice |
| ARCANA | Physical ×4 | Dark, Light |
| ARCHAICMACHINE | Ice, Wind, Earth | Thunder, Water |
| AVATAR | Slash, Dark | Earth, Light |
| BEAST | Thunder, Earth | Fire, Ice |
| BEASTMEN | Earth, Dark | Fire, Light |
| BIRD | Wind, Earth | Ice, Thunder |
| DEMON | Fire, Dark | Light, Ice |
| DRAGON | Fire, Slash | Ice, Thunder |
| ELEMENTAL | Physical ×4 | — |
| EMPTY | Pierce, Slash, Dark | Light, Fire |
| HUMANOID | — (balanced) | — |
| LIZARD | Fire, Earth | Ice, Water |
| LUMINIAN | Physical ×3 | Thunder, Light |
| LUMINION | Slash, Pierce, Dark | Light, Thunder |
| PLANTOID | Water, Earth | Fire, Ice, Wind, Slash |
| UNDEAD | Ice, Dark, Pierce, Slash | Light, Fire, Blunt |
| VERMIN | Earth, Thunder | Fire, Ice, Wind |
| VORAGEAN | Physical ×4 | Thunder, Light |

---

### Session 3 — Flattened XP Curve (Lv50–75)
**PR:** #4 | **Date:** 2026-04-23  
**Branch:** `claude/flatten-xp-curve-7kP3V`  
**Session:** `session_01JRCUF3rbKyWTmcJNXyxDfL`

Reduced the XP grind in the 50–75 range by flattening per-level cost to mirror the shape of the 1–50 curve.

**Deliverables:**
- XP table updated for levels 51–75:
  - 51–55: +200 XP/level
  - 56–60: +300 XP/level
  - 61–65: +400 XP/level
  - 66–70: +500 XP/level
  - 71–75: +600 XP/level
- Total XP to Lv75: **42,000 → 17,700**

---

### Session 4 — Full Job Balance Pass (All 14 Jobs)
**PRs:** #6, #7, #8, #9 | **Date:** 2026-04-27–29  
**Branch:** `claude/balance-warrior-job-MYvlk`

Custom mechanics for every job at the Lv75 cap — each job received 1–3 systems creating unique combat identity without disrupting retail feel.

| Job | Mechanics Added |
|---|---|
| **WAR** | Aggressor and Tomahawk exploit weapon-type physical weaknesses |
| **MNK** | Footwork Third Strike (rhythm combo), Focus Vital Point |
| **THF** | Feint Open Guard (defense debuff window), SA/TA Pickpocket (gil steal) |
| **WHM** | Solace shield stacking, Misery damage stacking, Divine Seal Aura |
| **BLM** | Elemental Seal — Arcane Echo (resonance burst) |
| **RDM** | Enspell identity via Composure and Chainspell |
| **PLD** | Holy Retribution — Sentinel absorbs hits, bursts on expiry |
| **DRK** | Soul Reservoir, Dark Empowerment, Crimson Tide |
| **BRD** | Threnody vulnerability, Troubadour resonance, Finale clarity, Lullaby groggy |
| **SAM** | Poised Strike, Drawn Bow Meditate, Zanshin Momentum |
| **RNG** | Velocity Shot Point Blank — axe hits generate +50 TP during VS |
| **NIN** | Blade Dance, Yonin Aggressive Evasion, Elemental Scar |
| **DRG** | Draconic Resonance, Wyvern's Blessing, Angon Breach |
| **SMN** | Ward Resonance — Ward BPs amplify next Rage BP |

**Infrastructure:** Toggleable combat notifications (`MIMIC_COMBAT_NOTIFICATIONS`), `MAX_EFFECTID` raised to 822, DRG/SMN IDs reassigned below hard cap of 817.

---

### Session 5 — Casket System: Augments & Mimics
**PRs:** #10, #15 | **Date:** 2026-05-03–17  
**Branch:** `claude/create-vibes-branch-vOG5p`

The namesake feature. Failed gold chests spawn a Mimic that drops augmented loot directly into the party treasure pool.

**Deliverables:**
- `modules/custom/casket_mimic.lua`:
  - Base casket drop rate: 10% → 25%
  - Failed gold chest: 25% chance to spawn a Mimic
  - Mimic drops augmented loot into party treasure pool on death, with announcement
- `modules/custom/casket_mimic_spawns.sql` — auto-loaded via dbtool
- `MAX_TRAIT_ID` bumped to 142
- THF `Casket Hunter` trait (Lv15/35/65) — boosts personal gold casket rate
- Gold caskets confirmed spawning in all zones (zone filter bug fixed)

---

### Session 6 — Fully Bespoke Website & Launcher
**PRs:** #11, #12, #13, #14 | **Date:** 2026-05-16  
**Branch:** `claude/character-creation-web-XbOG9`  
**Session:** `session_01D5zkCMFA7EtKxc5JGLX1eA`

Web-based account registration and character creation. Frontend is largely built locally; committed work covers the Flask API backend, React scaffold, and cross-platform launchers.

**Deliverables:**
- `POST /api/register` — bcrypt, manual account ID allocation, full `accounts` row
- `GET /api/session` — lightweight auth check
- Static file serving from `public/` same-origin (design files drop in, no build step needed)
- React character creation component with JSON API for Claude Design integration
- Cross-platform launchers: `run.bat`, `run.py`, `run.sh`; port overridable via `argv[1]`

---

### Session 7 — New Trust Implementations
**PR:** #16 | **Date:** 2026-05-17  
**Branch:** `claude/lsb-trust-options-VdDTz`

Retail-accurate behaviors for 20 Trusts, with all stats and damage scaled to Lv75 cap.

**Deliverables:**
- Batch 1 + Batch 2 (20 trusts total) — retail behavior scripts
- Full 1–99 ability suites restored and scaled to Lv75 cap
- Fixes: MNK double-attack, WS at 1000 TP, caster auto-attack, missing `quick_draw` script
- Systematic stat and damage balance pass

---

## Built But Not Yet Merged

These branches contain completed work that is ready (or nearly ready) to pull into `base`.

---

### New Armor, Weapons and Items
**Branch:** `claude/design-new-items-hecdW`  
**State:** Complete — awaiting merge

80+ custom items designed and injected into casket loot pools. Items are tied into the existing Casket Mimic system rather than being standalone drops.

**What's built:**
- `documentation/new_items_design.csv` — full design sheet of 80 items across two batches, with stats, slots, and balance notes
- `modules/custom/lua/casket_gold_chest_custom_items.lua` — injects custom items into gold chest rare pools across all zones per tier
- `modules/init.txt` updated to auto-load the new module

**Next step:** Review item balance from the design sheet, then merge to `base`.

---

### Weapon Augment Crafting System — Phase 1
**Branch:** `claude/augment-crafting-system-1I7Eh`  
**State:** Phase 1 complete — awaiting merge

A crafting-based system for applying augments to weapons using materials. Distinct from the random Casket Mimic augment drops — this is deliberate, recipe-driven customisation.

**What's built:**
- `modules/custom/lua/augment_crafter.lua` (160 lines) — core crafting logic: materials, recipes, casket pools
- `scripts/enum/item.lua` — new item enum entries for augment materials
- `scripts/globals/casket_loot.lua` — augment material drop integration
- `sql/synth_recipes.sql` — recipe definitions
- C++ changes to `exdata.cpp` and `item_equipment.cpp` — fix: augmented non-EX items no longer incorrectly gain the EX flag

**Planned Phase 2 (not started):** Incremental weapon augmentation (levelling augments over time via kills/quests).

**Next step:** Merge Phase 1 to `base`, then design Phase 2 scope.

---

### New Levelling Incentives
**Branch:** `claude/leveling-incentive-systems-yXQU2`  
**State:** Complete — awaiting merge

Three systems that make levelling in a party feel more rewarding and encourage new player onboarding.

**What's built:**
- **New Player Aura** — bonus applied to genuine new characters; fix ensures it does not apply to synced-down veterans
- **Party Momentum Bonus** — party XP bonus that builds with sustained engagement
- **Sync Buddy system** — explicit opt-in pair system via `/syncbuddy` command (10-minute cooldown after accepting a request); implemented as a full Lua command with C++ backing in `charentity.h` / `charutils.cpp`
- `settings/default/map.lua` updated with toggle settings for all three systems

**Next step:** Playtest the Sync Buddy cooldown and aura thresholds, then merge to `base`.

---

## Development Pipeline (Planned)

> Nothing below is committed. Design directions noted here reflect session discussions.

---

### Treasure Hunter Changes
**Status:** Planned  
**Design direction:** TH removed from the THF job trait model and instead tied to **Key Items** — players acquire Key Items that grant or enhance TH, making it accessible to all jobs with the right setup rather than a THF exclusive.

**Open design questions:**
- Which Key Items grant TH and at what tiers? (Dropped, crafted, or quest-rewarded?)
- Does this fully replace the THF TH trait, or do both coexist?
- Interaction with Casket Hunter (THF trait) — does TH affect casket drop rates or remain separate?
- Does TH affect the Casket Mimic spawn chance?

---

### Levelling System Alternatives — Hunt Board
**Status:** Planned  
**Depends on:** Nothing — standalone module, but pairs well with Daily Login Rewards NPC

An alternative XP path where players pick up hunting targets (specific mob types or named NMs) from a board NPC, earning bonus XP and rewards on completion. Reduces reliance on static camp grinding.

**Design considerations:**
- NPC placement: Jeuno, homepoints, or per-region boards?
- Reward structure: bonus XP, currency, augment materials?
- Target variety: fixed mob families per level range, or rotating/daily?
- Could share an NPC with Daily Login Rewards

---

### Daily Login Rewards & New NPC Shops
**Status:** Planned  
**Depends on:** Nothing — but benefits from having a Hunt Board currency to spend

Login streak rewards (consumables, materials, rare items) paired with new NPC shops giving players spend targets for earned currencies.

**Design considerations:**
- Fixed calendar vs. streak-based rewards?
- New token currency vs. reusing gil?
- NPC shop rotation (static, daily, weekly)?
- Should feed into the augment crafting material economy

---

### Incremental Weapon Augmentation System
**Status:** Planned (Phase 2 of Augment Crafting)  
**Depends on:** Weapon Augment Crafting Phase 1 merged

Weapons accumulate "charge" over time through kills, quests, or crafting, and can be upgraded to strengthen augments or unlock new ones. Long-term weapon investment without obsoleting gear.

**Design considerations:**
- How is charge accumulated? (Kill count, specific mob types, crafting sessions?)
- Upgrade tiers and stat/visual milestones
- Reforge/reset path if the player wants to change direction
- Relationship to Casket Mimic augments — same slots or separate?

---

### Modular Endgame System
**Status:** Planned  
**Reference branch:** `Nyzul` (upstream LSB Nyzul Isle as likely first content target)  
**Depends on:** Job balance (done), augmentation systems, new gear

A pluggable framework for custom endgame events — BCNMs, NM fights, Nyzul-style floors — implemented as modules that define their own entry, rules, and reward tables without touching core code.

**Design considerations:**
- What does a module need to define? (Entry NPC, zone, reward table, participant limits, scaling rules)
- Solo, party, or alliance content — or all three?
- Reward integration: augment materials, Key Items for TH, unique gear?
- First target: Nyzul Isle (upstream foundation already exists in the `Nyzul` branch)
- Extend the existing `modules/` pattern already used by Casket Mimic

---

## Systems Architecture

```
MimicXI
├── Combat Layer                                    [COMPLETE]
│   ├── Ecosystem resistances
│   ├── Job balance mechanics (14 jobs)
│   └── Trust retail behaviours + lv75 balance
│
├── Progression Layer                               [PARTIAL]
│   ├── Flattened XP curve (lv50–75)               [MERGED]
│   ├── New levelling incentives                    [BUILT — not merged]
│   │   ├── New Player Aura
│   │   ├── Party Momentum Bonus
│   │   └── Sync Buddy (/syncbuddy)
│   ├── Hunt Board (alt. XP system)                [PLANNED]
│   └── Daily login rewards                        [PLANNED]
│
├── Content Layer                                   [PARTIAL]
│   ├── Casket Mimic system                        [MERGED]
│   ├── THF Casket Hunter trait                    [MERGED]
│   ├── Custom items (80+, casket-injected)        [BUILT — not merged]
│   └── Modular endgame system                     [PLANNED]
│
├── Economy / Crafting Layer                        [PARTIAL]
│   ├── Weapon Augment Crafting — Phase 1          [BUILT — not merged]
│   ├── Incremental Weapon Augmentation — Phase 2  [PLANNED]
│   ├── Treasure Hunter changes (Key Items)        [PLANNED]
│   └── New NPC shops                              [PLANNED]
│
└── Infrastructure Layer                            [COMPLETE]
    ├── Web creator + Flask API
    ├── Bespoke frontend (locally built)
    └── Module autoload via dbtool
```

---

## Key Files Reference

| System | Key Files |
|---|---|
| Ecosystem resistances | `scripts/globals/mob_family_resistances.lua`, `scripts/globals/mobs.lua` |
| Job balance | `scripts/globals/jobabilities/` (per-job), `scripts/globals/status_effects/` |
| Casket Mimic | `modules/custom/casket_mimic.lua`, `modules/custom/casket_mimic_spawns.sql` |
| Custom items | `modules/custom/lua/casket_gold_chest_custom_items.lua`, `documentation/new_items_design.csv` |
| Augment crafting | `modules/custom/lua/augment_crafter.lua`, `sql/synth_recipes.sql` |
| Levelling incentives | `scripts/commands/syncbuddy.lua`, `settings/default/map.lua` |
| XP curve | `sql/player_xp_table.sql` |
| Web creator | `tools/web_creator/app.py`, `tools/web_creator/public/` |
| Trust behaviours | `scripts/globals/trust/` (per-trust Lua files) |
| Module autoload | `modules/init.txt`, `modules/` subdirs |

---

## Development Notes

- All custom content lives in `modules/custom/` or standalone `scripts/` files — upstream LSB files patched minimally to keep merges clean.
- The `vibes` / `stg` branches are used as staging areas before PRs land on `base`.
- The `Nyzul` branch tracks upstream LSB Nyzul Isle work as a reference baseline for the planned endgame module.
- Claude Code sessions are the primary development tool; each session maps to one or more PRs.
- Session links in PR bodies (`claude.ai/code/session_*`) are the conversation trail for decisions made.
- **This document should be updated at the end of each session** — tick off merged items, note new pipeline additions.
