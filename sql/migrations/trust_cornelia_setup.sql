-- MimicXI: Cornelia trust setup
-- Creates spell (ID 1003) and mob pool (ID 6003) for the Cornelia aura trust.
--
-- Aura: Haste +20%, Accuracy +30, Ranged Accuracy +30, Magic Accuracy +30
-- Applied to all PC party members via COMBAT_TICK while summoned.
--
-- NOTE: modelid below uses Pieuje UC's model as a placeholder.
--       Replace 0x0000F20B with Cornelia's correct client model ID before shipping.

INSERT IGNORE INTO `spell_list` VALUES (
    1003,           -- spell ID
    'cornelia',     -- name (must match Lua file: scripts/actions/spells/trust/cornelia.lua)
    0x01010101010101010101010101010101010101010101,  -- job mask (all jobs, trust)
    8,              -- spell type (ALTER_EGO / trust)
    0,              -- element
    @ELEMENT_LIGHT,
    0,              -- targets self (spawn on caster)
    1,              -- valid targets
    @SKILL_NONE,
    0,              -- MP cost
    2000,           -- cast time (ms)
    240000,         -- recast time (ms)
    0, 0,
    939,            -- spell animation (standard trust cast)
    1500,
    0, 0,
    1.00,
    0, 0, 0, 0, 0,
    NULL
);

INSERT IGNORE INTO `mob_pools` VALUES (
    6003,           -- pool ID
    'cornelia',     -- internal name
    'Cornelia',     -- display name
    145,            -- family (Hume)
    -- TODO: Replace 0x0000F20B with Cornelia's actual client model ID
    0x0000F20B00000000000000000000000000000000,
    21,             -- level (max support trust level)
    0,              -- sub_level
    3,              -- pos (standing)
    240,            -- cmbDelay (irrelevant; auto-attack disabled in Lua)
    30,             -- cmbDmgMult (low; pure support)
    0, 0, 0, 0, 0, 0,
    32,             -- systemGroup
    0,
    3,
    0, 0, 0, 0, 0,
    1118,           -- skill_list_id
    145,            -- defFamily
    NULL,
    NULL
);
