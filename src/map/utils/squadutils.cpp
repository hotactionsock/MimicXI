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

#include <fmt/format.h>

#include "common/database.h"

namespace squadutils
{

namespace
{
    constexpr const char* kJobCols[] = {
        "war", "mnk", "whm", "blm", "rdm", "thf", "pld", "drk", "bst", "brd", "rng",
        "sam", "nin", "drg", "smn", "blu", "cor", "pup", "dnc", "sch", "geo", "run"
    };
} // namespace

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

}; // namespace squadutils
