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
--   MSQ|g|<charid>|<equipSlot>|<itemId>|<aug>            one of the 16 worn slots
--   MSQ|gc|<charid>|<equipSlot>|<srcChar>|<srcSelf>|<srcCont>|<srcSlot>|<itemId>|<aug>|<equipped>
--                                  one equip candidate (srcSelf 1 = the summoner)
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

xi.squad.GEAR_RESULT =
{
    [0] = nil,
    [1] = 'That is not one of your account characters.',
    [2] = 'That character is logged in - change its gear directly.',
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
        rec(player, string.format('g|%d|%d|%d|%d', charid, g.equipSlot, g.itemId, g.aug and 1 or 0))
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

-- Human-readable reason for a setSquadMemberJob result code.
xi.squad.JOB_RESULT =
{
    [0] = nil,                                   -- ok
    [1] = 'That character is not on your account.',
    [2] = 'That character is logged in - change jobs on it directly.',
    [3] = 'That job is not unlocked on that character.',
    [4] = 'Invalid job.',
    [5] = 'Job changed - the trust re-summons on the new jobs after this fight.',
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
