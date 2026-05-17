-- MimicXI Trust WS Fix: Add mob_skill_lists entries so TryTrustSkill() can execute player weapon skills.
--
-- Background: ai.r.WS in addGambit() is silently a no-op — the gambit execution loop only
-- handles MA/JA/MS/RATTACK. Trust weapon skills are fired exclusively by TryTrustSkill()
-- (called before the gambit loop at TP>=tp_trigger), which reads from mob_skill_lists.
-- Without entries here, setTrustTPSkillSettings() does nothing.
--
-- All prior ai.r.WS gambit lines in the affected trust Lua files have been removed.
--
-- Run this against your database once. Re-running is safe (INSERT IGNORE).

-- TRUST_Zeid (skill_list_id 1021) — DRK/scythe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Zeid',1021,99);  -- Nightmare Scythe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Zeid',1021,102); -- Guillotine
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Zeid',1021,104); -- Spiral Hell

-- TRUST_Zazarg (skill_list_id 1039) — MNK/H2H
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Zazarg',1039,5); -- Raging Fists
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Zazarg',1039,7); -- Howling Fist
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Zazarg',1039,9); -- Asuran Fists

-- TRUST_Aldo (skill_list_id 1045) — THF/dagger
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Aldo',1045,23); -- Dancing Edge
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Aldo',1045,25); -- Evisceration

-- TRUST_Gilgamesh (skill_list_id 1053) — SAM/great katana
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Gilgamesh',1053,150); -- Tachi: Yukikaze
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Gilgamesh',1053,151); -- Tachi: Gekko
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Gilgamesh',1053,152); -- Tachi: Kasha

-- TRUST_Klara (skill_list_id 1063) — WAR/great axe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Klara',1063,81); -- Iron Tempest
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Klara',1063,82); -- Sturmwind

-- TRUST_Lhe_Lhangavo (skill_list_id 1079) — MNK/H2H
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Lhe_Lhangavo',1079,5); -- Raging Fists
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Lhe_Lhangavo',1079,7); -- Howling Fist
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Lhe_Lhangavo',1079,9); -- Asuran Fists

-- TRUST_Halver (skill_list_id 1087) — PLD/sword
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Halver',1087,40); -- Vorpal Blade
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Halver',1087,42); -- Savage Blade

-- TRUST_Rongelouts (skill_list_id 1088) — WAR/great axe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Rongelouts',1088,81); -- Iron Tempest
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Rongelouts',1088,82); -- Sturmwind

-- TRUST_Leonoyne (skill_list_id 1089) — DRK/scythe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Leonoyne',1089,99);  -- Nightmare Scythe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Leonoyne',1089,102); -- Guillotine
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Leonoyne',1089,104); -- Spiral Hell

-- TRUST_Morimar (skill_list_id 1105) — BST/great axe
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Morimar',1105,81); -- Iron Tempest
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Morimar',1105,82); -- Sturmwind
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Morimar',1105,88); -- Steel Cyclone

-- TRUST_Darrcuiln (skill_list_id 1106) — WAR/great axe, premier DD
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Darrcuiln',1106,81); -- Iron Tempest
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Darrcuiln',1106,82); -- Sturmwind
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Darrcuiln',1106,88); -- Steel Cyclone
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Darrcuiln',1106,91); -- Fell Cleave

-- TRUST_Ayame_UC (skill_list_id 1120) — SAM/great katana
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Ayame_UC',1120,150); -- Tachi: Yukikaze
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Ayame_UC',1120,151); -- Tachi: Gekko
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Ayame_UC',1120,152); -- Tachi: Kasha
