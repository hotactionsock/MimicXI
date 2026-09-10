-----------------------------------
-- !msq <verb> [args...]
-- Machine-facing squad command for the msquad Ashita addon. Every reply is a
-- stream of "MSQ|" records (see scripts/globals/squad.lua). Humans use !squad;
-- the addon uses this.
--
--   !msq who
--   !msq set <slot> <charid>   /  !msq clear <slot>
--   !msq engage <0|1>
--   !msq setjob <charid> <mjob> [sjob]
--   !msq savejobs <name>  /  usejobs <name>  /  deljobs <name>
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

commandObj.onTrigger = function(player, input)
    local a = {}
    for token in string.gmatch(input or '', '%S+') do
        a[#a + 1] = token
    end

    local verb = string.lower(a[1] or 'who')

    if verb == 'who' then
        xi.squad.msqRoster(player, 'who')

    elseif verb == 'bags' then
        xi.squad.msqBags(player, 'bags')

    elseif verb == 'bag' then
        local charid = tonumber(a[2])
        local cont   = tonumber(a[3])
        if not charid or not cont then
            xi.squad.msqError(player, 'bag <charid> <containerId>')
            return
        end
        xi.squad.msqBagItems(player, 'bag', charid, cont)

    elseif verb == 'gear' then
        local charid = tonumber(a[2])
        if not charid then
            xi.squad.msqError(player, 'gear <charid>')
            return
        end
        xi.squad.msqGear(player, 'gear', charid)

    elseif verb == 'gearslot' then
        local charid = tonumber(a[2])
        local slot   = tonumber(a[3])
        if not charid or not slot then
            xi.squad.msqError(player, 'gearslot <charid> <equipSlot>')
            return
        end
        xi.squad.msqGearCandidates(player, 'gearslot', charid, slot)

    elseif verb == 'equip' then
        local charid = tonumber(a[2])
        local slot   = tonumber(a[3])
        local sC, sK, sS = tonumber(a[4]), tonumber(a[5]), tonumber(a[6])
        if not (charid and slot and sC and sK and sS) then
            xi.squad.msqError(player, 'equip <charid> <equipSlot> <srcChar> <srcCont> <srcSlot>')
            return
        end
        local res = player:squadEquip(charid, slot, sC, sK, sS)
        local why = xi.squad.GEAR_RESULT[res]
        if why then
            if res == 8 then xi.squad.msqStatus(player, why) else xi.squad.msqError(player, why) end
        else
            xi.squad.msqStatus(player, 'Equipped.')
        end
        xi.squad.msqGear(player, 'equip', charid)

    elseif verb == 'unequip' then
        local charid = tonumber(a[2])
        local slot   = tonumber(a[3])
        if not charid or not slot then
            xi.squad.msqError(player, 'unequip <charid> <equipSlot>')
            return
        end
        local res = player:squadUnequip(charid, slot)
        local why = xi.squad.GEAR_RESULT[res]
        if why then
            if res == 8 then xi.squad.msqStatus(player, why) else xi.squad.msqError(player, why) end
        else
            xi.squad.msqStatus(player, 'Unequipped.')
        end
        xi.squad.msqGear(player, 'unequip', charid)

    elseif verb == 'learn' then
        local sC, sK, sS = tonumber(a[2]), tonumber(a[3]), tonumber(a[4])
        if not (sC and sK and sS) then
            xi.squad.msqError(player, 'learn <srcCharid> <srcCont> <srcSlot>')
            return
        end
        xi.squad.msqLearn(player, sC, sK, sS)

    elseif verb == 'bagmove' then
        local sC, sK, sS = tonumber(a[2]), tonumber(a[3]), tonumber(a[4])
        local dC, dK     = tonumber(a[5]), tonumber(a[6])
        local qty        = tonumber(a[7]) or 0
        if not (sC and sK and sS and dC and dK) then
            xi.squad.msqError(player, 'bagmove <srcCharid> <srcCont> <srcSlot> <dstCharid> <dstCont> [qty]')
            return
        end
        local res = player:squadBagMove(sC, sK, sS, dC, dK, qty)
        local why = xi.squad.BAG_RESULT[res]
        if why then
            xi.squad.msqError(player, why)
        else
            xi.squad.msqStatus(player, 'Moved.')
        end
        -- Refresh both affected containers so the addon repaints.
        xi.squad.msqBagItems(player, 'bagmove', sC, sK)
        if dC ~= sC or dK ~= sK then
            xi.squad.msqBagItems(player, 'bagmove', dC, dK)
        end

    elseif verb == 'set' then
        local slot   = tonumber(a[2])
        local charid = tonumber(a[3])
        if not slot or slot < 1 or slot > xi.squad.SLOTS or not charid then
            xi.squad.msqError(player, 'set <slot> <charid>')
            return
        end
        -- setSquadSlot validates account ownership / self server-side; the
        -- roster reply below reflects whatever actually took.
        player:setSquadSlot(slot, charid)
        xi.squad.msqRoster(player, 'set')

    elseif verb == 'clear' then
        local slot = tonumber(a[2])
        if not slot or slot < 1 or slot > xi.squad.SLOTS then
            xi.squad.msqError(player, 'clear <slot>')
            return
        end
        player:setSquadSlot(slot, 0)
        xi.squad.msqRoster(player, 'clear')

    elseif verb == 'engage' then
        local mode = tonumber(a[2])
        if not xi.squad.setEngageMode(player, mode) then
            xi.squad.msqError(player, 'engage <0|1>')
            return
        end
        xi.squad.msqRoster(player, 'engage')

    elseif verb == 'setjob' then
        local charid = tonumber(a[2])
        local mjob   = tonumber(a[3])
        local sjob   = tonumber(a[4]) or 0
        if not charid or not mjob then
            xi.squad.msqError(player, 'setjob <charid> <mjob> [sjob]')
            return
        end
        local res = player:setSquadMemberJob(charid, mjob, sjob)
        local why = xi.squad.JOB_RESULT[res]
        if why then
            if res == 5 then xi.squad.msqStatus(player, why) else xi.squad.msqError(player, why) end
        end
        xi.squad.msqRoster(player, 'setjob')

    elseif verb == 'savejobs' then
        local name = a[2]
        if not name or #name == 0 then
            xi.squad.msqError(player, 'savejobs <name>')
            return
        end
        player:saveSquadJobPreset(name)
        xi.squad.msqStatus(player, 'Saved lineup "' .. name .. '".')
        xi.squad.msqRoster(player, 'savejobs')

    elseif verb == 'usejobs' then
        local name = a[2]
        local entries = name and player:loadSquadJobPreset(name) or {}
        if #entries == 0 then
            xi.squad.msqError(player, 'No lineup called "' .. tostring(name) .. '".')
            xi.squad.msqRoster(player, 'usejobs')
            return
        end
        local applied, deferred = 0, 0
        for _, e in ipairs(entries) do
            local res = player:setSquadMemberJob(e.charid, e.mjob, e.sjob)
            if res == 0 then applied = applied + 1
            elseif res == 5 then applied, deferred = applied + 1, deferred + 1 end
        end
        local msg = string.format('Applied lineup "%s" to %d member(s).', name, applied)
        if deferred > 0 then
            msg = msg .. string.format(' %d re-summon after this fight.', deferred)
        end
        xi.squad.msqStatus(player, msg)
        xi.squad.msqRoster(player, 'usejobs')

    elseif verb == 'deljobs' then
        local name = a[2]
        if not name or #name == 0 then
            xi.squad.msqError(player, 'deljobs <name>')
            return
        end
        player:deleteSquadJobPreset(name)
        xi.squad.msqRoster(player, 'deljobs')

    else
        xi.squad.msqError(player, 'unknown verb: ' .. verb)
    end
end

return commandObj
