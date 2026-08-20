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

#include "common/database.h"

#include "entities/battleentity.h"
#include "entities/charentity.h"
#include "items/item.h"
#include "items/item_equipment.h"
#include "items/item_weapon.h"
#include "utils/itemutils.h"

namespace mimicutils
{

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

auto LoadMimicTrustSnapshot(uint32 charId, uint8 mlvl, uint8 slvl) -> std::optional<MimicTrustSnapshot>
{
    MimicTrustSnapshot snapshot;
    snapshot.charId = charId;
    snapshot.mlvl   = mlvl;
    snapshot.slvl   = slvl;

    const auto charRset = db::preparedStmt("SELECT charname FROM chars WHERE charid = ? LIMIT 1", charId);
    if (!charRset || charRset->rowsCount() == 0 || !charRset->next())
    {
        return std::nullopt;
    }
    snapshot.name = charRset->get<std::string>("charname");

    const auto statsRset = db::preparedStmt("SELECT mjob, sjob FROM char_stats WHERE charid = ? LIMIT 1", charId);
    if (!statsRset || statsRset->rowsCount() == 0 || !statsRset->next())
    {
        return std::nullopt;
    }
    snapshot.mjob = static_cast<JOBTYPE>(statsRset->get<uint8>("mjob"));
    snapshot.sjob = static_cast<JOBTYPE>(statsRset->get<uint8>("sjob"));

    const auto lookRset = db::preparedStmt(
        "SELECT face, race, size, head, body, hands, legs, feet, main, sub, ranged FROM char_look WHERE charid = ? LIMIT 1",
        charId);
    if (!lookRset || lookRset->rowsCount() == 0 || !lookRset->next())
    {
        return std::nullopt;
    }

    snapshot.look.face   = lookRset->get<uint8>("face");
    snapshot.look.race   = lookRset->get<uint8>("race");
    snapshot.look.size   = lookRset->get<uint8>("size");
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

    return snapshot;
}

}; // namespace mimicutils
