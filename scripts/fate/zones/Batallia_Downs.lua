-----------------------------------
-- FATE Zone: Batallia Downs
-- Zone ID: 105
-- Region pool: NORVALLEN_QUFIM
-- Boss weapon: Whitemantle Saber (29856, Lv32)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BATALLIA_DOWNS] =
{
    zoneName    = "Batallia_Downs",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events = {},
}
