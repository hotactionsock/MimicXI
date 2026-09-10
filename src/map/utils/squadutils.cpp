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

#include "squadutils.h"

#include <algorithm>
#include <cstring>

#include <fmt/format.h>

#include "common/database.h"

#include "item_container.h"
#include "items/item_equipment.h"
#include "items/item_weapon.h"
#include "utils/itemutils.h"

namespace squadutils
{

namespace
{
    constexpr const char* kJobCols[] = {
        "war", "mnk", "whm", "blm", "rdm", "thf", "pld", "drk", "bst", "brd", "rng",
        "sam", "nin", "drg", "smn", "blu", "cor", "pup", "dnc", "sch", "geo", "run"
    };

    // Containers surfaced to the Bags UI. LOC_STORAGE / TEMPITEMS / RECYCLEBIN are
    // deliberately excluded - not gear storage and not cleanly DB-sized per char.
    const std::vector<BagContainerDef> kBagContainers = {
        { LOC_INVENTORY, "inv", "inventory" },
        { LOC_MOGSAFE, "safe", "safe" },
        { LOC_MOGSAFE2, "safe2", "safe" },
        { LOC_MOGLOCKER, "locker", "locker" },
        { LOC_MOGSATCHEL, "satchel", "satchel" },
        { LOC_MOGSACK, "sack", "sack" },
        { LOC_MOGCASE, "case", "case" },
        { LOC_WARDROBE, "wr1", "wardrobe" },
        { LOC_WARDROBE2, "wr2", "wardrobe2" },
        { LOC_WARDROBE3, "wr3", "wardrobe3" },
        { LOC_WARDROBE4, "wr4", "wardrobe4" },
        { LOC_WARDROBE5, "wr5", "wardrobe5" },
        { LOC_WARDROBE6, "wr6", "wardrobe6" },
        { LOC_WARDROBE7, "wr7", "wardrobe7" },
        { LOC_WARDROBE8, "wr8", "wardrobe8" },
    };

