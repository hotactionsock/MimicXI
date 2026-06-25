-- Adoulin Zone Mob Level Rebalance for 75-cap Era
-- Original Adoulin levels (99-128) remapped to three tiers:
--   Tier 1: 99-105  -> 55-70  (entry-level outdoor content)
--   Tier 2: 106-115 -> 71-75  (mid-tier threats)
--   Tier 3: 116-128 -> 76-85  (high-end / NM-adjacent)
-- Static-level spawns (level 0 or 1) are left untouched.
--
-- Covered zones:
--   258  Rala Waterways         (17833985 - 17834136)
--   259  Rala Waterways [U]     (17838081 - 17842599)
--   261  Ceizak Battlegrounds   (17846273 - 17846677)
--   262  Foret de Hennetiel     (17850369 - 17850805)
--   263  Yorcia Weald           (17854465 - 17854865)
--   264  Yorcia Weald [U]       (17858561 - 17863297)
--   266  Marjami Ravine         (17866753 - 17867063)
--   267  Kamihr Drifts          (17870849 - 17879323)
--   270  Cirdas Caverns         (17883137 - 17883749)
--   271  Cirdas Caverns [U]     (17887233 - 17887844)
--   272  Dho Gates              (17891329 - 17891565)

-- Level mapping function (applied identically to minLevel and maxLevel):
--   level <= 1              -> unchanged (environmental spawns / fished)
--   99  <= level <= 105     -> ROUND(55 + (level - 99) * 15 / 6)   range 55-70
--   106 <= level <= 115     -> ROUND(71 + (level - 106) * 4 / 9)   range 71-75
--   116 <= level <= 128     -> ROUND(76 + (level - 116) * 9 / 12)  range 76-85

UPDATE mob_spawn_points
SET
    minLevel = CASE
        WHEN minLevel <= 1   THEN minLevel
        WHEN minLevel <= 105 THEN ROUND(55 + (minLevel - 99) * 15 / 6)
        WHEN minLevel <= 115 THEN ROUND(71 + (minLevel - 106) * 4 / 9)
        ELSE                      ROUND(76 + (minLevel - 116) * 9 / 12)
    END,
    maxLevel = CASE
        WHEN maxLevel <= 1   THEN maxLevel
        WHEN maxLevel <= 105 THEN ROUND(55 + (maxLevel - 99) * 15 / 6)
        WHEN maxLevel <= 115 THEN ROUND(71 + (maxLevel - 106) * 4 / 9)
        ELSE                      ROUND(76 + (maxLevel - 116) * 9 / 12)
    END
WHERE mobid BETWEEN 17833985 AND 17834136   -- Rala Waterways
   OR mobid BETWEEN 17838081 AND 17842599   -- Rala Waterways [U]
   OR mobid BETWEEN 17846273 AND 17846677   -- Ceizak Battlegrounds
   OR mobid BETWEEN 17850369 AND 17850805   -- Foret de Hennetiel
   OR mobid BETWEEN 17854465 AND 17854865   -- Yorcia Weald
   OR mobid BETWEEN 17858561 AND 17863297   -- Yorcia Weald [U]
   OR mobid BETWEEN 17866753 AND 17867063   -- Marjami Ravine
   OR mobid BETWEEN 17870849 AND 17879323   -- Kamihr Drifts
   OR mobid BETWEEN 17883137 AND 17883749   -- Cirdas Caverns
   OR mobid BETWEEN 17887233 AND 17887844   -- Cirdas Caverns [U]
   OR mobid BETWEEN 17891329 AND 17891565   -- Dho Gates
;
