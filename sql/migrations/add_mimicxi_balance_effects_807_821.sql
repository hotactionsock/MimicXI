-- MimicXI Balance Pass: Add custom status effects 807-822
-- Run this on existing databases that already have status_effects populated.
-- Also requires server recompile after raising MAX_EFFECTID to 823 in src/map/status_effect.h.

SET @FLAG_DEATH            = 32;
SET @FLAG_ON_ZONE          = 256;
SET @FLAG_NO_LOSS_MESSAGE  = 512;

INSERT IGNORE INTO `status_effects` VALUES (807,'aura_of_radiance',  @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (808,'arcane_echo',        @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (809,'holy_retribution',   @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (810,'soul_reservoir',     @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (811,'dark_empowerment',   @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (812,'crimson_tide',       @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (813,'groggy',             @FLAG_DEATH | @FLAG_NO_LOSS_MESSAGE,                0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (814,'strategic_clarity',  @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (815,'drawn_bow',          @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (816,'zanshin_momentum',   @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (817,'elemental_scar',     @FLAG_DEATH | @FLAG_NO_LOSS_MESSAGE,                0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (818,'draconic_resonance', @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (819,'wyvern_blessing',    @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (820,'breach',             @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (821,'ward_resonance',     @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
INSERT IGNORE INTO `status_effects` VALUES (822,'dead_aim',           @FLAG_DEATH | @FLAG_ON_ZONE | @FLAG_NO_LOSS_MESSAGE,0,0,0,0,0,0,0,0,NULL);
