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

#include "common/types/position.h"
#include "player_controller.h"

#include <optional>

class CCharEntity;

// Installed on a world-population bot's CCharEntity in place of the default
// CPlayerController (see src/map/utils/botutils.cpp). A bot has no real client
// sending movement packets, so it needs its own CPathFind (mirroring the
// existing CPlayerCharmController precedent for attaching one to a live
// CCharEntity) driven here instead, at the entity's normal walking speed -
// not a teleport.
class CWorldBotController : public CPlayerController
{
public:
    explicit CWorldBotController(CCharEntity* PChar);
    ~CWorldBotController() override;

    auto Tick(timer::time_point tick) -> Task<void> override;

    // Sets a new walk destination. Consumed incrementally across subsequent
    // Tick() calls via the navmesh/pathfind - safe to call again mid-walk to
    // redirect. Cleared automatically once reached or found unreachable.
    void SetWanderTarget(const position_t& dest);

private:
    std::optional<position_t> wanderTarget_;
};
