-----------------------------------
-- FATE Zone: Caedarva Mire
-- Zone ID: 79
-- Region pool: TOAU
-- Boss weapon: Soulcleave (29858, Lv55)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.CAEDARVA_MIRE] =
{
    zoneName    = "Caedarva_Mire",
    spawnChance = 0.30,
    minCooldown = 900,
    region      = "TOAU",

    events = {},
}
