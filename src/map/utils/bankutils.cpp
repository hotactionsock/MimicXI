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

#include "bankutils.h"

#include "charutils.h"
#include "itemutils.h"

#include "common/database.h"

#include "entities/charentity.h"
#include "item_container.h"
#include "items/item.h"

#include "packets/s2c/0x01d_item_same.h"
#include "packets/s2c/0x1f0_bank_list.h"

#include <algorithm>
#include <utility>

namespace bankutils
{

bool IsBankable(uint16 itemId)
{
    const auto* PItem = xi::items::lookup(itemId);
    if (PItem == nullptr)
    {
        return false;
    }

    // Equipment/weapons (including augmented gear) can't merge on itemid alone --
    // each instance would need its own row keyed on its unique augment data, which
    // is a future extension. v1 only banks plain stackables.
    return !PItem->isType(ITEM_EQUIPMENT) && !PItem->isType(ITEM_WEAPON);
}

uint32 GetItemQuantity(uint32 accid, uint16 itemId)
{
    auto rset = db::preparedStmt("SELECT quantity FROM account_bank WHERE accid = ? AND itemid = ?", accid, itemId);
    if (rset && rset->rowsCount() > 0 && rset->next())
    {
        return rset->get<uint32>("quantity");
    }

    return 0;
}

std::vector<BankItem> GetItems(uint32 accid)
{
    std::vector<BankItem> items;

    auto rset = db::preparedStmt("SELECT itemid, quantity FROM account_bank WHERE accid = ? ORDER BY itemid", accid);
    if (rset)
    {
        while (rset->next())
        {
            items.emplace_back(BankItem{ rset->get<uint16>("itemid"), rset->get<uint32>("quantity") });
        }
    }

    return items;
}

bool AddItem(uint32 accid, uint16 itemId, uint32 quantity)
{
    if (quantity == 0 || !IsBankable(itemId))
    {
        return false;
    }

    auto rset = db::preparedStmt(
        "INSERT INTO account_bank (accid, itemid, quantity) VALUES (?, ?, ?) "
        "ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)",
        accid, itemId, quantity);

    return rset != nullptr;
}

bool RemoveItem(uint32 accid, uint16 itemId, uint32 quantity)
{
    if (quantity == 0)
    {
        return false;
    }

    const auto current = GetItemQuantity(accid, itemId);
    if (current < quantity)
    {
        return false;
    }

    if (current == quantity)
    {
        db::preparedStmt("DELETE FROM account_bank WHERE accid = ? AND itemid = ?", accid, itemId);
    }
    else
    {
        db::preparedStmt("UPDATE account_bank SET quantity = quantity - ? WHERE accid = ? AND itemid = ?", quantity, accid, itemId);
    }

    return true;
}

namespace
{
    // True if inventory slotID is currently filled by an equipped item.
    bool IsEquippedSlot(CCharEntity* PChar, uint8 slotId)
    {
        for (uint8 equipSlot = 0; equipSlot < EquipSlotCount; ++equipSlot)
        {
            auto eloc = PChar->equipLocation(equipSlot);
            if (eloc && eloc->Container == LOC_INVENTORY && eloc->Slot == slotId)
            {
                return true;
            }
        }

        return false;
    }
} // namespace

bool DepositItem(CCharEntity* PChar, uint16 itemId, uint32 quantity)
{
    if (PChar == nullptr || quantity == 0 || !IsBankable(itemId))
    {
        return false;
    }

    auto* PItemContainer = PChar->getStorage(LOC_INVENTORY);

    // Gather unequipped slots holding this item, and make sure there's enough
    // available before touching anything (deposits are all-or-nothing).
    std::vector<uint8> sources;
    uint32              available = 0;

    for (const auto slotId : PItemContainer->SearchItems(itemId))
    {
        if (IsEquippedSlot(PChar, slotId))
        {
            continue;
        }

        const auto* PItem = PItemContainer->GetItem(slotId);
        if (PItem == nullptr || PItem->getCharPrice() > 0) // skip items listed in the player's bazaar
        {
            continue;
        }

        sources.push_back(slotId);
        available += PItem->getQuantity();
    }

    if (available < quantity)
    {
        return false;
    }

    uint32 remaining = quantity;
    for (const auto slotId : sources)
    {
        if (remaining == 0)
        {
            break;
        }

        const auto* PItem = PItemContainer->GetItem(slotId);
        const auto  take  = std::min<uint32>(PItem->getQuantity(), remaining);

        charutils::UpdateItem(PChar, LOC_INVENTORY, slotId, -static_cast<int32>(take));
        remaining -= take;
    }

    PChar->pushPacket<GP_SERV_COMMAND_ITEM_SAME>(PChar);

    return AddItem(PChar->accid, itemId, quantity);
}

std::vector<BankItem> DepositAll(CCharEntity* PChar)
{
    std::vector<BankItem> deposited;

    if (PChar == nullptr)
    {
        return deposited;
    }

    auto* PItemContainer = PChar->getStorage(LOC_INVENTORY);

    // Tally up everything eligible per itemid first, then perform the moves --
    // avoids re-scanning the container mid-mutation.
    std::vector<std::pair<uint16, uint32>> tally;

    for (uint8 slotId = 1; slotId <= PItemContainer->GetSize(); ++slotId)
    {
        const auto* PItem = PItemContainer->GetItem(slotId);
        if (PItem == nullptr || !IsBankable(PItem->getID()) || PItem->getCharPrice() > 0 || IsEquippedSlot(PChar, slotId))
        {
            continue;
        }

        const auto itemId = PItem->getID();
        auto       it      = std::find_if(tally.begin(), tally.end(), [&](const auto& pair) { return pair.first == itemId; });
        if (it == tally.end())
        {
            tally.emplace_back(itemId, PItem->getQuantity());
        }
        else
        {
            it->second += PItem->getQuantity();
        }
    }

    for (const auto& [itemId, quantity] : tally)
    {
        if (DepositItem(PChar, itemId, quantity))
        {
            deposited.emplace_back(BankItem{ itemId, quantity });
        }
    }

    return deposited;
}

bool WithdrawItem(CCharEntity* PChar, uint16 itemId, uint32 quantity)
{
    if (PChar == nullptr || quantity == 0)
    {
        return false;
    }

    const auto* PTemplate = xi::items::lookup(itemId);
    if (PTemplate == nullptr)
    {
        return false;
    }

    // Mirrors the stack-splitting behaviour of CLuaBaseEntity::addItem, since
    // charutils::AddItem(PChar, LocationID, itemID, quantity) silently drops any
    // quantity above one stack (CItem::setQuantity self-clamps to stackSize).
    const auto stackSize = std::max<uint32>(PTemplate->getStackSize(), 1);

    if (!RemoveItem(PChar->accid, itemId, quantity))
    {
        return false;
    }

    uint32 remaining = quantity;
    while (remaining > 0)
    {
        const auto give = std::min<uint32>(remaining, stackSize);
        if (charutils::AddItem(PChar, LOC_INVENTORY, itemId, give) == ERROR_SLOTID)
        {
            // Ran out of inventory room partway through -- refund what we couldn't
            // deliver back into the bank so nothing is lost.
            AddItem(PChar->accid, itemId, remaining);
            return false;
        }

        remaining -= give;
    }

    return true;
}

void SendBankList(CCharEntity* PChar)
{
    if (PChar == nullptr || PChar->objtype != TYPE_PC)
    {
        return;
    }

    PChar->pushPacket<GP_SERV_COMMAND_BANK_LIST>(PChar, GetItems(PChar->accid));
}

} // namespace bankutils
