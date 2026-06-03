-----------------------------------
-- FATE Zone: Uleguerand Range
-- Zone ID: 5
-- Region pool: SKY_SEA_HIGHEND
-- Boss weapon: Ironhail Cannon (29907, Lv72)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ULEGUERAND_RANGE] =
{
    zoneName    = "Uleguerand_Range",
    spawnChance = 0.30,
    minCooldown = 900,
    region      = "SKY_SEA_HIGHEND",

    events = {},
}
