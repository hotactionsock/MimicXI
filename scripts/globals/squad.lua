-----------------------------------
-- xi.squad  -  mimic-trust squad shared logic + machine protocol
--
-- The human command (!squad) and the addon command (!msq) both live on top of
-- this. The addon protocol is a stream of pipe-delimited records sent to the
-- player under the reserved chat sender "_MSQDATA"; the msquad addon parses and
-- hides them. Wire layout (bump PROTOCOL for any breaking change):
--
--   d|<protocol>|<verb>            envelope open, names the verb being answered
--   c|<charid>|<name>|<mjob>|<mlvl>|<flags>   one account character
--                                  flags: 1 online, 2 locked (out as a mimic), 4 self
--   s|<slot>|<charid>              one filled squad slot (1..SLOTS)
--   t|<0|1>                        trust-engage mode charvar
--   m|<text>  /  e|<text>          status / error prose (any time)
--   z|<verb>                       envelope close
-----------------------------------
xi       = xi       or {}
xi.squad = xi.squad or {}

xi.squad.SLOTS      = 5
xi.squad.PROTOCOL   = 1
xi.squad.ENGAGE_VAR = 'TrustEngageType' -- 0 = engage + swing (retail), 1 = engage on target

local MSQ_SENDER = '_MSQDATA'

local FLAG_ONLINE = 1
local FLAG_LOCKED = 2
local FLAG_SELF   = 4

local function rec(player, line)
    player:printToPlayer(line, xi.msg.channel.SYSTEM_3, MSQ_SENDER)
end

xi.squad.msqStatus = function(player, text)
    rec(player, 'm|' .. tostring(text))
end

xi.squad.msqError = function(player, text)
    rec(player, 'e|' .. tostring(text))
end

-- Emit the full roster answer for verb (who|set|clear|engage).
xi.squad.msqRoster = function(player, verb)
    rec(player, string.format('d|%d|%s', xi.squad.PROTOCOL, verb))

    local selfId = player:getID()
    for _, c in ipairs(player:getAccountCharacters()) do
        local flags = 0
        if c.online          then flags = flags + FLAG_ONLINE end
        if c.locked          then flags = flags + FLAG_LOCKED end
        if c.charid == selfId then flags = flags + FLAG_SELF   end
        rec(player, string.format('c|%d|%s|%d|%d|%d', c.charid, c.name, c.mainJob, c.mainLvl, flags))
    end

    local roster = player:getSquadRoster()
    for slot = 1, xi.squad.SLOTS do
        local charid = roster[slot] or 0
        if charid ~= 0 then
            rec(player, string.format('s|%d|%d', slot, charid))
        end
    end

    rec(player, string.format('t|%d', player:getCharVar(xi.squad.ENGAGE_VAR)))
    rec(player, 'z|' .. verb)
end

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
