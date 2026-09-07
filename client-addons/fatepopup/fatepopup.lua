--[[
* FatePopup - Ashita v4 addon
*
* Renders a custom banner image when the player joins a MimicXI FATE.
*
* Wire protocol (server side): scripts/globals/fate.lua -> xi.fate.announceJoin()
* sends a hidden line over SYSTEM_3 chat immediately after a successful
* xi.fate.register() call:
*
*     FJOIN|<eventID>
*
* This addon watches incoming chat text, blocks that exact line so it never
* reaches the player's chat log, and instead pops the bundled banner image
* on screen with a short fade-in / hold / fade-out.
*
* CONFIDENCE NOTE FOR WHOEVER FINISHES THIS LOCALLY:
* The event registration pattern and fade timing math below are standard
* Ashita v4 idioms and should work as-is. The two blocks marked "VERIFY"
* depend on the exact Ashita build/version installed locally:
*
*   1. Chat interception (VERIFY #1) - the event name/field names for
*      intercepting + blocking an incoming chat line. MimicXI's server
*      already relies on this exact trick for its FSYNC marker, consumed by
*      the existing FATETracker addon (see scripts/globals/fate.lua, search
*      "FSYNC"). That addon is already proven to work against this exact
*      client/Ashita build - copy its chat-hook code verbatim in preference
*      to the version below if it differs.
*
*   2. Texture loading (VERIFY #2) - the FFI signature for
*      D3DXCreateTextureFromFileA (or whatever the local Ashita build
*      exposes for loading a texture from a PNG on disk). Check any other
*      installed addon that renders a custom image (screenshots, HUD
*      overlays, etc.) for the exact working call and swap it in here.
--]]

addon.name    = 'fatepopup';
addon.author  = 'MimicXI';
addon.version = '1.0';
addon.desc    = 'Displays a banner when the player joins a MimicXI FATE.';
addon.link    = '';

require('common');
local ffi = require('ffi');
local d3d = require('d3d8');
local C   = ffi.C;

local d3d8dev = d3d.get_device();

-- Must match the prefix sent by xi.fate.announceJoin() in fate.lua.
local MARKER_PREFIX = 'FJOIN|';

-- Path to the bundled banner image (client-addons/fatepopup/resources/fate_joined.png).
local IMAGE_PATH = string.format('%s\\resources\\fate_joined.png', addon.path);

-- Native resolution of the bundled PNG - used to keep aspect ratio when scaling.
local IMAGE_NATIVE_W = 1280;
local IMAGE_NATIVE_H = 360;

local settings =
{
    scale    = 0.45,  -- displayed size = native size * scale
    top_pct  = 0.20,  -- vertical position as a fraction of screen height
    fade_in  = 0.25,  -- seconds
    hold     = 2.25,  -- seconds
    fade_out = 0.60,  -- seconds
};

local banner =
{
    texture  = nil,
    visible  = false,
    shown_at = 0,
};

---------------------------------------------------------------------------
-- VERIFY #2: texture loading.
-- This is the common Ashita v4 pattern (FFXI runs on Direct3D8, so textures
-- are loaded via d3dx8's D3DXCreateTextureFromFileA). If this errors on
-- load, find a working example in another installed addon that displays a
-- custom image and copy its loader instead.
---------------------------------------------------------------------------
local d3dx8 = ffi.load('d3dx8');

ffi.cdef[[
    typedef struct IDirect3DTexture8 IDirect3DTexture8;
    int32_t __stdcall D3DXCreateTextureFromFileA(void* pDevice, const char* pSrcFile, IDirect3DTexture8** ppTexture);
]];

local function ensure_texture()
    if (banner.texture ~= nil) then
        return true;
    end

    local texture_ptr = ffi.new('IDirect3DTexture8*[1]');
    local hr = d3dx8.D3DXCreateTextureFromFileA(d3d8dev, IMAGE_PATH, texture_ptr);
    if (hr ~= 0) then
        print(chat.header(addon.name):append(chat.error(string.format('Failed to load %s (hr: 0x%08X)', IMAGE_PATH, hr))));
        return false;
    end

    banner.texture = texture_ptr[0];
    return true;
end

local function show_banner()
    if (not ensure_texture()) then
        return;
    end
    banner.visible  = true;
    banner.shown_at = os.clock();
end

---------------------------------------------------------------------------
-- VERIFY #1: chat interception.
-- Prefer copying this block from the existing FATETracker addon's handling
-- of its FSYNC marker if the event/field names differ on this build.
---------------------------------------------------------------------------
ashita.events.register('text_in', 'fatepopup_text_in', function (e)
    local start_idx = e.message:find(MARKER_PREFIX, 1, true);
    if (start_idx == nil) then
        return;
    end

    -- Swallow the raw marker line so it never reaches the chat log.
    e.blocked = true;

    local event_id = e.message:sub(start_idx + #MARKER_PREFIX):gsub('%s+$', '');
    show_banner(event_id);
end);

---------------------------------------------------------------------------
-- Render loop - fade in, hold, fade out. High confidence, should work as-is
-- once the texture pointer + imgui binding names above are confirmed.
---------------------------------------------------------------------------
ashita.events.register('d3d_present', 'fatepopup_present', function ()
    if (not banner.visible) then
        return;
    end

    local elapsed = os.clock() - banner.shown_at;
    local total   = settings.fade_in + settings.hold + settings.fade_out;
    if (elapsed >= total) then
        banner.visible = false;
        return;
    end

    local alpha = 1.0;
    if (elapsed < settings.fade_in) then
        alpha = elapsed / settings.fade_in;
    elseif (elapsed > settings.fade_in + settings.hold) then
        alpha = 1.0 - ((elapsed - settings.fade_in - settings.hold) / settings.fade_out);
    end

    local draw_w = IMAGE_NATIVE_W * settings.scale;
    local draw_h = IMAGE_NATIVE_H * settings.scale;

    -- TODO: pull the real viewport size from the d3d8 device's presentation
    -- parameters instead of hardcoding 1280x720; screen_w is only used to
    -- center the banner horizontally.
    local screen_w = 1280;
    local pos_x    = (screen_w - draw_w) / 2;
    local pos_y    = 720 * settings.top_pct;

    imgui.SetNextWindowPos({ pos_x, pos_y });
    imgui.SetNextWindowSize({ draw_w, draw_h });
    imgui.PushStyleColor(ImGuiCol_WindowBg, { 0, 0, 0, 0 });
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });

    local flags = bit.bor(
        ImGuiWindowFlags_NoDecoration,
        ImGuiWindowFlags_NoInputs,
        ImGuiWindowFlags_NoBackground,
        ImGuiWindowFlags_NoFocusOnAppearing,
        ImGuiWindowFlags_NoBringToFrontOnFocus,
        ImGuiWindowFlags_NoSavedSettings
    );

    if (imgui.Begin('FatePopup##fatejoined', true, flags)) then
        imgui.Image(tostring(banner.texture), { draw_w, draw_h }, { 0, 0 }, { 1, 1 }, { 1, 1, 1, alpha });
    end
    imgui.End();

    imgui.PopStyleVar(1);
    imgui.PopStyleColor(1);
end);

ashita.events.register('unload', 'fatepopup_unload', function ()
    if (banner.texture ~= nil) then
        d3d.gc_safe_release(banner.texture);
        banner.texture = nil;
    end
end);
