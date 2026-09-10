-----------------------------------
-- !warehouse <subcommand> [args...]
-- Your account-wide unlimited item stash. The mwarehouse addon is the real UI;
-- these typed verbs are the fallback.
--
--   !warehouse info                 -- generation / rows used / cap
--   !warehouse list [page]          -- list a page of rows (rowid item xqty)
--   !warehouse put <slot> [qty]     -- deposit an inventory slot
--   !warehouse take <rowid> [qty]   -- withdraw a row to your inventory
--   !warehouse trash <rowid>        -- discard a row
--   !warehouse stashall             -- dump your whole inventory into the stash
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

local function msg(player, text)
    player:printToPlayer('[Warehouse] ' .. text)
end

local function tokenize(input)
    local t = {}
    for token in string.gmatch(input or '', '%S+') do
        t[#t + 1] = token
    end
    return t
end

local dispatch =
{
    info = function(player)
        local i = player:warehouseInfo()
        msg(player, string.format('gen %d - %d / %d rows used - %d page(s)',
            i.generation or 0, i.used or 0, i.cap or 0, i.pages or 1))
    end,

    list = function(player, a)
        local page = tonumber(a[2]) or 0
        local rows = player:warehousePage(page)
        msg(player, string.format('Page %d: %d row(s)', page, #rows))
        for _, r in ipairs(rows) do
            msg(player, string.format('  #%d: item %d x%d%s', r.rowid, r.itemId, r.quantity, r.aug and ' (aug)' or ''))
        end
    end,

    put = function(player, a)
        local slot = tonumber(a[2])
        local qty  = tonumber(a[3]) or 0
        if not slot then
            msg(player, 'Usage: !warehouse put <inventory slot> [qty]')
            return
        end
        local item = player:getStorageItem(0, slot, 255)
        local id   = item and item:getID() or 0
        local code = player:warehousePut(0, slot, id, qty)
        msg(player, xi.warehouse.RESULT[code] or 'Stored.')
    end,

    take = function(player, a)
        local rowid = tonumber(a[2])
        local qty   = tonumber(a[3]) or 0
        if not rowid then
            msg(player, 'Usage: !warehouse take <rowid> [qty]')
            return
        end
        msg(player, xi.warehouse.RESULT[player:warehouseTake(rowid, qty)] or 'Withdrawn.')
    end,

    trash = function(player, a)
        local rowid = tonumber(a[2])
        if not rowid then
            msg(player, 'Usage: !warehouse trash <rowid>')
            return
        end
        msg(player, xi.warehouse.RESULT[player:warehouseTrash(rowid)] or 'Discarded.')
    end,

    stashall = function(player)
        local res = player:warehouseStashAll(0)
        msg(player, string.format('Deposited %d item(s).', res.deposited or 0))
    end,
}

commandObj.onTrigger = function(player, input)
    local a = tokenize(input)
    local verb = string.lower(a[1] or 'info')
    local handler = dispatch[verb]

    if handler then
        handler(player, a)
    else
        msg(player, 'Subcommands: info | list [page] | put <slot> [qty] | take <rowid> [qty] | trash <rowid> | stashall')
    end
end

return commandObj