    auto BagContainerDefFor(uint8 containerId) -> const BagContainerDef*
    {
        for (const auto& def : kBagContainers)
        {
            if (def.id == containerId)
            {
                return &def;
            }
        }
        return nullptr;
    }
} // namespace

auto BagContainers() -> const std::vector<BagContainerDef>&
{
    return kBagContainers;
}

auto JobColumn(uint8 jobId) -> const char*
{
    if (jobId < 1 || jobId > 22)
    {
        return nullptr;
    }
    return kJobCols[jobId - 1];
}

auto GetSquad(uint32 accId) -> std::array<uint32, SquadSlots>
{
    std::array<uint32, SquadSlots> squad{};

    const auto rset = db::preparedStmt("SELECT slot, charid FROM account_squad WHERE accid = ?", accId);
    if (rset)
    {
        while (rset->next())
        {
            const uint8 slot = rset->get<uint8>("slot");
            if (slot >= 1 && slot <= SquadSlots)
            {
                squad[slot - 1] = rset->get<uint32>("charid");
            }
        }
    }

    return squad;
}

void SetSquadSlot(uint32 accId, uint8 slot, uint32 charId)
{
    if (slot < 1 || slot > SquadSlots)
    {
        return;
    }

    if (charId == 0)
    {
        db::preparedStmt("DELETE FROM account_squad WHERE accid = ? AND slot = ?", accId, slot);
        return;
    }

    db::preparedStmt("INSERT INTO account_squad (accid, slot, charid) VALUES (?, ?, ?) "
                     "ON DUPLICATE KEY UPDATE charid = VALUES(charid)",
                     accId, slot, charId);
}

auto ListAccountChars(uint32 accId) -> std::vector<AccountChar>
{
    std::vector<AccountChar> chars;

    const auto rset = db::preparedStmt(
        "SELECT c.charid, c.charname, s.mjob, s.mlvl, s.sjob, s.slvl, "
        "       (sess.charid IS NOT NULL) AS online, "
        "       (mim.charid IS NOT NULL)  AS locked, "
        "       j.unlocked, "
        "       j.war, j.mnk, j.whm, j.blm, j.rdm, j.thf, j.pld, j.drk, j.bst, j.brd, j.rng, "
        "       j.sam, j.nin, j.drg, j.smn, j.blu, j.cor, j.pup, j.dnc, j.sch, j.geo, j.run "
        "FROM chars c "
        "JOIN char_stats s          ON s.charid    = c.charid "
        "JOIN char_jobs  j          ON j.charid    = c.charid "
        "LEFT JOIN accounts_sessions sess ON sess.charid = c.charid "
        "LEFT JOIN char_mimic_active mim  ON mim.charid  = c.charid "
        "WHERE c.accid = ? ORDER BY c.charid",
        accId);

    if (rset)
    {
        while (rset->next())
        {
            AccountChar entry;
            entry.charId   = rset->get<uint32>("charid");
            entry.name     = rset->get<std::string>("charname");
            entry.mainJob  = rset->get<uint8>("mjob");
            entry.mainLvl  = rset->get<uint8>("mlvl");
            entry.subJob   = rset->get<uint8>("sjob");
            entry.subLvl   = rset->get<uint8>("slvl");
            entry.online   = rset->get<uint32>("online") != 0;
            entry.locked   = rset->get<uint32>("locked") != 0;
            entry.unlocked = rset->get<uint32>("unlocked");

            for (uint8 jobId = 1; jobId <= 22; ++jobId)
            {
                entry.levels[jobId] = rset->get<uint8>(kJobCols[jobId - 1]);
            }

            chars.emplace_back(std::move(entry));
        }
    }

    return chars;
}

auto IsOwnedByAccount(uint32 accId, uint32 charId) -> bool
{
    const auto rset = db::preparedStmt("SELECT 1 FROM chars WHERE charid = ? AND accid = ? LIMIT 1", charId, accId);
    return rset && rset->rowsCount() != 0;
}

auto SetAltJob(uint32 accId, uint32 charId, uint8 mjob, uint8 sjob) -> SetJobResult
{
    const char* mjobCol = JobColumn(mjob);
    if (mjobCol == nullptr || mjob == 0)
    {
        return SetJobResult::BadJob;
    }
    if (sjob != 0 && JobColumn(sjob) == nullptr)
    {
        return SetJobResult::BadJob;
    }

    if (!IsOwnedByAccount(accId, charId))
    {
        return SetJobResult::NotFound;
    }

    const auto sessRset = db::preparedStmt("SELECT 1 FROM accounts_sessions WHERE charid = ? LIMIT 1", charId);
    if (sessRset && sessRset->rowsCount() != 0)
    {
        return SetJobResult::Online;
    }

    const char* sjobCol  = sjob != 0 ? JobColumn(sjob) : mjobCol; // placeholder column when no sub
    const auto  jobsRset = db::preparedStmt(
        fmt::format("SELECT unlocked, `{}` AS mlvl, `{}` AS slvl FROM char_jobs WHERE charid = ? LIMIT 1",
                    mjobCol, sjobCol),
        charId);
    if (!jobsRset || jobsRset->rowsCount() == 0 || !jobsRset->next())
    {
        return SetJobResult::NotFound;
    }

    const uint32 unlocked = jobsRset->get<uint32>("unlocked");
    if ((unlocked & (1u << mjob)) == 0)
    {
        return SetJobResult::JobLocked;
    }
    if (sjob != 0 && (unlocked & (1u << sjob)) == 0)
    {
        return SetJobResult::JobLocked;
    }

    const uint8 mlvl = std::max<uint8>(jobsRset->get<uint8>("mlvl"), 1);
    const uint8 slvl = sjob != 0 ? std::min<uint8>(jobsRset->get<uint8>("slvl"), mlvl / 2) : 0;

    db::preparedStmt("UPDATE char_stats SET mjob = ?, sjob = ?, mlvl = ?, slvl = ? WHERE charid = ?",
                     mjob, sjob, mlvl, slvl, charId);

    return SetJobResult::Ok;
}

void SaveJobPreset(uint32 accId, const std::string& name, const std::vector<JobPresetEntry>& entries)
{
    db::preparedStmt("DELETE FROM account_jobpreset WHERE accid = ? AND name = ?", accId, name);
    for (const auto& e : entries)
    {
        db::preparedStmt("INSERT INTO account_jobpreset (accid, name, charid, mjob, sjob) VALUES (?, ?, ?, ?, ?)",
                         accId, name, e.charId, e.mjob, e.sjob);
    }
}

auto LoadJobPreset(uint32 accId, const std::string& name) -> std::vector<JobPresetEntry>
{
    std::vector<JobPresetEntry> out;

    const auto rset = db::preparedStmt(
        "SELECT charid, mjob, sjob FROM account_jobpreset WHERE accid = ? AND name = ?", accId, name);
    if (rset)
    {
        while (rset->next())
        {
            JobPresetEntry e;
            e.charId = rset->get<uint32>("charid");
            e.mjob   = rset->get<uint8>("mjob");
            e.sjob   = rset->get<uint8>("sjob");
            out.emplace_back(e);
        }
    }

    return out;
}

auto ListJobPresets(uint32 accId) -> std::vector<std::pair<std::string, uint32>>
{
    std::vector<std::pair<std::string, uint32>> out;

    const auto rset = db::preparedStmt(
        "SELECT name, COUNT(*) AS n FROM account_jobpreset WHERE accid = ? GROUP BY name ORDER BY name", accId);
    if (rset)
    {
        while (rset->next())
        {
            out.emplace_back(rset->get<std::string>("name"), rset->get<uint32>("n"));
        }
    }

    return out;
}

void DeleteJobPreset(uint32 accId, const std::string& name)
{
    db::preparedStmt("DELETE FROM account_jobpreset WHERE accid = ? AND name = ?", accId, name);
}

auto IsCharOnline(uint32 charId) -> bool
{
    const auto rset = db::preparedStmt("SELECT 1 FROM accounts_sessions WHERE charid = ? LIMIT 1", charId);
    return rset && rset->rowsCount() != 0;
}

auto BagContainerSize(uint32 charId, uint8 containerId) -> uint8
{
    const auto* def = BagContainerDefFor(containerId);
    if (def == nullptr)
    {
        return 0;
    }

    const auto rset = db::preparedStmt(
        fmt::format("SELECT `{}` AS sz FROM char_storage WHERE charid = ? LIMIT 1", def->col), charId);
    if (!rset || rset->rowsCount() == 0 || !rset->next())
    {
        return 0;
    }
    return rset->get<uint8>("sz");
}

auto ListBagChars(uint32 accId) -> std::vector<BagChar>
{
    std::vector<BagChar> out;

    const auto charRset = db::preparedStmt(
        "SELECT c.charid, c.charname, "
        "       (sess.charid IS NOT NULL) AS online, "
        "       (mim.charid  IS NOT NULL) AS locked "
        "FROM chars c "
        "LEFT JOIN accounts_sessions  sess ON sess.charid = c.charid "
        "LEFT JOIN char_mimic_active  mim  ON mim.charid  = c.charid "
        "WHERE c.accid = ? ORDER BY c.charid",
        accId);
    if (!charRset)
    {
        return out;
    }

    while (charRset->next())
    {
        BagChar bc;
        bc.charId = charRset->get<uint32>("charid");
        bc.name   = charRset->get<std::string>("charname");
        bc.online = charRset->get<uint32>("online") != 0;
        bc.locked = charRset->get<uint32>("locked") != 0;
        out.emplace_back(std::move(bc));
    }

    for (auto& bc : out)
    {
        // Occupied slots per container in one pass.
        std::array<uint8, MAX_CONTAINER_ID> used{};
        const auto usedRset = db::preparedStmt(
            "SELECT location, COUNT(*) AS n FROM char_inventory WHERE charid = ? GROUP BY location", bc.charId);
        if (usedRset)
        {
            while (usedRset->next())
            {
                const uint8 loc = usedRset->get<uint8>("location");
                if (loc < MAX_CONTAINER_ID)
                {
                    used[loc] = static_cast<uint8>(std::min<uint32>(usedRset->get<uint32>("n"), 255));
                }
            }
        }

        for (const auto& def : kBagContainers)
        {
            const uint8 size = BagContainerSize(bc.charId, def.id);
            if (size == 0)
            {
                continue;
            }
            BagContainerFill fill;
            fill.id   = def.id;
            fill.size = size;
            fill.used = used[def.id];
            bc.containers.emplace_back(fill);
        }
    }

    return out;
}

auto ListBagItems(uint32 charId, uint8 containerId) -> std::vector<BagItem>
{
    std::vector<BagItem> out;

    const auto rset = db::preparedStmt(
        "SELECT slot, itemId, quantity, signature, extra FROM char_inventory "
        "WHERE charid = ? AND location = ? ORDER BY slot",
        charId, containerId);
    if (!rset)
    {
        return out;
    }

    while (rset->next())
    {
        BagItem it;
        it.slot      = rset->get<uint8>("slot");
        it.itemId    = rset->get<uint16>("itemId");
        it.quantity  = rset->get<uint32>("quantity");
        it.signature = rset->get<std::string>("signature");
        db::extractFromBlob(rset, "extra", it.extra);

        if (it.itemId == 0 || it.itemId == 65535)
        {
            continue;
        }
        out.emplace_back(std::move(it));
    }

    return out;
}

auto BagFirstFreeSlot(uint32 charId, uint8 containerId) -> uint8
{
    const uint8 size = BagContainerSize(charId, containerId);
    if (size == 0)
    {
        return 0;
    }

    std::vector<bool> taken(size + 1, false);
    const auto        rset = db::preparedStmt(
        "SELECT slot FROM char_inventory WHERE charid = ? AND location = ?", charId, containerId);
    if (rset)
    {
        while (rset->next())
        {
            const uint8 slot = rset->get<uint8>("slot");
            if (slot >= 1 && slot <= size)
            {
                taken[slot] = true;
            }
        }
    }

    for (uint8 slot = 1; slot <= size; ++slot)
    {
        if (!taken[slot])
        {
            return slot;
        }
    }
    return 0;
}

auto BagReadRow(uint32 charId, uint8 containerId, uint8 slot, BagItem& out) -> bool
{
    const auto rset = db::preparedStmt(
        "SELECT slot, itemId, quantity, signature, extra FROM char_inventory "
        "WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
        charId, containerId, slot);
    if (!rset || rset->rowsCount() == 0 || !rset->next())
    {
        return false;
    }

    out.slot      = rset->get<uint8>("slot");
    out.itemId    = rset->get<uint16>("itemId");
    out.quantity  = rset->get<uint32>("quantity");
    out.signature = rset->get<std::string>("signature");
    db::extractFromBlob(rset, "extra", out.extra);

    return out.itemId != 0 && out.itemId != 65535;
}

auto BagInsertRow(uint32 charId, uint8 containerId, uint8 slot, const BagItem& item) -> bool
{
    // The blob binder only takes a non-const array, so hand it a mutable copy.
    uint8 extra[24];
    std::memcpy(extra, item.extra, sizeof(extra));

    return db::preparedStmt(
               "INSERT INTO char_inventory (charid, location, slot, itemId, quantity, signature, extra) "
               "VALUES (?, ?, ?, ?, ?, ?, ?)",
               charId, containerId, slot, item.itemId, item.quantity, item.signature, extra) != nullptr;
}

auto BagTakeRow(uint32 charId, uint8 containerId, uint8 slot, uint32 quantity) -> bool
{
    BagItem row;
    if (!BagReadRow(charId, containerId, slot, row))
    {
        return false;
    }

    if (quantity >= row.quantity)
    {
        return db::preparedStmt(
            "DELETE FROM char_inventory WHERE charid = ? AND location = ? AND slot = ?",
            charId, containerId, slot) != nullptr;
    }

    return db::preparedStmt(
        "UPDATE char_inventory SET quantity = quantity - ? WHERE charid = ? AND location = ? AND slot = ?",
        quantity, charId, containerId, slot) != nullptr;
}

auto ItemStackSize(uint16 itemId) -> uint16
{
    auto PItem = xi::items::spawn(itemId);
    return PItem ? static_cast<uint16>(PItem->getStackSize()) : 1;
}

// --- gear ---------------------------------------------------------------

namespace
{
    // Equip slot ids (mirror battle_entity.h SLOTTYPE) - kept local so this file
    // needn't pull the entity headers.
    enum : uint8
    {
        SL_MAIN = 0, SL_SUB = 1, SL_RANGED = 2, SL_AMMO = 3,
        SL_HEAD = 4, SL_BODY = 5, SL_HANDS = 6, SL_LEGS = 7, SL_FEET = 8,
        SL_NECK = 9, SL_WAIST = 10, SL_EAR1 = 11, SL_EAR2 = 12,
        SL_RING1 = 13, SL_RING2 = 14, SL_BACK = 15,
    };

