-----------------------------------
-- FATE Zone: Bhaflau Thickets
-- Zone ID: 52
-- Region pool: TOAU
-- Boss weapon: Ravager's Axe (29862, Lv62)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BHAFLAU_THICKETS] =
{
    zoneName    = "Bhaflau_Thickets",
    spawnChance = 0.30,
    minCooldown = 900,
    region      = "TOAU",

    events = {},
}
