/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#pragma once

#include "common/cbasetypes.h"
#include "common/types/position.h"

#include <optional>
#include <vector>

// Simple melee combat for world bots (see botutils.h). Everything goes through
// the same engine paths a real client's actions use: CPlayerController::Engage
// (valid-target + 30-yalm rules), the Healing status effect /heal applies, the
// treasure pool's own lotting, and the normal kill -> EXP -> level-up flow - so
// bots really earn their levels. Chasing a target into melee range is done per
// tick by CWorldBotController.
namespace botutils
{

struct BotTarget
{
    uint32     mobId;
    position_t pos;
    float      distance;
    bool       attacking; // the mob is already fighting the bot (fight back, any level)
};

// The mob a bot should fight, if any: first anything currently attacking it,
// otherwise the nearest unclaimed, idle, normal (non-NM) mob within `radius`
// that's prey for the bot (Easy Prey .. Even Match solo; tougher for a party of
// partySize - see botutils::IsBotPrey).
auto FindBotTarget(uint32 charId, float radius, uint8 partySize = 1) -> std::optional<BotTarget>;

// Like FindBotTarget, but only mobs already attacking the bot. Cheap enough to
// check while travelling, so bots fight back instead of being chased across zones.
auto FindBotAttacker(uint32 charId) -> std::optional<BotTarget>;

// Engages mobId via the bot's controller (same rules as a player's /attack).
auto EngageBotTarget(uint32 charId, uint32 mobId) -> bool;

// /heal on or off (the Healing status effect, as GP_CLI_COMMAND_CAMP applies it).
void SetBotHealing(uint32 charId, bool on);

// Lots every item in the bot's treasure pool it hasn't lotted yet, while it has
// inventory space. Returns how many items it lotted on.
auto LotBotTreasure(uint32 charId) -> uint8;

// Uses the best weapon skill the bot knows for its main weapon (highest skill
// requirement) on its current target, if it's engaged with >= 1000 TP. Goes
// through CPlayerController::WeaponSkill (TP, range, target checks). Returns the
// weapon skill id used, or 0.
auto UseBotWeaponSkill(uint32 charId) -> uint16;

struct BotAbility
{
    uint16 id;
    bool   ready;     // learned and off recast
    bool   onEnemy;   // targets the enemy (otherwise self)
};

// Job abilities the bot has learned on its current jobs, minus SP abilities
// (two-hours - recast group 0). Which to use, and when, is xi.worldbots policy.
auto GetBotAbilities(uint32 charId) -> std::vector<BotAbility>;

// Uses abilityId on the bot's current target (enemy-targeted abilities) or on
// itself. Goes through CPlayerController::Ability (recast, state checks), after
// checking the bot has actually learned it. Returns true if it was used.
auto UseBotAbility(uint32 charId, uint16 abilityId) -> bool;

// A dead bot returns to its home point: revived at full HP/MP (as the real
// home-point menu does), then moved there with the bot-safe teleport. Returns
// false if the bot isn't a live, dead bot.
auto HomepointBot(uint32 charId) -> bool;

// ---- Spellcasting (Phase 3) -------------------------------------------------

struct BotSpell
{
    uint16 id;
    uint16 mpCost;
    uint8  skill;   // xi::SkillType (healing, enhancing, enfeebling, elemental, ...)
    uint8  group;   // SPELLGROUP (white, black, song, ninjutsu, ...)
    bool   onEnemy; // can target an enemy (otherwise self/party)
    bool   ready;   // off recast
};

// Spells the bot knows and can cast at its current main/sub job levels - the
// same job/level gate a player's spell list uses (spell::CanUseSpell). Not
// cheap (runs the spell checks for every learned spell): xi.worldbots caches
// it and refreshes after level-ups and inventory checks. `ready` is a snapshot.
auto GetBotSpells(uint32 charId) -> std::vector<BotSpell>;

enum class BotCastResult : uint8
{
    Cast      = 0, // started casting
    NotReady  = 1, // on recast, or the bot can't act right now (already casting, stunned...)
    NoMP      = 2, // not enough MP
    NoTarget  = 3, // enemy spell with no battle target, or target out of range
    Invalid   = 4, // not a live bot, unknown spell, or one it can't cast
};

// Casts spellId through CPlayerController::Cast (the player path: recast, MP,
// silence, range and target checks all apply). Enemy spells go at the bot's
// current battle target, everything else at the bot itself. Stops any walk
// first - moving interrupts a spell.
auto CastBotSpell(uint32 charId, uint16 spellId) -> BotCastResult;

// True while the bot is casting (it can't act otherwise until it finishes).
auto IsBotCasting(uint32 charId) -> bool;

// How close a bot closes in on its battle target. 0 (the default) = melee
// range; anything else = stay about that many yalms away (casters), only
// moving in if the target is further than that. See CWorldBotController.
void SetBotCombatRange(uint32 charId, float yalms);

// ---- Travel safety (Phase 3) -----------------------------------------------

struct BotThreat
{
    uint32     mobId;
    position_t pos;
    float      distance;
    bool       sight;         // detects by sight (Invisible counters it)
    bool       sound;         // detects by sound (Sneak counters it)
    bool       trueDetection; // sees through Sneak/Invisible
    float      sightRange;
    float      soundRange;
};

// Mobs within radius that would aggro the bot and are too strong for it to
// want to fight (tougher than prey - see IsBotPrey), nearest first. Uses the
// same aggression checks a mob's own aggro routine does (aggressive, not
// neutral, not busy, not underground) and its detection mods.
auto ScanBotThreats(uint32 charId, float radius, uint8 partySize = 1) -> std::vector<BotThreat>;

// Uses the first itemId in the bot's inventory on itself (Silent Oil, Prism
// Powder, potions...) through CPlayerController::UseItem. Returns true if the
// item use started.
auto UseBotItem(uint32 charId, uint16 itemId) -> bool;

// True if the bot carries at least one itemId in its inventory.
auto BotHasItem(uint32 charId, uint16 itemId) -> bool;

// Stops any walk in progress (e.g. to wait for a roaming mob to pass).
void StopBot(uint32 charId);

} // namespace botutils
