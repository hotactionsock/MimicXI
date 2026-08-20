/*
===========================================================================

  Copyright (c) 2018 Darkstar Dev Teams

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

#include "mimictrustentity.h"
#include "common/database.h"

CMimicTrustEntity::CMimicTrustEntity(CCharEntity* PChar)
: CTrustEntity(PChar)
{
}

void CMimicTrustEntity::OnDespawn(CDespawnState& state)
{
    CTrustEntity::OnDespawn(state);

    if (m_MimicSourceCharId != 0)
    {
        db::preparedStmt("DELETE FROM char_mimic_active WHERE charid = ?", m_MimicSourceCharId);
    }
}
