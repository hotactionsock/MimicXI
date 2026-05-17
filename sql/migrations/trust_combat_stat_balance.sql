-- MimicXI Trust Balance: Differentiate auto-attack damage and weapon timing by job role.
--
-- Previously every trust used cmbDmgMult=100 and cmbDelay=240, making all trusts
-- deal identical auto-attack damage regardless of job (WHM same as DRK).
-- This update assigns values consistent with each trust's weapon type and role.
--
-- cmbDmgMult: weapon damage percentage (100 = base mob damage formula * 0.5)
-- cmbDelay:   weapon delay in 60Hz ticks (240 ≈ 4s/min = sword speed, 440 = great katana)
--
-- Role tiers used:
--   Heavy DD  (WAR/DRK/SAM) : 140-150 mult, 280-440 delay (weapon-appropriate)
--   Moderate DD (MNK/THF)   : 110-120 mult, 240-280 delay (fast, moderate damage)
--   Tank/Hybrid (PLD/RDM)   :  80-90  mult, 280     delay
--   Ranged (RNG/COR)         :  80-100 mult, 480-500 delay (bow/gun timing)
--   Support/Healer (WHM/BRD) :  40     mult, 280-300 delay (auto-attack disabled in Lua)
--   Pure Caster (BLM/GEO)   :  30     mult, 300     delay (auto-attack disabled in Lua)

-- -------------------------
-- Batch 1 trusts
-- -------------------------

-- Zeid (DRK/8): scythe, heavy melee DD
UPDATE `mob_pools` SET `cmbDmgMult` = 140, `cmbDelay` = 280 WHERE `poolid` = 5906;

-- Zazarg (MNK/2): H2H, fast moderate hits; DOUBLE_ATTACK added in Lua
UPDATE `mob_pools` SET `cmbDmgMult` = 120, `cmbDelay` = 240 WHERE `poolid` = 5924;

-- Luzaf (COR/17): gunslinger, ranged
UPDATE `mob_pools` SET `cmbDmgMult` = 80,  `cmbDelay` = 480 WHERE `poolid` = 5928;

-- Najelith (RNG/11): bow, ranged
UPDATE `mob_pools` SET `cmbDmgMult` = 80,  `cmbDelay` = 500 WHERE `poolid` = 5929;

-- Aldo (THF/6): dagger, fast low damage
UPDATE `mob_pools` SET `cmbDmgMult` = 80,  `cmbDelay` = 200 WHERE `poolid` = 5930;

-- Star Sibyl (GEO/21): pure support, auto-attack disabled in Lua
UPDATE `mob_pools` SET `cmbDmgMult` = 30,  `cmbDelay` = 300 WHERE `poolid` = 5935;

-- Klara (WAR/1): great axe, heavy melee DD
UPDATE `mob_pools` SET `cmbDmgMult` = 140, `cmbDelay` = 340 WHERE `poolid` = 5948;

-- Kuyin Hathdenna (GEO/21): pure support, auto-attack disabled in Lua
UPDATE `mob_pools` SET `cmbDmgMult` = 30,  `cmbDelay` = 300 WHERE `poolid` = 5950;

-- Pieuje UC (WHM/3): healer, auto-attack disabled in Lua
UPDATE `mob_pools` SET `cmbDmgMult` = 40,  `cmbDelay` = 280 WHERE `poolid` = 5953;

-- Lhe Lhangavo (MNK/2): H2H, fast moderate hits; DOUBLE_ATTACK added in Lua
UPDATE `mob_pools` SET `cmbDmgMult` = 120, `cmbDelay` = 240 WHERE `poolid` = 5964;

-- -------------------------
-- Batch 2 trusts
-- -------------------------

-- Halver (PLD/7): sword+shield, tank
UPDATE `mob_pools` SET `cmbDmgMult` = 90,  `cmbDelay` = 280 WHERE `poolid` = 5972;

-- Rongelouts (WAR/1): great axe, heavy melee DD
UPDATE `mob_pools` SET `cmbDmgMult` = 140, `cmbDelay` = 340 WHERE `poolid` = 5973;

-- Leonoyne (DRK/4): scythe + ice magic, DD/mage hybrid
UPDATE `mob_pools` SET `cmbDmgMult` = 140, `cmbDelay` = 280 WHERE `poolid` = 5974;

-- Margret (RNG/11): bow, ranged
UPDATE `mob_pools` SET `cmbDmgMult` = 80,  `cmbDelay` = 500 WHERE `poolid` = 5962;

-- King of Hearts (RDM/5): enchanter support, auto-attack disabled in Lua
UPDATE `mob_pools` SET `cmbDmgMult` = 60,  `cmbDelay` = 280 WHERE `poolid` = 5989;

-- Morimar (BST/9): great axe-type, heavy melee DD
UPDATE `mob_pools` SET `cmbDmgMult` = 140, `cmbDelay` = 340 WHERE `poolid` = 5990;

-- Darrcuiln (WAR/1): great axe, premier physical DD
UPDATE `mob_pools` SET `cmbDmgMult` = 150, `cmbDelay` = 340 WHERE `poolid` = 5991;

-- AAEV (PLD/7): sword+shield, tank
UPDATE `mob_pools` SET `cmbDmgMult` = 90,  `cmbDelay` = 280 WHERE `poolid` = 5993;

-- Ayame UC (SAM/12): great katana, heavy DD
UPDATE `mob_pools` SET `cmbDmgMult` = 150, `cmbDelay` = 440 WHERE `poolid` = 6005;

-- Gilgamesh (SAM/12): great katana, heavy DD
UPDATE `mob_pools` SET `cmbDmgMult` = 150, `cmbDelay` = 440 WHERE `poolid` = 5938;
