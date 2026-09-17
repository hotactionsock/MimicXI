-----------------------------------
-- xi.squad  -  mimic-trust squad shared logic + machine protocol
--
-- The human command (!squad) and the addon command (!msq) both live on top of
-- this. The addon protocol is a stream of pipe-delimited records, each line
-- prefixed "MSQ|" and sent on SYSTEM_3; the msquad addon matches the prefix,
-- parses and blocks them (same shape FATETracker uses for FSYNC|). Bump
-- PROTOCOL for any breaking change:
--
--   MSQ|d|<protocol>|<verb>        envelope open, names the verb being answered
--   MSQ|c|<charid>|<name>|<mjob>|<mlvl>|<flags>|<sjob>|<slvl>   one account character
--                                  flags: 1 online, 2 locked (out as a mimic), 4 self
--                                  sjob/slvl are appended (0/0 = no sub)
--   MSQ|s|<slot>|<charid>          one filled squad slot (1..SLOTS)
--   MSQ|t|<0|1>                    trust-engage mode charvar
--   MSQ|m|<text>  /  MSQ|e|<text>  status / error prose (any time)
--   MSQ|z|<verb>                   envelope close
--
-- Bags (item transfer between the account's characters):
--   MSQ|bk|<charid>|<containerId>|<size>|<used>          one container's fill
--   MSQ|bi|<charid>|<containerId>|<slot>|<itemId>|<qty>|<aug>   one item row
--                                  aug: 1 if the item carries an augment / exdata
--
-- Gear (equip an offline alt / trust):
--   MSQ|g|<charid>|<equipSlot>|<itemId>|<aug>|<containerId>|<invSlot>   one of the 16 worn slots
--                                  containerId/invSlot address the backing
--                                  char_inventory row (0/0 if empty) - reuse
--                                  them for an augment lookup, same as a
--                                  candidate's srcCont/srcSlot below
--   MSQ|gc|<charid>|<equipSlot>|<srcChar>|<srcSelf>|<srcCont>|<srcSlot>|<itemId>|<aug>|<equipped>
--                                  one equip candidate (srcSelf 1 = the summoner)
--
-- Warehouse as a gear/bag source (account_warehouse, rowid-addressed rather
-- than charid/container/slot - see warehouseutils / squadutils):
--   MSQ|wgc|<charid>|<equipSlot>|<rowid>|<itemId>|<aug>  one warehouse equip candidate
--   MSQ|wp|<page>|<pages>|<used>|<cap>                   warehouse page info (Bags tab)
--   MSQ|wi|<rowid>|<itemId>|<qty>|<aug>                  one warehouse row (Bags tab)
--
-- Item stat readout (Gear tab hover/click):
--   MSQ|mi|<itemId>|<statsText>    base item_mods, static per itemId - no
--                                  charid. Space-separated "MOD+n"/"MOD-n"
--                                  pairs, may be empty for a plain item.
--   MSQ|ma|<charid>|<containerId>|<slot>|<augText>   augment-only stats for
--                                  one specific instance (account bag slot,
--                                  or a worn slot's containerId/invSlot) -
--                                  augments don't live on the itemId.
--   MSQ|mw|<rowid>|<augText>       same, for one account_warehouse row.
--
-- Gambits (see scripts/globals/gambitrules.lua for the whitelist/parsing):
--   MSQ|gvt|<id>|<key>|<label>            vocab: target        (verb "gambitvocab")
--   MSQ|gvc|<id>|<key>|<argkind>|<label>  vocab: condition     (argkind: none|percent|tp|status)
--   MSQ|gvs|<id>|<key>|<label>            vocab: status
--   MSQ|gvf|<id>|<KEY>                    vocab: spell family (addon prettifies KEY)
--   MSQ|gvw|<id>|<key>|<label>            vocab: weaponskill trigger (ai.tp.*)
--   MSQ|gvu|<id>|<key>|<label>            vocab: weaponskill selector (ai.s.* subset)
--   MSQ|gs|<setid>|<name>|<count>|<tptrigger>|<tpselector>|<tpactionid>  one owned gambit set  (verb "gambits")
--   MSQ|gr|<setid>|<ordinal>|<target>|<cond>|<arg>|<reaction>|<selector>|<actionid>  one rule
--   MSQ|ga|<charid>|<mjob>|<setid>        one (charid,mjob) -> set assignment
-----------------------------------
require('scripts/globals/gambitrules')
-----------------------------------
xi       = xi       or {}
xi.squad = xi.squad or {}

xi.squad.SLOTS      = 5
xi.squad.PROTOCOL   = 1
xi.squad.ENGAGE_VAR = 'TrustEngageType' -- 0 = engage + swing (retail), 1 = engage on target

local FLAG_ONLINE = 1
local FLAG_LOCKED = 2
local FLAG_SELF   = 4

local function rec(player, line)
    player:printToPlayer('MSQ|' .. line, xi.msg.channel.SYSTEM_3)
end

xi.squad.msqStatus = function(player, text)
    rec(player, 'm|' .. tostring(text))
end

xi.squad.msqError = function(player, text)
    rec(player, 'e|' .. tostring(text))
end

-- Emit the full roster answer for verb (who|set|clear|engage|setjob|...).
-- One answer feeds both the Squad tab and the Jobs tab of the addon.
xi.squad.msqRoster = function(player, verb)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))

    local selfId = player:getID()
    for _, c in ipairs(player:getAccountCharacters()) do
        local flags = 0
        if c.online          then flags = flags + FLAG_ONLINE end
        if c.locked          then flags = flags + FLAG_LOCKED end
        if c.charid == selfId then flags = flags + FLAG_SELF   end
        rec(player, string.format('c|%d|%s|%d|%d|%d|%d|%d|%d',
            c.charid, c.name, c.mainJob, c.mainLvl, flags, c.subJob or 0, c.subLvl or 0, c.unlocked or 0))

        -- Per-job levels, comma list WAR..RUN (job 1..22).
        local lv, parts = c.levels or {}, {}
        for j = 1, 22 do
            parts[j] = tostring(lv[j] or 0)
        end
        rec(player, string.format('j|%d|%s', c.charid, table.concat(parts, ',')))
    end

    local roster = player:getSquadRoster()
    for slot = 1, xi.squad.SLOTS do
        local charid = roster[slot] or 0
        if charid ~= 0 then
            rec(player, string.format('s|%d|%d', slot, charid))
        end
    end

    for _, p in ipairs(player:listSquadJobPresets()) do
        rec(player, string.format('p|%s|%d', p.name, p.count))
    end

    rec(player, string.format('t|%d', player:getCharVar(xi.squad.ENGAGE_VAR)))
    rec(player, 'z|' .. verb)
