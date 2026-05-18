-- MimicXI: Cornelia trust setup
-- Spell ID 1003 → pool ID 6003 (trust system: pool = spell + 5000).
-- Aura: Haste +20%, Accuracy +30, Ranged Accuracy +30, Magic Accuracy +30
-- Applied to all PC party members via COMBAT_TICK listener in cornelia.lua.
-- Model: 0x00002F0C (AltanaView: ROM/310/11, 16-bit 0x0C2F).

INSERT IGNORE INTO `spell_list` VALUES (1003,'cornelia',0x01010101010101010101010101010101010101010101,8,0,@ELEMENT_LIGHT,0,1,@SKILL_NONE,0,2000,240000,0,0,939,1500,0,0,1.00,0,0,0,0,0,NULL);

INSERT IGNORE INTO `mob_pools` VALUES (6003,'cornelia','Cornelia',145,0x00002F0C00000000000000000000000000000000,21,0,3,240,30,0,0,0,0,0,0,32,0,3,0,0,0,0,0,1118,145,1,17);
