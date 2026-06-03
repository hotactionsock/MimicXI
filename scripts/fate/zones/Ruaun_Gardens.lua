-----------------------------------
-- FATE Zone: Ru'Aun Gardens
-- Zone ID: 130
-- Region pool: SKY_SEA_HIGHEND
-- Boss weapon: Wrath Caestus (29899, Lv68)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.RUAUN_GARDENS] =
{
    zoneName    = "Ruaun_Gardens",
    spawnChance = 0.30,
    minCooldown = 900,
    region      = "SKY_SEA_HIGHEND",

    events = {},
}
