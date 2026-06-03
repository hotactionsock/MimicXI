-----------------------------------
-- FATE Zone: Yuhtunga Jungle
-- Zone ID: 123
-- Region pool: KOLSHUSHU_ELSHIMO
-- Boss weapon: Dragonthorn Bident (29873, Lv60)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.YUHTUNGA_JUNGLE] =
{
    zoneName    = "Yuhtunga_Jungle",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "KOLSHUSHU_ELSHIMO",

    events = {},
}
