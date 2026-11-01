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

#include "botutils.h"

#include "common/database.h"
#include "common/ipp.h"
#include "common/logging.h"
#include "common/macros.h"

#include "ai/ai_container.h"
#include "ai/controllers/world_bot_controller.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "packet_system.h"
#include "packets/basic.h"
#include "packets/c2s/0x00a_login.h"

#include "utils/charutils.h"
#include "utils/zoneutils.h"

#include <format>

namespace botutils
{

auto CreateBotCharacter(xi::ZoneId zoneId, CharRace race, CharFace face, const std::string& name) -> uint32
{
    uint32 accId = 0;

    {
        const auto rset = db::preparedStmt("SELECT max(id) FROM accounts");
        FOR_DB_SINGLE_RESULT(rset)
        {
            accId = rset->get<uint32>("max(id)") + 1;
        }
        else
        {
            ShowError("botutils::CreateBotCharacter: unable to get max accounts id");
            return 0;
        }
    }

    // No real password is ever needed - this account is never authenticated
    // through the login server, only spawned in-process by SpawnBotCharacter.
    if (!db::preparedStmt("INSERT INTO accounts (id, login, password) VALUES (?, ?, ?)",
                          accId, std::format("BOT_{}", accId), std::string(60, '*')))
    {
        ShowError("botutils::CreateBotCharacter: unable to create account row");
        return 0;
    }

    uint32 charId = 0;

    {
        const auto rset = db::preparedStmt("SELECT max(charid) FROM chars");
        FOR_DB_SINGLE_RESULT(rset)
        {
            charId = rset->get<uint32>("max(charid)") + 1;
        }
        else
        {
            ShowError("botutils::CreateBotCharacter: unable to get max charid");
            return 0;
        }
    }

    // Mirrors loginHelpers::saveCharacter's row set (that helper lives in the
    // login binary and isn't linked into the map server, so it's reproduced here).
    if (!db::preparedStmt("INSERT INTO chars(charid,accid,charname,pos_zone,nation) VALUES(?, ?, ?, ?, ?)",
                          charId, accId, name, static_cast<uint16>(zoneId), 0))
    {
        ShowError("botutils::CreateBotCharacter: unable to create chars row");
        return 0;
    }

    if (!db::preparedStmt("INSERT INTO char_look(charid,face,race,size) VALUES(?, ?, ?, ?)",
                          charId, static_cast<uint8>(face), static_cast<uint8>(race), static_cast<uint16>(CharSize::Small)))
    {
        ShowError("botutils::CreateBotCharacter: unable to create char_look row");
        return 0;
    }

    if (!db::preparedStmt("INSERT INTO char_stats(charid,mjob) VALUES(?, ?)", charId, static_cast<uint8>(xi::Job::WAR)))
    {
        ShowError("botutils::CreateBotCharacter: unable to create char_stats row");
        return 0;
    }

    db::preparedStmt("INSERT INTO char_exp(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charId);
    db::preparedStmt("INSERT INTO char_flags(charid) VALUES(?) ON DUPLICATE KEY UPDATE disconnecting = disconnecting", charId);
    db::preparedStmt("INSERT INTO char_jobs(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charId);
    db::preparedStmt("INSERT INTO char_points(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charId);
    db::preparedStmt("INSERT INTO char_unlocks(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charId);
    db::preparedStmt("INSERT INTO char_profile(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charId);
    db::preparedStmt("INSERT INTO char_storage(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid = charid", charId);
    // A leftover row from a previously-deleted character can still occupy this
    // charid here even though `chars` itself is free of it - clear it first,
    // same as loginHelpers::saveCharacter does.
    db::preparedStmt("DELETE FROM char_inventory WHERE charid = ?", charId);
    db::preparedStmt("INSERT INTO char_inventory(charid) VALUES(?)", charId);

    return charId;
}

auto GetBotAppearance(uint32 charId) -> std::optional<BotAppearance>
{
    const auto rset = db::preparedStmt(
        "SELECT c.charname, cl.race, cl.face FROM chars c JOIN char_look cl ON c.charid = cl.charid WHERE c.charid = ?", charId);
    FOR_DB_SINGLE_RESULT(rset)
    {
        BotAppearance appearance;
        appearance.name = rset->get<std::string>("charname");
        appearance.race = static_cast<CharRace>(rset->get<uint8>("race"));
        appearance.face = static_cast<CharFace>(rset->get<uint8>("face"));
        return appearance;
    }

    return std::nullopt;
}

auto EditBotCharacter(uint32 charId, CharRace race, CharFace face, const std::string& name) -> bool
{
    if (!db::preparedStmt("UPDATE char_look SET race = ?, face = ? WHERE charid = ?",
                          static_cast<uint8>(race), static_cast<uint8>(face), charId))
    {
        ShowError("botutils::EditBotCharacter: unable to update char_look for charid %u", charId);
        return false;
    }

    if (!db::preparedStmt("UPDATE chars SET charname = ? WHERE charid = ?", name, charId))
    {
        ShowError("botutils::EditBotCharacter: unable to update chars.charname for charid %u", charId);
        return false;
    }

    return true;
}

auto SpawnBotCharacter(uint32 charId) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        ShowError("botutils::SpawnBotCharacter: no live MapEngine");
        return nullptr;
    }

    auto& networking = g_PMapEngine->networking();

    if (networking.sessions().getSessionByCharId(charId) != nullptr)
    {
        ShowError("botutils::SpawnBotCharacter: charid %u already has a live session", charId);
        return nullptr;
    }

    uint32 accId = 0;

    {
        const auto rset = db::preparedStmt("SELECT accid FROM chars WHERE charid = ?", charId);
        FOR_DB_SINGLE_RESULT(rset)
        {
            accId = rset->get<uint32>("accid");
        }
        else
        {
            ShowError("botutils::SpawnBotCharacter: charid %u not found", charId);
            return nullptr;
        }
    }

    // A synthetic session, keyed by a fake IPP (ip = charId - never a real client
    // address) rather than a real client socket. Mirrors what the Lua test/
    // simulation harness already does in CLuaSimulation::spawnPlayer.
    const IPP fakeIpp(charId, 1);
    uint8     sessionKey[20]{};

    db::preparedStmt("DELETE FROM accounts_sessions WHERE charid = ?", charId);
    if (!db::preparedStmt("INSERT INTO accounts_sessions(accid,charid,session_key,server_addr,server_port,client_addr,version_mismatch) "
                          "VALUES(?,?,?,?,?,?,?)",
                          accId, charId, sessionKey, 0, 0, charId, 0))
    {
        ShowError("botutils::SpawnBotCharacter: unable to create accounts_sessions row for charid %u", charId);
        return nullptr;
    }

    auto* session = networking.sessions().createSession(fakeIpp);
    if (session == nullptr)
    {
        ShowError("botutils::SpawnBotCharacter: unable to create session for charid %u", charId);
        return nullptr;
    }

    session->isBotSession     = true;
    session->client_packet_id = 0;
    session->server_packet_id = 0;
    session->blowfish.status  = BLOWFISH_PENDING_ZONE;

    auto PChar = charutils::LoadChar(charId);
    if (PChar == nullptr)
    {
        ShowError("botutils::SpawnBotCharacter: LoadChar failed for charid %u", charId);
        networking.sessions().destroySession(session);
        return nullptr;
    }

    // Real login relies on the destination zone already being loaded (a real
    // client can only have gotten there by zoning through it); a bot has no such
    // guarantee, so load it explicitly first.
    zoneutils::EnsureZoneLoaded(g_PMapEngine->scheduler(), g_PMapEngine->config(), PChar->loc.destination);

    session->charID           = PChar->id;
    session->PChar            = std::move(PChar);
    session->PChar->PSession  = session;

    auto* PBotChar = session->PChar.get();

    // Synthesize the same 0x00A login packet a real client sends to begin its
    // zone-in sequence, and dispatch it through the real handler
    // (GP_CLI_COMMAND_LOGIN::process) rather than duplicating its logic here.
    CBasicPacket loginPacket;
    loginPacket.setType(static_cast<uint16>(GP_CLI_COMMAND_LOGIN::packetId));
    loginPacket.setSize(sizeof(GP_CLI_COMMAND_LOGIN));
    loginPacket.setSequence(0);
    loginPacket.as<GP_CLI_COMMAND_LOGIN>()->UniqueNo = charId;

    networking.packetSystem().dispatch(loginPacket.getType(), session, PBotChar, loginPacket);

    if (PBotChar->loc.zone == nullptr)
    {
        ShowError("botutils::SpawnBotCharacter: charid %u failed to enter its zone", charId);
        networking.sessions().destroySession(session);
        return nullptr;
    }

    // Replace the default CPlayerController (which only reacts to real client
    // packets - a bot never sends any) with one that owns a real CPathFind and
    // walks it toward wherever WalkBotTo() points it, at normal walking speed.
    PBotChar->PAI->SetController(std::make_unique<CWorldBotController>(PBotChar));

    return PBotChar;
}

void DespawnBotCharacter(uint32 charId)
{
    if (g_PMapEngine == nullptr)
    {
        return;
    }

    auto& sessions = g_PMapEngine->networking().sessions();
    auto* session  = sessions.getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession)
    {
        return;
    }

    // shuttingDown == 1 tells destroySession to clear the accounts_sessions row,
    // same as a real logout - see MapSessionContainer::destroySession.
    session->shuttingDown = 1;
    sessions.destroySession(session);
}

void KeepBotSessionAlive(uint32 charId)
{
    if (g_PMapEngine == nullptr)
    {
        return;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession)
    {
        return;
    }

    session->tapLastUpdate();

    // Nothing will ever flush this over a real socket - drain it so it can't
    // grow unbounded over a long-lived bot session.
    if (session->PChar)
    {
        session->PChar->clearPacketList();
    }
}

void WalkBotTo(uint32 charId, float x, float y, float z)
{
    if (g_PMapEngine == nullptr)
    {
        return;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar)
    {
        return;
    }

    auto* controller = dynamic_cast<CWorldBotController*>(session->PChar->PAI->GetController());
    if (controller == nullptr)
    {
        ShowError("botutils::WalkBotTo: charid %u has no CWorldBotController", charId);
        return;
    }

    position_t dest{};
    dest.x = x;
    dest.y = y;
    dest.z = z;

    controller->SetWanderTarget(dest);
}

void SaveBotPosition(uint32 charId)
{
    if (g_PMapEngine == nullptr)
    {
        return;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar)
    {
        return;
    }

    charutils::SaveCharPosition(session->PChar.get());
}

auto TeleportBotCharacter(uint32 charId, xi::ZoneId zoneId, float x, float y, float z, uint8 rotation) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        return nullptr;
    }

    auto& sessions = g_PMapEngine->networking().sessions();
    auto* session  = sessions.getSessionByCharId(charId);
    if (session != nullptr && !session->isBotSession)
    {
        ShowError("botutils::TeleportBotCharacter: charid %u is not a bot session", charId);
        return nullptr;
    }

    // Clean despawn regardless of current zone/zoning state - destroySession
    // tolerates a null loc.zone, which is exactly the state a bot stuck mid
    // zone-transition is left in (it can never complete that sequence itself).
    if (session != nullptr)
    {
        session->shuttingDown = 1;
        sessions.destroySession(session);
    }

    if (!db::preparedStmt("UPDATE chars SET pos_zone = ?, pos_rot = ?, pos_x = ?, pos_y = ?, pos_z = ? WHERE charid = ?",
                          static_cast<uint16>(zoneId), rotation, x, y, z, charId))
    {
        ShowError("botutils::TeleportBotCharacter: unable to update position for charid %u", charId);
        return nullptr;
    }

    return SpawnBotCharacter(charId);
}

} // namespace botutils
