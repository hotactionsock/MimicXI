# FatePopup — handoff plan

This folder is a starting point for an Ashita v4 addon that pops the
`fate_joined.png` banner on screen when a player joins a MimicXI FATE. It was
built remotely (no local Ashita install to test against), so it needs a
verification pass on the real client before it's usable. This doc is written
for whoever (Claude or otherwise) picks this up on the local machine.

## What already works (server side, already committed on this branch)

`scripts/globals/fate.lua` now sends a hidden marker over `SYSTEM_3` chat the
moment a player's `xi.fate.register()` call succeeds:

```
FJOIN|<eventID>
```

`<eventID>` is the event def's string `id` field (e.g. `VD_LIZARD_01`). This
fires once per player per FATE join — see `xi.fate.announceJoin()` right
above `xi.fate.register()` in that file. Nothing else needs to change
server-side for the basic banner to work; the plain `[FATE] You have joined
...` message is sent on the same channel for players without the addon.

## What's in this folder

- `fatepopup.lua` — addon skeleton: listens for `FJOIN|`, blocks it from
  chat, and renders `resources/fate_joined.png` with a fade-in/hold/fade-out.
- `resources/fate_joined.png` — the banner art (1280x360, provided by the user).

## What needs verifying before this works

The addon is written to standard Ashita v4 idioms, but two pieces are
version/build-sensitive and marked `VERIFY #1` / `VERIFY #2` in the code:

1. **Chat interception.** The `text_in` event and its `e.message` /
   `e.blocked` fields are the common Ashita v4 shape, but MimicXI's own
   FATETracker addon (referenced in `fate.lua`'s comments, already installed
   and working against this exact client) already does this exact trick for
   its `FSYNC|` marker. **Find that addon locally and copy its chat-hook code
   verbatim** instead of trusting the version in `fatepopup.lua` if anything
   differs — it's guaranteed compatible with this environment; my version is
   a best-effort guess.

2. **Texture loading.** `fatepopup.lua` loads the PNG via
   `D3DXCreateTextureFromFileA` through `ffi.load('d3dx8')`, which is the
   standard way Ashita v4 addons load images on FFXI's D3D8 renderer. If
   this addon errors on load (check `/addon` console output), find another
   locally installed addon that displays a custom image (screenshot tools,
   HUD overlays, etc.) and copy its texture-loading call instead.

Everything else (event registration pattern, the fade-in/hold/fade-out
alpha math, the imgui window setup) is standard and should need no changes
beyond cosmetic tuning.

## Install & test steps

1. Copy this whole `fatepopup` folder into `<Ashita4 install>/addons/`.
2. `/addon load fatepopup` in-game (or add `fatepopup` to your `scripts/default.txt`
   autoload list once it's confirmed working).
3. Trigger a FATE join in-game (talk to a FATE herald NPC and register).
4. Confirm:
   - The banner renders once, centered, with a visible fade in/out.
   - The raw `FJOIN|<eventID>` line does **not** appear in your chat log
     (confirms the block is working — if you see it in chat, `VERIFY #1`
     needs fixing).
   - No console errors on `/addon load` (confirms `VERIFY #2` is fine).
5. Tune to taste in `fatepopup.lua`'s `settings` table:
   - `scale` — displayed size relative to the native 1280x360 art.
   - `top_pct` — vertical position as a fraction of screen height.
   - `fade_in` / `hold` / `fade_out` — timing in seconds.
6. The `screen_w`/`720` values used to center the banner are hardcoded
   placeholders — pull the real back-buffer size from the d3d8 device's
   presentation parameters if you run at a non-standard resolution or want
   the banner to reposition correctly on resize.

## Possible follow-ups (not built yet)

- Overlay the FATE's actual name/difficulty as text on top of the banner
  (the marker already carries `eventID`, so the addon has enough info to
  look up a display name from a local table if you want that).
- Extend the same marker pattern for other moments (FATE victory/failure,
  boss pre-announce) if you like how this one feels in-game.
