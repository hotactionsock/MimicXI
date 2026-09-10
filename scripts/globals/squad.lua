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
