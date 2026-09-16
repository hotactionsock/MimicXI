/*
===========================================================================

  Copyright (c) 2024 LandSandBoat Dev Teams

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

#include <array>
#include <optional>
#include <string>
#include <utility>
#include <vector>

#include "common/cbasetypes.h"

namespace squadutils
{

// Number of mimic-trust squad slots per account.
inline constexpr uint8 SquadSlots = 5;

// char_jobs / char_exp / char_stats column name for job id 1..22 (WAR..RUN),
// nullptr for anything out of range.
auto JobColumn(uint8 jobId) -> const char*;

struct AccountChar
{
    uint32                charId{};
    std::string           name;
    uint8                 mainJob{};
    uint8                 mainLvl{};
    uint8                 subJob{};
    uint8                 subLvl{};
    bool                  online{};   // has a live accounts_sessions row
    bool                  locked{};   // currently out as someone's mimic trust (char_mimic_active)
    uint32                unlocked{}; // char_jobs.unlocked bitmask, bit jobId
    std::array<uint8, 23> levels{};   // levels[jobId], 1..22
};

enum class SetJobResult : uint8
{
    Ok,       // char_stats updated; the caller resummons if appropriate
    NotFound, // not one of this account's characters
    Online,   // the character is logged in
    JobLocked,// main or sub job is not unlocked
    BadJob,   // job id out of range
};

// Sets an offline alt's active main/sub job (writes char_stats mjob/sjob/mlvl/slvl,
// mlvl/slvl from char_jobs). sjob 0 = no sub.
auto SetAltJob(uint32 accId, uint32 charId, uint8 mjob, uint8 sjob) -> SetJobResult;

// --- job presets (account_jobpreset) ---
struct JobPresetEntry
{
    uint32 charId{};
    uint8  mjob{};
    uint8  sjob{};
};

void SaveJobPreset(uint32 accId, const std::string& name, const std::vector<JobPresetEntry>& entries);
auto LoadJobPreset(uint32 accId, const std::string& name) -> std::vector<JobPresetEntry>;
auto ListJobPresets(uint32 accId) -> std::vector<std::pair<std::string, uint32>>; // name, entry count
void DeleteJobPreset(uint32 accId, const std::string& name);

// Returns slot -> charid for the account (index 0 == slot 1). 0 means the slot is empty.
auto GetSquad(uint32 accId) -> std::array<uint32, SquadSlots>;

// Writes one slot. charId 0 clears the slot. slot is 1..SquadSlots.
void SetSquadSlot(uint32 accId, uint8 slot, uint32 charId);

// Every character on the account (charid ascending), for roster pickers.
auto ListAccountChars(uint32 accId) -> std::vector<AccountChar>;

// True if charId belongs to accId (an owned alt).
auto IsOwnedByAccount(uint32 accId, uint32 charId) -> bool;

// True if charId has a live accounts_sessions row.
auto IsCharOnline(uint32 charId) -> bool;

// --- bags (item transfer between the account's characters) ---
//
// The mimic squad lets you shuffle items between your own characters through
// the addon: a trust IS an offline alt, so "the trust's bag" is that alt's
// char_inventory. Only the summoner is ever online, so one endpoint of a move
// is the live CCharEntity (handled by the lua binding via ItemClaimTransaction)
// and the other is pure DB. Rare/Ex and every other item flag are ignored on
// purpose - moving between your own characters is always allowed.

// Storable containers surfaced to the Bags UI, with the char_storage column
// that carries each one's capacity. Order matters: it is the wire order.
struct BagContainerDef
{
    uint8       id;    // CONTAINER_ID
    const char* key;   // short label for the addon
    const char* col;   // char_storage column
};
auto BagContainers() -> const std::vector<BagContainerDef>&;

struct BagContainerFill
{
    uint8 id{};
    uint8 size{};  // capacity from char_storage (0 = not provisioned; skip)
    uint8 used{};  // occupied slots
};

struct BagChar
{
    uint32                        charId{};
    std::string                   name;
    bool                          online{};
    bool                          locked{};
    std::vector<BagContainerFill> containers;
};

// The account's characters and how full each surfaced container is.
auto ListBagChars(uint32 accId) -> std::vector<BagChar>;

struct BagItem
{
    uint8       slot{};
    uint16      itemId{};
    uint32      quantity{};
    std::string signature;
    uint8       extra[24]{};
};

// One container's rows for an offline character (DB read). The online summoner's
// own containers are read from the live entity by the binding instead.
auto ListBagItems(uint32 charId, uint8 containerId) -> std::vector<BagItem>;

// char_storage capacity for one container of one character; 0 if unprovisioned.
auto BagContainerSize(uint32 charId, uint8 containerId) -> uint8;

// Lowest free slot [1..size] in an offline character's container, 0 if full.
auto BagFirstFreeSlot(uint32 charId, uint8 containerId) -> uint8;

// Read a single offline row. False if the slot is empty.
auto BagReadRow(uint32 charId, uint8 containerId, uint8 slot, BagItem& out) -> bool;

// Insert a row for an offline character. Caller supplies a known-free slot.
auto BagInsertRow(uint32 charId, uint8 containerId, uint8 slot, const BagItem& item) -> bool;

// Remove `quantity` from an offline row (deletes the row when it hits zero).
auto BagTakeRow(uint32 charId, uint8 containerId, uint8 slot, uint32 quantity) -> bool;

// True if the item stacks (maxstack > 1) - the binding needs it to decide
// whether a partial move is legal.
auto ItemStackSize(uint16 itemId) -> uint16;

// --- gear (equip an offline alt, i.e. a trust) ---
//
// A mimic trust reads its look/stats/weapons from the source character's real
// char_equip / char_look at summon time. Equipping a trust therefore rewrites
// that offline character's equipment (it persists), then the caller rebuilds the
// live trust. Candidate items are filtered by the alt's *real* main-job level,
// its main job, and its race - and pulled from every account character's
// inventory + wardrobes, equipped pieces included (taking one force-unequips the
// other, offline, character).

// One of the 16 equipment slots (SLOT_MAIN..SLOT_BACK) and what the alt wears there.
struct GearSlot
{
    uint8  equipSlotId{};
    uint16 itemId{};      // 0 = empty
    bool   aug{};
    uint8  containerId{}; // char_inventory.location backing this slot (0 if empty)
    uint8  invSlot{};     // char_inventory.slot backing this slot (0 if empty) -
                           // lets the caller re-address this exact instance
                           // (e.g. for an augment stat lookup) the same way a
                           // GearCandidate's srcCont/srcSlot does.
};
auto ListAltGear(uint32 charId) -> std::array<GearSlot, 16>;

struct GearCandidate
{
    uint32 srcCharId{};
    uint8  srcCharSelf{};    // 1 if this is the account's summoner (online)
    uint8  srcContainer{};
    uint8  srcSlot{};
    uint16 itemId{};
    uint8  aug{};
    uint8  equippedElsewhere{}; // currently sitting in some char's char_equip
};
// Everything on the account that altCharId can wear in equipSlotId right now.
auto ListGearCandidates(uint32 accId, uint32 altCharId, uint8 equipSlotId) -> std::vector<GearCandidate>;

struct ItemModRow
{
    uint16 modId{};
    int16  value{};
};
// Raw item_mods rows (base stats baked into the item, e.g. STR+3) for one
// itemId. Does not include augments (those live per-instance in char_inventory
// extdata, not per-itemId) - Lua resolves modId -> label text via xi.mod, which
// is already a name->id enum on that side.
auto ListItemMods(uint16 itemId) -> std::vector<ItemModRow>;

// Decodes up to 5 augment slots from a raw 24-byte extdata blob (the same
// bytes char_inventory.extra / account_warehouse.extra store) into their
// resulting stat deltas - i.e. augment-only, not combined with the item's
// base item_mods. Replicates CItemEquipment::SetAugmentMod's formula
// (item_equipment.cpp) as pure data so the Gear tab can preview an augmented
// instance's stats without spawning a live item object. Pet mods are
// skipped (not a gear stat); empty for a plain, non-augmented item.
auto DecodeAugmentMods(const uint8 (&extra)[24]) -> std::vector<ItemModRow>;

struct WeaponDamageDelay
{
    bool   isWeapon{};
    uint16 damage{};
    uint16 delay{};
};
// Damage/Delay for a weapon itemId (item_weapon columns, not item_mods - these
// are intrinsic to the weapon, not a stat modifier). isWeapon false for
// anything that isn't a CItemWeapon (armor, or an unknown itemId).
auto GetWeaponDamageDelay(uint16 itemId) -> WeaponDamageDelay;

enum class GearResult : uint8
{
    Ok,           // char_equip / char_look written; caller resummons if appropriate
    NotOwned,     // altCharId or srcCharId not on the account
    Online,       // altCharId is logged in
    BadSlot,      // equipSlotId out of 0..15, or the item does not fit it
    NoItem,       // the source slot is empty / vanished
    NotEquippable,// job / level / race check failed for this alt
    NeedsLiveMove,// the source is the online summoner - the binding must move it
    DbError,
};

// Look-column name for an equip slot (main/sub/ranged/head/body/hands/legs/feet),
// or nullptr for slots with no visible model.
auto GearLookColumn(uint8 equipSlotId) -> const char*;

// item_equipment.MId (model id) for an item, 0 if none.
auto ItemModelId(uint16 itemId) -> uint16;

// Validate + relocate a purely-offline source item into altCharId's inventory,
// then set char_equip + char_look for equipSlotId (clearing sub for 2H/H2H).
// Returns NeedsLiveMove if srcCharId is the online summoner - the lua binding
// handles that side with an item transaction and then calls FinishAltEquip.
auto EquipAltItem(uint32 accId, uint32 altCharId, uint8 equipSlotId,
                  uint32 srcCharId, uint8 srcContainer, uint8 srcSlot) -> GearResult;

// Second half of an equip whose item was placed into altCharId's inventory by
// the caller (used when the source was the online summoner). invSlot is where it
// landed. Sets char_equip + char_look, clears sub for 2H/H2H.
auto FinishAltEquip(uint32 altCharId, uint8 equipSlotId, uint8 invSlot, uint16 itemId) -> GearResult;

// Clear one equip slot; the item stays in the alt's inventory.
auto UnequipAltItem(uint32 accId, uint32 altCharId, uint8 equipSlotId) -> GearResult;

// --- warehouse as a gear/bag source ---
//
// account_warehouse (warehouseutils) is an account-wide stash addressed by
// rowid rather than (charid, container, slot). Both sides of every move here
// are pure DB - an alt is offline and the warehouse has no live entity either -
// so, unlike the online summoner's own warehouse bindings (which move through
// a live ItemClaimTransaction), these run as plain sequential statements with
// a best-effort revert of the side already written if the second write fails.

struct WarehouseGearCandidate
{
    uint32 rowid{};
    uint16 itemId{};
    uint8  aug{};
};

// Everything in the account's warehouse that altCharId can wear in equipSlotId
// right now (same job/level/race/slot filtering as ListGearCandidates).
auto ListWarehouseGearCandidates(uint32 accId, uint32 altCharId, uint8 equipSlotId) -> std::vector<WarehouseGearCandidate>;

// Equip a warehouse row directly onto an offline alt: relocates it into the
// alt's inventory (char_inventory), removes it from account_warehouse, then
// writes char_equip / char_look. altCharId must be owned and offline.
auto EquipAltItemFromWarehouse(uint32 accId, uint32 altCharId, uint8 equipSlotId, uint32 rowid) -> GearResult;

enum class WarehouseBagResult : uint8
{
    Ok,
    NotOwned,     // altCharId not on the account
    Online,       // altCharId is logged in (live summoner uses warehousePut/Take instead)
    BadContainer, // containerId not provisioned for this alt
    NoItem,       // source slot / warehouse row is empty or stale
    Full,         // warehouse soft row cap reached
    BagFull,      // the alt's container has no free slot
    BadQuantity,
    DbError,
};

// Move `quantity` (0 = whole stack) from an offline alt's bag slot into the
// account warehouse. Merges into an existing plain-stack row when possible.
auto MoveAltBagToWarehouse(uint32 accId, uint32 altCharId, uint8 containerId, uint8 slot, uint32 quantity) -> WarehouseBagResult;

// Move `quantity` (0 = whole row) of a warehouse row into an offline alt's
// bag container. Refuses a partial move of a non-stacking item.
auto MoveWarehouseToAltBag(uint32 accId, uint32 altCharId, uint8 containerId, uint32 rowid, uint32 quantity) -> WarehouseBagResult;

// --- scroll learning (account-wide) ---
//
// A spell scroll in any bag can be learned if ANY character on the account meets
// the spell's job/level requirement. Learning consumes one scroll and grants the
// spell to every character on the account (and, live, to the online summoner) -
// so any trust whose job/level fits can then cast it.

// The spell a scroll item teaches (item_basic.type 5 + subid resolving to a
// spell), or 0 if the item is not a spell scroll.
auto ScrollSpellId(uint16 itemId) -> uint16;

// True if any character on the account has a job at or above the level that job
// learns spellId.
auto AccountMeetsSpellPrereq(uint32 accId, uint16 spellId) -> bool;

// INSERT IGNORE spellId into char_spells for every character on the account.
void FanOutSpellToAccount(uint32 accId, uint16 spellId);

// --- gambit rule sets (player-authored trust AI, account_gambit_*) ---
//
// A rule set is a small ordered list of gambits (target/condition/reaction),
// stored raw as the native ai.t/ai.c/ai.r/ai.s ints - the Lua-side whitelist
// (scripts/globals/gambitrules.lua) is what decides which of those values a
// player is allowed to author; this layer is just ownership-scoped CRUD, the
// same shape as the job-preset table above. A set can be assigned per
// (charid, mjob), since a mimic's usable spells/JAs are job-dependent.

inline constexpr uint8  MaxGambitSets        = 8;
inline constexpr uint8  MaxGambitRulesPerSet = 10;

struct GambitSet
{
    uint32      setId{};
    std::string name;
    uint8       ruleCount{};

    // Weaponskill config (setTrustTPSkillSettings): tpTrigger is an ai.tp
    // value, tpSelector an ai.s value, tpActionId a specific weaponskill id
    // (meaningful only when tpSelector is SPECIFIC). Defaults (0, 3, 0) match
    // the engine's own pre-mgambits default (ASAP + RANDOM).
    uint8  tpTrigger{};
    uint8  tpSelector{ 3 };
    uint16 tpActionId{};
};

struct GambitRule
{
    uint8  ordinal{};
    uint8  target{};
    uint8  cond{};
    uint16 arg{};
    uint8  reaction{};
    uint8  selector{};
    uint16 actionid{};
};

enum class GambitSetResult : uint8
{
    Ok,
    AlreadyExists,
    TooMany,
    BadName,
    NotFound,
};

enum class GambitRuleResult : uint8
{
    Ok,
    NotFound, // set not owned / doesn't exist
    TooMany,  // rule cap hit
    BadOrdinal,
};

// Owned sets for the account, name-ascending.
auto ListGambitSets(uint32 accId) -> std::vector<GambitSet>;

// 0 if no set of that name exists for this account.
auto FindGambitSet(uint32 accId, const std::string& name) -> uint32;

auto CreateGambitSet(uint32 accId, const std::string& name) -> GambitSetResult;
auto RenameGambitSet(uint32 accId, const std::string& name, const std::string& newName) -> GambitSetResult;
void DeleteGambitSet(uint32 accId, const std::string& name);

// Updates just the weaponskill config of an owned set.
auto SetGambitTpSkill(uint32 accId, const std::string& name, uint8 tpTrigger, uint8 tpSelector, uint16 tpActionId) -> GambitSetResult;

// Rules of an owned set, ordinal-ascending.
auto ListGambitRules(uint32 accId, const std::string& name) -> std::vector<GambitRule>;

// Appends a rule at the end of the named set (ordinal = current count + 1).
auto AddGambitRule(uint32 accId, const std::string& name, const GambitRule& rule) -> GambitRuleResult;

// Removes the rule at ordinal and compacts the ordinals after it.
auto RemoveGambitRule(uint32 accId, const std::string& name, uint8 ordinal) -> GambitRuleResult;

// --- assignment (account_gambit_assign, keyed accid+charid+mjob) ---

enum class GambitAssignResult : uint8
{
    Ok,
    NotOwned, // charId not on the account
    BadJob,
    NotFound, // named set doesn't exist for this account
};

// Assigns the named set to (charId, mjob). An empty name clears the assignment.
auto SetGambitAssign(uint32 accId, uint32 charId, uint8 mjob, const std::string& name) -> GambitAssignResult;

// The rule-set name assigned to (charId, mjob), or "" if none.
auto GetGambitAssignName(uint32 accId, uint32 charId, uint8 mjob) -> std::string;

struct GambitAssignEntry
{
    uint32 charId{};
    uint8  mjob{};
    uint32 setId{};
};

// Every (charId, mjob) -> setId assignment on the account, for the addon's
// one-shot Gambits tab refresh (avoids one getGambitAssign call per possible
// charid/job combination).
auto ListGambitAssigns(uint32 accId) -> std::vector<GambitAssignEntry>;

}; // namespace squadutils
