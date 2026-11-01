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
// real character, not a synthetic stat block. Returns the new charId, or 0.
auto CreateBotCharacter(xi::ZoneId zoneId, float x, float y, float z, uint8 rotation, CharRace race, CharFace face, const std::string& name) -> uint32;

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

// Despawns (if needed) and permanently deletes a bot character, its throwaway
// account and its `world_bots` row. Returns false if charId isn't a bot.
auto DeleteBotCharacter(uint32 charId) -> bool;

// True if charId is registered in `world_bots` (spawned or not).
auto IsBotCharacter(uint32 charId) -> bool;

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

// Instantly and safely relocates a bot to (x,y,z,rotation) in zoneId, even
// across zones or out of a stuck mid-zone-transition state (a bot has no
// client to complete that sequence on its own, unlike a real player), and
// re-anchors its loiter area there. Does a clean despawn (tolerant of a
// broken/limbo zone state) + a direct position/zone update in the database +
// a fresh spawn. Returns nullptr if charId isn't a bot or the move failed.
auto TeleportBotCharacter(uint32 charId, xi::ZoneId zoneId, float x, float y, float z, uint8 rotation) -> CCharEntity*;

} // namespace botutils
