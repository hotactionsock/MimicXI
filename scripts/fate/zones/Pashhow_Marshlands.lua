-----------------------------------
-- FATE Zone: Pashhow Marshlands
-- Zone ID: 109
-- Region pool: DERFLAND_ARAGONEU
-- Boss weapon: Wrathcleft (29859, Lv20)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.PASHHOW_MARSHLANDS] =
{
    zoneName    = "Pashhow_Marshlands",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "DERFLAND_ARAGONEU",

    events = {},
}
