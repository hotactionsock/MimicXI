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

    // Zone line the bot walked into since the last call (0 = none), consumed by
    // botutils::ProcessPendingZoneLines at the start of the zone tick - the bot
    // can't be moved to another zone from inside its own Tick().
    auto TakePendingZoneLine() -> uint32;

    // True about once a second (and then not again until the next interval) -
    // paces botutils::TickBotSenses like a real client's position updates.
    auto SenseDue(timer::time_point now) -> bool;

private:
    void checkZoneLineArea(bool allowCrossing = true);
    void tickCombatMovement();

    position_t chaseAim_{}; // where the current chase path was aimed (re-path when the target moves off it)

    std::optional<position_t> wanderTarget_;

    // Zone-line area tracking: a crossing fires only on ENTERING an area (like a
    // real client), so a bot that spawns standing inside one - e.g. arriving
    // next to the return line - doesn't bounce straight back through it.
    uint32 currentZoneLineArea_{ 0 };
    bool   zoneLineAreaKnown_{ false };
    uint32 pendingZoneLine_{ 0 };

    timer::time_point nextSense_{};
};
