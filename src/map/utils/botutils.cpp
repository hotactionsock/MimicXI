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
#include "botinventory.h"
#include "botlog.h"

#include "common/database.h"
#include "common/earth_time.h"
#include "common/settings.h"
#include "common/timer.h"
#include "common/tracy.h"
#include "common/ipp.h"
#include "common/logging.h"
#include "common/macros.h"
#include "common/utils.h"
#include "common/xirand.h"

#include "ai/ai_container.h"
#include "ai/controllers/world_bot_controller.h"
#include "map_engine.h"
#include "map_networking.h"
#include "map_session.h"
#include "map_session_container.h"
#include "packet_system.h"
#include "packets/basic.h"
#include "packets/c2s/0x00a_login.h"
#include "zone.h"
#include "zone_entities.h"
#include "navmesh/navmesh.h"
#include "entities/mob_entity.h"
#include "entities/npc_entity.h"

#include "utils/charutils.h"
#include "utils/zoneutils.h"

#include <algorithm>
#include <array>
#include <limits>
#include <unordered_map>
#include <unordered_set>
#include <cmath>
#include <format>

namespace botutils
{

namespace
{

constexpr uint8 kNationCount = 3; // San d'Oria, Bastok, Windurst - see kHomeCities

// Defined with the world-map helpers further down.
auto nearestHomeCity(uint8 nation, uint16 from) -> std::pair<uint16, uint8>;
void ensureCityHomePoint(CCharEntity* PChar);

} // namespace

auto CreateBotCharacter(xi::ZoneId zoneId, float x, float y, float z, uint8 rotation, CharRace race, CharFace face, const std::string& name,
                        xi::Job job, uint8 size) -> uint32
{
    // Names are unique, as for real characters. Checked before anything is
    // written so a clash (e.g. a random name in a mass create) leaves no orphans.
    {
        const auto rset = db::preparedStmt("SELECT charid FROM chars WHERE charname = ? LIMIT 1", name);
        if (rset && rset->rowsCount() > 0)
        {
            return 0;
        }
    }

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
    // Nation = whichever nation's city is the fewest zone hops from where the
    // bot is created, so a bot made in Gustaberg calls Bastok home.
    uint8 nation     = 0;
    uint8 nationHops = std::numeric_limits<uint8>::max();
    for (uint8 n = 0; n < kNationCount; ++n)
    {
        const auto [city, hops] = nearestHomeCity(n, static_cast<uint16>(zoneId));
        if (city != 0 && hops < nationHops)
        {
            nation     = n;
            nationHops = hops;
        }
    }

    if (!db::preparedStmt("INSERT INTO chars(charid,accid,charname,pos_zone,pos_rot,pos_x,pos_y,pos_z,nation) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)",
                          charId, accId, name, static_cast<uint16>(zoneId), rotation, x, y, z, nation))
    {
        ShowError("botutils::CreateBotCharacter: unable to create chars row");
        return 0;
    }

    if (!db::preparedStmt("INSERT INTO char_look(charid,face,race,size) VALUES(?, ?, ?, ?)",
                          charId, static_cast<uint8>(face), static_cast<uint8>(race), static_cast<uint16>(std::min<uint8>(size, 2))))
    {
        ShowError("botutils::CreateBotCharacter: unable to create char_look row");
        return 0;
    }

    if (!db::preparedStmt("INSERT INTO char_stats(charid,mjob) VALUES(?, ?)", charId, static_cast<uint8>(job)))
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

    if (!db::preparedStmt("INSERT INTO world_bots(charid,active,anchor_x,anchor_y,anchor_z) VALUES(?, 0, ?, ?, ?)", charId, x, y, z))
    {
        ShowError("botutils::CreateBotCharacter: unable to create world_bots row");
        return 0;
    }

    {
        static const std::array<const char*, 3> nations = { "San d'Oria", "Bastok", "Windurst" };

        auto*      PZone    = zoneutils::GetZone(zoneId);
        const auto zoneName = PZone ? HumanName(PZone->getName()) : std::to_string(static_cast<uint16>(zoneId));
        LogBotEvent(charId, BotLogLevel::Milestone, "lifecycle", "created",
                    std::format("{} began their adventure in {} as a {} of {}", name, zoneName, JobFullName(static_cast<uint8>(job)),
                                nations.at(std::min<uint8>(nation, 2))),
                    std::format(R"({{"zone_id":{},"zone":"{}","job":{},"nation":{},"race":{}}})", static_cast<uint16>(zoneId), JsonEscape(zoneName),
                                static_cast<uint8>(job), nation, static_cast<uint8>(race)));
    }

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
    if (!IsBotCharacter(charId))
    {
        ShowError("botutils::EditBotCharacter: charid %u is not a registered world bot", charId);
        return false;
    }

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

namespace
{

// The engine loads a character's look (char_look) separately from its gear and
// never reconciles the two - harmless for real players, whose race can't change,
// but a bot edited to another race keeps the old race's gear models on show
// while LoadEquip (correctly) refuses to put that gear on. Rebuild the visible
// equipment slots from what's actually equipped, before the bot is spawned to
// anyone. Empty slots covered by another item (e.g. a robe hiding the head) are
// left alone - that item owns their look.
void reconcileLook(CCharEntity* PChar)
{
    uint16 covered = 0;
    for (uint8 slot = SLOT_HEAD; slot <= SLOT_FEET; ++slot)
    {
        if (auto* PItem = PChar->getEquip(static_cast<SLOTTYPE>(slot)))
        {
            const auto lookMask = PItem->getRemoveSlotLookId();
            covered |= lookMask > 0 ? lookMask : PItem->getRemoveSlotId();
        }
    }

    const auto lookFor = [&](SLOTTYPE slot, uint16 current) -> uint16
    {
        if (auto* PItem = PChar->getEquip(slot))
        {
            return PItem->getModelId();
        }

        return (covered & (1 << slot)) ? current : 0;
    };

    look_t look = PChar->look;

    look.head   = lookFor(SLOT_HEAD, look.head);
    look.body   = lookFor(SLOT_BODY, look.body);
    look.hands  = lookFor(SLOT_HANDS, look.hands);
    look.legs   = lookFor(SLOT_LEGS, look.legs);
    look.feet   = lookFor(SLOT_FEET, look.feet);
    look.main   = lookFor(SLOT_MAIN, look.main);
    look.sub    = lookFor(SLOT_SUB, look.sub);
    look.ranged = lookFor(SLOT_RANGED, look.ranged);

    if (look.head != PChar->look.head || look.body != PChar->look.body || look.hands != PChar->look.hands ||
        look.legs != PChar->look.legs || look.feet != PChar->look.feet || look.main != PChar->look.main ||
        look.sub != PChar->look.sub || look.ranged != PChar->look.ranged)
    {
        PChar->look = look;
        PChar->setPersist(CharPersist::Look);
    }
}

} // namespace

auto SpawnBotCharacter(uint32 charId) -> CCharEntity*
{
    if (g_PMapEngine == nullptr)
    {
        ShowError("botutils::SpawnBotCharacter: no live MapEngine");
        return nullptr;
    }

    // Only ever drive characters registered as bots - never a real player's
    // (offline) character.
    if (!IsBotCharacter(charId))
    {
        ShowError("botutils::SpawnBotCharacter: charid %u is not a registered world bot", charId);
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

    reconcileLook(PChar.get());

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

    // After the login handler ran (a first login's charCreate sets the home
    // point wherever the character stands - for a bot, out in the field).
    ensureCityHomePoint(PBotChar);

    db::preparedStmt("UPDATE world_bots SET active = 1 WHERE charid = ?", charId);
    LogBotEvent(charId, BotLogLevel::Detail, "lifecycle", "spawned", std::format("{} logged in", PBotChar->getName()));

    return PBotChar;
}

namespace
{

// Tears down a bot's live session (if any), mirroring a normal logout -
// shuttingDown == 1 tells destroySession to clear the accounts_sessions row (see
// MapSessionContainer::destroySession). Tolerates a null loc.zone, which is the
// state a bot stuck mid zone-transition is left in. Does not touch world_bots.
void destroyBotSession(uint32 charId)
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

    session->shuttingDown = 1;
    sessions.destroySession(session);
    ForgetBotActivity(charId);
    ForgetBotGear(charId);
}

} // namespace

void DespawnBotCharacter(uint32 charId)
{
    destroyBotSession(charId);
    db::preparedStmt("UPDATE world_bots SET active = 0 WHERE charid = ?", charId);
}

auto DeleteBotCharacter(uint32 charId) -> bool
{
    if (!IsBotCharacter(charId))
    {
        return false;
    }

    // The log outlives the bot: it's its history.
    {
        const auto rset = db::preparedStmt("SELECT charname FROM chars WHERE charid = ?", charId);
        FOR_DB_SINGLE_RESULT(rset)
        {
            LogBotEvent(charId, BotLogLevel::Milestone, "lifecycle", "retired", std::format("{} retired", rset->get<std::string>("charname")));
        }
    }

    destroyBotSession(charId);

    uint32 accId = 0;
    {
        const auto rset = db::preparedStmt("SELECT accid FROM chars WHERE charid = ?", charId);
        FOR_DB_SINGLE_RESULT(rset)
        {
            accId = rset->get<uint32>("accid");
        }
    }

    // Deleting the account cascades to `chars` and on to every char_* table via
    // the account_delete/char_delete triggers - except char_flags, which the
    // char_delete trigger doesn't cover, so it's cleared by hand. The account
    // delete must not reference `chars` itself (MariaDB refuses a statement whose
    // trigger modifies a table the statement already uses), hence the separate
    // accid lookup. Only ever deletes a throwaway BOT_ account.
    if (accId != 0)
    {
        const auto rset = db::preparedStmt("DELETE FROM accounts WHERE id = ? AND login LIKE 'BOT\\_%'", accId);
        if (!rset)
        {
            ShowError("botutils::DeleteBotCharacter: unable to delete account %u for charid %u", accId, charId);
            return false;
        }
    }

    db::preparedStmt("DELETE FROM char_flags WHERE charid = ?", charId);
    db::preparedStmt("DELETE FROM world_bots WHERE charid = ?", charId);

    return true;
}

auto IsBotCharacter(uint32 charId) -> bool
{
    const auto rset = db::preparedStmt("SELECT charid FROM world_bots WHERE charid = ?", charId);
    return rset && rset->rowsCount() > 0;
}

auto IsBotEntity(const CCharEntity* PChar) -> bool
{
    return PChar != nullptr && PChar->PSession != nullptr && PChar->PSession->isBotSession;
}

auto GetBotList() -> std::vector<BotRecord>
{
    std::vector<BotRecord> result;

    const auto rset = db::preparedStmt("SELECT w.charid, w.active, c.charname, c.pos_zone FROM world_bots w "
                                       "JOIN chars c ON c.charid = w.charid ORDER BY w.charid");
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        BotRecord record{};
        record.charId  = rset->get<uint32>("charid");
        record.active  = rset->get<uint8>("active") != 0;
        record.name    = rset->get<std::string>("charname");
        record.zoneId  = rset->get<uint16>("pos_zone");
        record.spawned = g_PMapEngine != nullptr && g_PMapEngine->networking().sessions().getSessionByCharId(record.charId) != nullptr;
        result.push_back(std::move(record));
    }

    return result;
}

auto GetBotAnchor(uint32 charId) -> std::optional<position_t>
{
    const auto rset = db::preparedStmt("SELECT anchor_x, anchor_y, anchor_z FROM world_bots WHERE charid = ?", charId);
    FOR_DB_SINGLE_RESULT(rset)
    {
        position_t anchor{};
        anchor.x = rset->get<float>("anchor_x");
        anchor.y = rset->get<float>("anchor_y");
        anchor.z = rset->get<float>("anchor_z");
        return anchor;
    }

    return std::nullopt;
}

void SetBotAnchor(uint32 charId, float x, float y, float z)
{
    db::preparedStmt("UPDATE world_bots SET anchor_x = ?, anchor_y = ?, anchor_z = ? WHERE charid = ?", x, y, z, charId);
}

void SpawnPersistentBots()
{
    // In lazy-loading/multi-process setups only spawn bots whose zone this
    // process manages; an empty list means this process manages every zone.
    std::vector<uint16> managedZones;
    for (const auto& [zoneId, name] : zoneutils::GetManagedZones())
    {
        managedZones.push_back(static_cast<uint16>(zoneId));
    }

    std::vector<uint32> toSpawn;

    const auto rset = db::preparedStmt("SELECT w.charid, c.pos_zone FROM world_bots w JOIN chars c ON c.charid = w.charid WHERE w.active = 1");
    FOR_DB_MULTIPLE_RESULTS(rset)
    {
        const auto zoneId = rset->get<uint16>("pos_zone");
        if (managedZones.empty() || std::find(managedZones.begin(), managedZones.end(), zoneId) != managedZones.end())
        {
            toSpawn.push_back(rset->get<uint32>("charid"));
        }
    }

    uint32 spawned = 0;
    for (const auto charId : toSpawn)
    {
        if (SpawnBotCharacter(charId) != nullptr)
        {
            ++spawned;
        }
    }

    if (!toSpawn.empty())
    {
        ShowInfo("botutils: respawned %u of %u active world bot(s)", spawned, static_cast<uint32>(toSpawn.size()));
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

    if (!IsBotCharacter(charId))
    {
        ShowError("botutils::TeleportBotCharacter: charid %u is not a registered world bot", charId);
        return nullptr;
    }

    destroyBotSession(charId);

    if (!db::preparedStmt("UPDATE chars SET pos_zone = ?, pos_rot = ?, pos_x = ?, pos_y = ?, pos_z = ? WHERE charid = ?",
                          static_cast<uint16>(zoneId), rotation, x, y, z, charId))
    {
        ShowError("botutils::TeleportBotCharacter: unable to update position for charid %u", charId);
        return nullptr;
    }

    SetBotAnchor(charId, x, y, z);

    return SpawnBotCharacter(charId);
}

namespace
{

constexpr float kZoneLineReachYalms     = 20.0f;
constexpr float kZoneLineMinRadius      = 2.5f;
constexpr float kZoneLineMaxRadius      = 10.0f;
constexpr float kZoneLineDefaultRadius  = 4.0f;
constexpr float kZoneLineVerticalYalms  = 6.0f;
constexpr float kReverseLineMatchYalms  = 40.0f;

auto isBotUsableZoneLine(const zoneLine_t& line) -> bool
{
    // Mog House entrances (zmr* classic cities, zms* WoTG [S] + Adoulin) - see
    // GP_CLI_COMMAND_MAPRECT. Their "destination" is the player's own Mog House.
    const auto* tag = reinterpret_cast<const char*>(&line.zoneLineId);
    if (tag[0] == 'z' && tag[1] == 'm' && (tag[2] == 'r' || tag[2] == 's'))
    {
        return false;
    }

    if (line.destinationZoneId == line.originZoneId)
    {
        return false;
    }

    // Only zones this process hosts (GetZone is null otherwise), and never into
    // instanced content.
    auto* PDestination = zoneutils::GetZone(line.destinationZoneId);
    if (PDestination == nullptr)
    {
        return false;
    }

    return (PDestination->GetTypeMask() & xi::ZoneType::Instanced) == xi::ZoneType::Unknown;
}

// See FindBotZoneLineAt: half the width of the return line's arrival box.
auto zoneLineRadius(const zoneLine_t& line) -> float
{
    auto* PDestination = zoneutils::GetZone(line.destinationZoneId);
    if (PDestination == nullptr)
    {
        return kZoneLineDefaultRadius;
    }

    const zoneLine_t* reverse     = nullptr;
    float             reverseDist = kReverseLineMatchYalms;

    for (const auto* candidate : PDestination->GetZoneLines())
    {
        if (candidate != nullptr && candidate->destinationZoneId == line.originZoneId)
        {
            const float d = distance(candidate->destinationPos, line.originPos, true);
            if (d < reverseDist)
            {
                reverse     = candidate;
                reverseDist = d;
            }
        }
    }

    if (reverse == nullptr)
    {
        return kZoneLineDefaultRadius;
    }

    return std::clamp(std::max(reverse->destinationScaleX, reverse->destinationScaleZ) * 0.5f, kZoneLineMinRadius, kZoneLineMaxRadius);
}

} // namespace

auto FindBotZoneLineAt(CZone* PZone, const position_t& pos) -> uint32
{
    if (PZone == nullptr)
    {
        return 0;
    }

    for (const auto* line : PZone->GetZoneLines())
    {
        if (line == nullptr || std::abs(pos.y - line->originPos.y) > kZoneLineVerticalYalms)
        {
            continue;
        }

        if (distance(pos, line->originPos, true) <= zoneLineRadius(*line) && isBotUsableZoneLine(*line))
        {
            return line->zoneLineId;
        }
    }

    return 0;
}

void TickBotSenses(CZone* PZone)
{
    if (PZone == nullptr)
    {
        return;
    }

    const auto now = timer::now();

    // Collect first: SpawnMOBs can engage mobs, which shouldn't happen mid-iteration.
    std::vector<CCharEntity*> due;

    // clang-format off
    PZone->GetZoneEntities()->ForEachChar([&](CCharEntity* PChar)
    {
        if (!IsBotEntity(PChar) || PChar->isDead() || PChar->PAI == nullptr)
        {
            return;
        }

        if (auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController()); controller && controller->SenseDue(now))
        {
            due.push_back(PChar);
        }
    });
    // clang-format on

    for (auto* PChar : due)
    {
        PZone->SpawnMOBs(PChar);
    }
}

void ProcessPendingZoneLines(CZone* PZone)
{
    if (PZone == nullptr)
    {
        return;
    }

    // Collect first: crossing removes the bot from this zone's char list.
    std::vector<std::pair<uint32, uint32>> crossings;

    // clang-format off
    PZone->GetZoneEntities()->ForEachChar([&](CCharEntity* PChar)
    {
        if (!IsBotEntity(PChar) || PChar->PAI == nullptr)
        {
            return;
        }

        if (auto* controller = dynamic_cast<CWorldBotController*>(PChar->PAI->GetController()))
        {
            if (const auto lineId = controller->TakePendingZoneLine(); lineId != 0)
            {
                crossings.emplace_back(PChar->id, lineId);
            }
        }
    });
    // clang-format on

    for (const auto& [charId, lineId] : crossings)
    {
        ZoneBotThroughLine(charId, lineId);
    }
}

auto GetBotZoneLines(xi::ZoneId zoneId) -> std::vector<BotZoneLine>
{
    std::vector<BotZoneLine> result;

    auto* PZone = zoneutils::GetZone(zoneId);
    if (PZone == nullptr)
    {
        return result;
    }

    for (const auto* line : PZone->GetZoneLines())
    {
        if (line != nullptr && isBotUsableZoneLine(*line))
        {
            result.push_back({ line->zoneLineId, static_cast<uint16>(line->destinationZoneId), line->originPos, zoneLineRadius(*line) });
        }
    }

    return result;
}

namespace
{

// ---- zone-line graph ----

struct GraphEdge
{
    uint32 lineId;
    uint16 destinationZoneId;
};

bool                                            g_graphBuilt = false;
std::unordered_map<uint16, std::vector<GraphEdge>> g_graph;

void ensureGraph()
{
    if (g_graphBuilt)
    {
        return;
    }

    // clang-format off
    zoneutils::ForEachZone([](CZone* PZone)
    {
        auto& edges = g_graph[static_cast<uint16>(PZone->GetID())];
        for (const auto& line : GetBotZoneLines(PZone->GetID()))
        {
            edges.push_back({ line.zoneLineId, line.destinationZoneId });
        }
    });
    // clang-format on

    g_graphBuilt = true;
}

struct Reach
{
    uint8  hops;
    uint32 firstLineId; // zone line out of the start zone on a shortest route (0 for the start)
};

// Breadth-first search over the zone-line graph from `from`, up to maxHops.
auto reachableZones(uint16 from, uint8 maxHops) -> std::unordered_map<uint16, Reach>
{
    ensureGraph();

    std::unordered_map<uint16, Reach> reached;
    std::vector<uint16>               frontier{ from };
    reached[from] = { 0, 0 };

    for (uint8 hops = 1; hops <= maxHops && !frontier.empty(); ++hops)
    {
        std::vector<uint16> next;
        for (const auto zoneId : frontier)
        {
            const auto it = g_graph.find(zoneId);
            if (it == g_graph.end())
            {
                continue;
            }

            for (const auto& edge : it->second)
            {
                if (reached.contains(edge.destinationZoneId))
                {
                    continue;
                }

                const uint32 firstLine           = zoneId == from ? edge.lineId : reached[zoneId].firstLineId;
                reached[edge.destinationZoneId] = { hops, firstLine };
                next.push_back(edge.destinationZoneId);
            }
        }
        frontier = std::move(next);
    }

    return reached;
}

constexpr uint8 kMaxRouteHops = 40;

// ---- huntable mobs ----

struct HuntMob
{
    uint8      minLevel;
    uint8      maxLevel;
    position_t spawnPoint;
    bool       aggressive; // attacks on sight/sound - a danger to bots it outclasses
};

// A camp is judged by what lives within this many yalms of it.
constexpr float kCampRadius = 30.0f;
constexpr float kCampNearScale = 120.0f; // a camp this far away counts for half as much as one right here

bool                                             g_huntBuilt = false;
std::unordered_map<uint16, std::vector<HuntMob>> g_hunt;

void ensureHuntData()
{
    if (g_huntBuilt)
    {
        return;
    }

    // clang-format off
    zoneutils::ForEachZone([](CZone* PZone)
    {
        if ((PZone->GetTypeMask() & xi::ZoneType::Instanced) != xi::ZoneType::Unknown)
        {
            return;
        }

        auto& mobs = g_hunt[static_cast<uint16>(PZone->GetID())];
        PZone->GetZoneEntities()->ForEachMob([&](CMobEntity* PMob)
        {
            if (PMob->m_Type != xi::MobType::Normal || PMob->m_SpawnType != xi::SpawnType::Normal ||
                PMob->m_RespawnTime <= timer::duration::zero() || PMob->PMaster != nullptr || PMob->m_minLevel == 0)
            {
                return;
            }

            mobs.push_back({ PMob->m_minLevel, std::max(PMob->m_minLevel, PMob->m_maxLevel), PMob->m_SpawnPoint, PMob->m_Aggro });
        });
    });
    // clang-format on

    g_huntBuilt = true;
}

// A mob suits a bot if any level it can spawn at is prey for the bot.
auto suitsLevel(const HuntMob& mob, uint8 level, uint8 partySize) -> bool
{
    for (int mobLevel = mob.minLevel; mobLevel <= mob.maxLevel; ++mobLevel)
    {
        if (IsBotPrey(level, mobLevel, partySize))
        {
            return true;
        }
    }

    return false;
}

// The con range a bot (or party of partySize) hunts: see IsBotPrey.
auto preyBand(uint8 partySize) -> std::pair<EMobDifficulty, EMobDifficulty>
{
    if (partySize >= 5)
    {
        return { EMobDifficulty::EvenMatch, EMobDifficulty::VeryTough };
    }

    if (partySize >= 3)
    {
        return { EMobDifficulty::DecentChallenge, EMobDifficulty::Tough };
    }

    return { EMobDifficulty::EasyPrey, EMobDifficulty::EvenMatch };
}

// A mob that would attack the bot unprovoked and outclasses what it can fight:
// an aggressive mob tougher than its prey band even at its lowest level.
auto threatens(const HuntMob& mob, uint8 level, uint8 partySize) -> bool
{
    return mob.aggressive && charutils::CheckMobLevel(level, mob.minLevel) > preyBand(partySize).second;
}

// ---- home cities ----

const std::vector<std::vector<xi::ZoneId>> kHomeCities = {
    { xi::ZoneId::SouthernSanDoria, xi::ZoneId::NorthernSanDoria, xi::ZoneId::PortSanDoria },
    { xi::ZoneId::BastokMines, xi::ZoneId::BastokMarkets, xi::ZoneId::PortBastok },
    { xi::ZoneId::WindurstWaters, xi::ZoneId::WindurstWalls, xi::ZoneId::PortWindurst, xi::ZoneId::WindurstWoods },
};

// Hops from `from` to the nearest city of `nation`, plus that city (0 = none).
auto nearestHomeCity(uint8 nation, uint16 from) -> std::pair<uint16, uint8>
{
    if (nation >= kHomeCities.size())
    {
        return { 0, 0 };
    }

    const auto reached = reachableZones(from, kMaxRouteHops);

    uint16 best     = 0;
    uint8  bestHops = std::numeric_limits<uint8>::max();
    for (const auto zoneId : kHomeCities[nation])
    {
        const auto it = reached.find(static_cast<uint16>(zoneId));
        if (it != reached.end() && it->second.hops < bestHops)
        {
            best     = static_cast<uint16>(zoneId);
            bestHops = it->second.hops;
        }
    }

    return { best, bestHops };
}

} // namespace

auto IsBotPrey(uint8 botLevel, int32 mobLevel, uint8 partySize) -> bool
{
    const auto [lowest, highest] = preyBand(partySize);
    const auto con               = charutils::CheckMobLevel(botLevel, mobLevel);
    return con >= lowest && con <= highest;
}

auto GetBotRouteNextLine(xi::ZoneId fromZone, xi::ZoneId toZone) -> std::optional<BotRouteHop>
{
    const auto from = static_cast<uint16>(fromZone);
    const auto to   = static_cast<uint16>(toZone);
    if (from == to)
    {
        return std::nullopt;
    }

    const auto reached = reachableZones(from, kMaxRouteHops);
    const auto it      = reached.find(to);
    if (it == reached.end())
    {
        return std::nullopt;
    }

    for (const auto& line : GetBotZoneLines(fromZone))
    {
        if (line.zoneLineId == it->second.firstLineId)
        {
            return BotRouteHop{ line, it->second.hops };
        }
    }

    return std::nullopt;
}

auto GetBotLevelingZones(uint8 level, xi::ZoneId fromZone, uint8 maxHops, uint8 partySize) -> std::vector<BotLevelingZone>
{
    ensureHuntData();

    std::vector<BotLevelingZone> result;
    for (const auto& [zoneId, reach] : reachableZones(static_cast<uint16>(fromZone), maxHops))
    {
        const auto it = g_hunt.find(zoneId);
        if (it == g_hunt.end())
        {
            continue;
        }

        uint32 suitable  = 0;
        uint32 dangerous = 0;
        for (const auto& mob : it->second)
        {
            if (suitsLevel(mob, level, partySize))
            {
                ++suitable;
            }
            else if (threatens(mob, level, partySize))
            {
                ++dangerous;
            }
        }

        if (suitable > 0)
        {
            result.push_back({ zoneId, suitable, reach.hops, dangerous });
        }
    }

    // More prey, fewer hops - and a zone crawling with aggressive mobs that
    // outclass the bot counts for much less, however much prey it has.
    const auto score = [](const BotLevelingZone& z)
    {
        const float safety = static_cast<float>(z.suitable) / static_cast<float>(z.suitable + 2 * z.dangerous);
        return static_cast<float>(z.suitable) / (1 + z.hops) * safety;
    };

    std::sort(result.begin(), result.end(),
              [&](const BotLevelingZone& a, const BotLevelingZone& b)
              {
                  return score(a) > score(b);
              });

    if (result.size() > 8)
    {
        // Always keep the bot's own zone: "is here good enough?" needs it.
        const auto here = std::find_if(result.begin(), result.end(),
                                       [fromZone](const BotLevelingZone& z)
                                       {
                                           return z.zoneId == static_cast<uint16>(fromZone);
                                       });
        const auto keep = here != result.end() && std::distance(result.begin(), here) >= 8 ? std::optional<BotLevelingZone>(*here) : std::nullopt;

        result.resize(8);
        if (keep)
        {
            result.push_back(*keep);
        }
    }

    return result;
}

auto GetBotReachableZones(xi::ZoneId fromZone, uint8 maxHops) -> std::vector<std::pair<uint16, uint8>>
{
    std::vector<std::pair<uint16, uint8>> result;
    for (const auto& [zoneId, reach] : reachableZones(static_cast<uint16>(fromZone), maxHops))
    {
        result.emplace_back(zoneId, reach.hops);
    }

    return result;
}

auto GetBotHuntSpot(xi::ZoneId zoneId, uint8 level, uint8 partySize, const std::optional<position_t>& nearPos,
                    const std::optional<position_t>& avoidPos) -> std::optional<position_t>
{
    ensureHuntData();

    const auto it = g_hunt.find(static_cast<uint16>(zoneId));
    if (it == g_hunt.end())
    {
        return std::nullopt;
    }

    std::vector<const HuntMob*> suitable;
    std::vector<const HuntMob*> threats;
    for (const auto& mob : it->second)
    {
        if (suitsLevel(mob, level, partySize))
        {
            suitable.push_back(&mob);
        }
        else if (threatens(mob, level, partySize))
        {
            threats.push_back(&mob);
        }
    }

    if (suitable.empty())
    {
        return std::nullopt;
    }

    // A good camp is a safe one first - the fewest outclassing aggressive mobs
    // within kCampRadius - and then a busy one: more prey around it.
    struct Camp
    {
        const HuntMob* mob;
        uint32         threats;
        uint32         prey;
    };

    std::vector<Camp> camps;
    camps.reserve(suitable.size());
    uint32 fewestThreats = std::numeric_limits<uint32>::max();
    for (const auto* mob : suitable)
    {
        if (avoidPos && distance(mob->spawnPoint, *avoidPos, true) <= kCampRadius)
        {
            continue;
        }

        Camp camp{ mob, 0, 0 };
        for (const auto* threat : threats)
        {
            camp.threats += distance(mob->spawnPoint, threat->spawnPoint, true) <= kCampRadius ? 1 : 0;
        }

        for (const auto* other : suitable)
        {
            camp.prey += distance(mob->spawnPoint, other->spawnPoint, true) <= kCampRadius ? 1 : 0;
        }

        fewestThreats = std::min(fewestThreats, camp.threats);
        camps.push_back(camp);
    }

    if (camps.empty())
    {
        return std::nullopt;
    }

    // Weighted by prey among the safest camps, so bots spread over the good
    // camps rather than all piling into the single best one - and, given a
    // starting point, by closeness too: a decent camp nearby beats a slightly
    // busier one across the zone.
    const auto weightOf = [&](const Camp& camp) -> float
    {
        if (camp.threats != fewestThreats)
        {
            return 0.0f;
        }

        float weight = static_cast<float>(camp.prey);
        if (nearPos)
        {
            weight /= 1.0f + distance(camp.mob->spawnPoint, *nearPos, true) / kCampNearScale;
        }

        return weight * weight; // sharpen: clearly better camps win most of the time
    };

    float total = 0.0f;
    for (const auto& camp : camps)
    {
        total += weightOf(camp);
    }

    float roll = xirand::GetRandomNumber<float>(total);
    for (const auto& camp : camps)
    {
        const float weight = weightOf(camp);
        if (weight <= 0.0f)
        {
            continue;
        }

        if (roll < weight)
        {
            return camp.mob->spawnPoint;
        }

        roll -= weight;
    }

    return camps.front().mob->spawnPoint;
}

auto GetBotSocialSpots(xi::ZoneId zoneId) -> std::vector<BotSocialSpot>
{
    std::vector<BotSocialSpot> result;

    auto* PZone = zoneutils::GetZone(zoneId);
    if (PZone == nullptr)
    {
        return result;
    }

    for (const auto* line : PZone->GetZoneLines())
    {
        const auto* tag = reinterpret_cast<const char*>(&line->zoneLineId);
        if (tag[0] == 'z' && tag[1] == 'm' && (tag[2] == 'r' || tag[2] == 's'))
        {
            result.push_back({ "mog", line->originPos });
        }
    }

    // clang-format off
    PZone->GetZoneEntities()->ForEachNpc([&](CNpcEntity* PNpc)
    {
        if (PNpc->status != xi::Status::Normal)
        {
            return;
        }

        const auto& name = PNpc->getName();
        if (name.starts_with("Auction_Counter"))
        {
            result.push_back({ "ah", PNpc->loc.p });
        }
        else if (name.starts_with("HomePoint#"))
        {
            result.push_back({ "hp", PNpc->loc.p });
        }
    });
    // clang-format on

    return result;
}

auto GetBotHomePoint(uint32 charId) -> std::optional<std::pair<uint16, position_t>>
{
    if (g_PMapEngine == nullptr)
    {
        return std::nullopt;
    }

    auto* session = g_PMapEngine->networking().sessions().getSessionByCharId(charId);
    if (session == nullptr || !session->isBotSession || !session->PChar)
    {
        return std::nullopt;
    }

    const auto& home = session->PChar->profile.home_point;
    return std::make_pair(static_cast<uint16>(home.destination), home.p);
}

auto GetBotHomeZone(uint8 nation, xi::ZoneId fromZone) -> uint16
{
    return nearestHomeCity(nation, static_cast<uint16>(fromZone)).first;
}

namespace
{

// A home point belongs in a city. charCreate's first-login setHomePoint puts it
// wherever the character stands - fine for a real player (they start in town),
// but a bot created in the field would "home point" straight back to its hunt
// area. If the home point isn't in a city, set it to a random Home Point
// crystal in the bot's starting city (its nation's city nearest where it is).
// After that it only changes when the bot itself picks a more convenient
// crystal for where it levels - see xi.worldbots.
void ensureCityHomePoint(CCharEntity* PChar)
{
    const auto home = PChar->profile.home_point.destination;
    for (const auto& cities : kHomeCities)
    {
        if (std::find(cities.begin(), cities.end(), home) != cities.end())
        {
            return;
        }
    }

    const auto current = static_cast<uint16>(PChar->getZone());
    const auto city    = nearestHomeCity(PChar->profile.nation, current).first;
    if (city == 0)
    {
        return;
    }

    std::vector<position_t> crystals;
    for (const auto& spot : GetBotSocialSpots(static_cast<xi::ZoneId>(city)))
    {
        if (spot.kind == "hp")
        {
            crystals.push_back(spot.pos);
        }
    }

    if (crystals.empty())
    {
        return;
    }

    // Any crystal in its starting city - it only moves later if the bot picks a
    // more convenient one for where it wants to level (xi.worldbots).
    position_t crystal = crystals[xirand::GetRandomNumber<std::size_t>(crystals.size())];

    // Stand beside the crystal rather than inside it.
    if (auto* PCity = zoneutils::GetZone(static_cast<xi::ZoneId>(city)); PCity && PCity->navMesh())
    {
        if (const auto standable = PCity->navMesh()->findRandomPosition(crystal, 3.0f))
        {
            crystal = *standable;
        }
    }

    PChar->profile.home_point.destination = static_cast<xi::ZoneId>(city);
    PChar->profile.home_point.p           = crystal;

    // Same write as the setHomePoint binding.
    db::preparedStmt("UPDATE chars SET home_zone = ?, home_rot = ?, home_x = ?, home_y = ?, home_z = ? WHERE charid = ? LIMIT 1",
                     city, crystal.rotation, crystal.x, crystal.y, crystal.z, PChar->id);
}

} // namespace

auto ZoneBotThroughLine(uint32 charId, uint32 zoneLineId) -> CCharEntity*
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

