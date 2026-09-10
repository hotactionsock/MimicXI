-----------------------------------
-- !msq <verb> [args...]
-- Machine-facing squad command for the msquad Ashita addon. Every reply is a
-- stream of "_MSQDATA" records (see scripts/globals/squad.lua). Humans use
-- !squad; the addon uses this.
--
--   !msq who
--   !msq set <slot> <charid>
--   !msq clear <slot>
--   !msq engage <0|1>
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

    else
        xi.squad.msqError(player, 'unknown verb: ' .. verb)
    end
end

return commandObj
