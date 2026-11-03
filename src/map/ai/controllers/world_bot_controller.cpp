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
#include "ai/states/magic_state.h"
#include "common/utils.h"
#include "entities/char_entity.h"
#include "utils/botutils.h"
#include "map_constants.h"

#include <algorithm>
#include <utility>

namespace
{

// A player's client moves speed / 10 yalms a second; AI pathing steps
// speed / 50 yalms per (running) step, one step per zone tick. Scale the steps
// so a bot covers ground like a player at the same speed (BASE_SPEED in
// settings/map.lua, plus gear, buffs and the rest - CBattleEntity::UpdateSpeed).
constexpr float kPlayerStepScale = std::chrono::duration<float>(kLogicUpdateInterval).count() * 50.0f / 10.0f;

} // namespace

CWorldBotController::CWorldBotController(CCharEntity* PChar)
: CPlayerController(PChar)
{
    POwner->PAI->PathFind = std::make_unique<CPathFind>(PChar);
    POwner->PAI->PathFind->SetStepScale(kPlayerStepScale);
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

    auto* PChar = static_cast<CCharEntity*>(POwner);

    // Dead: lie still until xi.worldbots sends it to its home point.
    if (PChar->isDead())
    {
        wanderTarget_.reset();
        if (PChar->PAI->PathFind)
        {
            PChar->PAI->PathFind->Clear();
        }
        co_return;
    }

    // Casting: hold still - moving would interrupt the spell.
    if (PChar->PAI->IsCurrentState<CMagicState>())
    {
        if (PChar->PAI->PathFind && PChar->PAI->PathFind->IsFollowingPath())
        {
            PChar->PAI->PathFind->Clear();
        }
        co_return;
    }

    // Fighting takes priority over any walk order: close to melee range and face
    // the target (a real client steers into range itself; the engine's attack
    // state only swings once in range).
    if (PChar->PAI->IsEngaged())
    {
        tickCombatMovement();
        co_return;
    }

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
            checkZoneLineArea();

            if (!POwner->PAI->PathFind->IsFollowingPath())
            {
                // Arrived.
                wanderTarget_.reset();
            }
        }
    }

    co_return;
}

void CWorldBotController::tickCombatMovement()
{
    auto* PChar   = static_cast<CCharEntity*>(POwner);
    auto* PTarget = PChar->GetBattleTarget();
    auto* path    = PChar->PAI->PathFind.get();
    if (PTarget == nullptr || path == nullptr)
    {
        return;
    }

    wanderTarget_.reset();

    // Casters stand off at their combat range; everyone else closes to melee.
    const float melee = PChar->GetMeleeRange(PTarget);
    const float range = combatRange_ > melee ? combatRange_ : melee;
    const float dist  = distance(PChar->loc.p, PTarget->loc.p);

    if (dist <= range - 0.3f)
    {
        if (path->IsFollowingPath())
        {
            path->Clear();
        }
        path->LookAt(PTarget->loc.p);
        return;
    }

    // Re-path when idle or when the target has moved away from where we aimed.
    if (!path->IsFollowingPath() || distance(chaseAim_, PTarget->loc.p) > 2.0f)
    {
        chaseAim_ = PTarget->loc.p;
        path->PathAround(PTarget->loc.p, std::max(range - 1.0f, 0.5f), PATHFLAG_RUN);
    }

    if (path->IsFollowingPath())
    {
        path->FollowPath(m_Tick);
        checkZoneLineArea(false); // track the area, but never zone out mid-fight
    }
}

void CWorldBotController::SetWanderTarget(const position_t& dest)
{
    wanderTarget_ = dest;
}

void CWorldBotController::ClearWanderTarget()
{
    wanderTarget_.reset();
}

void CWorldBotController::SetCombatRange(float yalms)
{
    combatRange_ = std::max(yalms, 0.0f);
}

auto CWorldBotController::SenseDue(const timer::time_point now) -> bool
{
    if (now < nextSense_)
    {
        return false;
    }

    nextSense_ = now + 1s;
    return true;
}

auto CWorldBotController::TakePendingZoneLine() -> uint32
{
    return std::exchange(pendingZoneLine_, 0);
}

void CWorldBotController::checkZoneLineArea(bool allowCrossing)
{
    const auto area = botutils::FindBotZoneLineAt(POwner->loc.zone, POwner->loc.p);

    if (allowCrossing && zoneLineAreaKnown_ && area != 0 && area != currentZoneLineArea_ && pendingZoneLine_ == 0)
    {
        pendingZoneLine_ = area;
    }

    currentZoneLineArea_ = area;
    zoneLineAreaKnown_   = true;
}
