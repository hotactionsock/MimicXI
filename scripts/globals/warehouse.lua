-----------------------------------
-- xi.warehouse  -  account-wide unlimited item stash (the mwarehouse addon)
--
-- The human command (!warehouse) and the addon command (!mwh) both sit on top
-- of this. The addon protocol is a stream of pipe-delimited records, each line
-- prefixed "MWH|" and sent on SYSTEM_3; the mwarehouse addon matches the prefix,
-- parses and blocks them (same shape msquad uses for MSQ|). Bump PROTOCOL for
-- any breaking change.
--
--   MWH|d|<protocol>|<verb>                envelope open
--   MWH|k|<gen>|<used>|<cap>|<pageSize>|<pages>   account meta (every envelope)
--   MWH|w|<rowid>|<itemId>|<qty>|<aug>     one stored row (aug: 1 = augmented)
--   MWH|r|<rowid>                          one removed row (delta)
--   MWH|m|<text>  /  MWH|e|<text>          status / error prose
--   MWH|z|<verb>                           envelope close
--
-- A write verb (put / take / trash / stashall) answers with an envelope whose
-- k| carries the new generation; the addon repages on any generation it did not
-- already have.
-----------------------------------
xi           = xi           or {}
xi.warehouse = xi.warehouse or {}

xi.warehouse.PROTOCOL = 1

local function rec(player, line)
    player:printToPlayer('MWH|' .. line, xi.msg.channel.SYSTEM_3)
end

local function meta(player)
    local info = player:warehouseInfo()
    rec(player, string.format('k|%d|%d|%d|%d|%d',
        info.generation or 0, info.used or 0, info.cap or 0, info.pageSize or 40, info.pages or 1))
end

xi.warehouse.status = function(player, text)
    rec(player, 'm|' .. tostring(text))
end

xi.warehouse.error = function(player, text)
    rec(player, 'e|' .. tostring(text))
end

-- Envelope carrying only the account meta (the addon then walks the pages).
xi.warehouse.emitInfo = function(player, verb)
    rec(player, string.format('d|%d|%s', xi.warehouse.PROTOCOL, verb))
    meta(player)
    rec(player, 'z|' .. verb)
end

-- One page of rows.
xi.warehouse.emitPage = function(player, verb, page)
    rec(player, string.format('d|%d|%s', xi.warehouse.PROTOCOL, verb))
    meta(player)
    for _, row in ipairs(player:warehousePage(page)) do
        rec(player, string.format('w|%d|%d|%d|%d', row.rowid, row.itemId, row.quantity, row.aug and 1 or 0))
    end
    rec(player, string.format('z|%s|%d', verb, page))
end

-- Result-code -> prose for a warehouse write.
xi.warehouse.RESULT =
{
    [0] = nil,
    [1] = 'That item is no longer in that slot.',
    [2] = 'The warehouse is full.',
    [3] = 'No such warehouse row.',
    [4] = 'Your inventory is full.',
    [5] = 'The transfer failed - nothing was changed.',
    [6] = 'Bad quantity (or the item does not stack).',
}

-- Answer a write: prose + fresh meta so the addon repages.
xi.warehouse.emitWriteResult = function(player, verb, code, okText)
    rec(player, string.format('d|%d|%s', xi.warehouse.PROTOCOL, verb))
    local why = xi.warehouse.RESULT[code]
    if why then
        rec(player, 'e|' .. why)
    elseif okText then
        rec(player, 'm|' .. okText)
    end
    meta(player)
    rec(player, 'z|' .. verb)
end
