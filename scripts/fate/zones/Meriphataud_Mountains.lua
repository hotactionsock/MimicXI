-----------------------------------
-- FATE Zone: Meriphataud Mountains
-- Zone ID: 119
-- Region pool: DERFLAND_ARAGONEU
-- Boss weapon: TBD
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.MERIPHATAUD_MOUNTAINS] =
{
    zoneName    = "Meriphataud_Mountains",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events = {},
}
