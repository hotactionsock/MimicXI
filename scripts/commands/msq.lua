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
--   !msq iteminfo <itemId>     base stat readout for the Gear tab hover/click
--   !msq itembagaug <charid> <containerId> <slot>   augment readout, one instance
--   !msq itemwhaug <rowid>                          augment readout, one warehouse row
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

    elseif verb == 'iteminfo' then
        local itemId = tonumber(a[2])
        if not itemId then
            xi.squad.msqError(player, 'iteminfo <itemId>')
            return
        end
        xi.squad.msqItemInfo(player, 'iteminfo', itemId)

    elseif verb == 'itembagaug' then
        local charid = tonumber(a[2])
        local cont   = tonumber(a[3])
        local slot   = tonumber(a[4])
        if not charid or not cont or not slot then
            xi.squad.msqError(player, 'itembagaug <charid> <containerId> <slot>')
            return
        end
        xi.squad.msqBagItemAugmentInfo(player, 'itembagaug', charid, cont, slot)

    elseif verb == 'itemwhaug' then
        local rowid = tonumber(a[2])
        if not rowid then
            xi.squad.msqError(player, 'itemwhaug <rowid>')
            return
        end
        xi.squad.msqWarehouseItemAugmentInfo(player, 'itemwhaug', rowid)

    elseif verb == 'gearslotwh' then
        local charid = tonumber(a[2])
        local slot   = tonumber(a[3])
        if not charid or not slot then
            xi.squad.msqError(player, 'gearslotwh <charid> <equipSlot>')
            return
        end
        xi.squad.msqWarehouseGearCandidates(player, 'gearslotwh', charid, slot)

    elseif verb == 'equipwh' then
        local charid = tonumber(a[2])
        local slot   = tonumber(a[3])
        local rowid  = tonumber(a[4])
        if not (charid and slot and rowid) then
            xi.squad.msqError(player, 'equipwh <charid> <equipSlot> <rowid>')
            return
        end
        local res = player:squadEquipFromWarehouse(charid, slot, rowid)
        local why = xi.squad.GEAR_RESULT[res]
        if why then
            if res == 8 then xi.squad.msqStatus(player, why) else xi.squad.msqError(player, why) end
        else
            xi.squad.msqStatus(player, 'Equipped.')
        end
        xi.squad.msqGear(player, 'equipwh', charid)

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

    elseif verb == 'warehouse' then
        local page = tonumber(a[2]) or 0
        xi.squad.msqWarehousePage(player, 'warehouse', page)

    elseif verb == 'bagtowh' then
        local charid, cont, slot = tonumber(a[2]), tonumber(a[3]), tonumber(a[4])
        local qty = tonumber(a[5]) or 0
        if not (charid and cont and slot) then
            xi.squad.msqError(player, 'bagtowh <charid> <containerId> <slot> [qty]')
            return
        end
        local res = player:squadBagMoveToWarehouse(charid, cont, slot, qty)
        local why = xi.squad.WAREHOUSE_BAG_RESULT[res]
        if why then
            xi.squad.msqError(player, why)
        else
            xi.squad.msqStatus(player, 'Stashed.')
        end
        -- Two separate envelopes (distinct verb tags: one is a bag envelope,
        -- the other a warehouse envelope - see msquad.lua's per-verb dispatch).
        xi.squad.msqBagItems(player, 'bagtowh', charid, cont)
        xi.squad.msqWarehousePage(player, 'bagtowh_wh', 0)

    elseif verb == 'bagfromwh' then
        local charid, cont, rowid = tonumber(a[2]), tonumber(a[3]), tonumber(a[4])
        local qty = tonumber(a[5]) or 0
        if not (charid and cont and rowid) then
            xi.squad.msqError(player, 'bagfromwh <charid> <containerId> <rowid> [qty]')
            return
        end
        local res = player:squadBagMoveFromWarehouse(charid, cont, rowid, qty)
        local why = xi.squad.WAREHOUSE_BAG_RESULT[res]
        if why then
            xi.squad.msqError(player, why)
        else
            xi.squad.msqStatus(player, 'Withdrawn.')
        end
        xi.squad.msqBagItems(player, 'bagfromwh', charid, cont)
        xi.squad.msqWarehousePage(player, 'bagfromwh_wh', 0)

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
            xi.squad.msqError(player, why)
        end
        xi.squad.msqRoster(player, 'setjob')

    elseif verb == 'selfjob' then
        local mjob = tonumber(a[2])
        local sjob = tonumber(a[3]) or 0
        if not mjob then
            xi.squad.msqError(player, 'selfjob <mjob> [sjob]')
            return
        end
        local res = xi.squad.selfChangeJob(player, mjob, sjob)
        local why = xi.squad.SELFJOB_RESULT[res]
        if why then
            xi.squad.msqError(player, why)
        else
            xi.squad.msqStatus(player, 'Job changed.')
        end
        xi.squad.msqRoster(player, 'selfjob')

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
        local applied = 0
        for _, e in ipairs(entries) do
            if player:setSquadMemberJob(e.charid, e.mjob, e.sjob) == 0 then
                applied = applied + 1
            end
        end
        xi.squad.msqStatus(player, string.format('Applied lineup "%s" to %d member(s).', name, applied))
        xi.squad.msqRoster(player, 'usejobs')

    elseif verb == 'deljobs' then
        local name = a[2]
        if not name or #name == 0 then
            xi.squad.msqError(player, 'deljobs <name>')
            return
        end
        player:deleteSquadJobPreset(name)
        xi.squad.msqRoster(player, 'deljobs')

    elseif verb == 'gambit' then
        local sub = string.lower(a[2] or '')

        if sub == 'vocab' then
            xi.squad.msqGambitVocab(player, 'gambitvocab')

        elseif sub == 'list' then
            xi.squad.msqGambits(player, 'gambit_list')

        elseif sub == 'new' then
            local name = a[3]
            if not name then
                xi.squad.msqError(player, 'gambit new <name>')
                return
            end
            local res = player:createGambitSet(name)
            local why = xi.squad.GAMBITSET_RESULT[res]
            if why then xi.squad.msqError(player, why) end
            xi.squad.msqGambits(player, 'gambit_new')

        elseif sub == 'del' then
            local name = a[3]
            if not name then
                xi.squad.msqError(player, 'gambit del <name>')
                return
            end
            player:deleteGambitSet(name)
            xi.squad.msqGambits(player, 'gambit_del')

        elseif sub == 'rename' then
            local name, newName = a[3], a[4]
            if not name or not newName then
                xi.squad.msqError(player, 'gambit rename <name> <newname>')
                return
            end
            local res = player:renameGambitSet(name, newName)
            local why = xi.squad.GAMBITSET_RESULT[res]
            if why then xi.squad.msqError(player, why) end
            xi.squad.msqGambits(player, 'gambit_rename')

        elseif sub == 'addraw' then
            local name = a[3]
            local target, cond, arg, reaction, selector, actionid =
                tonumber(a[4]), tonumber(a[5]), tonumber(a[6]), tonumber(a[7]), tonumber(a[8]), tonumber(a[9])
            if not (name and target and cond and arg and reaction and selector and actionid) then
                xi.squad.msqError(player, 'gambit addraw <name> <target> <cond> <arg> <reaction> <selector> <actionid>')
                return
            end
            local ok, why = xi.gambitRules.validateRaw(target, cond, arg, reaction, selector, actionid)
            if not ok then
                xi.squad.msqError(player, why)
            else
                local res = player:addGambitRule(name, target, cond, arg, reaction, selector, actionid)
                local resWhy = xi.squad.GAMBITRULE_ADD_RESULT[res]
                if resWhy then xi.squad.msqError(player, resWhy) end
            end
            xi.squad.msqGambits(player, 'gambit_addraw')

        elseif sub == 'rem' then
            local name, ordinal = a[3], tonumber(a[4])
            if not name or not ordinal then
                xi.squad.msqError(player, 'gambit rem <name> <ordinal>')
                return
            end
            local res = player:removeGambitRule(name, ordinal)
            local why = xi.squad.GAMBITRULE_REMOVE_RESULT[res]
            if why then xi.squad.msqError(player, why) end
            xi.squad.msqGambits(player, 'gambit_rem')

        elseif sub == 'assign' then
            local charid, mjob, name = tonumber(a[3]), tonumber(a[4]), a[5]
            if not charid or not mjob or not name then
                xi.squad.msqError(player, 'gambit assign <charid> <mjob> <name>')
                return
            end
            local res = player:setGambitAssign(charid, mjob, name)
            local why = xi.squad.GAMBITASSIGN_RESULT[res]
            if why then xi.squad.msqError(player, why) end
            xi.squad.msqGambits(player, 'gambit_assign')

        elseif sub == 'tpskill' then
            local name = a[3]
            local trigger, selector, actionid = tonumber(a[4]), tonumber(a[5]), tonumber(a[6])
            if not (name and trigger and selector and actionid ~= nil) then
                xi.squad.msqError(player, 'gambit tpskill <name> <trigger> <selector> <actionid>')
                return
            end
            local ok, why = xi.gambitRules.validateTpSkill(trigger, selector, actionid)
            if not ok then
                xi.squad.msqError(player, why)
            else
                local res = player:setGambitTpSkill(name, trigger, selector, actionid)
                local resWhy = xi.squad.GAMBITSET_UPDATE_RESULT[res]
                if resWhy then xi.squad.msqError(player, resWhy) end
            end
            xi.squad.msqGambits(player, 'gambit_tpskill')

        elseif sub == 'unassign' then
            local charid, mjob = tonumber(a[3]), tonumber(a[4])
            if not charid or not mjob then
                xi.squad.msqError(player, 'gambit unassign <charid> <mjob>')
                return
            end
            player:setGambitAssign(charid, mjob, '')
            xi.squad.msqGambits(player, 'gambit_unassign')

        else
            xi.squad.msqError(player, 'gambit vocab|list|new|del|rename|addraw|rem|assign|unassign|tpskill')
        end

    else
        xi.squad.msqError(player, 'unknown verb: ' .. verb)
    end
end

return commandObj
