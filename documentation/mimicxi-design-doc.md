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

## Session History & Completed Work

### Session 1 — Initial Fork & Vibes Setup
**PRs:** #1, #2 | **Date:** 2026-04-22  
**Branch:** `vibes`

The initial setup of the MimicXI fork from LandSandBoat. Established the `base` branch as the main development target and `vibes` as a staging/experimental branch. First pass at custom identity.

**Deliverables:**
- Repository forked and base branch established
- Vibes branch created as a staging area

---

### Session 2 — Ecosystem Damage Type Resistances
**PR:** #3, #5 | **Date:** 2026-04-23–24  
**Branch:** `claude/rebalance-combat-damage-types-7Oa6r`  
**Session link:** `session_016edVohyjzzdCL5Zw78FGAB`

Introduced a global ecosystem-based resistance system so that mob families have meaningful damage type weaknesses and resistances, making weapon and spell choice feel more strategic.

**Deliverables:**
- `scripts/globals/mob_family_resistances.lua` — assigns SDT (Specific Damage Taken) mods at spawn for all 21 ecosystems
- Hook added to `scripts/globals/mobs.lua` exposing `xi.mob.onMobSpawn` (global, runs before per-mob scripts so individual scripts can still override)
- C++ `luautils::OnMobSpawn` calls the global hook before per-mob scripts
- Resistances are applied via `mob:setMod()` — silent per-mob overrides still work

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

**Fix in follow-up:** Removed spurious `require('scripts/globals/utils')` from the module (Apr 24).  
**Fix (May 18):** Further tuning pass on `mob_family_resistances.lua` values.

---

### Session 3 — XP Curve Flattening (Lv50–75)
**PR:** #4 | **Date:** 2026-04-23  
**Branch:** `claude/flatten-xp-curve-7kP3V`  
**Session link:** `session_01JRCUF3rbKyWTmcJNXyxDfL`

Reduced the XP grind in the 50–75 range by flattening the per-level curve to mirror the shape of the 1–50 curve.

**Deliverables:**
- XP table updated for levels 51–75 using a stepped plateau pattern:
  - 51–55: +200 XP/level
  - 56–60: +300 XP/level
  - 61–65: +400 XP/level
  - 66–70: +500 XP/level
  - 71–75: +600 XP/level
- Total XP to reach Lv75: reduced from **42,000** → **17,700**

---

### Session 4 — Job Balance Pass (All Jobs)
**PRs:** #6, #7, #8, #9 | **Date:** 2026-04-27–29  
**Branch:** `claude/balance-warrior-job-MYvlk`

A sweeping job balance pass implementing custom mechanics for every job at the Lv75 cap. Each job received 1–3 new passive or active systems that create unique combat identity without breaking the core retail feel.

**Deliverables per job:**

| Job | Mechanics Added |
|---|---|
| **WAR** | Aggressor and Tomahawk now exploit weapon-type physical weaknesses |
| **MNK** | Footwork Third Strike (rhythm combo), Focus Vital Point |
| **THF** | Feint Open Guard (defense debuff window), SA/TA Pickpocket (gil steal) |
| **WHM** | Solace shield stacking, Misery damage stacking, Divine Seal Aura |
| **BLM** | Elemental Seal — Arcane Echo (resonance burst) |
| **RDM** | Enspell identity via Composure and Chainspell |
| **PLD** | Holy Retribution — Sentinel absorbs hits, bursts on expiry |
| **DRK** | Soul Reservoir, Dark Empowerment, Crimson Tide |
| **BRD** | Threnody vulnerability window, Troubadour resonance, Finale clarity, Lullaby groggy |
| **SAM** | Poised Strike, Drawn Bow Meditate, Zanshin Momentum |
| **RNG** | Velocity Shot Point Blank — axe hits generate +50 TP during VS |
| **NIN** | Blade Dance, Yonin Aggressive Evasion, Elemental Scar |
| **DRG** | Draconic Resonance, Wyvern's Blessing, Angon Breach |
| **SMN** | Ward Resonance — Ward BPs amplify next Rage BP |