    struct AltEquipInfo
    {
        uint8  mjob{};
        uint8  mjobLevel{};   // real char_jobs.<mjob>
        uint8  race{};
        bool   ok{};
    };

    auto LoadAltEquipInfo(uint32 charId) -> AltEquipInfo
    {
        AltEquipInfo info;

        const auto sRset = db::preparedStmt("SELECT mjob FROM char_stats WHERE charid = ? LIMIT 1", charId);
        if (!sRset || sRset->rowsCount() == 0 || !sRset->next())
        {
            return info;
        }
        info.mjob = sRset->get<uint8>("mjob");

        const auto lRset = db::preparedStmt("SELECT race FROM char_look WHERE charid = ? LIMIT 1", charId);
        if (lRset && lRset->rowsCount() != 0 && lRset->next())
        {
            info.race = lRset->get<uint8>("race");
        }

        if (const char* col = JobColumn(info.mjob))
        {
            const auto jRset = db::preparedStmt(
                fmt::format("SELECT `{}` AS lv FROM char_jobs WHERE charid = ? LIMIT 1", col), charId);
            if (jRset && jRset->rowsCount() != 0 && jRset->next())
            {
                info.mjobLevel = std::max<uint8>(jRset->get<uint8>("lv"), 1);
            }
        }

        info.ok = info.mjob >= 1 && info.mjob <= 22;
        return info;
    }

