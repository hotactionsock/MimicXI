-----------------------------------
-- !squad <subcommand> [args...]
-- Manage and summon your mimic-trust squad: a persistent, account-wide roster
-- of your own offline alt characters.
--
--   !squad list                 -- show the roster and your alts
--   !squad set <slot> <name>    -- assign an alt to a slot (1-5)
--   !squad clear <slot>         -- empty a slot
--   !squad call [slot|all]      -- summon rostered alts as mimic trusts
--   !squad dismiss              -- dismiss your mimic trusts
--
-- permission = 0 (all players)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

local SLOTS = 5

local function msg(player, text)
    player:printToPlayer('[Squad] ' .. text)
end

local function tokenize(input)
    local t = {}
    for token in string.gmatch(input or '', '%S+') do
        t[#t + 1] = token
    end
    return t
end

-- charid -> { charid, name, mainJob, mainLvl }
local function charsById(player)
    local byId = {}
    for _, c in ipairs(player:getAccountCharacters()) do
        byId[c.charid] = c
    end
    return byId
end

local function findAltByName(player, name)
    local want = string.lower(name or '')
    for _, c in ipairs(player:getAccountCharacters()) do
        if string.lower(c.name) == want then
            return c
        end
    end
    return nil
end

-----------------------------------
-- Subcommands
-----------------------------------

local function doList(player)
    local roster = player:getSquadRoster()
    local byId   = charsById(player)

    msg(player, 'Squad roster:')
    for slot = 1, SLOTS do
        local charid = roster[slot] or 0
        if charid ~= 0 then
            local c = byId[charid]
            if c then
                msg(player, string.format('  %d. %s (Lv%d)', slot, c.name, c.mainLvl))
            else
                msg(player, string.format('  %d. charid %d', slot, charid))
            end
        else
            msg(player, string.format('  %d. (empty)', slot))
        end
    end

    msg(player, 'Your characters:')
    for _, c in ipairs(player:getAccountCharacters()) do
        if c.charid ~= player:getID() then
            msg(player, string.format('  %s  Lv%d', c.name, c.mainLvl))
        end
    end
end

local function doSet(player, args)
    local slot = tonumber(args[2])
    local name = args[3]

    if not slot or slot < 1 or slot > SLOTS or not name then
        msg(player, string.format('Usage: !squad set <1-%d> <character name>', SLOTS))
        return
    end

    local alt = findAltByName(player, name)
    if not alt then
        msg(player, string.format('"%s" is not one of your characters.', name))
        return
    end

    if alt.charid == player:getID() then
        msg(player, 'You cannot add yourself to your own squad.')
        return
    end

    player:setSquadSlot(slot, alt.charid)
    msg(player, string.format('Slot %d set to %s.', slot, alt.name))
end

local function doClear(player, args)
    local slot = tonumber(args[2])
    if not slot or slot < 1 or slot > SLOTS then
        msg(player, string.format('Usage: !squad clear <1-%d>', SLOTS))
        return
    end

    player:setSquadSlot(slot, 0)
    msg(player, string.format('Slot %d cleared.', slot))
end

local function doCall(player, args)
    local roster = player:getSquadRoster()
    local byId   = charsById(player)

    local only = nil
    if args[2] and args[2] ~= 'all' then
        only = tonumber(args[2])
        if not only or only < 1 or only > SLOTS then
            msg(player, string.format('Usage: !squad call [1-%d|all]', SLOTS))
            return
        end
    end

    local summoned = 0
    for slot = 1, SLOTS do
        local charid = roster[slot] or 0
        if charid ~= 0 and (only == nil or only == slot) then
            local c = byId[charid]
            if c then
                if not xi.trust.checkSlotCapacity(player) then
                    break -- party/trust cap reached; checkSlotCapacity already messaged
                end

                local trust = player:spawnMimicTrust(c.name)
                if trust ~= nil then
                    summoned = summoned + 1
                else
                    msg(player, string.format('Could not summon %s (offline & not already out?).', c.name))
                end
            end
        end
    end

    if summoned > 0 then
        msg(player, string.format('Summoned %d squad member(s).', summoned))
    elseif only ~= nil then
        msg(player, 'Nothing to summon in that slot.')
    else
        msg(player, 'Squad is empty. Use !squad set <slot> <name>.')
    end
end

local function doDismiss(player)
    player:clearMimicTrusts()
    msg(player, 'Mimic trusts dismissed.')
end

local function doEngage(player, args)
    local mode = tonumber(args[2])
    if not xi.squad.setEngageMode(player, mode) then
        msg(player, 'Usage: !squad engage 0|1  (0 = engage + swing, 1 = engage on your target)')
        return
    end
    msg(player, mode == 1
        and 'Squad now engages as soon as you target a monster.'
        or  'Squad now engages when you land a swing.')
end

local function doSetJob(player, args)
    local name = args[2]
    local mj   = args[3] and (tonumber(args[3]) or xi.job[string.upper(args[3])])
    local sj   = args[4] and (tonumber(args[4]) or xi.job[string.upper(args[4])]) or 0

    local alt = name and xi.squad.findAltByName(player, name)
    if not alt or not mj then
        msg(player, 'Usage: !squad setjob <character name> <mainJob> [subJob]   (job short name or id)')
        return
    end

    local res = player:setSquadMemberJob(alt.charid, mj, sj)
    local why = xi.squad.JOB_RESULT[res]
    msg(player, why or string.format('%s is now on the new job.', alt.name))
end

-----------------------------------
-- Dispatch
-----------------------------------

local dispatch =
{
    list    = function(player, _)    doList(player)        end,
    who     = function(player, _)    doList(player)        end,
    set     = function(player, args) doSet(player, args)   end,
    clear   = function(player, args) doClear(player, args) end,
    call    = function(player, args) doCall(player, args)  end,
    summon  = function(player, args) doCall(player, args)  end,
    dismiss = function(player, _)    doDismiss(player)     end,
    engage  = function(player, args) doEngage(player, args) end,
    setjob  = function(player, args) doSetJob(player, args) end,
}

commandObj.onTrigger = function(player, input)
    local args = tokenize(input)
    local verb = string.lower(args[1] or '')
    local handler = dispatch[verb]

    if handler then
        handler(player, args)
    else
        msg(player, 'Subcommands: list | set <slot> <name> | clear <slot> | call [slot|all] | dismiss | engage 0|1 | setjob <name> <mjob> [sjob]')
    end
end

return commandObj
