-----------------------------------
-- FATE Zone: La Theine Plateau
-- Zone ID: 102
-- Region pool: STARTER_ZULKHEIM
-- Boss weapon: Fangbore Lance (29874, Lv24)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.LA_THEINE_PLATEAU] =
{
    zoneName    = "La_Theine_Plateau",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events = {},
}