end

-- Containers surfaced to the Bags UI: id -> short label. Mirrors the wire order
-- in squadutils.cpp kBagContainers. Used by !squad prose; the addon has its own
-- names from the client resources.
xi.squad.CONTAINERS =
{
    [0]  = 'inventory',
    [1]  = 'mog safe',
    [9]  = 'mog safe 2',
    [4]  = 'mog locker',
    [5]  = 'mog satchel',
    [6]  = 'mog sack',
    [7]  = 'mog case',
    [8]  = 'wardrobe',
    [10] = 'wardrobe 2',
    [11] = 'wardrobe 3',
    [12] = 'wardrobe 4',
    [13] = 'wardrobe 5',
    [14] = 'wardrobe 6',
    [15] = 'wardrobe 7',
    [16] = 'wardrobe 8',
}

xi.squad.CONTAINER_ORDER = { 0, 1, 9, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16 }

-- Human-readable reason for a squadLearnScroll result code.
xi.squad.LEARN_RESULT =
{
    [0] = 'Learned! Every character on the account now knows it.',
    [1] = 'That is not one of your account characters.',
    [2] = 'That item is not a spell scroll.',
    [3] = 'Nothing is in that slot.',
    [4] = 'The account already knows that spell.',
    [5] = 'No character on the account meets the requirement for that spell.',
    [6] = 'Learning failed - nothing was changed.',
}

-- Try to learn the scroll at (srcChar, srcCont, srcSlot); refresh that bag.
xi.squad.msqLearn = function(player, srcChar, srcCont, srcSlot)
    local res = player:squadLearnScroll(srcChar, srcCont, srcSlot)
    local why = xi.squad.LEARN_RESULT[res]
    if res == 0 then
        xi.squad.msqStatus(player, why)
    else
        xi.squad.msqError(player, why or ('learn failed (' .. tostring(res) .. ')'))
    end
    xi.squad.msqBagItems(player, 'learn', srcChar, srcCont)
end

-- Human-readable reason for a squadBagMove result code.
xi.squad.BAG_RESULT =
{
    [0] = nil,
    [1] = 'That is not one of your account characters.',
    [2] = 'That container is not available on that character.',
    [3] = 'Nothing is in that slot.',
    [4] = 'The destination bag is full.',
    [5] = 'That character is logged in - move items on it directly.',
    [6] = 'Bad quantity (or the item does not stack).',
    [7] = 'The move failed - nothing was changed.',
    [8] = 'Nothing to move.',
}

