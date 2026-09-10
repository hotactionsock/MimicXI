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

#include <string>
#include <vector>

#include "common/cbasetypes.h"

class CCharEntity;

namespace warehouseutils
{

// Effectively unlimited; a backstop against a runaway loop filling the table.
inline constexpr uint32 SoftRowCap = 5000;

// Rows returned per page envelope on the wire.
inline constexpr uint32 PageSize = 40;

struct WarehouseRow
{
    uint32      rowid{};
    uint16      itemId{};
    uint32      quantity{};
    bool        aug{};       // has augment / exdata (a non-zero extra blob)
    std::string signature;
    uint8       extra[24]{};
};

// Per-account generation counter (bumped on every write); 0 if the account has
// never touched the warehouse.
auto Generation(uint32 accId) -> uint32;

// Number of rows the account currently has stored.
auto RowCount(uint32 accId) -> uint32;

// Number of page envelopes needed to walk the whole stash (>= 1).
auto PageCount(uint32 accId) -> uint32;

// One page of rows, ordered by rowid ascending. page is 0-based.
auto ListPage(uint32 accId, uint32 page) -> std::vector<WarehouseRow>;

// Read one row, scoped to accId. False if it does not exist / belongs elsewhere.
auto ReadRow(uint32 accId, uint32 rowid, WarehouseRow& out) -> bool;

enum class Result : uint8
{
    Ok,          // done; caller bumps the generation
    NoItem,      // the source slot is empty, or the item id did not match (stale)
    Full,        // the soft row cap was reached
    BadRow,      // rowid not found for this account
    InventoryFull, // withdrawal target has no free slot
    BadQuantity,
    DbError,
};

// --- deposit / withdraw (the lua binding owns the live-inventory side) ---
//
// Put/Take move items between the online character's live inventory (handled by
// the binding through an ItemClaimTransaction) and account_warehouse (handled
// here as direct SQL). Stackable plain items merge into an existing row;
// augmented / signed / charged items always get a fresh row.

// True if a plain (no signature, no augment/exdata) item may merge - the binding
// decides whether the deposited item qualifies.
auto FindMergeRow(uint32 accId, uint16 itemId) -> uint32; // rowid, 0 if none

// Add quantity to an existing row (merge path).
auto AddQuantity(uint32 accId, uint32 rowid, uint32 delta) -> bool;

// Insert a fresh row; returns the new rowid, 0 on failure.
auto InsertRow(uint32 accId, uint16 itemId, uint32 quantity,
               const std::string& signature, const uint8 extra[24]) -> uint32;

// Remove quantity from a row (deletes it at zero). False if the row is gone or
// holds less than quantity.
auto TakeQuantity(uint32 accId, uint32 rowid, uint32 quantity) -> bool;

// Delete a row outright (trash).
auto DeleteRow(uint32 accId, uint32 rowid) -> bool;

// Bump the account's generation counter. Call once per successful mutation.
void BumpGeneration(uint32 accId);

}; // namespace warehouseutils
