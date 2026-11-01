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

#include "world_bot_controller.h"

#include "ai/ai_container.h"
#include "ai/helpers/pathfind.h"
#include "entities/char_entity.h"

CWorldBotController::CWorldBotController(CCharEntity* PChar)
: CPlayerController(PChar)
{
    POwner->PAI->PathFind = std::make_unique<CPathFind>(PChar);
}

CWorldBotController::~CWorldBotController()
{
    if (POwner->PAI)
    {
        POwner->PAI->PathFind.reset();
    }
}

auto CWorldBotController::Tick(const timer::time_point tick) -> Task<void>
{
    m_Tick = tick;

    if (wanderTarget_ && POwner->PAI->PathFind)
    {
        if (!POwner->PAI->PathFind->IsFollowingPath())
        {
            // PATHFLAG_RUN: every other AI-driven mover (mobs, trusts, pets,
            // the charm controller) always paths at run speed - matching that
            // keeps a bot indistinguishable from a real player's normal pace.
            if (!POwner->PAI->PathFind->PathTo(*wanderTarget_, PATHFLAG_RUN))
            {
                // Unreachable from here - drop it rather than retry every tick.
                wanderTarget_.reset();
            }
        }

        if (POwner->PAI->PathFind->IsFollowingPath())
        {
            POwner->PAI->PathFind->FollowPath(tick);

            if (!POwner->PAI->PathFind->IsFollowingPath())
            {
                // Arrived.
                wanderTarget_.reset();
            }
        }
    }

    co_return;
}

void CWorldBotController::SetWanderTarget(const position_t& dest)
{
    wanderTarget_ = dest;
}
