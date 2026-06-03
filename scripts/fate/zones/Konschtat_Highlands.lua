-----------------------------------
-- FATE Zone: Konschtat Highlands
-- Zone ID: 108
-- Region pool: STARTER_ZULKHEIM
-- Boss weapon: Colossbreaker (29866, Lv28)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.KONSCHTAT_HIGHLANDS] =
{
    zoneName    = "Konschtat_Highlands",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events = {},
}
