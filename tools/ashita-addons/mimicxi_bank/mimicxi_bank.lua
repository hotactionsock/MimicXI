--[[
* mimicxi_bank - Ashita v4 addon
*
* Client-side UI for the MimicXI server's account-wide bank (see the server repo's
* CLAUDE.md, "Account Bank System", and src/map/utils/bankutils.h). There is no
* in-world NPC for this feature -- every action is a chat command under the hood
* (!bankdeposit, !bankdepositall, !bankwithdraw, !banklist), and this addon is just
* a convenience front-end that fires those commands from a window instead of the
* command line.
*
* The server also pushes a non-retail packet (opcode 0x1F0, GP_SERV_COMMAND_BANK_LIST)
* after every bank action so this addon can keep its view of the bank's contents in
* sync. The retail client has NO handler for that opcode, so this addon MUST block it
* in its packet_in hook (done below) -- letting it through to the game engine is
* undefined behaviour.
*
* Usage: type /mimicxibank in-game to toggle the window.
*
* NOTE: the exact byte layout parsed in parse_bank_list() below mirrors
* GP_SERV_COMMAND_BANK_LIST::PacketData in the server's
* src/map/packets/s2c/0x1f0_bank_list.h -- if that struct ever changes, update
* PAYLOAD_TRUNCATED_OFFSET / PAYLOAD_ENTRIES_OFFSET / ENTRY_SIZE here to match.
--]]

addon.name    = 'mimicxi_bank';
addon.author  = 'MimicXI';
addon.version = '1.0';
addon.desc    = 'Account-wide bank UI for the MimicXI server.';
addon.link    = '';

require('common');

-- Must match PacketS2C::GP_SERV_COMMAND_BANK_LIST in src/map/enums/packet_s2c.h
local BANK_LIST_PACKET_ID = 0x1F0;

-- Must match GP_SERV_COMMAND_BANK_LIST::MAX_ENTRIES in 0x1f0_bank_list.h
local MAX_ENTRIES = 24;

-- Wire layout (see 0x1f0_bank_list.h):
--   [0..3]   GP_SERV_HEADER (id:9 + size:7, sync:16)
--   [4]      truncated (uint8)
--   [5..7]   padding
--   [8..]    Entry[MAX_ENTRIES], 8 bytes each: itemId(u16) category(u8) pad(u8) quantity(u32)
local HEADER_SIZE               = 4;
local PAYLOAD_TRUNCATED_OFFSET  = HEADER_SIZE;
local PAYLOAD_ENTRIES_OFFSET    = HEADER_SIZE + 4;
local ENTRY_SIZE                = 8;

local categoryNames =
{
    [1] = 'General',
    [2] = 'Usable',
    [3] = 'Currency',
    [4] = 'Other',
};

local bank =
{
    items     = T{},
    truncated = false,
    visible   = { false },
};

-- Per-item scratch input state for the withdraw quantity fields, keyed by item id.
local withdrawQty = T{};

local depositItemId = { 0 };
local depositQty     = { 1 };

local function parse_bank_list(data)
    local ok, truncatedFlag, items = pcall(function ()
        local truncatedByte = struct.unpack('B', data, PAYLOAD_TRUNCATED_OFFSET + 1);
        local parsed         = T{};

        for i = 0, MAX_ENTRIES - 1 do
            local base   = PAYLOAD_ENTRIES_OFFSET + (i * ENTRY_SIZE);
            local itemId = struct.unpack('H', data, base + 1);

            if (itemId ~= nil and itemId > 0) then
                local category = struct.unpack('B', data, base + 3);
                local quantity = struct.unpack('I', data, base + 5);

                parsed:append({ id = itemId, category = category, quantity = quantity, });
            end
        end

        return (truncatedByte == 1), parsed;
    end);

    if (not ok) then
        return T{}, false;
    end

    return items, truncatedFlag;
end

local function queue(cmd)
    AshitaCore:GetChatManager():QueueCommand(cmd, -1);
end

local function refresh()
    queue('!banklist');
end

local function depositAll()
    queue('!bankdepositall');
end

local function deposit(itemId, quantity)
    queue(('!bankdeposit %d %d'):format(itemId, quantity));
end

local function withdraw(itemId, quantity)
    queue(('!bankwithdraw %d %d'):format(itemId, quantity));
end

ashita.events.register('packet_in', 'mimicxi_bank_packet_in', function (e)
    if (e.id == BANK_LIST_PACKET_ID) then
        bank.items, bank.truncated = parse_bank_list(e.data);

        -- The retail client has no handler for this opcode -- never let it through.
        e.blocked = true;
    end
end);

ashita.events.register('command', 'mimicxi_bank_command', function (e)
    local args = e.command:args();
    if (#args == 0 or args[1]:lower() ~= '/mimicxibank') then
        return;
    end

    e.blocked = true;
    bank.visible[1] = not bank.visible[1];

    if (bank.visible[1]) then
        refresh();
    end
end);

ashita.events.register('d3d_present', 'mimicxi_bank_present', function ()
    if (not bank.visible[1]) then
        return;
    end

    imgui.SetNextWindowSize({ 440, 500, }, ImGuiCond_FirstUseEver);
    if (imgui.Begin('MimicXI Bank', bank.visible)) then
        if (imgui.Button('Refresh')) then
            refresh();
        end

        imgui.SameLine();
        if (imgui.Button('Deposit All')) then
            depositAll();
        end

        imgui.Separator();
        imgui.Text('Deposit');
        imgui.PushItemWidth(100);
        imgui.InputInt('Item ID##deposit', depositItemId);
        imgui.SameLine();
        imgui.InputInt('Qty##deposit', depositQty);
        imgui.PopItemWidth();
        imgui.SameLine();
        if (imgui.Button('Deposit##button')) then
            if (depositItemId[1] > 0 and depositQty[1] > 0) then
                deposit(depositItemId[1], depositQty[1]);
            end
        end

        imgui.Separator();

        local header = 'Bank Contents';
        if (bank.truncated) then
            header = header .. ' (truncated -- withdraw some items to see the rest)';
        end
        imgui.Text(header);

        if (imgui.BeginTabBar('mimicxi_bank_tabs')) then
            for catId = 1, 4 do
                if (imgui.BeginTabItem(categoryNames[catId])) then
                    if (imgui.BeginTable('mimicxi_bank_table_' .. catId, 3, ImGuiTableFlags_Borders)) then
                        imgui.TableSetupColumn('Item ID');
                        imgui.TableSetupColumn('Qty');
                        imgui.TableSetupColumn('');
                        imgui.TableHeadersRow();

                        for _, item in ipairs(bank.items) do
                            if (item.category == catId) then
                                imgui.TableNextRow();
                                imgui.TableNextColumn();
                                imgui.Text(tostring(item.id));
                                imgui.TableNextColumn();
                                imgui.Text(tostring(item.quantity));
                                imgui.TableNextColumn();

                                withdrawQty[item.id] = withdrawQty[item.id] or { 1 };
                                imgui.PushItemWidth(60);
                                imgui.InputInt('##qty' .. item.id, withdrawQty[item.id]);
                                imgui.PopItemWidth();
                                imgui.SameLine();
                                if (imgui.Button('Withdraw##' .. item.id)) then
                                    local qty = withdrawQty[item.id][1];
                                    if (qty > 0) then
                                        withdraw(item.id, qty);
                                    end
                                end
                            end
                        end

                        imgui.EndTable();
                    end

                    imgui.EndTabItem();
                end
            end

            imgui.EndTabBar();
        end
    end
    imgui.End();
end);
