-----------------------------------
-- FATE Zone: Beaucedine Glacier
-- Zone ID: 111
-- Region pool: NORTHLANDS
-- Boss weapon: Veilstrike (29877, Lv65)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BEAUCEDINE_GLACIER] =
{
    zoneName    = "Beaucedine_Glacier",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORTHLANDS",

    events = {},
}
