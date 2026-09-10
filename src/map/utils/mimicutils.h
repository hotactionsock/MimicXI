/*
===========================================================================

  Copyright (c) 2024 LandSandBoat Dev Teams

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

#include <array>
#include <memory>
#include <optional>
#include <string>

#include "common/cbasetypes.h"
#include "common/mmo.h"

#include "data/enums/job.h"

class CCharEntity;
class CItem;
class CTrustEntity;

namespace mimicutils
{

enum class MimicEligibility : uint8
{
    Ok,
    NotFound,       // No character by that name owned by the caller's account
    Online,         // The alt is currently logged in somewhere
    AlreadyMimicked // The alt is already summoned as someone's mimic trust
};

struct MimicCandidate
{
    uint32           charId{};
    std::string      charName;
    MimicEligibility eligibility{};
};

// Resolves an alt character name to a charid owned by PMaster's account and
// checks that it's currently eligible to be summoned as a mimic trust
// (offline, and not already active as a mimic trust elsewhere).
auto CheckMimicEligibility(CCharEntity* PMaster, const std::string& altCharName) -> MimicCandidate;

struct MimicTrustSnapshot
{
    uint32      charId{};
    std::string name;
    look_t      look{};
    xi::Job     mjob{};
    xi::Job     sjob{};
    uint8       mlvl{};
    uint8       slvl{};
    stats_t     stats{};
    int16       maxhp{};
    int16       maxmp{};

    // Indexed by SLOTTYPE: [0]=SLOT_MAIN, [1]=SLOT_SUB, [2]=SLOT_RANGED, [3]=SLOT_AMMO
    std::array<std::unique_ptr<CItem>, 4> weapons;

    // Indexed by (slotid - SLOT_HEAD), covering SLOT_HEAD (4) through SLOT_BACK (15)
    std::array<std::unique_ptr<CItem>, 12> armor;
};

// Reads the alt's real char_look / char_stats / char_jobs / char_exp / char_equip /
// char_inventory rows and builds real (augmented) item objects for its equipped gear.
// The mimic's level is the alt's *own* real level for its current main job, capped at
// levelCap (the summoner's main level) - it never syncs up to the summoner. Sub level
// is the alt's real sub-job level, capped at half the resolved main level.
auto LoadMimicTrustSnapshot(uint32 charId, uint8 levelCap) -> std::optional<MimicTrustSnapshot>;

// Credits an offline alt character with gainedExp toward its current main job (1:1
// with what the summoner earned). Handles level-ups against the real FFXI exp table,
// writes char_jobs / char_exp / char_stats directly (the alt cannot be online while
// mimicked), stops at levelCap = the summoner's current main level, and refreshes the
// live mimic-trust entity (level, HP/MP, party frame) plus a level-up message.
void AwardMimicExp(CCharEntity* PMaster, CTrustEntity* PMimic, uint32 gainedExp);

// Rebuilds PMimic->SpellContainer from the source character's learned spells
// (char_spells), keeping only those its current main/sub job + level can cast.
// spell::CanUseSpell's TYPE_TRUST path does not consult a trust's spell list, so
// this is the only thing that lets a mimic caster act. Safe to call repeatedly
// (it clears first); call it on summon and on every level-up.
void LoadTrustSpells(CTrustEntity* PMimic, uint32 altCharId, xi::Job mjob, xi::Job sjob, uint8 mlvl, uint8 slvl);

}; // namespace mimicutils
