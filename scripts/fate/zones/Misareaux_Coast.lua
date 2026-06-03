-----------------------------------
-- FATE Zone: Misareaux Coast
-- Zone ID: 25
-- Region pool: LUFAISE_MISAREAUX
-- Boss weapon: TBD
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.MISAREAUX_COAST] =
{
    zoneName    = "Misareaux_Coast",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "LUFAISE_MISAREAUX",

    events = {},
}