    auto* PChar = session->PChar.get();
    auto* line  = PChar->loc.zone->GetZoneLine(zoneLineId);
    if (line == nullptr || !isBotUsableZoneLine(*line))
    {
        ShowWarning("botutils::ZoneBotThroughLine: zone line %u is not usable by bots in zone %u", zoneLineId, PChar->getZone());
        return nullptr;
    }

    if (distance(PChar->loc.p, line->originPos, true) > kZoneLineReachYalms)
    {
        ShowWarning("botutils::ZoneBotThroughLine: %s too far from zone line %u (%.1fy)", PChar->getName(), zoneLineId,
                    distance(PChar->loc.p, line->originPos, true));
        return nullptr;
    }

    // Copy what's needed before the teleport destroys PChar.
    const auto destinationZoneId = line->destinationZoneId;
    const auto arrival           = line->nextSpawnPosition();

    return TeleportBotCharacter(charId, destinationZoneId, arrival.x, arrival.y, arrival.z, arrival.rotation);
}

// ---- Zone wakefulness -------------------------------------------------------

namespace
{

// How the budget weighs each bot (see UpdateBotAwakeZones).
constexpr auto  kStallAfter         = 10min; // an Active bot with no movement or EXP for this long is "stalled"
constexpr float kStalledWeight      = 0.25f; // ...and counts for this much instead of 1
constexpr auto  kMinHold            = 2min;  // once held, a zone keeps its slot at least this long (no thrashing)
constexpr float kWaitingPerMinute   = 0.5f;  // a zone kept waiting for a slot gains this much priority per minute
constexpr float kProgressMoveYalms  = 1.0f;  // movement that counts as progress between two updates

struct BotActivityState
{
    BotActivity       activity{ BotActivity::Unknown };
    uint32            wakeAt{ 0 };
    timer::time_point lastProgress{ timer::now() };
    position_t        lastPos{};
    bool              hasLastPos{ false };
};

std::unordered_map<uint32, BotActivityState>      g_botActivity;
std::unordered_set<uint16>                        g_heldZones;
std::unordered_map<uint16, timer::time_point>     g_heldSince;
std::unordered_map<uint16, timer::time_point>     g_waitingSince;
std::vector<BotAwakeZoneInfo>                     g_awakeSnapshot;

auto activityState(uint32 charId) -> BotActivityState&
{
    return g_botActivity[charId]; // default-constructs as Unknown
}

// How much one bot wants its zone awake right now.
auto botDemand(CCharEntity* PChar, timer::time_point now, uint32 unixNow) -> float
{
    auto& state = activityState(PChar->id);

    // Movement since the last update counts as progress (walking to a camp,
    // chasing prey, travelling); EXP gain is noted separately (NoteBotProgress).
    const auto& pos = PChar->loc.p;
    if (!state.hasLastPos || distance(state.lastPos, pos) >= kProgressMoveYalms)
    {
        state.lastPos      = pos;
        state.hasLastPos   = true;
        state.lastProgress = now;
    }

    // A party invite waiting: the zone has to tick for the AI to answer it.
    if (PChar->InvitePending.UniqueNo != 0)
    {
        return 1.0f;
    }

    switch (state.activity)
    {
        case BotActivity::Unknown:
            // Nothing reported yet (just spawned, or the AI lost its state):
            // the zone has to tick for the AI to decide, so it counts in full.
            return 1.0f;

        case BotActivity::Active:
            return now - state.lastProgress < kStallAfter ? 1.0f : kStalledWeight;

        case BotActivity::Resting:
            // Asleep until its next decision is due; then it needs one tick of
            // the zone to pick a new goal (after which it reports again).
            return state.wakeAt != 0 && unixNow >= state.wakeAt ? 1.0f : 0.0f;
    }

    return 0.0f;
}

} // namespace

