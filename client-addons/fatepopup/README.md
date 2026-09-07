# FatePopup — handoff plan

This folder is a starting point for an Ashita v4 addon that pops a banner
image (with sound, for completion and failure) on screen for MimicXI FATE
milestones. It was built remotely (no local Ashita install to test against),
so it needs a verification pass on the real client before it's usable. This
doc is written for whoever (Claude or otherwise) picks this up on the local
machine.

## What already works (server side, already committed on this branch)

`scripts/globals/fate.lua` sends hidden markers over `SYSTEM_3` chat at three
points:

```
FJOIN|<eventID>       -- xi.fate.announceJoin(), on successful xi.fate.register()
FCOMPLETE|<eventID>   -- xi.fate.announceComplete(), on victory, registered participants only
FFAIL|<eventID>       -- xi.fate.announceFailure(), on failure, registered participants only
```

`<eventID>` is the event def's string `id` field (e.g. `VD_LIZARD_01`).
`FCOMPLETE`/`FFAIL` both fire from inside `xi.fate.resolve()`, once per
participant, on the matching outcome. Nothing else needs to change
server-side for these three banners to work; plain readable messages are
still sent on the same channel for players without the addon.

## What's in this folder

- `fatepopup.lua` — addon: listens for any known marker prefix, blocks it
  from chat, and renders the matching banner with a fade-in/hold/fade-out.
  `FCOMPLETE` and `FFAIL` additionally play a sound. The popup types (image +
  optional sound per marker) are defined in the `POPUP_TYPES` table near the
  top.
- `resources/fate_joined.png` — join banner art (1280x360, provided by the user).
- `resources/fate_complete.png` — completion banner art (1280x360, provided by the user).
- `resources/fate_failed.png` — failure banner art (1280x360, provided by the user).
- `resources/level_up.wav`, `resources/fate_failed.wav` — **not included**.
  You need to supply both yourself (short clips — the game's own level-up
  jingle for completion, something suitably negative for failure, or
  placeholders) — audio assets aren't something this repo can source or
  ship. `fatepopup.lua` no-ops the sound if a file isn't there; the banner
  itself doesn't depend on it.

## What needs verifying before this works

The addon is written to standard Ashita v4 idioms, but three pieces are
version/build-sensitive and marked `VERIFY #1` / `#2` / `#3` in the code:

1. **Chat interception.** The `text_in` event and its `e.message` /
   `e.blocked` fields are the common Ashita v4 shape, but MimicXI's own
   FATETracker addon (referenced in `fate.lua`'s comments, already installed
   and working against this exact client) already does this exact trick for
   its `FSYNC|` marker. **Find that addon locally and copy its chat-hook code
   verbatim** instead of trusting the version in `fatepopup.lua` if anything
   differs — it's guaranteed compatible with this environment; my version is
   a best-effort guess.

2. **Texture loading.** `fatepopup.lua` loads each PNG via
   `D3DXCreateTextureFromFileA` through `ffi.load('d3dx8')`, the standard way
   Ashita v4 addons load images on FFXI's D3D8 renderer. If this errors on
   load (check `/addon` console output), find another locally installed
   addon that displays a custom image and copy its texture-loading call
   instead.

3. **Sound playback.** Plays `resources/level_up.wav` (on completion) or
   `resources/fate_failed.wav` (on failure) via the raw Windows
   `winmm.PlaySoundA` API (`ffi.load('winmm')`), which is independent of
   Ashita's own API surface and should be reliable, but is untested here.
   If it doesn't fire, check that the .wav path resolves and is a plain PCM
   `.wav` (PlaySoundA doesn't handle every codec) — as a fallback, look for
   an `ashita.misc.play_sound`-style helper on this Ashita build and swap it
   in instead.

Everything else (event registration pattern, the fade-in/hold/fade-out alpha
math, the imgui window setup, the per-type texture cache) is standard and
should need no changes beyond cosmetic tuning.

## Install & test steps

1. Copy this whole `fatepopup` folder into `<Ashita4 install>/addons/`.
2. Drop your own `level_up.wav` and `fate_failed.wav` into `fatepopup/resources/`.
3. `/addon load fatepopup` in-game (or add `fatepopup` to your
   `scripts/default.txt` autoload list once it's confirmed working).
4. Trigger a FATE join in-game (talk to a FATE herald NPC and register) and
   confirm:
   - The join banner renders once, centered, with a visible fade in/out.
   - The raw `FJOIN|<eventID>` line does **not** appear in your chat log
     (confirms the block is working — if you see it in chat, `VERIFY #1`
     needs fixing).
   - No console errors on `/addon load` (confirms `VERIFY #2` is fine).
5. Finish that same FATE in victory and confirm:
   - The completion banner renders (different art from the join banner).
   - `level_up.wav` plays alongside it (confirms `VERIFY #3`).
   - The raw `FCOMPLETE|<eventID>` line does not appear in chat.
6. Let a FATE time out or wipe and confirm:
   - The failure banner renders (different art again).
   - `fate_failed.wav` plays alongside it.
   - The raw `FFAIL|<eventID>` line does not appear in chat.
7. Tune to taste in `fatepopup.lua`'s `settings` table:
   - `scale` — displayed size relative to the native 1280x360 art (shared by
     all three banners).
   - `top_pct` — vertical position as a fraction of screen height.
   - `fade_in` / `hold` / `fade_out` — timing in seconds (shared by all three).
8. The `screen_w`/`screen_h` values used to center the banner are hardcoded
   placeholders — pull the real back-buffer size from the d3d8 device's
   presentation parameters if you run at a non-standard resolution or want
   the banner to reposition correctly on resize.

## Possible follow-ups (not built yet)

- Overlay the FATE's actual name/difficulty as text on top of the banner
  (the marker already carries `eventID`, so the addon has enough info to
  look up a display name from a local table if you want that).
- Per-type timing/position overrides if the three banners should behave
  differently (currently all share the same `settings` table).
