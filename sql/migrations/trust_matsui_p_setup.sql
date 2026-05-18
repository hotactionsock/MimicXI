-- MimicXI: Matsui-P trust setup
-- Spell 1020 → pool 6020 (trust system: pool = spell + 5000).
-- Model: 0x0000310C (AltanaView: ROM/310/13, 16-bit 0x0C31).
-- Spell list 435 (mob_spell_lists), skill list 1135 (mob_skill_lists).

-- Trust spell
INSERT IGNORE INTO `spell_list` VALUES (1020,'matsui_p',0x01010101010101010101010101010101010101010101,8,0,@ELEMENT_LIGHT,0,1,@SKILL_NONE,0,2000,240000,0,0,939,1500,0,0,1.00,0,0,0,0,0,NULL);

-- Mob pool: NIN/BLM Hume (pool 6020, spellList 435, skill_list 1135)
INSERT IGNORE INTO `mob_pools` VALUES (6020,'matsui_p','Matsui',149,0x0000310C00000000000000000000000000000000,13,4,3,240,100,0,0,0,0,0,0,32,0,3,0,0,435,0,0,1135,149,1,17);

-- Spell list 435: spells for HIGHEST/MB_ELEMENT gambit resolution
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,144,10,255); -- fire
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,149,24,255); -- blizzard
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,154,10,255); -- aero
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,159,10,255); -- stone
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,164,10,255); -- thunder
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,169,10,255); -- water
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,322,40,255); -- katon_san
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,325,40,255); -- hyoton_san
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,328,40,255); -- huton_san
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,331,40,255); -- doton_san
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,334,40,255); -- raiton_san
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,337,40,255); -- suiton_san
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,338,1,255);  -- utsusemi_ichi
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,339,37,255); -- utsusemi_ni
INSERT IGNORE INTO `mob_spell_lists` VALUES ('TRUST_Matsui-P',435,340,73,255); -- utsusemi_san

-- Skill list 1135: Blade weapon skills for SPECIAL_MATSUI_P WS selection
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,128); -- Blade: Rin  (Scission)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,129); -- Blade: Retsu (Impaction)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,133); -- Blade: Ei   (Gravitation)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,134); -- Blade: Jin  (Distortion)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,135); -- Blade: Ten  (Fusion)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,136); -- Blade: Ku   (Light/Darkness)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,138); -- Blade: Kamu (Darkness)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,140); -- Blade: Hi   (Light/Darkness)
INSERT IGNORE INTO `mob_skill_lists` VALUES ('TRUST_Matsui-P',1135,141); -- Blade: Shun (Distortion)
