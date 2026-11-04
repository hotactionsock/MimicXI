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

#include "common/cbasetypes.h"
#include "entities/char_entity.h"

#include <optional>
#include <utility>
#include <string>
#include <vector>

// AI-driven world-population bots: a bot is a real
// CCharEntity, on a real (throwaway) account, spawned into the world with no live
// network socket - the same shape the Lua test harness already proves works
// (TestChar/CLuaSimulation::spawnPlayer), just wired for a live, non-test server.
// See project memory `project_playerbots_ffxi` for the full design rationale.
namespace botutils
{

struct BotAppearance
{
    CharRace    race;
    CharFace    face;
    std::string name;
};

// Creates a fresh throwaway account + character to serve as a world bot, placed
// at (x,y,z,rotation) in zoneId, and registers it in `world_bots` (inactive,
// anchored at that same spot). Writes the same set of rows real character
// creation does (chars, char_look, char_stats, char_exp, char_jobs, etc.) - a
// real character, not a synthetic stat block. job is its starting main job
// (charCreate hands out that job's starting gear on first login), size the
// model size (0 small, 1 medium, 2 large). Returns the new charId, or 0 - also
// 0, with nothing written, if the name is already taken.
auto CreateBotCharacter(xi::ZoneId zoneId, float x, float y, float z, uint8 rotation, CharRace race, CharFace face, const std::string& name,
                        xi::Job job, uint8 size) -> uint32;

// Reads back a bot character's current race/face/name, or nullopt if charId
// doesn't exist. Used by the !worldbot edit command so unspecified fields can
// be left unchanged rather than re-randomized.
auto GetBotAppearance(uint32 charId) -> std::optional<BotAppearance>;

// Updates a bot character's race/face/name in the database. Does not touch a
// currently-spawned live entity - despawn before editing and spawn again
// afterward to see the change.
auto EditBotCharacter(uint32 charId, CharRace race, CharFace face, const std::string& name) -> bool;

// Spawns charId into the world as a live, AI-driven session with no network socket
// and marks it active in `world_bots` (so it is respawned on the next server
// start). Runs the character through the exact same zone-in path a real client's
// login packet would (IncreaseZoneCounter/InsertPC). Returns nullptr on failure.
auto SpawnBotCharacter(uint32 charId) -> CCharEntity*;

// Removes a bot character from the world (mirroring a normal logout, including
// clearing its accounts_sessions row) and marks it inactive in `world_bots`.
void DespawnBotCharacter(uint32 charId);

// Ends a bot's play session: saves where it stands, removes it from the world
// like a logout, and keeps it offline for offlineSec (world_bots.logged_out_until),
// after which UpdateBotLogins brings it back where it left off. It stays part
// of the population (active = 1) - just not online, so it gains nothing while
// away. where is how it left ("in their Mog House", "in the field") for the log.
void LogOffBot(uint32 charId, uint32 offlineSec, const std::string& where);

// Logs bots back in (map engine timer). With map.WORLDBOTS_POPULATION set,
// it keeps that many bots online: rested bots (time away over) log in,
// longest-away first, only to fill gaps below the target. With it at 0,
// every bot logs back in as soon as its time away is up. With a gap and no
// rested bot, one away an hour or more comes back early.
void UpdateBotLogins();

// The online population (map.WORLDBOTS_POPULATION): may this bot end its play
// session now? Yes if there's no target; if, once it and every bot already on
// its way out have gone, bots waiting offline can refill the target (rested,
// or away an hour or more and willing to come back early); or if the online
// count stays within a 5% dip of the target anyway. A yes holds its place in the queue
// out (renewed by asking again) until it logs off, so a crowd of session ends
// can't all leave at once. Asking again while already leaving is always yes.
auto ReserveBotLogOff(uint32 charId) -> bool;

struct BotPopulation
{
    uint32 target;  // map.WORLDBOTS_POPULATION (0 = none)
    uint32 online;  // active bots logged on
    uint32 leaving; // ...of those, on their way out (ReserveBotLogOff)
    uint32 standby; // offline and rested - ready to log in when needed
    uint32 resting; // offline, time away not yet up
    uint32 early;   // ...of those, away long enough to come back early if needed
    uint32 floor;   // log-offs never take the online count below this
};

// For !worldbot population.
auto GetBotPopulation() -> BotPopulation;

// Despawns (if needed) and permanently deletes a bot character, its throwaway
// account and its `world_bots` row. Returns false if charId isn't a bot.
auto DeleteBotCharacter(uint32 charId) -> bool;

// True if charId is registered in `world_bots` (spawned or not).
auto IsBotCharacter(uint32 charId) -> bool;

// The zone targid of an entity from its full id. Static entities (zone mobs,
// NPCs) have id = 0x01000000 | zone << 12 | targid; dynamic ones (FATE mobs and
// other insertDynamicEntity spawns, targid 0x700-0x8FF) are offset by 0x100 -
// see CZoneEntities::AssignDynamicTargIDandLongID. `id & 0xFFF` alone is wrong
// for those. Callers still check the found entity's id matches.
inline auto EntityTargId(uint32 id) -> uint16
{
    const auto low = static_cast<uint16>(id & 0xFFF);
    return (low >= 0x800 && low <= 0x9FF) ? static_cast<uint16>(low - 0x100) : low;
}

// True if PChar is a live bot session (cheap - no database access).
auto IsBotEntity(const CCharEntity* PChar) -> bool;

struct BotRecord
{
    uint32      charId;
    std::string name;
    bool        active;
    bool        spawned;
    uint16      zoneId;
};

// All registered bots, for the !worldbot list command.
auto GetBotList() -> std::vector<BotRecord>;

// The centre of a bot's loiter area, or nullopt if charId isn't a bot.
auto GetBotAnchor(uint32 charId) -> std::optional<position_t>;
void SetBotAnchor(uint32 charId, float x, float y, float z);

// Spawns every `world_bots` row marked active whose zone this map process
// manages. Called once at map server startup - bot sessions never survive a
// restart (startup clears this process's accounts_sessions rows).
void SpawnPersistentBots();

// Directs a spawned bot to walk toward (x,y,z) via the zone's navmesh, at its
// normal walking speed - not a teleport. Safe to call again mid-walk to
// redirect. No-op if charId isn't a live bot (see CWorldBotController).
void WalkBotTo(uint32 charId, float x, float y, float z);

// Writes a live bot's current position back to `chars` (pos_rot/x/y/z), same as
// a real player's periodic position save - so a server restart respawns it near
// where it left off. No-op if charId isn't a live bot.
void SaveBotPosition(uint32 charId);

// A zone line a bot can use: walk to `origin` (the centre of the zone-line box in
// the bot's current zone), then ZoneBotThroughLine to cross it.
struct BotZoneLine
{
    uint32     zoneLineId;
    uint16     destinationZoneId;
    position_t origin;
    float      radius; // approximate trigger-area radius around origin (see FindBotZoneLineAt)
};

// Zone lines in zoneId that bots may use. Excludes Mog House lines, lines back
// into the same zone, instanced destinations, and destinations this map process
// doesn't host (bots can't hand off across map processes).
auto GetBotZoneLines(xi::ZoneId zoneId) -> std::vector<BotZoneLine>;

// The usable zone line whose trigger area contains pos, or 0. Trigger boxes
// aren't stored server-side, only their centre; the box width is estimated from
// the return line's arrival box (which sits just in front of this trigger box
// at about the same width). Cheap - zones have only a handful of lines.
auto FindBotZoneLineAt(CZone* PZone, const position_t& pos) -> uint32;

// Refreshes each bot's nearby-mob list via CZone::SpawnMOBs, about once a
// second - what a real client's position packets (GP_CLI_COMMAND_POS) trigger.
// That refresh is where mob aggro is checked (CZoneEntities::tapMobAggro), so
// without it aggressive mobs would never notice bots. Called from the zone tick.
void TickBotSenses(CZone* PZone);

// Moves every bot in PZone that walked into a zone line (see
// CWorldBotController::TakePendingZoneLine) across it. Called at the start of
// the zone tick, outside any entity's own tick.
void ProcessPendingZoneLines(CZone* PZone);

// ---- World map / goals ----------------------------------------------------
// The zone-line graph (zones connected by bot-usable zone lines) is built once,
// lazily, from the loaded zones. So is a per-zone list of "huntable" mobs:
// normal (non-NM, non-battlefield), normally-spawning, respawning mobs, with
// their level range and spawn point - read from the engine's loaded mob lists
// (the source of truth since mobs moved to data/zones/*/mobs.yaml).

// What a bot hunts, by the engine's own /check (charutils::CheckMobLevel) - the
// same verdict a player sees - and the size of its group:
//   solo or a pair:  Easy Prey .. Even Match
//   3-4 members:     Decent Challenge .. Tough
//   5-6 members:     Even Match .. Very Tough
auto IsBotPrey(uint8 botLevel, int32 mobLevel, uint8 partySize = 1) -> bool;

struct BotRouteHop
{
    BotZoneLine line; // the zone line to take out of the current zone
    uint8       hops; // total zone hops to the destination, including this one
};

// Next zone line to take from fromZone toward toZone, or nullopt if toZone is
// unreachable over bot-usable zone lines (or is fromZone itself).
auto GetBotRouteNextLine(xi::ZoneId fromZone, xi::ZoneId toZone) -> std::optional<BotRouteHop>;

struct BotLevelingZone
{
    uint16 zoneId;
    uint32 suitable; // huntable mob spawns whose level range suits the bot
    uint8  hops;      // zone hops from the bot's current zone (0 = here)
    uint32 dangerous; // aggressive mob spawns that outclass the bot (or its party)
    float  value;     // suitable spawns weighted by the EXP they're worth (BotPreyValue): Easy Prey counts
                      // for a third of an Even Match, so a zone the bot has outgrown loses its appeal
};

// What a mob of this con is worth to train on, relative to an Even Match (1):
// roughly the EXP it gives. Too Weak 0 .. Incredibly Tough 1.3.
auto BotPreyValue(uint8 botLevel, int32 mobLevel) -> float;

// Zones within maxHops of fromZone that have huntable mobs suiting `level`,
// best first (more EXP-weighted prey, fewer hops, fewer dangerous aggressive
// mobs). At most 8.
// partySize widens what counts as prey (see IsBotPrey).
auto GetBotLevelingZones(uint8 level, xi::ZoneId fromZone, uint8 maxHops, uint8 partySize = 1) -> std::vector<BotLevelingZone>;

// Zones reachable from fromZone within maxHops over bot-usable zone lines
// (fromZone itself at 0 hops): { zoneId, hops }.
auto GetBotReachableZones(xi::ZoneId fromZone, uint8 maxHops) -> std::vector<std::pair<uint16, uint8>>;

// A suitable mob spawn point in zoneId for `level` to camp at, or nullopt:
// among the safest camps (fewest outclassing aggressive mobs nearby), picked
// at random weighted by how much prey is around it.
// nearPos (optional): prefer camps close to this point - the path of least
// resistance - and avoidPos: skip camps within 30 yalms of this point (the
// camp being left because it ran dry).
auto GetBotHuntSpot(xi::ZoneId zoneId, uint8 level, uint8 partySize = 1, const std::optional<position_t>& nearPos = std::nullopt,
                    const std::optional<position_t>& avoidPos = std::nullopt) -> std::optional<position_t>;

// A live bot's current home point: (zone, position), or nullopt.
auto GetBotHomePoint(uint32 charId) -> std::optional<std::pair<uint16, position_t>>;

// The nearest (by zone hops) city zone of `nation` (0 San d'Oria, 1 Bastok,
// 2 Windurst) from fromZone, or 0 if none is reachable.
auto GetBotHomeZone(uint8 nation, xi::ZoneId fromZone) -> uint16;

// Social spots in a zone where bots like to hang around, mostly in cities:
//   "mog"  - Mog House entrances (the zmr*/zms* zone-line centres)
//   "ah"   - Auction Counter NPCs
//   "hp"   - Home Point NPCs (only ones currently shown - some are content-gated)
// Empty for zones without any.
struct BotSocialSpot
{
    std::string kind;
    position_t  pos;
};

auto GetBotSocialSpots(xi::ZoneId zoneId) -> std::vector<BotSocialSpot>;

// Moves a bot through zone line zoneLineId of its current zone, arriving where a
// real player crossing that line would (zoneLine_t::nextSpawnPosition), and
// re-anchors it there. The bot must be within reach of the line's origin - the
// same kind of proximity check the real client handler (0x05E) applies. Returns
// the bot's new entity, or nullptr if it isn't a live bot, the line isn't usable,
// or it's too far away.
auto ZoneBotThroughLine(uint32 charId, uint32 zoneLineId) -> CCharEntity*;

// Instantly and safely relocates a bot to (x,y,z,rotation) in zoneId, even
// across zones or out of a stuck mid-zone-transition state (a bot has no
// client to complete that sequence on its own, unlike a real player), and
// re-anchors its loiter area there. Does a clean despawn (tolerant of a
// broken/limbo zone state) + a direct position/zone update in the database +
// a fresh spawn. Returns nullptr if charId isn't a bot or the move failed.
auto TeleportBotCharacter(uint32 charId, xi::ZoneId zoneId, float x, float y, float z, uint8 rotation) -> CCharEntity*;

// ---- Zone wakefulness (Phase 2b) -------------------------------------------
// A zone with no real players normally goes dormant (CZone::HasAnyRealPlayers).
// Bots that are busy levelling must keep progressing with nobody online, so
// the zones they're in are held awake - up to a budget, chosen by activity.
// Cities and other zones holding only idle bots still sleep.
//
// The Lua AI (xi.worldbots) reports each bot's activity when it changes:
//   Active  - levelling, or on a trip/errand that serves it (travelling, selling,
//             walking back from a home point): holds its zone awake.
//   Resting - idle (e.g. loitering in a city): its zone may sleep until wakeAt
//             (a Unix timestamp), when it wakes so the bot can pick a new goal.
//   Unknown - just spawned, nothing reported yet: holds its zone awake so the
//             AI gets a chance to decide.
// The AI re-reports periodically, so a lost record heals itself.
enum class BotActivity : uint8
{
    Unknown = 0,
    Active  = 1,
    Resting = 2,
};

// Records a bot's activity. wakeAt is only used for Resting (0 = never wake).
void SetBotActivity(uint32 charId, BotActivity activity, uint32 wakeAt);

// Marks a bot as making progress (EXP gained). A levelling bot that neither
// moves nor gains EXP for a while counts for less when the budget is shared out.
void NoteBotProgress(uint32 charId);

// Drops a bot's activity record (despawn/delete).
void ForgetBotActivity(uint32 charId);

// True if bots currently hold zoneId awake (see UpdateBotAwakeZones).
auto IsZoneHeldAwakeByBots(uint16 zoneId) -> bool;

// Re-decides which zones bots hold awake and wakes newly chosen ones. Zones
// that drop out go back to sleep through the normal dormancy check in
// CZone::ZoneServer. Called every few seconds by the map engine, independent of
// any zone's own tick (dormant zones don't tick).
// Budget: map.WORLDBOTS_MAX_AWAKE_ZONES (0 = unlimited).
void UpdateBotAwakeZones();

struct BotAwakeZoneInfo
{
    uint16 zoneId;
    float  demand;  // weighted bot demand (see UpdateBotAwakeZones)
    uint32 bots;    // bots in the zone
    bool   held;    // held awake by bots
    bool   players; // awake anyway because real players are here
};

// Per-zone snapshot from the last UpdateBotAwakeZones, for !worldbot zones.
auto GetBotAwakeZones() -> std::vector<BotAwakeZoneInfo>;

} // namespace botutils
