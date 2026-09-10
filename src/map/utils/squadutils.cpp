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

#include "common/database.h"

namespace squadutils
{

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
        "SELECT c.charid, c.charname, s.mjob, s.mlvl, "
        "       (sess.charid IS NOT NULL) AS online, "
        "       (mim.charid IS NOT NULL)  AS locked "
        "FROM chars c "
        "JOIN char_stats s          ON s.charid    = c.charid "
        "LEFT JOIN accounts_sessions sess ON sess.charid = c.charid "
        "LEFT JOIN char_mimic_active mim  ON mim.charid  = c.charid "
        "WHERE c.accid = ? ORDER BY c.charid",
        accId);

    if (rset)
    {
        while (rset->next())
        {
            AccountChar entry;
            entry.charId  = rset->get<uint32>("charid");
            entry.name    = rset->get<std::string>("charname");
            entry.mainJob = rset->get<uint8>("mjob");
            entry.mainLvl = rset->get<uint8>("mlvl");
            entry.online  = rset->get<uint32>("online") != 0;
            entry.locked  = rset->get<uint32>("locked") != 0;
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

}; // namespace squadutils