-- Emit every account character's container fills (Bags tab overview).
xi.squad.msqBags = function(player, verb)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    for _, c in ipairs(player:getSquadBags()) do
        for _, k in ipairs(c.containers) do
            rec(player, string.format('bk|%d|%d|%d|%d', c.charid, k.id, k.size, k.used))
        end
    end
    rec(player, 'z|' .. verb)
end

-- Emit one container's contents for one character.
xi.squad.msqBagItems = function(player, verb, charid, containerId)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))

    for _, c in ipairs(player:getSquadBags()) do
        if c.charid == charid then
            for _, k in ipairs(c.containers) do
                if k.id == containerId then
                    rec(player, string.format('bk|%d|%d|%d|%d', c.charid, k.id, k.size, k.used))
                end
            end
        end
    end

    for _, it in ipairs(player:getSquadBagItems(charid, containerId)) do
        rec(player, string.format('bi|%d|%d|%d|%d|%d|%d',
            charid, containerId, it.slot, it.itemId, it.quantity, it.aug and 1 or 0))
    end

    rec(player, 'z|' .. verb)
end

-- Equip-slot id -> label (SLOTTYPE in battle_entity.h).
xi.squad.EQUIP_SLOTS =
{
    [0]  = 'Main',  [1]  = 'Sub',   [2]  = 'Range', [3]  = 'Ammo',
    [4]  = 'Head',  [5]  = 'Body',  [6]  = 'Hands', [7]  = 'Legs',
    [8]  = 'Feet',  [9]  = 'Neck',  [10] = 'Waist', [11] = 'Ear 1',
    [12] = 'Ear 2', [13] = 'Ring 1',[14] = 'Ring 2',[15] = 'Back',
}

-- Your own live character equips/unequips straight from your own bags (result
-- 0, same as an alt). Result 2/6 below still apply to you for a warehouse or
-- another alt's item - move it into your own bags first (Bags tab), then
-- equip it from there.
xi.squad.GEAR_RESULT =
{
    [0] = nil,
    [1] = 'That is not one of your account characters.',
    [2] = 'That character is logged in - equip from its own bags, or move the item to your bags first.',
    [3] = 'That item does not fit that slot.',
    [4] = 'The item is no longer there.',
    [5] = "That character's job, level or race cannot wear it.",
    [6] = 'The equip failed - nothing was changed.',
    [8] = 'Equipped - the trust re-summons on the new gear after this fight.',
}

-- Emit an alt's 16 worn slots.
xi.squad.msqGear = function(player, verb, charid)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    for _, g in ipairs(player:getSquadGear(charid)) do
        rec(player, string.format('g|%d|%d|%d|%d|%d|%d',
            charid, g.equipSlot, g.itemId, g.aug and 1 or 0, g.containerId, g.invSlot))
    end
    rec(player, 'z|' .. verb)
end

-- Emit the equip candidates for one slot.
xi.squad.msqGearCandidates = function(player, verb, charid, equipSlot)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    for _, c in ipairs(player:getSquadGearCandidates(charid, equipSlot)) do
        rec(player, string.format('gc|%d|%d|%d|%d|%d|%d|%d|%d|%d',
            charid, equipSlot, c.srcChar, c.srcSelf, c.srcCont, c.srcSlot, c.itemId, c.aug, c.equipped))
    end
    rec(player, 'z|' .. verb)
end

-- Emit the equip candidates for one slot, sourced from account_warehouse.
xi.squad.msqWarehouseGearCandidates = function(player, verb, charid, equipSlot)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    for _, c in ipairs(player:getSquadWarehouseGearCandidates(charid, equipSlot)) do
        rec(player, string.format('wgc|%d|%d|%d|%d|%d',
            charid, equipSlot, c.rowid, c.itemId, c.aug and 1 or 0))
    end
    rec(player, 'z|' .. verb)
end

-- modId -> short label, built once from xi.mod (already a generated name->id
-- enum). Falls back to "mod<id>" for anything not in it (item_mods should
-- only ever reference real mods, so this is just a safety net).
local modLabel
local function getModLabel(modId)
    if not modLabel then
        modLabel = {}
        for name, id in pairs(xi.mod) do
            if modLabel[id] == nil then
                modLabel[id] = name
            end
        end
    end
    return modLabel[modId] or ('mod' .. tostring(modId))
