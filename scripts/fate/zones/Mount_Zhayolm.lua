-----------------------------------
-- FATE Zone: Mount Zhayolm
-- Zone ID: 61
-- Region pool: TOAU
-- Boss weapon: Volcanic Tabar ★★ (29865, Lv62)
-- Loot rates are out of 1000:
--   240=24%, 150=15%, 100=10%, 50=5%, 10=1%
-----------------------------------
xi        = xi        or {}
xi.fate   = xi.fate   or {}
xi.fate.zones = xi.fate.zones or {}

xi.fate.zones[xi.zone.MOUNT_ZHAYOLM] =
{
    zoneName    = "Mount_Zhayolm",
    spawnChance = 0.30,
    minCooldown = 900,
    region      = "TOAU",

    events = {},
}
