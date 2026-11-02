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

#include "botlog.h"
#include "botutils.h"

#include "common/database.h"
#include "common/settings.h"

#include "common/logging.h"

#include "ai/ai_container.h"
#include "entities/char_entity.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "packet_system.h"
#include "packets/basic.h"
#include "packets/c2s/0x074_group_solicit_res.h"
#include "party.h"
#include "status_effect.h"
#include "status_effect_container.h"
#include "utils/charutils.h"

#include <format>
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

// ---- Hired by players --------------------------------------------------------

namespace
{

auto partyHasRealPlayer(CParty* PParty) -> bool
{
    for (auto* PMember : PParty->members)
    {
        if (auto* PChar = dynamic_cast<CCharEntity*>(PMember); PChar && !IsBotEntity(PChar))
        {
            return true;
        }
    }

    return false;
}

} // namespace

void FreeBotForPlayerInvite(CCharEntity* PInvitee)
{
    if (PInvitee == nullptr || !IsBotEntity(PInvitee) || PInvitee->PParty == nullptr || partyHasRealPlayer(PInvitee->PParty))
    {
        return;
    }

    LogBotEvent(PInvitee->id, BotLogLevel::Notable, "party", "left_for_player",
                std::format("{} left their party to answer a player's invite", PInvitee->getName()));
    PInvitee->PParty->RemoveMember(PInvitee);
}

auto GetBotPendingInvite(uint32 charId) -> BotInvite
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->InvitePending.UniqueNo == 0)
    {
        return {};
    }

    BotInvite invite;
    invite.inviterId    = PChar->InvitePending.UniqueNo;
    invite.inviterIsBot = IsBotCharacter(invite.inviterId);
    return invite;
}

auto AnswerBotInvite(uint32 charId, bool accept) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->InvitePending.UniqueNo == 0)
    {
        return false;
    }

    CBasicPacket packet;
    packet.setType(static_cast<uint16>(GP_CLI_COMMAND_GROUP_SOLICIT_RES::packetId));
    packet.setSize(sizeof(GP_CLI_COMMAND_GROUP_SOLICIT_RES));
    packet.setSequence(0);
    packet.as<GP_CLI_COMMAND_GROUP_SOLICIT_RES>()->Res =
        static_cast<uint8_t>(accept ? GP_CLI_COMMAND_GROUP_SOLICIT_RES_RES::Accept : GP_CLI_COMMAND_GROUP_SOLICIT_RES_RES::Decline);

    g_PMapEngine->networking().packetSystem().dispatch(packet.getType(), PChar->PSession, PChar, packet);

    // The handler clears the invite; make sure a stale one can't block future invites.
    PChar->InvitePending.clean();
    return PChar->PParty != nullptr;
}

void SetBotLevelSync(uint32 charId, uint8 level)
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return;
    }

    // Our cap is a Level Restriction with subPower 7 (an unused marker), so a
    // restriction from content (an instance, a BCNM) is never touched.
    constexpr uint16 kBotSyncMarker = 7;

    auto* PEffect = PChar->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::LevelRestriction);
    if (PEffect != nullptr && PEffect->GetSubPower() != kBotSyncMarker)
    {
        return; // someone else's restriction is in charge
    }

    if (PEffect != nullptr && (level == 0 || PEffect->GetPower() != level))
    {
        PChar->StatusEffectContainer->DelStatusEffectSilent(xi::StatusEffect::LevelRestriction);
        PEffect = nullptr;
    }

    if (level != 0 && PEffect == nullptr)
    {
        PChar->StatusEffectContainer->AddStatusEffect(xi::StatusEffect::LevelRestriction, static_cast<uint16>(xi::StatusEffect::LevelRestriction), level,
                                                      0s, 0s, kBotSyncMarker);
    }
}

auto GetBotTrueLevel(uint32 charId) -> uint8
{
    auto* PChar = liveBot(charId);
    return PChar ? PChar->jobs.job[static_cast<uint8>(PChar->GetMJob())] : 0;
}

void SetBotSeekingParty(uint32 charId, bool seeking, const std::string& comment)
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return;
    }

    // Same changes the client's /invite toggle (GP_CLI_COMMAND_CONFIG) and
    // /seacom (GP_CLI_COMMAND_SET_USERMSG) make.
    constexpr uint8 kSeekPartyComment = 0x11; // EXP party: seeking party

    const uint8       type    = seeking ? kSeekPartyComment : 0;
    const std::string message = seeking ? comment.substr(0, 120) : std::string();

    if (PChar->playerConfig.InviteFlg != seeking)
    {
        PChar->playerConfig.InviteFlg = seeking;
        PChar->updatemask |= UPDATE_HP;
        charutils::SavePlayerSettings(PChar);
    }

    if (PChar->search.messagetype != type || PChar->search.message != message)
    {
        if (db::preparedStmt("UPDATE accounts_sessions SET seacom_type = ?, seacom_message = ? WHERE charid = ? LIMIT 1", type, message, PChar->id))
        {
            PChar->search.message     = message;
            PChar->search.messagetype = type;
        }
    }
}

} // namespace botutils
