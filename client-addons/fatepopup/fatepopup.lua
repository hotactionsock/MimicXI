--[[
* FatePopup - Ashita v4 addon
*
* Renders a custom banner image (and optionally plays a sound) when a
* MimicXI FATE hits certain milestones for the player.
*
* Wire protocol (server side): scripts/globals/fate.lua sends hidden lines
* over SYSTEM_3 chat:
*
*     FJOIN|<eventID>       - xi.fate.announceJoin(), on successful registration
*     FCOMPLETE|<eventID>   - xi.fate.announceComplete(), on victory (participants only)
*     FFAIL|<eventID>       - xi.fate.announceFailure(), on failure (participants only)
*
* This addon watches incoming chat text, blocks any line starting with a
* known marker prefix so it never reaches the player's chat log, and pops
* the matching banner image on screen with a short fade-in / hold / fade-out,
* optionally playing a bundled sound alongside it.
*
* CONFIDENCE NOTE FOR WHOEVER FINISHES THIS LOCALLY:
* The event registration pattern and fade timing math below are standard
* Ashita v4 idioms and should work as-is. Three blocks are marked "VERIFY"
* because they depend on the exact Ashita build/version and on files that
* aren't in this repo:
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
*      installed addon that renders a custom image for the exact working
*      call and swap it in here if this one errors.
*
*   3. Sound playback (VERIFY #3) - plays resources/level_up.wav (on
*      completion) or resources/fate_failed.wav (on failure) via the
*      standard Windows winmm PlaySoundA API, which is independent of
*      Ashita's own API surface and should be reliable, but has not been
*      tested here. You must supply both .wav files yourself - audio assets
*      aren't something that can be extracted/shipped from this repo.
--]]

addon.name    = 'fatepopup';
addon.author  = 'MimicXI';
addon.version = '1.1';
addon.desc    = 'Displays a banner (and sound, for completion) on MimicXI FATE milestones.';
addon.link    = '';

require('common');
local ffi = require('ffi');
local d3d = require('d3d8');

local d3d8dev = d3d.get_device();

-- Native resolution of the bundled banner art - both images share this size.
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

-- One entry per marker prefix the server can send.
local POPUP_TYPES =
{
    FJOIN =
    {
        image_path = string.format('%s\\resources\\fate_joined.png', addon.path),
        sound_path = nil,
    },
    FCOMPLETE =
    {
        image_path = string.format('%s\\resources\\fate_complete.png', addon.path),
        sound_path = string.format('%s\\resources\\level_up.wav', addon.path),
    },
    FFAIL =
    {
        image_path = string.format('%s\\resources\\fate_failed.png', addon.path),
        sound_path = string.format('%s\\resources\\fate_failed.wav', addon.path),
    },
};

local banner =
{
    active_type = nil,
    visible     = false,
    shown_at    = 0,
};

-- Loaded textures, keyed by popup type name. Loaded lazily on first use so
-- addon load never fails just because one banner's art is missing.
local textures = {};

---------------------------------------------------------------------------
-- VERIFY #2: texture loading.
-- Standard Ashita v4 pattern for FFXI's Direct3D8 renderer. If this errors
-- on load, find a working example in another installed addon that displays
-- a custom image and copy its loader instead.
---------------------------------------------------------------------------
local d3dx8 = ffi.load('d3dx8');

ffi.cdef[[
    typedef struct IDirect3DTexture8 IDirect3DTexture8;
    int32_t __stdcall D3DXCreateTextureFromFileA(void* pDevice, const char* pSrcFile, IDirect3DTexture8** ppTexture);
]];

local function load_texture(path)
    local texture_ptr = ffi.new('IDirect3DTexture8*[1]');
    local hr = d3dx8.D3DXCreateTextureFromFileA(d3d8dev, path, texture_ptr);
    if (hr ~= 0) then
        print(chat.header(addon.name):append(chat.error(string.format('Failed to load %s (hr: 0x%08X)', path, hr))));
        return nil;
    end
    return texture_ptr[0];
end

local function ensure_texture(popup_type)
    if (textures[popup_type] ~= nil) then
        return textures[popup_type];
    end

    local def = POPUP_TYPES[popup_type];
    if (def == nil) then
        return nil;
    end

    local tex = load_texture(def.image_path);
    textures[popup_type] = tex;
    return tex;
end

---------------------------------------------------------------------------
-- VERIFY #3: sound playback via winmm. Independent of Ashita's own API, so
-- this should be reliable across versions, but is untested in this repo.
---------------------------------------------------------------------------
local winmm = ffi.load('winmm');

ffi.cdef[[
    int PlaySoundA(const char* pszSound, void* hmod, unsigned int fdwSound);
]];

local SND_FILENAME  = 0x00020000;
local SND_ASYNC     = 0x00000001;
local SND_NODEFAULT = 0x00000002;

local function play_sound(path)
    if (path == nil) then
        return;
    end
    winmm.PlaySoundA(path, nil, bit.bor(SND_FILENAME, SND_ASYNC, SND_NODEFAULT));
end

---------------------------------------------------------------------------
-- Shared popup trigger, called from the chat hook below.
---------------------------------------------------------------------------
local function show_popup(popup_type)
    local def = POPUP_TYPES[popup_type];
    if (def == nil) then
        return;
    end

    if (ensure_texture(popup_type) == nil) then
        return;
    end

    banner.active_type = popup_type;
    banner.visible      = true;
    banner.shown_at      = os.clock();

    play_sound(def.sound_path);
end

---------------------------------------------------------------------------
-- VERIFY #1: chat interception.
-- Prefer copying this block from the existing FATETracker addon's handling
-- of its FSYNC marker if the event/field names differ on this build.
---------------------------------------------------------------------------
ashita.events.register('text_in', 'fatepopup_text_in', function (e)
    for popup_type in pairs(POPUP_TYPES) do
        local prefix = popup_type .. '|';
        if (e.message:find(prefix, 1, true) ~= nil) then
            e.blocked = true;
            show_popup(popup_type);
            return;
        end
    end
end);

---------------------------------------------------------------------------
-- Render loop - fade in, hold, fade out. High confidence, should work as-is
-- once the texture pointer + imgui binding names above are confirmed.
---------------------------------------------------------------------------
ashita.events.register('d3d_present', 'fatepopup_present', function ()
    if (not banner.visible) then
        return;
    end

    local tex = textures[banner.active_type];
    if (tex == nil) then
        banner.visible = false;
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
    -- parameters instead of hardcoding 1280x720; screen_w/h are only used
    -- to center the banner.
    local screen_w = 1280;
    local screen_h = 720;
    local pos_x    = (screen_w - draw_w) / 2;
    local pos_y    = screen_h * settings.top_pct;

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

    if (imgui.Begin('FatePopup##fatepopup', true, flags)) then
        imgui.Image(tostring(tex), { draw_w, draw_h }, { 0, 0 }, { 1, 1 }, { 1, 1, 1, alpha });
    end
    imgui.End();

    imgui.PopStyleVar(1);
    imgui.PopStyleColor(1);
end);

ashita.events.register('unload', 'fatepopup_unload', function ()
    for popup_type, tex in pairs(textures) do
        if (tex ~= nil) then
            d3d.gc_safe_release(tex);
        end
        textures[popup_type] = nil;
    end
end);
