-----------------------------------
-- !mimic <subcommand> [args...]
-- Server-event control command.
-- permission = 4 (senior GM only)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 4,
    parameters = 's',
}

-----------------------------------
-- Helpers
-----------------------------------
local function msg(player, text)
    player:printToPlayer('[Mimic] ' .. text)
end

local function printHelp(player)
    msg(player, 'Subcommands:')
    msg(player, '  bonus on|off            — toggle FATE bonus weekend')
    msg(player, '  bonus status            — show current rates')
    msg(player, '  bonus set exp|drop|cp <multiplier>')
end

-----------------------------------
-- !mimic bonus ...
-----------------------------------
local BONUS_FIELD =
{
    exp  = 'exp',
    drop = 'drop',
    cp   = 'capacity',
}

local function handleBonus(player, args)
    local action = args[2]
    local b      = xi.mimic.bonus

    if action == 'on' then
        b.active = true
        msg(player, string.format(
            'Bonus weekend ACTIVE — EXP x%.1f | Drop x%.1f | CP x%.1f',
            b.exp, b.drop, b.capacity))

    elseif action == 'off' then
        b.active = false
        msg(player, 'Bonus weekend deactivated.')

    elseif action == 'status' then
        local state = b.active and 'ACTIVE' or 'inactive'
        msg(player, string.format(
            '%s | EXP x%.1f | Drop x%.1f | CP x%.1f',
            state, b.exp, b.drop, b.capacity))

    elseif action == 'set' then
        local key   = args[3]
        local val   = tonumber(args[4])
        local field = BONUS_FIELD[key]

        if not field then
            msg(player, 'Unknown key. Valid: exp, drop, cp')
            return
        end
        if not val or val < 1.0 or val > 10.0 then
            msg(player, 'Multiplier must be between 1.0 and 10.0')
            return
        end

        b[field] = val
        msg(player, string.format('%s multiplier set to x%.1f', key, val))

    else
        msg(player, 'Usage: !mimic bonus on|off|status|set <key> <value>')
    end
end

-----------------------------------
-- Subcommand dispatch table
-- Add new subcommands here.
-----------------------------------
local subcommands =
{
    bonus = handleBonus,
}

-----------------------------------
-- Entry point
-----------------------------------
commandObj.onTrigger = function(player, input)
    local args = {}
    for token in string.gmatch(input or '', '%S+') do
        args[#args + 1] = token
    end

    local handler = subcommands[args[1]]
    if handler then
        handler(player, args)
    else
        printHelp(player)
    end
end

return commandObj
