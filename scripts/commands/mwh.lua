-----------------------------------
-- !mwh <verb> [args...]
-- Machine-facing warehouse command for the mwarehouse Ashita addon. Every reply
-- is a stream of "MWH|" records (see scripts/globals/warehouse.lua). Humans use
-- !warehouse; the addon uses this.
--
--   !mwh info
--   !mwh page <n>
--   !mwh put <container> <slot> <itemId> [qty]
--   !mwh take <rowid> [qty]
--   !mwh trash <rowid>
--   !mwh stashall <container>
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

    local verb = string.lower(a[1] or 'info')

    if verb == 'info' then
        xi.warehouse.emitInfo(player, 'info')

    elseif verb == 'page' then
        local n = tonumber(a[2])
        if not n or n < 0 then
            xi.warehouse.error(player, 'page <n>')
            return
        end
        xi.warehouse.emitPage(player, 'page', n)

    elseif verb == 'put' then
        local cont   = tonumber(a[2])
        local slot   = tonumber(a[3])
        local itemId = tonumber(a[4])
        local qty    = tonumber(a[5]) or 0
        if not (cont and slot and itemId) then
            xi.warehouse.error(player, 'put <container> <slot> <itemId> [qty]')
            return
        end
        local code = player:warehousePut(cont, slot, itemId, qty)
        xi.warehouse.emitWriteResult(player, 'put', code, 'Stored.')

    elseif verb == 'take' then
        local rowid = tonumber(a[2])
        local qty   = tonumber(a[3]) or 0
        if not rowid then
            xi.warehouse.error(player, 'take <rowid> [qty]')
            return
        end
        local code = player:warehouseTake(rowid, qty)
        xi.warehouse.emitWriteResult(player, 'take', code, 'Withdrawn.')

    elseif verb == 'trash' then
        local rowid = tonumber(a[2])
        if not rowid then
            xi.warehouse.error(player, 'trash <rowid>')
            return
        end
        local code = player:warehouseTrash(rowid)
        xi.warehouse.emitWriteResult(player, 'trash', code, 'Discarded.')

    elseif verb == 'stashall' then
        local cont = tonumber(a[2])
        if not cont then
            xi.warehouse.error(player, 'stashall <container>')
            return
        end
        local res = player:warehouseStashAll(cont)
        xi.warehouse.emitWriteResult(player, 'stashall', 0,
            string.format('Deposited %d item(s).', res.deposited or 0))

    else
        xi.warehouse.error(player, 'unknown verb: ' .. verb)
    end
end

return commandObj