void SetBotActivity(uint32 charId, BotActivity activity, uint32 wakeAt)
{
    auto& state = activityState(charId);
    if (state.activity != activity)
    {
        state.lastProgress = timer::now(); // a fresh start, not an instant stall
    }

    state.activity = activity;
    state.wakeAt   = activity == BotActivity::Resting ? wakeAt : 0;
}

void NoteBotProgress(uint32 charId)
{
    const auto it = g_botActivity.find(charId);
    if (it != g_botActivity.end())
    {
        it->second.lastProgress = timer::now();
    }
}

void ForgetBotActivity(uint32 charId)
{
    g_botActivity.erase(charId);
}

auto IsZoneHeldAwakeByBots(uint16 zoneId) -> bool
{
    return g_heldZones.contains(zoneId);
}

void UpdateBotAwakeZones()
{
    TracyZoneScoped;

    const auto   now     = timer::now();
    const uint32 unixNow = earth_time::timestamp();
    const auto   budget  = settings::get<uint32>("map.WORLDBOTS_MAX_AWAKE_ZONES");

    struct Candidate
    {
        CZone* zone;
        float  demand;
        float  priority;
    };

    std::vector<Candidate>        candidates;
    std::vector<BotAwakeZoneInfo> snapshot;

    zoneutils::ForEachZone(
        [&](CZone* PZone)
        {
            if (PZone == nullptr || !PZone->GetZoneEntities()->HasBotChars())
            {
                return;
            }

            float  demand = 0.0f;
            uint32 bots   = 0;
            PZone->ForEachChar(
                [&](CCharEntity* PChar)
                {
                    if (IsBotEntity(PChar))
                    {
                        ++bots;
                        demand += botDemand(PChar, now, unixNow);
                    }
                });

            const auto zoneId  = static_cast<uint16>(PZone->GetID());
            const bool players = PZone->HasAnyRealPlayers();

            snapshot.push_back({ zoneId, demand, bots, false, players });

            // Zones with real players are awake anyway and don't use the budget.
            if (players || demand <= 0.0f)
            {
                return;
            }

            float priority = demand;

            // Keep a recently granted slot (avoids zones flickering on and off).
            if (g_heldZones.contains(zoneId) && now - g_heldSince[zoneId] < kMinHold)
            {
                priority += 1000.0f;
            }

            // Zones left waiting creep up the list, so a crowded budget rotates
            // rather than starving small camps forever.
            if (const auto it = g_waitingSince.find(zoneId); it != g_waitingSince.end())
            {
                const auto waited = std::chrono::duration_cast<std::chrono::seconds>(now - it->second).count() / 60.0f;
                priority += waited * kWaitingPerMinute;
            }

            candidates.push_back({ PZone, demand, priority });
        });

    std::sort(candidates.begin(), candidates.end(),
              [](const Candidate& a, const Candidate& b)
              {
                  return a.priority > b.priority;
              });

    std::unordered_set<uint16> held;
    for (const auto& candidate : candidates)
    {
        const auto zoneId = static_cast<uint16>(candidate.zone->GetID());
        if (budget == 0 || held.size() < budget)
        {
            held.insert(zoneId);
            g_waitingSince.erase(zoneId);
            if (!g_heldZones.contains(zoneId))
            {
                g_heldSince[zoneId] = now;
            }
        }
        else if (!g_waitingSince.contains(zoneId))
        {
            g_waitingSince[zoneId] = now;
        }
    }

    // Forget waiting/held bookkeeping for zones that no longer want a slot.
    std::erase_if(g_waitingSince,
                  [&](const auto& entry)
                  {
                      return std::none_of(candidates.begin(), candidates.end(),
                                          [&](const Candidate& c)
                                          {
                                              return static_cast<uint16>(c.zone->GetID()) == entry.first;
                                          });
                  });
    std::erase_if(g_heldSince,
                  [&](const auto& entry)
                  {
                      return !held.contains(entry.first);
                  });

    g_heldZones = std::move(held);

    // Wake newly held zones. Zones that lost their slot fall asleep on their own
    // (CZone::ZoneServer's dormancy check asks IsZoneHeldAwakeByBots).
    for (const auto& candidate : candidates)
    {
        if (g_heldZones.contains(static_cast<uint16>(candidate.zone->GetID())))
        {
            candidate.zone->WakeIfSleeping();
        }
    }

    for (auto& info : snapshot)
    {
        info.held = g_heldZones.contains(info.zoneId);
    }
    g_awakeSnapshot = std::move(snapshot);
}

auto GetBotAwakeZones() -> std::vector<BotAwakeZoneInfo>
{
    return g_awakeSnapshot;
}

} // namespace botutils
