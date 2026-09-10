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

#include "warehouseutils.h"

#include <cstring>
#include <stdexcept>

#include "common/database.h"

namespace warehouseutils
{

namespace
{
    auto rowHasAug(const uint8 extra[24]) -> bool
    {
        for (uint8 i = 0; i < 24; ++i)
        {
            if (extra[i] != 0)
            {
                return true;
            }
        }
        return false;
    }
} // namespace

auto Generation(uint32 accId) -> uint32
{
    const auto rset = db::preparedStmt("SELECT generation FROM account_warehouse_meta WHERE accid = ? LIMIT 1", accId);
    if (rset && rset->rowsCount() != 0 && rset->next())
    {
        return rset->get<uint32>("generation");
    }
    return 0;
}

void BumpGeneration(uint32 accId)
{
    db::preparedStmt(
        "INSERT INTO account_warehouse_meta (accid, generation) VALUES (?, 1) "
        "ON DUPLICATE KEY UPDATE generation = generation + 1",
        accId);
}

auto RowCount(uint32 accId) -> uint32
{
    const auto rset = db::preparedStmt("SELECT COUNT(*) AS n FROM account_warehouse WHERE accid = ?", accId);
    if (rset && rset->rowsCount() != 0 && rset->next())
    {
        return rset->get<uint32>("n");
    }
    return 0;
}

auto PageCount(uint32 accId) -> uint32
{
    const uint32 rows = RowCount(accId);
    return rows == 0 ? 1 : (rows + PageSize - 1) / PageSize;
}

auto ListPage(uint32 accId, uint32 page) -> std::vector<WarehouseRow>
{
    std::vector<WarehouseRow> out;

    const auto rset = db::preparedStmt(
        "SELECT rowid, itemId, quantity, signature, extra FROM account_warehouse "
        "WHERE accid = ? ORDER BY rowid ASC LIMIT ?, ?",
        accId, page * PageSize, PageSize);
    if (!rset)
    {
        return out;
    }

    while (rset->next())
    {
        WarehouseRow row;
        row.rowid     = rset->get<uint32>("rowid");
        row.itemId    = rset->get<uint16>("itemId");
        row.quantity  = rset->get<uint32>("quantity");
        row.signature = rset->get<std::string>("signature");
        db::extractFromBlob(rset, "extra", row.extra);
        row.aug = rowHasAug(row.extra);

        if (row.itemId == 0 || row.itemId == 65535 || row.quantity == 0)
        {
            continue;
        }
        out.emplace_back(std::move(row));
    }

    return out;
}

auto ReadRow(uint32 accId, uint32 rowid, WarehouseRow& out) -> bool
{
    const auto rset = db::preparedStmt(
        "SELECT rowid, itemId, quantity, signature, extra FROM account_warehouse "
        "WHERE rowid = ? AND accid = ? LIMIT 1",
        rowid, accId);
    if (!rset || rset->rowsCount() == 0 || !rset->next())
    {
        return false;
    }

    out.rowid     = rset->get<uint32>("rowid");
    out.itemId    = rset->get<uint16>("itemId");
    out.quantity  = rset->get<uint32>("quantity");
    out.signature = rset->get<std::string>("signature");
    db::extractFromBlob(rset, "extra", out.extra);
    out.aug = rowHasAug(out.extra);

    return out.itemId != 0 && out.itemId != 65535;
}

auto FindMergeRow(uint32 accId, uint16 itemId) -> uint32
{
    // A plain stack row: same item, empty signature, all-zero extra.
    const auto rset = db::preparedStmt(
        "SELECT rowid, extra FROM account_warehouse "
        "WHERE accid = ? AND itemId = ? AND signature = '' ORDER BY rowid ASC",
        accId, itemId);
    if (!rset)
    {
        return 0;
    }

    while (rset->next())
    {
        uint8 extra[24]{};
        db::extractFromBlob(rset, "extra", extra);
        if (!rowHasAug(extra))
        {
            return rset->get<uint32>("rowid");
        }
    }
    return 0;
}

auto AddQuantity(uint32 accId, uint32 rowid, uint32 delta) -> bool
{
    return db::preparedStmt(
               "UPDATE account_warehouse SET quantity = quantity + ? WHERE rowid = ? AND accid = ?",
               delta, rowid, accId) != nullptr;
}

auto InsertRow(uint32 accId, uint16 itemId, uint32 quantity,
               const std::string& signature, const uint8 extra[24]) -> uint32
{
    uint8 extraCopy[24];
    std::memcpy(extraCopy, extra, sizeof(extraCopy));

    uint32 newRowId = 0;

    // One connection for the INSERT + LAST_INSERT_ID() read (see gmcall_container).
    const bool ok = db::transaction(
        [&]()
        {
            if (!db::preparedStmt(
                    "INSERT INTO account_warehouse (accid, itemId, quantity, signature, extra) VALUES (?, ?, ?, ?, ?)",
                    accId, itemId, quantity, signature, extraCopy))
            {
                throw std::runtime_error("account_warehouse insert failed");
            }
            if (const auto rset = db::preparedStmt("SELECT LAST_INSERT_ID() AS id"); rset && rset->next())
            {
                newRowId = rset->get<uint32>("id");
            }
        });

    return ok ? newRowId : 0;
}

auto TakeQuantity(uint32 accId, uint32 rowid, uint32 quantity) -> bool
{
    WarehouseRow row;
    if (!ReadRow(accId, rowid, row))
    {
        return false;
    }
    if (quantity == 0 || quantity > row.quantity)
    {
        return false;
    }

    if (quantity == row.quantity)
    {
        return db::preparedStmt("DELETE FROM account_warehouse WHERE rowid = ? AND accid = ?", rowid, accId) != nullptr;
    }

    return db::preparedStmt(
               "UPDATE account_warehouse SET quantity = quantity - ? WHERE rowid = ? AND accid = ?",
               quantity, rowid, accId) != nullptr;
}

auto DeleteRow(uint32 accId, uint32 rowid) -> bool
{
    return db::preparedStmt("DELETE FROM account_warehouse WHERE rowid = ? AND accid = ?", rowid, accId) != nullptr;
}

}; // namespace warehouseutils
