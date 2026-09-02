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

#include "0x1f0_bank_list.h"

#include "entities/charentity.h"
#include "items/item.h"
#include "utils/bankutils.h"
#include "utils/itemutils.h"

#include <algorithm>

namespace
{
// Mirrors xi.bank.category in scripts/globals/bank.lua -- keep the two in sync.
enum BankCategory : uint8_t
{
    BANK_CATEGORY_GENERAL  = 1,
    BANK_CATEGORY_USABLE   = 2,
    BANK_CATEGORY_CURRENCY = 3,
    BANK_CATEGORY_OTHER    = 4,
};

uint8_t CategoryForItem(uint16_t itemId)
{
    const auto* PItem = xi::items::lookup(itemId);
    if (PItem == nullptr)
    {
        return BANK_CATEGORY_OTHER;
    }

    if (PItem->isType(ITEM_CURRENCY))
    {
        return BANK_CATEGORY_CURRENCY;
    }

    if (PItem->isType(ITEM_USABLE))
    {
        return BANK_CATEGORY_USABLE;
    }

    if (PItem->isType(ITEM_GENERAL))
    {
        return BANK_CATEGORY_GENERAL;
    }

    return BANK_CATEGORY_OTHER;
}
} // namespace

GP_SERV_COMMAND_BANK_LIST::GP_SERV_COMMAND_BANK_LIST(CCharEntity* PChar, const std::vector<bankutils::BankItem>& items)
{
    auto& packet = this->data();

    const auto count = std::min(items.size(), MAX_ENTRIES);
    packet.truncated  = items.size() > MAX_ENTRIES ? 1 : 0;

    for (std::size_t i = 0; i < count; ++i)
    {
        packet.entries[i].itemId   = items[i].itemId;
        packet.entries[i].category = CategoryForItem(items[i].itemId);
        packet.entries[i].quantity = items[i].quantity;
    }
}
