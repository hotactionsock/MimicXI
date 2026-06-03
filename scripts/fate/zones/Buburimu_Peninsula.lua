-----------------------------------
-- FATE Zone: Buburimu Peninsula
-- Zone ID: 118
-- Region pool: DERFLAND_ARAGONEU
-- Boss weapon: Hammerfall Fists (29900, Lv24)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BUBURIMU_PENINSULA] =
{
    zoneName    = "Buburimu_Peninsula",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events = {},
}
