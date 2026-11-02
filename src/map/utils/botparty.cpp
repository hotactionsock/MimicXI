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

#include "botparty.h"

#include "botutils.h"

#include "common/logging.h"

#include "ai/ai_container.h"
#include "entities/char_entity.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "party.h"
#include "zone.h"

namespace botutils
{

namespace
{

constexpr std::size_t kMaxPartySize = 6;

auto liveBot(uint32 charId) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        return nullptr;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar || session->PChar->loc.zone == nullptr)
    {
        return nullptr;
    }

    return session->PChar.get();
}

} // namespace

auto FormBotParty(uint32 leaderId, const std::vector<uint32>& memberIds) -> uint8
{
    auto* PLeader = liveBot(leaderId);
    if (PLeader == nullptr || PLeader->isDead())
    {
        return 0;
    }

    if (PLeader->PParty == nullptr)
    {
        PLeader->PParty = new CParty(PLeader);
    }
    else if (PLeader->PParty->GetLeader() != PLeader)
    {
        return 0; // only a leader brings people in, as with invites
    }

    uint8 added = 0;
    for (const auto memberId : memberIds)
    {
        auto* PMember = liveBot(memberId);
        if (PMember == nullptr || PMember == PLeader || PMember->PParty != nullptr || PMember->isDead())
        {
            continue;
        }

        if (PLeader->PParty->members.size() >= kMaxPartySize)
        {
            break;
        }

        PLeader->PParty->AddMember(PMember);
        if (PMember->PParty == PLeader->PParty)
        {
            ++added;
        }
    }

    // A party of one (everyone else was skipped) isn't a party.
    if (PLeader->PParty != nullptr && PLeader->PParty->HasOnlyOneMember())
    {
        PLeader->PParty->DisbandParty(false);
    }

    return added;
}

void LeaveBotParty(uint32 charId)
{
    auto* PChar = liveBot(charId);
    if (PChar != nullptr && PChar->PParty != nullptr)
    {
        PChar->PParty->RemoveMember(PChar);
    }
}

auto GetBotParty(uint32 charId) -> std::optional<std::vector<BotPartyMember>>
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->PParty == nullptr)
    {
        return std::nullopt;
    }

    std::vector<BotPartyMember> result;
    auto*                       PLeader = PChar->PParty->GetLeader();

    for (auto* PEntity : PChar->PParty->members)
    {
        auto* PMember = dynamic_cast<CCharEntity*>(PEntity);
        if (PMember == nullptr || PMember->loc.zone == nullptr)
        {
            continue;
        }

        auto* PTarget = PMember->GetBattleTarget();

        BotPartyMember member{};
        member.charId   = PMember->id;
        member.isBot    = IsBotEntity(PMember);
        member.isLeader = PMember == PLeader;
        member.mainJob  = static_cast<uint8>(PMember->GetMJob());
        member.subJob   = static_cast<uint8>(PMember->GetSJob());
        member.level    = PMember->GetMLevel();
        member.hpp      = PMember->GetHPP();
        member.mpp      = PMember->GetMaxMP() > 0 ? static_cast<uint8>(PMember->health.mp * 100 / PMember->GetMaxMP()) : 0;
        member.tp       = static_cast<uint16>(PMember->health.tp);
        member.zoneId   = static_cast<uint16>(PMember->getZone());
        member.pos      = PMember->loc.p;
        member.dead     = PMember->isDead();
        member.engaged  = PMember->PAI->IsEngaged();
        member.targetId = PTarget ? PTarget->id : 0;
        result.push_back(member);
    }

    return result;
}

} // namespace botutils
