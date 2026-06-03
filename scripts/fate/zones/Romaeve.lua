-----------------------------------
-- FATE Zone: Ro'Maeve
-- Zone ID: 122
-- Region pool: LITEILOR
-- Boss weapon: TBD
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.ROMAEVE] =
{
    zoneName    = "Romaeve",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "LITEILOR",

    events = {},
}
