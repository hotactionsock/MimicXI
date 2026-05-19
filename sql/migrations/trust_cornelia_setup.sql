-- MimicXI: Cornelia trust setup
-- Spell ID 1000 → pool ID 6000 (trust system: pool = spell + 5000).
-- NOTE: If !addspell 1000 shows a different trust in the FFXI client, the
--       spell ID must be changed. Run !addspell 1001 / 1002 to check alternatives.
-- Aura: Haste +20%, Accuracy +30, Ranged Accuracy +30, Magic Accuracy +30
-- Applied to all PC party members via COMBAT_TICK listener in cornelia.lua.
-- Model: 0x00002F0C (AltanaView: ROM/310/11, 16-bit 0x0C2F).
-- Skill list 1118 has no entries (support-only, no weapon skills).

INSERT IGNORE INTO `spell_list` VALUES (1000,'cornelia',0x01010101010101010101010101010101010101010101,8,0,@ELEMENT_LIGHT,0,1,@SKILL_NONE,0,2000,240000,0,0,939,1500,0,0,1.00,0,0,0,0,0,NULL);

INSERT IGNORE INTO `mob_pools` VALUES (6000,'cornelia','Cornelia',149,0x00002F0C00000000000000000000000000000000,21,0,3,240,100,0,0,0,0,0,0,32,0,3,0,0,0,0,0,1118,149,1,17);
