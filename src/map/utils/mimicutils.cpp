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

#include "mimicutils.h"

#include <algorithm>

#include <fmt/format.h>

#include "common/database.h"

#include "entities/battle_entity.h"
#include "entities/char_entity.h"
#include "entities/trust_entity.h"
#include "grades.h"
#include "items/item.h"
#include "items/item_equipment.h"
#include "items/item_weapon.h"
#include "packets/entity_update.h"
#include "packets/s2c/0x02d_battle_message2.h"
#include "enums/msg_basic.h"
#include "party.h"
#include "zone.h"
#include "utils/charutils.h"
#include "utils/itemutils.h"

namespace mimicutils
{

namespace
{
    // char_jobs / char_exp column name for a job, indexed by xi::Job (WAR=1 .. RUN=22).
    // Returns nullptr for NONE / MON / anything without a per-job column.
    auto JobColumn(xi::Job job) -> const char*
    {
        static constexpr const char* cols[] = {
            "war", "mnk", "whm", "blm", "rdm", "thf", "pld", "drk", "bst", "brd", "rng",
            "sam", "nin", "drg", "smn", "blu", "cor", "pup", "dnc", "sch", "geo", "run"
        };

        const auto idx = static_cast<uint8>(job);
        if (idx < 1 || idx > 22)
        {
            return nullptr;
        }
        return cols[idx - 1];
    }
} // namespace

auto CheckMimicEligibility(CCharEntity* PMaster, const std::string& altCharName) -> MimicCandidate
{
    MimicCandidate result;

    const auto charRset = db::preparedStmt(
        "SELECT charid, charname FROM chars WHERE charname = ? AND accid = ? LIMIT 1",
        altCharName,
        PMaster->accid);

    if (!charRset || charRset->rowsCount() == 0 || !charRset->next())
    {
        result.eligibility = MimicEligibility::NotFound;
        return result;
    }

    result.charId   = charRset->get<uint32>("charid");
    result.charName = charRset->get<std::string>("charname");

    if (result.charId == PMaster->id)
    {
        result.eligibility = MimicEligibility::NotFound;
        return result;
    }

    const auto sessionRset = db::preparedStmt("SELECT 1 FROM accounts_sessions WHERE charid = ? LIMIT 1", result.charId);
    if (sessionRset && sessionRset->rowsCount() != 0)
    {
        result.eligibility = MimicEligibility::Online;
        return result;
    }

    const auto activeRset = db::preparedStmt("SELECT 1 FROM char_mimic_active WHERE charid = ? LIMIT 1", result.charId);
    if (activeRset && activeRset->rowsCount() != 0)
    {
        result.eligibility = MimicEligibility::AlreadyMimicked;
        return result;
    }

    result.eligibility = MimicEligibility::Ok;
    return result;
}

namespace
{
    // Maps a raw char_look.race value to the 0-4 race index used by the grade:: growth tables
    // (0 Hume, 1 Elvaan, 2 Tarutaru, 3 Mithra, 4 Galka) - mirrors charutils::CalculateStats.
    auto RaceIndexFromLook(uint8 lookRace) -> uint8
    {
        switch (static_cast<CharRace>(lookRace))
        {
            case CharRace::ElvaanMale:
            case CharRace::ElvaanFemale:
                return 1;
            case CharRace::TarutaruMale:
            case CharRace::TarutaruFemale:
                return 2;
            case CharRace::Mithra:
                return 3;
            case CharRace::Galka:
                return 4;
            default:
                return 0; // Hume / unknown
        }
    }

    // Fills in base stats / max HP / max MP on the snapshot from the mimicked alt's
    // race, jobs and level using the same growth tables charutils::CalculateStats uses
    // for a live character (merit bonuses are intentionally not applied to trusts).
    void ComputeSnapshotStats(MimicTrustSnapshot& snapshot)
    {
        const uint8 race = RaceIndexFromLook(snapshot.look.race);
        const uint8 mlvl = snapshot.mlvl;
        const uint8 slvl = snapshot.slvl;

        snapshot.maxhp = static_cast<int16>(grade::GetBaseHP(race, grade::GetJobGrade(snapshot.mjob, 0), mlvl, grade::GetJobGrade(snapshot.sjob, 0), slvl));
        snapshot.maxmp = static_cast<int16>(grade::GetBaseMP(race, grade::GetJobGrade(snapshot.mjob, 1), mlvl, grade::GetJobGrade(snapshot.sjob, 1), slvl));

        uint16* const statFields[] = {
            &snapshot.stats.STR, &snapshot.stats.DEX, &snapshot.stats.VIT, &snapshot.stats.AGI,
            &snapshot.stats.INT, &snapshot.stats.MND, &snapshot.stats.CHR
        };

        for (uint8 statIndex = 2; statIndex <= 8; ++statIndex)
        {
            *statFields[statIndex - 2] = grade::GetBaseStat(
                grade::GetRaceGrades(race, statIndex),
                grade::GetJobGrade(snapshot.mjob, statIndex),
                mlvl,
                grade::GetJobGrade(snapshot.sjob, statIndex),
                slvl);
        }
    }

