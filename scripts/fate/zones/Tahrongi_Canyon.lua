-----------------------------------
-- FATE Zone: Tahrongi Canyon
-- Zone ID: 117
-- Region pool: DERFLAND_ARAGONEU
-- Boss weapon: Bonecleave Hatchet (29863, Lv22)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.TAHRONGI_CANYON] =
{
    zoneName    = "Tahrongi_Canyon",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events = {},
}
