-----------------------------------
-- FATE Zone: Bibiki Bay
-- Zone ID: 4
-- Region pool: KOLSHUSHU_ELSHIMO
-- Boss weapon: Stormreaver's Edge (29854, Lv58)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.BIBIKI_BAY] =
{
    zoneName    = "Bibiki_Bay",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "KOLSHUSHU_ELSHIMO",

    events = {},
}