    // Race / final validation on a spawned equipment item for this alt.
    auto ItemFitsAlt(uint16 itemId, uint8 equipSlotId, const AltEquipInfo& alt) -> bool
    {
        auto PItem = xi::items::spawn(itemId);
        auto* PEquip = dynamic_cast<CItemEquipment*>(PItem.get());
        if (PEquip == nullptr)
        {
            return false;
        }
        if ((PEquip->getEquipSlotId() & (1 << equipSlotId)) == 0)
        {
            return false;
        }
        if ((PEquip->getJobs() & (1u << (alt.mjob - 1))) == 0)
        {
            return false;
        }
        if (PEquip->getReqLvl() > alt.mjobLevel)
        {
            return false;
        }
        if (!PEquip->isEquippableByRace(alt.race))
        {
            return false;
        }
        return true;
    }

    auto ItemHasAug(uint32 charId, uint8 containerId, uint8 slot) -> bool
    {
        const auto rset = db::preparedStmt(
            "SELECT extra FROM char_inventory WHERE charid = ? AND location = ? AND slot = ? LIMIT 1",
            charId, containerId, slot);
        if (!rset || rset->rowsCount() == 0 || !rset->next())
        {
            return false;
        }
        uint8 extra[24]{};
        db::extractFromBlob(rset, "extra", extra);
        for (uint8 i = 0; i < sizeof(extra); ++i)
        {
            if (extra[i] != 0)
            {
                return true;
            }
        }
        return false;
    }