**Additional work in this session:**
- Toggleable combat stack notifications (`MIMIC_COMBAT_NOTIFICATIONS` server setting)
- Soul Reservoir notification shows WS bonus % instead of raw HP
- `MAX_EFFECTID` raised to 822 to accommodate 15 custom balance-pass effects
- DRG/SMN effect IDs reassigned below server hard cap of 817

---

### Session 5 — Casket Mimic System
**PRs:** #10, #15 | **Date:** 2026-05-03–17  
**Branch:** `claude/create-vibes-branch-vOG5p`

The namesake feature of MimicXI. Implemented a complete Casket Mimic system: failed gold chests have a chance to spawn a Mimic mob that drops augmented loot into the party treasure pool.

**Deliverables:**
- `modules/custom/casket_mimic.lua` — core module:
  - Base casket drop rate raised from 10% → 25%
  - Failed gold chest has a **25% chance** to spawn a Mimic
  - Mimic drops augmented loot directly into the party treasure pool on death
  - Augment announcement message shown on loot drop
- `modules/custom/casket_mimic_spawns.sql` — spawn data moved into module system for auto-loading via `dbtool`
- `MAX_TRAIT_ID` bumped to 142 for Casket Hunter traits
- THF gets a new `Casket Hunter` trait (Lv15/35/65) boosting gold casket rate
- Gold caskets confirmed spawning in all zones (zone filter bug fixed)

**Bug fixes during this session:**
- Fixed bitwise OR in `getMimicMobId` for LuaJIT/Lua 5.1 compatibility
- Fixed mob not being forwarded to `setCasketData` (gold chests were never spawning)
- Fixed `SpawnMob` not found: changed mob `local_index` from `0xE00` → `0x700`
- Used `INSERT IGNORE` in SQL to handle partial imports cleanly

---

### Session 6 — Web Character Creator
**PRs:** #11, #12, #13, #14 | **Date:** 2026-05-16  
**Branch:** `claude/character-creation-web-XbOG9`  
**Session link:** `session_01D5zkCMFA7EtKxc5JGLX1eA`

Built a web-based account registration and character creation interface, served by the existing Flask backend in `tools/web_creator/`.

**Deliverables:**
- `tools/web_creator/app.py`:
  - `POST /api/register` — validates username/password/email, bcrypt-hashes password, manually allocates account ID (no AUTO_INCREMENT), inserts full `accounts` row, logs user in via session
  - `GET /api/session` — lightweight auth check returning session state
  - `GET /` — serves `public/index.html` if present, falls back to auth redirect
  - `GET /site/<path>` — serves any file from `public/` (same-origin, correct relative asset resolution)
- React character creation component integrated with JSON API for Claude Design compatibility
- Character faces expanded to 3 variants per face number
- Cross-platform launchers:
  - `run.bat` — Windows launcher using `.venv\Scripts\` (correct Windows path, stays open on error)
  - `run.py` — cross-platform Python launcher (auto-detects OS venv path, dependency check before launch)
  - `run.sh` — improved error messages, removed silent `set -e`
  - `app.py` accepts port as `argv[1]` so all launchers can override it
- `tools/web_creator/public/.gitkeep` — directory tracked in git, ready for design site files

**Architecture note:** Design site files drop into `tools/web_creator/public/` — Flask serves them same-origin so all relative asset paths resolve correctly without a build step.

---

### Session 7 — Trust System Retail Behaviors & Lv75 Balance
**PR:** #16 | **Date:** 2026-05-17  
**Branch:** `claude/lsb-trust-options-VdDTz`

Implemented retail-accurate behaviors for 20 Trust NPCs and balanced all Trust stats/damage for the Lv75 cap server.

**Deliverables:**
- Batch 1 (10 trusts) — retail behavior implementation
- Batch 2 (10 trusts) — retail behavior implementation
- Full 1–99 ability suite restored and scaled to Lv75 cap for all trusts
- Fixes:
  - MNK Trust double-attack
  - Weapon skills triggering at 1000 TP
  - Caster auto-attack behavior
  - `quick_draw` missing script
- Systematic stat and damage balance pass for all trusts at Lv75 cap

---

## Systems Overview

```
MimicXI
├── Combat Layer
│   ├── Ecosystem resistances (mob_family_resistances.lua)
│   ├── Job balance mechanics (per-job custom Lua effects)
│   └── Trust retail + lv75 balance
│
├── Content Layer
│   ├── Casket Mimic system (modules/custom/)
│   └── THF Casket Hunter trait
│
├── Progression Layer
│   └── Flattened XP curve (lv50–75)
│
└── Infrastructure Layer
    ├── Web character creator (tools/web_creator/)
    │   ├── Flask API (register, session, character CRUD)
    │   └── React frontend (public/)
    └── Module system (auto-loaded via dbtool)