end

-- Race id (xi.race, 1..8) -> { group, sex }. Bit (race-1) of an
-- EQUIPMENT_ONLY_RACE mod being set means that race can wear the item
-- (item_equipment.cpp: isEquippableByRace). Matches scripts/enum/race.lua.
local RACE_INFO =
{
    [1] = { group = 'Hume',     sex = 'M' },
    [2] = { group = 'Hume',     sex = 'F' },
    [3] = { group = 'Elvaan',   sex = 'M' },
    [4] = { group = 'Elvaan',   sex = 'F' },
    [5] = { group = 'Tarutaru', sex = 'M' },
    [6] = { group = 'Tarutaru', sex = 'F' },
    [7] = { group = 'Mithra' },
    [8] = { group = 'Galka' },
}

-- "EQUIPMENT_ONLY_RACE" is a race bitmask, not a signed stat delta - decode it
-- into readable names ("Hume/Galka") instead of showing the raw mod name and
-- mask value.
local function formatRaceMask(mask)
    local groups, order = {}, {}
    for race = 1, 8 do
        if bit.band(mask, bit.lshift(1, race - 1)) ~= 0 then
            local info = RACE_INFO[race]
            if not groups[info.group] then
                groups[info.group] = {}
                order[#order + 1] = info.group
            end
            if info.sex then groups[info.group][info.sex] = true else groups[info.group].any = true end
        end
    end

    local parts = {}
    for _, name in ipairs(order) do
        local g = groups[name]
        if g.any or (g.M and g.F) then
            parts[#parts + 1] = name
        elseif g.M then
            parts[#parts + 1] = name .. ' (M)'
        else
            parts[#parts + 1] = name .. ' (F)'
        end
    end
    return table.concat(parts, '/')
end

-- Compact "STR+3 DEX+2 HP+15" stat line from a list of { modId, value } rows
-- (whatever shape - base item_mods or decoded augment deltas). Shared by
-- formatItemMods and formatAugmentMods below.
local function formatModRows(rows)
    local parts = {}
    for _, m in ipairs(rows) do
        if m.modId == xi.mod.EQUIPMENT_ONLY_RACE then
            if m.value > 0 then
                parts[#parts + 1] = formatRaceMask(m.value)
            end
        elseif m.value ~= 0 then
            parts[#parts + 1] = string.format('%s%+d', getModLabel(m.modId), m.value)
        end
    end
    return table.concat(parts, ' ')
end

-- Base "DMG:54 Delay:240 STR+3 DEX+2 HP+15" stat line for one itemId, from
-- the item's base item_mods rows (augments are per-instance and not covered
-- here), with DMG/Delay prefixed for a weapon - those are item_weapon's own
-- columns, not a stat modifier, so getItemMods doesn't carry them. Lets
-- players in the msquad Gear tab see stats before moving gear to inventory.
xi.squad.formatItemMods = function(player, itemId)
    local text   = formatModRows(player:getItemMods(itemId))
    local weapon = player:getWeaponDamageDelay(itemId)

    if weapon.isWeapon then
        local prefix = string.format('DMG:%d Delay:%d', weapon.damage, weapon.delay)
        text = (text ~= '') and (prefix .. ' ' .. text) or prefix
    end

    return text
end

-- Augment-only stat line for one specific item instance (an account bag/
-- wardrobe slot, or a worn slot's backing containerId/invSlot - see
-- getSquadGear). Empty for a plain, non-augmented item.
xi.squad.formatBagItemAugmentMods = function(player, charid, containerId, slot)
    return formatModRows(player:getBagItemAugmentMods(charid, containerId, slot))
end

-- Same, for one account_warehouse row (rowid-addressed).
xi.squad.formatWarehouseItemAugmentMods = function(player, rowid)
    return formatModRows(player:getWarehouseItemAugmentMods(rowid))
end

-- Emit the base stat readout for one itemId. Static per item, not
-- per-character - callable regardless of which alt/slot is currently open in
-- the Gear tab.
xi.squad.msqItemInfo = function(player, verb, itemId)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    rec(player, string.format('mi|%d|%s', itemId, xi.squad.formatItemMods(player, itemId)))
    rec(player, 'z|' .. verb)
end

-- Emit the augment-only stat readout for one account bag/wardrobe slot (or a
-- worn slot's backing containerId/invSlot).
xi.squad.msqBagItemAugmentInfo = function(player, verb, charid, containerId, slot)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    rec(player, string.format('ma|%d|%d|%d|%s',
        charid, containerId, slot, xi.squad.formatBagItemAugmentMods(player, charid, containerId, slot)))
    rec(player, 'z|' .. verb)
end

-- Emit the augment-only stat readout for one account_warehouse row.
xi.squad.msqWarehouseItemAugmentInfo = function(player, verb, rowid)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))
    rec(player, string.format('mw|%d|%s', rowid, xi.squad.formatWarehouseItemAugmentMods(player, rowid)))
    rec(player, 'z|' .. verb)
end

-- Emit one page of the account warehouse, for the Bags tab's Warehouse
-- pseudo-character (reuses the mwarehouse-addon's own warehouseInfo/Page
-- bindings - listing is account-wide and not alt-specific).
xi.squad.msqWarehousePage = function(player, verb, page)
    page = page or 0
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))

    local info = player:warehouseInfo()
    rec(player, string.format('wp|%d|%d|%d|%d', page, info.pages, info.used, info.cap))

    for _, row in ipairs(player:warehousePage(page)) do
        rec(player, string.format('wi|%d|%d|%d|%d', row.rowid, row.itemId, row.quantity, row.aug and 1 or 0))
    end

    rec(player, 'z|' .. verb)
end

-- Human-readable reason for a squadBagMoveToWarehouse / squadBagMoveFromWarehouse
-- result code (the two share one numbering - see squadutils::WarehouseBagResult).
xi.squad.WAREHOUSE_BAG_RESULT =
{
    [0] = nil,
    [1] = 'That is not one of your account characters.',
    [2] = 'That container is not available on that character.',
    [3] = 'That character is logged in - use the warehouse directly.',
    [4] = 'Nothing is there any more.',
    [5] = 'The destination is full.',
    [6] = 'Bad quantity (or the item does not stack).',
    [7] = 'The move failed - nothing was changed.',
}

-- Human-readable reason for a swapOwnJobs (self job change) result code.
xi.squad.SELFJOB_RESULT =
{
    [0] = nil,
    [1] = 'Invalid job.',
    [2] = 'That job is not unlocked on your character.',
    [3] = 'You cannot change jobs while engaged.',
    [4] = 'You are already on that job.',
    [5] = 'You cannot change jobs here.',
}

-- Change the caller's own main/sub job (Jobs-tab "You" row). Handles the PUP
-- automaton setup and despawns any active pet first, like !changejob does.
xi.squad.selfChangeJob = function(player, mjob, sjob)
    sjob = sjob or 0

    if mjob == xi.job.PUP or sjob == xi.job.PUP then
        if player:getAutomatonName() == '' then
            player:setPetName(xi.petType.AUTOMATON, xi.petName.MK_IV)
        end
        if not player:hasAttachment(xi.item.HARLEQUIN_FRAME) then
            player:unlockAttachment(xi.item.HARLEQUIN_FRAME)
        end
        if not player:hasAttachment(xi.item.HARLEQUIN_HEAD) then
            player:unlockAttachment(xi.item.HARLEQUIN_HEAD)
        end
    end

    if player:getPet() then
        player:despawnPet()
    end

    return player:swapOwnJobs(mjob, sjob)
end

-- Human-readable reason for a setSquadMemberJob result code.
xi.squad.JOB_RESULT =
{
    [0] = nil,                                   -- ok - if the alt is currently
                                                  -- out as a trust, it is force-
                                                  -- resummoned immediately on the
                                                  -- new job (no deferral, even in
                                                  -- combat - see setSquadMemberJob)
    [1] = 'That character is not on your account.',
    [2] = 'That character is logged in - change jobs on it directly.',
    [3] = 'That job is not unlocked on that character.',
    [4] = 'Invalid job.',
}

-- charid -> account character row, by (case-insensitive) name.
xi.squad.findAltByName = function(player, needle)
    local want = string.lower(needle or '')
    for _, c in ipairs(player:getAccountCharacters()) do
        if string.lower(c.name) == want then
            return c
        end
    end
    return nil
end

-- Set the trust-engage mode charvar. Returns true on a valid mode.
xi.squad.setEngageMode = function(player, mode)
    if mode ~= 0 and mode ~= 1 then
        return false
    end
    player:setCharVar(xi.squad.ENGAGE_VAR, mode)
    return true
end

-----------------------------------
-- Gambits (see scripts/globals/gambitrules.lua for the whitelist/parsing)
-----------------------------------

xi.squad.GAMBITSET_RESULT =
{
    [0] = nil, -- ok
    [1] = 'You already have a gambit set with that name.',
    [2] = string.format('You already have %d gambit sets (the max).', xi.gambitRules.MAX_SETS_PER_ACCOUNT),
    [3] = 'Bad name (1-24 characters).',
    [4] = 'No gambit set with that name.',
}

xi.squad.GAMBITRULE_ADD_RESULT =
{
    [0] = nil, -- ok
    [1] = 'No gambit set with that name.',
    [2] = string.format('That set already has %d rules (the max).', xi.gambitRules.MAX_RULES_PER_SET),
}

xi.squad.GAMBITRULE_REMOVE_RESULT =
{
    [0] = nil, -- ok
    [1] = 'No gambit set with that name.',
    [3] = 'No rule at that position.', -- GambitRuleResult::BadOrdinal
}

xi.squad.GAMBITASSIGN_RESULT =
{
    [0] = nil, -- ok
    [1] = 'That character is not on your account.',
    [2] = 'Invalid job.',
    [3] = 'No gambit set with that name.',
}

xi.squad.GAMBITSET_UPDATE_RESULT =
{
    [0] = nil, -- ok
    [3] = 'Bad name.',
    [4] = 'No gambit set with that name.',
}

-- The vocabulary the msquad Gambits tab builds its dropdowns from. Sent once
-- (the addon caches it) under its own envelope so it never competes with the
-- (much more frequently refreshed) gambits envelope below.
--   MSQ|gvt|<id>|<key>|<label>            target
--   MSQ|gvc|<id>|<key>|<argkind>|<label>  condition (argkind: none|percent|tp|status)
--   MSQ|gvs|<id>|<key>|<label>            status (for the status/notstatus arg)
--   MSQ|gvf|<id>|<KEY>                    spell family (addon prettifies KEY into a label)
xi.squad.msqGambitVocab = function(player, verb)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))

    for _, t in ipairs(xi.gambitRules.TARGET_LIST) do
        rec(player, string.format('gvt|%d|%s|%s', xi.gambitRules.TARGETS[t.name], t.name, t.label))
    end

    for _, c in ipairs(xi.gambitRules.CONDITION_LIST) do
        local def = xi.gambitRules.CONDITIONS[c.name]
        rec(player, string.format('gvc|%d|%s|%s|%s', def.id, c.name, def.arg, c.label))
    end

    for _, s in ipairs(xi.gambitRules.STATUSES) do
        rec(player, string.format('gvs|%d|%s|%s', s.id, s.name, s.label))
    end

    for _, f in ipairs(xi.gambitRules.FAMILY_LIST) do
        rec(player, string.format('gvf|%d|%s', f.id, f.name))
    end

    for _, t in ipairs(xi.gambitRules.TP_TRIGGER_LIST) do
        rec(player, string.format('gvw|%d|%s|%s', xi.gambitRules.TP_TRIGGERS[t.name], t.name, t.label))
    end

    for _, s in ipairs(xi.gambitRules.TP_SELECTOR_LIST) do
        rec(player, string.format('gvu|%d|%s|%s', xi.gambitRules.TP_SELECTORS[s.name], s.name, s.label))
    end

    rec(player, 'z|' .. verb)
