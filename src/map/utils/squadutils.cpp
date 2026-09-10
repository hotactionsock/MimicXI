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

}; // namespace squadutils