```

---

## Development Pipeline (Planned / In Progress)

> Items here are not committed work — they represent directions identified across sessions. Priorities and scope may change.

### Near-term

- [ ] **Web creator polish** — Complete the Claude Design frontend and copy finished files into `tools/web_creator/public/`. The Flask backend is ready; it's waiting on the UI.
- [ ] **Casket Mimic tuning** — Adjust spawn rates, augment tables, and Mimic mob stats based on playtesting feedback.
- [ ] **Trust batch 3+** — Continue retail behavior implementation for remaining trusts beyond the initial 20.
- [ ] **Mob resistance tuning** — Follow-up pass on ecosystem SDT values based on actual combat feel (the May 18 update was a first pass).

### Medium-term

- [ ] **Additional job mechanics** — RUN, GEO, BLU, COR, PUP, SCH not yet covered by the balance pass (post-75 jobs; decide scope for lv75-cap server).
- [ ] **Character creator — character CRUD** — Extend `/api/register` flow to support full character creation (race, job, face, starting zone) via the web interface.
- [ ] **Casket Mimic — named Mimics** — Special named Mimic variants with unique drops for high-tier caskets (optional, high-complexity).
- [ ] **XP curve review** — Assess whether the 17,700 total XP to 75 creates a satisfying pace or if sub-ranges need further tuning.

### Long-term / Ideas

- [ ] **Module: custom NM spawns** — Boss-style NMs tied to Casket Mimic chain events (Mimic chain → rare NM spawn).
- [ ] **Module: lv75 cap content** — Custom BCNMs or events designed specifically for the lv75 cap era feel.
- [ ] **Web creator: live character preview** — 3D or sprite-based character preview in the browser before finalising creation.
- [ ] **Ecosystem resistances: per-zone overrides** — Zone-specific resistance profiles (e.g. Sea mobs feel different from Sky mobs of the same family).

---

## Key Files Reference

| System | Key Files |
|---|---|
| Ecosystem resistances | `scripts/globals/mob_family_resistances.lua`, `scripts/globals/mobs.lua` |
| Job balance | `scripts/globals/jobabilities/` (per-job), `scripts/globals/status_effects/` |
| Casket Mimic | `modules/custom/casket_mimic.lua`, `modules/custom/casket_mimic_spawns.sql` |
| XP curve | `sql/player_xp_table.sql` (or equivalent exp Lua) |
| Web creator | `tools/web_creator/app.py`, `tools/web_creator/public/` |
| Trust behaviors | `scripts/globals/trust/` (per-trust Lua files) |
| Module autoload | `modules/` (all subdirs, loaded via dbtool) |

---

## Notes on Development Approach

- All custom content lives in `modules/custom/` or separate `scripts/` files — never patching upstream LSB files directly where avoidable, so upstream merges stay clean.
- The `vibes` branch is used as a staging / experimental area before PRs land on `base`.
- Claude Code sessions are the primary development tool — each session maps to one or more PRs.
- Session links in PR bodies (`claude.ai/code/session_*`) provide the conversation trail for decisions made.