end

-- The player's own gambit sets/rules/assignments. Sent whole every time (sets
-- are capped small - see MAX_SETS_PER_ACCOUNT/MAX_RULES_PER_SET), the same
-- shape as msqRoster's full-dump-every-refresh pattern.
--   MSQ|gs|<setid>|<name>|<count>|<tptrigger>|<tpselector>|<tpactionid>
--   MSQ|gr|<setid>|<ordinal>|<target>|<cond>|<arg>|<reaction>|<selector>|<actionid>
--   MSQ|ga|<charid>|<mjob>|<setid>
xi.squad.msqGambits = function(player, verb)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))

    for _, s in ipairs(player:getGambitSets()) do
        rec(player, string.format('gs|%d|%s|%d|%d|%d|%d',
            s.setid, s.name, s.count, s.tpTrigger, s.tpSelector, s.tpActionId))

        for _, r in ipairs(player:getGambitRules(s.name)) do
            rec(player, string.format('gr|%d|%d|%d|%d|%d|%d|%d|%d',
                s.setid, r.ordinal, r.target, r.cond, r.arg, r.reaction, r.selector, r.actionid))
        end
    end

    for _, a in ipairs(player:getGambitAssignments()) do
        rec(player, string.format('ga|%d|%d|%d', a.charid, a.mjob, a.setid))
    end

    rec(player, 'z|' .. verb)
end
