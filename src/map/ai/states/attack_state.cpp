/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

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

#include "attack_state.h"

#include "action/action.h"
#include "entities/battle_entity.h"

#include "ai/ai_container.h"
#include "enmity_container.h"
#include "entities/mob_entity.h"
#include "packets/s2c/0x028_battle2.h"
#include "packets/s2c/0x058_assist.h"
#include "utils/battleutils.h"

CAttackState::CAttackState(xi::Badge<CState>, CBattleEntity* PEntity, const EntityId& target)
: CState(PEntity, target)
, m_PEntity(PEntity)
{
    // Capture constructor arguments into members and nothing else. All other logic goes into init().
}

auto CAttackState::init() -> StateErrorOr<void>
{
    m_PEntity->setBattleTarget(target());
    m_PEntity->SetBattleStartTime(timer::now());
    CAttackState::UpdateTarget();

    if (!m_PEntity->GetBattleTarget() || m_errorMsg)
    {
        m_PEntity->setBattleTarget(std::nullopt);
        return refuseWithErrorMsg();
    }

    if (m_PEntity->PAI->PathFind)
    {
        m_PEntity->PAI->PathFind->Clear();
    }

    return Success();
}

auto CAttackState::Update(timer::time_point tick) -> bool
{
    auto* PTarget = m_PEntity->GetBattleTarget();
    if (!PTarget || PTarget->isDead())
    {
        return true;
    }

    // Subtract on every tick, including the one we swing on, or each swing costs an extra tick.
    m_attackTime -= (m_PEntity->PAI->getTick() - m_PEntity->PAI->getPrevTick());

    if (AttackReady())
    {
        if (CanAttack(PTarget))
        {
            // CanAttack may have set target id to 0 (disengage from out of range)
            if (!m_PEntity->battleTarget().isSet())
            {
                return true;
            }
            action_t action{};
            if (m_PEntity->OnAttack(*this, action))
            {
                // TODO: what about AoE auto attacks?
                battleutils::handleKillshotEnmity(m_PEntity, PTarget);

                // CMobEntity::OnAttack(...) can generate it's own action with a mobmod, and that leaves this action.actionType = 0, which is never valid. Skip sending the packet.
                if (action.actiontype != ActionCategory::None)
                {
                    m_PEntity->loc.zone->PushPacket(m_PEntity, CHAR_INRANGE_SELF, std::make_unique<GP_SERV_COMMAND_BATTLE2>(action));
                }
            }
        }
        else if (m_PEntity->OnAttackError(*this))
        {
            m_PEntity->HandleErrorMessage(m_errorMsg);
        }
        if (!m_PEntity->battleTarget().isSet())
        {
            return true;
        }
    }

    // Don't bank time while we can't swing. Sits after the swing so leftover time carries.
    m_attackTime = std::max<timer::duration>(m_attackTime, 0ms);

    return false;
}

void CAttackState::Cleanup(timer::time_point tick)
{
    if (!m_PEntity->isDead())
    {
        m_PEntity->OnDisengage(*this);
    }
}

void CAttackState::ResetAttackTimer()
{
    m_attackTime = std::chrono::milliseconds(m_PEntity->GetWeaponDelay(false));
}

void CAttackState::UpdateTarget(const EntityId& target)
{
    m_errorMsg.reset();
    auto           newTarget{ m_PEntity->battleTarget() };
    CBattleEntity* PNewTarget{ nullptr };
    if (newTarget.isSet())
    {
        PNewTarget = m_PEntity->IsValidTarget(newTarget, TARGET_ENEMY, m_errorMsg);
        if (!PNewTarget)
        {
            newTarget          = EntityId{};
            CCharEntity* PChar = dynamic_cast<CCharEntity*>(m_PEntity);
            if (PChar && PChar->hasAutoTargetEnabled())
            {
                // Retarget priority:
                //  1. any still-hostile mob that has THIS player on its hate list -
                //     don't drop combat just because the player isn't facing it.
                //  2. otherwise the vanilla behaviour: an engaged mob in front of
                //     the player and close by.
                CBattleEntity* PAggroPick  = nullptr;
                CBattleEntity* PFacingPick = nullptr;

                for (auto&& PPotentialTarget : PChar->SpawnMOBList)
                {
                    auto* PMob = dynamic_cast<CMobEntity*>(PPotentialTarget.second);
                    if (!PMob || PMob->animation != xi::Animation::Attack)
                    {
                        continue;
                    }

                    const float dist = distance(PChar->loc.p, PMob->loc.p);
                    if (dist > 25.0f)
                    {
                        continue;
                    }

                    std::unique_ptr<CBasicPacket> errMsg;
                    if (!PChar->IsValidTarget(EntityId(PMob), TARGET_ENEMY, errMsg))
                    {
                        continue;
                    }

                    if (PMob->PEnmityContainer && PMob->PEnmityContainer->HasID(PChar->id))
                    {
                        PAggroPick = PMob;
                        break;
                    }

                    if (!PFacingPick && dist <= 10.0f && facing(PChar->loc.p, PMob->loc.p, 64))
                    {
                        PFacingPick = PMob;
                    }
                }

                CBattleEntity* PRetarget = PAggroPick ? PAggroPick : PFacingPick;
                if (PRetarget)
                {
                    newTarget = EntityId(PRetarget);
                    PChar->pushPacket<GP_SERV_COMMAND_ASSIST>(PChar, PRetarget);
                }
            }
            m_PEntity->PAI->ChangeTarget(newTarget);
        }
    }
    if (target != newTarget)
    {
        if (target.isSet())
        {
            m_PEntity->OnChangeTarget(PNewTarget);
            SetTarget(newTarget);
            if (!PNewTarget)
            {
                m_errorMsg.reset();
                return;
            }
        }
    }
}

auto CAttackState::CanAttack(CBattleEntity* PTarget) -> bool
{
    const auto ret = m_PEntity->CanAttack(PTarget, m_errorMsg);

    if (ret && !m_errorMsg)
    {
        m_attackTime += std::chrono::milliseconds(m_PEntity->GetWeaponDelay(false));
    }
    return ret;
}

auto CAttackState::AttackReady() const -> bool
{
    return m_attackTime <= 0ms && m_PEntity->isAlive();
}

auto CAttackState::CanChangeState() -> bool
{
    return true;
}

auto CAttackState::CanFollowPath() -> bool
{
    return true;
}

auto CAttackState::CanInterrupt() -> bool
{
    return false;
}
