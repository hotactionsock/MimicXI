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
// that's prey for the bot (Easy Prey .. Even Match, see botutils::IsBotPrey).
auto FindBotTarget(uint32 charId, float radius) -> std::optional<BotTarget>;

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

} // namespace botutils
