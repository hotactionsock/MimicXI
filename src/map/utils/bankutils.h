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
#include <vector>

class CCharEntity;

// The account-wide bank. Unlike CItemContainer (charid-keyed, fixed slot count,
// per-item stack-size cap), this is keyed by accid and has no slot limit and no
// per-item stack cap -- see account_bank.sql.
//
// v1 scope: bankable items are non-equipment, non-weapon stackables (materials,
// usables, currency, etc). Equipment/weapons (including augmented gear) are
// intentionally rejected -- each instance would need its own row (can't merge
// on itemid alone), which is left as a future extension.
namespace bankutils
{
struct BankItem
{
    uint16 itemId;
    uint32 quantity;
};

// True if this item type is allowed in the account bank.
bool IsBankable(uint16 itemId);

// Current quantity of itemId in accid's bank (0 if none).
uint32 GetItemQuantity(uint32 accid, uint16 itemId);

// Every item currently in accid's bank, ordered by itemid.
std::vector<BankItem> GetItems(uint32 accid);

// Adds quantity of itemId to accid's bank, merging with any existing stack.
// This only touches the bank table -- callers that also need to remove the
// item from a character's inventory should use DepositItem/DepositAll instead.
bool AddItem(uint32 accid, uint16 itemId, uint32 quantity);

// Removes quantity of itemId from accid's bank. Fails if the bank doesn't have enough.
bool RemoveItem(uint32 accid, uint16 itemId, uint32 quantity);

// Moves quantity of itemId out of PChar's main inventory and into their account bank.
// Skips equipped slots. Fails (no partial deposit) if PChar doesn't have quantity
// available across their unequipped stacks of itemId, or if itemId isn't bankable.
bool DepositItem(CCharEntity* PChar, uint16 itemId, uint32 quantity);

// Moves every eligible (bankable, unequipped, not up for bazaar sale) item out of
// PChar's main inventory and into their account bank. Returns what was deposited.
std::vector<BankItem> DepositAll(CCharEntity* PChar);

// Moves quantity of itemId out of PChar's account bank and into their main inventory,
// splitting across multiple inventory stacks as needed to respect the item's normal
// stack size. Fails (no partial withdrawal) if the bank doesn't have quantity, or if
// PChar doesn't have enough free inventory slots to hold it.
bool WithdrawItem(CCharEntity* PChar, uint16 itemId, uint32 quantity);

// Pushes the current contents of PChar's account bank to their client via
// GP_SERV_COMMAND_BANK_LIST, for the companion Ashita addon (see
// tools/ashita-addons/mimicxi_bank) to render. No-op for non-PC callers.
void SendBankList(CCharEntity* PChar);

} // namespace bankutils