    auto IsTwoHandedOrH2H(uint16 itemId) -> bool
    {
        auto  PItem   = xi::items::spawn(itemId);
        auto* PWeapon = dynamic_cast<CItemWeapon*>(PItem.get());
        return PWeapon != nullptr && (PWeapon->isTwoHanded() || PWeapon->isHandToHand());
    }
} // namespace

auto GearLookColumn(uint8 equipSlotId) -> const char*
{
    switch (equipSlotId)
    {
        case SL_MAIN:   return "main";
        case SL_SUB:    return "sub";
        case SL_RANGED: return "ranged";
        case SL_HEAD:   return "head";
        case SL_BODY:   return "body";
        case SL_HANDS:  return "hands";
        case SL_LEGS:   return "legs";
        case SL_FEET:   return "feet";
        default:        return nullptr;
    }
}

auto ItemModelId(uint16 itemId) -> uint16
{
    const auto rset = db::preparedStmt("SELECT MId FROM item_equipment WHERE itemId = ? LIMIT 1", itemId);
    if (rset && rset->rowsCount() != 0 && rset->next())
    {
        return rset->get<uint16>("MId");
    }
    return 0;
}

auto ListAltGear(uint32 charId) -> std::array<GearSlot, 16>
{
    std::array<GearSlot, 16> gear{};
    for (uint8 i = 0; i < 16; ++i)
    {
        gear[i].equipSlotId = i;
    }

    const auto rset = db::preparedStmt(
        "SELECT e.equipslotid, e.slotid, e.containerid, i.itemId, i.extra "
        "FROM char_equip e "
        "JOIN char_inventory i ON i.charid = e.charid AND i.location = e.containerid AND i.slot = e.slotid "
        "WHERE e.charid = ?",
        charId);
    if (rset)
    {
        while (rset->next())
        {
            const uint8 slot = rset->get<uint8>("equipslotid");
            if (slot >= 16)
            {
                continue;
            }
            gear[slot].itemId = rset->get<uint16>("itemId");

            uint8 extra[24]{};
            db::extractFromBlob(rset, "extra", extra);
            for (uint8 i = 0; i < sizeof(extra); ++i)
            {
                if (extra[i] != 0)
                {
                    gear[slot].aug = true;
                    break;
                }
            }
        }
    }

    return gear;
}

auto ListGearCandidates(uint32 accId, uint32 altCharId, uint8 equipSlotId) -> std::vector<GearCandidate>
{
    std::vector<GearCandidate> out;

    if (equipSlotId >= 16 || !IsOwnedByAccount(accId, altCharId))
    {
        return out;
    }

    const AltEquipInfo alt = LoadAltEquipInfo(altCharId);
    if (!alt.ok)
    {
        return out;
    }

    // Account characters and which of them is the (online) summoner.
    const auto charRset = db::preparedStmt(
        "SELECT c.charid, (sess.charid IS NOT NULL) AS online "
        "FROM chars c LEFT JOIN accounts_sessions sess ON sess.charid = c.charid "
        "WHERE c.accid = ? ORDER BY c.charid",
        accId);
    if (!charRset)
    {
        return out;
    }

    std::vector<std::pair<uint32, bool>> chars;
    while (charRset->next())
    {
        chars.emplace_back(charRset->get<uint32>("charid"), charRset->get<uint32>("online") != 0);
    }

    // SQL pre-filter on item_equipment; race is checked afterwards on a spawn.
    const std::string containerList = "0,8,10,11,12,13,14,15,16"; // LOC_INVENTORY + wardrobes 1-8

    for (const auto& [cid, online] : chars)
    {
        const auto rset = db::preparedStmt(
            fmt::format(
                "SELECT ci.location, ci.slot, ci.itemId, "
                "       (ce.equipslotid IS NOT NULL) AS equipped "
                "FROM char_inventory ci "
                "JOIN item_equipment ie ON ie.itemId = ci.itemId "
                "LEFT JOIN char_equip ce ON ce.charid = ci.charid AND ce.containerid = ci.location AND ce.slotid = ci.slot "
                "WHERE ci.charid = ? AND ci.location IN ({}) "
                "  AND (ie.slot & (1 << ?)) <> 0 "
                "  AND (ie.jobs & (1 << ?)) <> 0 "
                "  AND ie.level <= ? "
                "ORDER BY ci.itemId",
                containerList),
            cid, equipSlotId, alt.mjob - 1, alt.mjobLevel);
        if (!rset)
        {
            continue;
        }

        while (rset->next())
        {
            const uint16 itemId = rset->get<uint16>("itemId");
            if (!ItemFitsAlt(itemId, equipSlotId, alt))
            {
                continue;
            }

            GearCandidate gc;
            gc.srcCharId         = cid;
            gc.srcCharSelf       = online ? 1 : 0;
            gc.srcContainer      = rset->get<uint8>("location");
            gc.srcSlot           = rset->get<uint8>("slot");
            gc.itemId            = itemId;
            gc.equippedElsewhere = rset->get<uint32>("equipped") != 0 ? 1 : 0;
            gc.aug               = ItemHasAug(cid, gc.srcContainer, gc.srcSlot) ? 1 : 0;
            out.emplace_back(gc);
        }
    }

    return out;
}

namespace
{
    // Write char_equip + char_look for a slot whose item already sits in
    // altCharId's inventory at invSlot. Clears the sub slot for a 2H / H2H main.
    auto ApplyAltEquipRows(uint32 altCharId, uint8 equipSlotId, uint8 invSlot, uint16 itemId) -> GearResult
    {
        db::preparedStmt(
            "INSERT INTO char_equip (charid, slotid, equipslotid, containerid) VALUES (?, ?, ?, 0) "
            "ON DUPLICATE KEY UPDATE slotid = VALUES(slotid), containerid = 0",
            altCharId, invSlot, equipSlotId);

        if (const char* col = GearLookColumn(equipSlotId))
        {
            db::preparedStmt(fmt::format("UPDATE char_look SET `{}` = ? WHERE charid = ?", col),
                             ItemModelId(itemId), altCharId);
        }

        if (equipSlotId == SL_MAIN && IsTwoHandedOrH2H(itemId))
        {
            db::preparedStmt("DELETE FROM char_equip WHERE charid = ? AND equipslotid = ?", altCharId, SL_SUB);
            db::preparedStmt("UPDATE char_look SET `sub` = 0 WHERE charid = ?", altCharId);
        }

        return GearResult::Ok;
    }
} // namespace

auto FinishAltEquip(uint32 altCharId, uint8 equipSlotId, uint8 invSlot, uint16 itemId) -> GearResult
{
    if (equipSlotId >= 16)
    {
        return GearResult::BadSlot;
    }
    return ApplyAltEquipRows(altCharId, equipSlotId, invSlot, itemId);
}

auto EquipAltItem(uint32 accId, uint32 altCharId, uint8 equipSlotId,
                  uint32 srcCharId, uint8 srcContainer, uint8 srcSlot) -> GearResult
{
    if (equipSlotId >= 16)
    {
        return GearResult::BadSlot;
    }
    if (!IsOwnedByAccount(accId, altCharId) || !IsOwnedByAccount(accId, srcCharId))
    {
        return GearResult::NotOwned;
    }
    if (IsCharOnline(altCharId))
    {
        return GearResult::Online;
    }

    const AltEquipInfo alt = LoadAltEquipInfo(altCharId);
    if (!alt.ok)
    {
        return GearResult::NotEquippable;
    }

    BagItem row;
    if (!BagReadRow(srcCharId, srcContainer, srcSlot, row))
    {
        return GearResult::NoItem;
    }
    if (!ItemFitsAlt(row.itemId, equipSlotId, alt))
    {
        return GearResult::NotEquippable;
    }

    if (IsCharOnline(srcCharId))
    {
        // The summoner holds it live; the binding must move it with a transaction.
        return GearResult::NeedsLiveMove;
    }

    // Free the source: if that row is currently equipped on srcCharId, drop the
    // char_equip pointer first (force-unequip, offline char).
    db::preparedStmt(
        "DELETE FROM char_equip WHERE charid = ? AND containerid = ? AND slotid = ?",
        srcCharId, srcContainer, srcSlot);

    // Relocate the item into the alt's inventory.
    uint8 destSlot = 0;
    if (srcCharId == altCharId)
    {
        if (srcContainer == LOC_INVENTORY)
        {
            destSlot = srcSlot; // already where it needs to be
        }
        else
        {
            destSlot = BagFirstFreeSlot(altCharId, LOC_INVENTORY);
            if (destSlot == 0)
            {
                return GearResult::DbError;
            }
            if (!db::preparedStmt(
                    "UPDATE char_inventory SET location = 0, slot = ? WHERE charid = ? AND location = ? AND slot = ?",
                    destSlot, altCharId, srcContainer, srcSlot))
            {
                return GearResult::DbError;
            }
        }
    }
    else
    {
        destSlot = BagFirstFreeSlot(altCharId, LOC_INVENTORY);
        if (destSlot == 0)
        {
            return GearResult::DbError;
        }
        BagItem placed = row;
        placed.slot    = destSlot;
        if (!BagInsertRow(altCharId, LOC_INVENTORY, destSlot, placed))
        {
            return GearResult::DbError;
        }
        db::preparedStmt(
            "DELETE FROM char_inventory WHERE charid = ? AND location = ? AND slot = ?",
            srcCharId, srcContainer, srcSlot);
    }

    return ApplyAltEquipRows(altCharId, equipSlotId, destSlot, row.itemId);
}

auto UnequipAltItem(uint32 accId, uint32 altCharId, uint8 equipSlotId) -> GearResult
{
    if (equipSlotId >= 16)
    {
        return GearResult::BadSlot;
    }
    if (!IsOwnedByAccount(accId, altCharId))
    {
        return GearResult::NotOwned;
    }
    if (IsCharOnline(altCharId))
    {
        return GearResult::Online;
    }

    db::preparedStmt("DELETE FROM char_equip WHERE charid = ? AND equipslotid = ?", altCharId, equipSlotId);

    if (const char* col = GearLookColumn(equipSlotId))
    {
        db::preparedStmt(fmt::format("UPDATE char_look SET `{}` = 0 WHERE charid = ?", col), altCharId);
    }

    return GearResult::Ok;
}

// --- scroll learning --------------------------------------------------

auto ScrollSpellId(uint16 itemId) -> uint16
{
    // item_basic.type 5 (usable) whose subid names a real spell = a spell scroll.
    const auto rset = db::preparedStmt(
        "SELECT subid FROM item_basic "
        "WHERE itemid = ? AND type = 5 AND subid > 0 AND subid IN (SELECT spellid FROM spell_list) LIMIT 1",
        itemId);
    if (rset && rset->rowsCount() != 0 && rset->next())
    {
        return rset->get<uint16>("subid");
    }
    return 0;
}

auto AccountMeetsSpellPrereq(uint32 accId, uint16 spellId) -> bool
{
    // spell_list.jobs is binary(22): byte j = the level job (j+1) learns it at,
    // 0 = never. Same test spell::CanUseSpell uses (level >= that).
    const auto sRset = db::preparedStmt("SELECT jobs FROM spell_list WHERE spellid = ? LIMIT 1", spellId);
    if (!sRset || sRset->rowsCount() == 0 || !sRset->next())
    {
        return false;
    }
    uint8 jobLvl[22]{};
    db::extractFromBlob(sRset, "jobs", jobLvl);

    std::string cols;
    for (int i = 0; i < 22; ++i)
    {
        if (i != 0)
        {
            cols += ",";
        }
        cols += "j.";
        cols += kJobCols[i];
    }

    const auto cRset = db::preparedStmt(
        fmt::format("SELECT {} FROM char_jobs j JOIN chars c ON c.charid = j.charid WHERE c.accid = ?", cols),
        accId);
    if (!cRset)
    {
        return false;
    }

    while (cRset->next())
    {
        for (int i = 0; i < 22; ++i)
        {
            if (jobLvl[i] > 0 && cRset->get<uint8>(kJobCols[i]) >= jobLvl[i])
            {
                return true;
            }
        }
    }
    return false;
}

void FanOutSpellToAccount(uint32 accId, uint16 spellId)
{
    db::preparedStmt(
        "INSERT IGNORE INTO char_spells (charid, spellid) "
        "SELECT charid, ? FROM chars WHERE accid = ?",
        spellId, accId);
}

}; // namespace squadutils