    // Reads a single char_inventory row (by location/slot) and builds a real, augmented
    // item object from it - mirrors charutils::LoadInventory's per-item and augment logic,
    // but against a single targeted row instead of a live storage container.
    auto LoadSnapshotItem(uint32 charId, uint8 location, uint8 slot) -> std::unique_ptr<CItem>
    {
        const auto rset = db::preparedStmt(
            "SELECT itemid, extra FROM char_inventory WHERE charid = ? AND location = ? AND slot = ?",
            charId,
            location,
            slot);

        if (!rset || rset->rowsCount() == 0 || !rset->next())
        {
            return nullptr;
        }

        auto PItem = xi::items::spawn(rset->get<uint16>("itemid"));
        if (!PItem)
        {
            return nullptr;
        }

        db::extractFromBlob(rset, "extra", PItem->m_extra);

        if (auto* PEquip = dynamic_cast<CItemEquipment*>(PItem.get()))
        {
            for (uint8 augSlot = 0; augSlot < 4; ++augSlot)
            {
                if (PEquip->getAugment(augSlot) != 0)
                {
                    PEquip->ApplyAugment(augSlot);
                }
            }
        }

        return PItem;
    }
} // namespace

auto LoadMimicTrustSnapshot(uint32 charId, uint8 levelCap) -> std::optional<MimicTrustSnapshot>
{
    MimicTrustSnapshot snapshot;
    snapshot.charId = charId;

    const auto charRset = db::preparedStmt("SELECT charname FROM chars WHERE charid = ? LIMIT 1", charId);
    if (!charRset || charRset->rowsCount() == 0 || !charRset->next())
    {
        return std::nullopt;
    }
    snapshot.name = charRset->get<std::string>("charname");

    const auto statsRset = db::preparedStmt("SELECT mjob, sjob, mlvl, slvl FROM char_stats WHERE charid = ? LIMIT 1", charId);
    if (!statsRset || statsRset->rowsCount() == 0 || !statsRset->next())
    {
        return std::nullopt;
    }
    snapshot.mjob = static_cast<xi::Job>(statsRset->get<uint8>("mjob"));
    snapshot.sjob = static_cast<xi::Job>(statsRset->get<uint8>("sjob"));

    // The mimic uses the alt's *own* real level for its current main job, never the
    // summoner's - only capped so it can't exceed the summoner (levelCap). Sub level is
    // the alt's real sub-job level, capped at half the resolved main level, like a trust.
    uint8 altMain = statsRset->get<uint8>("mlvl");
    uint8 altSub  = statsRset->get<uint8>("slvl");

    if (const char* mjobCol = JobColumn(snapshot.mjob))
    {
        const char* sjobCol   = JobColumn(snapshot.sjob);
        const auto  jobsRset  = db::preparedStmt(
            fmt::format("SELECT `{}` AS mlvl, `{}` AS slvl FROM char_jobs WHERE charid = ? LIMIT 1",
                        mjobCol, sjobCol ? sjobCol : mjobCol),
            charId);
        if (jobsRset && jobsRset->rowsCount() != 0 && jobsRset->next())
        {
            altMain = jobsRset->get<uint8>("mlvl");
            altSub  = sjobCol ? jobsRset->get<uint8>("slvl") : 0;
        }
    }

    snapshot.mlvl = std::clamp<uint8>(altMain, 1, std::max<uint8>(levelCap, 1));
    snapshot.slvl = std::min<uint8>(altSub, snapshot.mlvl / 2);

    const auto lookRset = db::preparedStmt(
        "SELECT face, race, head, body, hands, legs, feet, main, sub, ranged FROM char_look WHERE charid = ? LIMIT 1",
        charId);
    if (!lookRset || lookRset->rowsCount() == 0 || !lookRset->next())
    {
        return std::nullopt;
    }

    // MODEL_EQUIPPED tells the entity-update packet to send the full look_t (race +
    // per-slot equipment model IDs) so the trust renders as a geared humanoid, exactly
    // like the source character. char_look.size is the racial body size, not a
    // look_t.size model-type value, so it must not be copied here.
    snapshot.look.size   = MODEL_EQUIPPED;
    snapshot.look.face   = lookRset->get<uint8>("face");
    snapshot.look.race   = lookRset->get<uint8>("race");
    snapshot.look.head   = lookRset->get<uint16>("head");
    snapshot.look.body   = lookRset->get<uint16>("body");
    snapshot.look.hands  = lookRset->get<uint16>("hands");
    snapshot.look.legs   = lookRset->get<uint16>("legs");
    snapshot.look.feet   = lookRset->get<uint16>("feet");
    snapshot.look.main   = lookRset->get<uint16>("main");
    snapshot.look.sub    = lookRset->get<uint16>("sub");
    snapshot.look.ranged = lookRset->get<uint16>("ranged");

    const auto equipRset = db::preparedStmt(
        "SELECT slotid, equipslotid, containerid FROM char_equip WHERE charid = ?",
        charId);
    if (equipRset)
    {
        // NOTE: Collected up-front since resolving each item below runs another query,
        // which would otherwise invalidate this result set (same reasoning as charutils::LoadEquip).
        std::vector<std::tuple<uint8, uint8, uint8>> equipRows; // { equipSlotId, slotId, containerId }
        while (equipRset->next())
        {
            equipRows.emplace_back(
                equipRset->get<uint8>("equipslotid"),
                equipRset->get<uint8>("slotid"),
                equipRset->get<uint8>("containerid"));
        }

        for (const auto& [equipSlotId, slotId, containerId] : equipRows)
        {
            if (equipSlotId >= SLOT_LINK1)
            {
                continue; // Mimic trusts don't carry linkshells
            }

            auto PItem = LoadSnapshotItem(charId, containerId, slotId);
            if (!PItem)
            {
                continue;
            }

            if (equipSlotId <= SLOT_AMMO)
            {
                snapshot.weapons[equipSlotId] = std::move(PItem);
            }
            else
            {
                snapshot.armor[equipSlotId - SLOT_HEAD] = std::move(PItem);
            }
        }
    }

    ComputeSnapshotStats(snapshot);

    return snapshot;
}

void AwardMimicExp(CCharEntity* PMaster, CTrustEntity* PMimic, uint32 gainedExp)
{
    if (PMaster == nullptr || PMimic == nullptr || gainedExp == 0)
    {
        return;
    }

    const uint32 altId = PMimic->m_MimicSourceCharId;
    if (altId == 0)
    {
        return;
    }

    const xi::Job job    = PMimic->GetMJob();
    const char*   jobCol = JobColumn(job);
    if (jobCol == nullptr)
    {
        return;
    }

    // Never let a mimic out-level the summoner. A mimic sitting at the cap earns nothing
    // until the summoner gains a level of their own.
    const uint8 cap = PMaster->GetMLevel();

    const auto rset = db::preparedStmt(
        fmt::format("SELECT j.`{0}` AS lvl, e.`{0}` AS exp "
                    "FROM char_jobs j JOIN char_exp e ON e.charid = j.charid "
                    "WHERE j.charid = ? LIMIT 1",
                    jobCol),
        altId);
    if (!rset || rset->rowsCount() == 0 || !rset->next())
    {
        return;
    }

    uint8  level = std::max<uint8>(rset->get<uint8>("lvl"), 1);
    uint32 exp   = rset->get<uint32>("exp");

    if (level >= cap)
    {
        return;
    }

    const uint8 startLevel = level;
    exp += gainedExp;

    while (level < cap && exp >= charutils::GetExpNEXTLevel(level))
    {
        exp -= charutils::GetExpNEXTLevel(level);
        ++level;
    }

    if (level >= cap)
    {
        level = cap;
        exp   = std::min<uint32>(exp, charutils::GetExpNEXTLevel(level) - 1);
    }

    // The alt is guaranteed offline while mimicked, so write its real progression directly.
    db::preparedStmt(fmt::format("UPDATE char_jobs SET `{}` = ? WHERE charid = ?", jobCol), level, altId);
    db::preparedStmt(fmt::format("UPDATE char_exp SET `{}` = ? WHERE charid = ?", jobCol), static_cast<uint16>(exp), altId);
    db::preparedStmt("UPDATE char_stats SET mlvl = ? WHERE charid = ?", level, altId);

    if (level <= startLevel)
    {
        return;
    }

    // Level-up: bring the live mimic entity up and refill it, like a player dinging.
    // Base stats and combat modifiers fully refresh on the next summon; here we keep
    // the level, HP/MP pool and party-frame numbers correct.
    PMimic->SetMLevel(level);
    PMimic->SetSLevel(static_cast<uint8>(level / 2));

    const uint8   race = RaceIndexFromLook(PMimic->look.race);
    const xi::Job sjob = PMimic->GetSJob();
    PMimic->health.maxhp = static_cast<int16>(grade::GetBaseHP(race, grade::GetJobGrade(job, 0), level, grade::GetJobGrade(sjob, 0), PMimic->GetSLevel()));
    PMimic->health.maxmp = static_cast<int16>(grade::GetBaseMP(race, grade::GetJobGrade(job, 1), level, grade::GetJobGrade(sjob, 1), PMimic->GetSLevel()));

    PMimic->UpdateHealth();
    PMimic->health.hp = PMimic->GetMaxHP();
    PMimic->health.mp = PMimic->GetMaxMP();
    PMimic->updatemask |= UPDATE_HP;

    // Broadcast the level-up exactly the way a player's does: BATTLE_MESSAGE2 with
    // MsgBasic::LevelUp, entity as the caster, to everyone in range - the client
    // plays the level-up glow on the caster and prints "<name> attains level N".
    if (PMimic->loc.zone != nullptr)
    {
        PMimic->loc.zone->PushPacket(
            PMimic, CHAR_INRANGE,
            std::make_unique<GP_SERV_COMMAND_BATTLE_MESSAGE2>(PMimic, PMimic, static_cast<int32>(level), 0, MsgBasic::LevelUp));
    }

    if (PMaster->PParty != nullptr)
    {
        PMaster->PParty->ReloadParty();
    }
}

}; // namespace mimicutils
