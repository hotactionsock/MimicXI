-----------------------------------
-- FATE Zone: Valkurm Dunes
-- Zone ID: 103
-- Region pool: STARTER_ZULKHEIM
-- Boss weapon: Soulcrop (29870, Lv22)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.VALKURM_DUNES] =
{
    zoneName    = "Valkurm_Dunes",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "STARTER_ZULKHEIM",

    events = {},
}
