-----------------------------------
-- FATE Zone: Sauromugue Champaign
-- Zone ID: 120
-- Region pool: NORVALLEN_QUFIM
-- Boss weapon: Blackscale Knife (29896, Lv36)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.SAUROMUGUE_CHAMPAIGN] =
{
    zoneName    = "Sauromugue_Champaign",
    spawnChance = 0.35,
    minCooldown = 600,
    region      = "NORVALLEN_QUFIM",

    events = {},
}
