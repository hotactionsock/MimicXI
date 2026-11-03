# Zone maps for the live view

Drop map images here to show them under the live radar (`watch.html`):

- `<zoneid>.png` for a zone with one map, e.g. `103.png` (Valkurm Dunes)
- `<zoneid>_<n>.png` for zones with several maps (floors), e.g. `141_0.png`, `141_1.png`

`.jpg` and `.webp` work too. The images are not committed to git (see
`.gitignore`) - they come from a map pack you're allowed to use, e.g.
[Remapster](https://www.remapster.com/) (check its terms, and keep the credit:
`credit` in `calibration.json` is shown on the live view).

**Quickest:** run `python3 tools/fetch_zone_maps.py` on the web server. It
downloads the Remapster maps from the AscensionXI wiki (used with the
AscensionXI team's permission) and calibrates each one automatically from the
NPC markers on their zone pages. Any map without enough markers is downloaded
but listed for calibrating by hand. Calibrations you make by hand are never
overwritten (unless you pass `--overwrite`).

Otherwise, line each image up with the game's coordinates on `mapcal.html` (signed
in as an admin account): click three or more spots on the map and enter their
in-game positions (`!where` shows yours in game), or use the spawn points it
offers. That writes `calibration.json`:

    pixel_x = ax * world_x + bx        pixel_y = az * world_z + bz

`ymin` / `ymax` (world height) let the live view pick the right floor.
