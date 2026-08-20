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

#ifndef _CMIMICTRUSTENTITY_H
#define _CMIMICTRUSTENTITY_H

#include "trustentity.h"

class CCharEntity;
class CDespawnState;

// A trust built from the real look/stats/gear of one of the summoner's own
// offline alt characters, rather than from mob_pools data.
class CMimicTrustEntity : public CTrustEntity
{
public:
    explicit CMimicTrustEntity(CCharEntity*);

    void OnDespawn(CDespawnState&) override;

    uint32 m_MimicSourceCharId{};
};

#endif
