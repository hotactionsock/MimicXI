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

#include "botjobs.h"

#include "botutils.h"

#include "common/database.h"
#include "common/logging.h"

#include "ai/ai_container.h"

#include "entities/char_entity.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "packet_system.h"
#include "packets/basic.h"
#include "packets/c2s/0x100_myroom_job.h"
#include "packets/s2c/0x01b_job_info.h"
#include "utils/charutils.h"

namespace botutils
{

namespace
{

constexpr float kMogHouseReachYalms = 8.0f; // how close to a Mog House entrance counts as "at home"

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

auto atMogHouse(CCharEntity* PChar) -> bool
{
    for (const auto& spot : GetBotSocialSpots(PChar->loc.zone->GetID()))
    {
        if (spot.kind == "mog" && distance(PChar->loc.p, spot.pos) <= kMogHouseReachYalms)
        {
            return true;
        }
    }

    return false;
}

} // namespace

auto GetBotJobInfo(uint32 charId) -> std::optional<BotJobInfo>
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr)
    {
        return std::nullopt;
    }

    BotJobInfo info;
    info.mainJob        = static_cast<uint8>(PChar->GetMJob());
    info.subJob         = static_cast<uint8>(PChar->GetSJob());
    info.subjobUnlocked = (PChar->jobs.unlocked & 1) != 0;

    for (uint8 job = 1; job < MAX_JOBTYPE && job < info.levels.size(); ++job)
    {
        info.levels[job]   = PChar->jobs.job[job];
        info.unlocked[job] = (PChar->jobs.unlocked & (1 << job)) != 0;
    }

    return info;
}

auto UnlockBotJob(uint32 charId, uint8 job) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || job >= MAX_JOBTYPE)
    {
        return false;
    }

    PChar->jobs.unlocked |= (1 << job);

    // Mirrors CLuaBaseEntity::unlockJob: an unlocked job starts at level 1
    // (unlocking subjobs touches WAR's row, as the original does).
    const uint8 levelJob = job == 0 ? static_cast<uint8>(xi::Job::WAR) : job;
    if (PChar->jobs.job[levelJob] == 0)
    {
        PChar->jobs.job[levelJob] = 1;
    }

    charutils::SaveCharJob(PChar, static_cast<xi::Job>(levelJob));
    PChar->pushPacket<GP_SERV_COMMAND_JOB_INFO>(PChar);
    return true;
}

auto ChangeBotJobs(uint32 charId, uint8 mainJob, uint8 subJob) -> bool
{
    auto* PChar = liveBot(charId);
    if (PChar == nullptr || PChar->isDead() || PChar->PAI->IsEngaged() || !atMogHouse(PChar))
    {
        return false;
    }

    auto* session = PChar->PSession;

    // The handler only accepts job changes in a Mog House (or a zone with a
    // moogle). A bot can't go inside, so standing at the entrance counts: it
    // is treated as in its Mog House just for this one packet.
    const auto savedMogHouse = PChar->m_moghouseID;
    PChar->m_moghouseID      = PChar->id;

    CBasicPacket packet;
    packet.setType(static_cast<uint16>(GP_CLI_COMMAND_MYROOM_JOB::packetId));
    packet.setSize(sizeof(GP_CLI_COMMAND_MYROOM_JOB));
    packet.setSequence(0);
    packet.as<GP_CLI_COMMAND_MYROOM_JOB>()->MainJobIndex    = mainJob;
    packet.as<GP_CLI_COMMAND_MYROOM_JOB>()->SupportJobIndex = subJob;

    const auto beforeMain = PChar->GetMJob();
    const auto beforeSub  = PChar->GetSJob();

    g_PMapEngine->networking().packetSystem().dispatch(packet.getType(), session, PChar, packet);

    PChar->m_moghouseID = savedMogHouse;

    return PChar->GetMJob() != beforeMain || PChar->GetSJob() != beforeSub;
}

auto GetBotCareerJob(uint32 charId) -> uint8
{
    const auto rset = db::preparedStmt("SELECT career_job FROM world_bots WHERE charid = ?", charId);
    FOR_DB_SINGLE_RESULT(rset)
    {
        return rset->get<uint8>("career_job");
    }

    return 0;
}

void SetBotCareerJob(uint32 charId, uint8 job)
{
    db::preparedStmt("UPDATE world_bots SET career_job = ? WHERE charid = ?", job, charId);
}

} // namespace botutils
