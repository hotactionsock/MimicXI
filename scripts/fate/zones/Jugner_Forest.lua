-----------------------------------
-- FATE Zone: Jugner Forest
-- Zone ID: 104
-- Region pool: NORVALLEN_QUFIM
-- Boss weapon: Duskfang Tachi (29882, Lv30)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.JUGNER_FOREST] =
{
    zoneName    = "Jugner_Forest",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events = {},
}
