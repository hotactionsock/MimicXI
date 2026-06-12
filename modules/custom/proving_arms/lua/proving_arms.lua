-----------------------------------
-- Module: proving_arms
--
-- The Proving Arms weapon upgrade system. Players evolve a single weapon
-- through five tiers (Nascent → Tempered → Forged → Resolute → Proven)
-- by spending materials earned from Tier Trials and The Circuit.
-- The Resonance Forge NPC handles all upgrades and augment activation.
--
-- Weapon families and capstones:
--   blade      (RDM/BRD)      → T1–T4 Blades,    Capstone: Virtus   (20037)
--   nodachi    (SAM/NIN)      → T1–T4 Nodachi,   Capstone: Vox      (20038)
--   kukri      (THF/NIN/RNG/COR/DNC) → T1–T4 Kukri, Capstone: Umbra (20039)
--   cesti      (MNK/PUP)      → T1–T4 Cesti,     Capstone: Fuga     (20040)
--   rod        (WHM/BLM/SMN/SCH/GEO) → T1–T4 Rods, Capstone: Vis   (20041)
--   falchion   (BLU)          → T1–T4 Falchions, Capstone: Lux      (20042)
--   sceptre    (GEO extra)    → T1–T4 Sceptres,  Capstone: Arcana   (20043)  [GEO alt line]
--   spatha     (PLD/RDM)      → T1–T4 Spathas,   Capstone: Tellus   (20044)
--   kite       (PLD)          → T1–T4 Kite Shields, Capstone: Lex   (20045)
--   caligo     (NIN solo)     → shares Nodachi T1–T4, Capstone: Caligo (20046)
--   (Tutela PLD shield capstone — pending item ID)
--
-- Augment pools (Tier V slot):
--   Nascent (30):    Accuracy · Evasion · Enmity+/- · Magic Attack Bonus
--   Tempered (40):   Haste · Subtle Blow · Cure Potency · Magic Accuracy
--   Forged (50):     Crit Hit Rate · Fast Cast · Store TP · Damage Taken-
--   Resolute (60):   Double Attack · Conserve MP · Magic Burst Bonus · Resist vs. Element
--
-- Toggle: comment/uncomment entries in modules/init.txt
--
-- Dependencies: tier_trials module (shard items), circuit module (badge item)
-----------------------------------
require('modules/module_utils')

local m = Module:new('mimic_proving_arms')

xi              = xi or {}
xi.provingArms  = xi.provingArms or {}

-----------------------------------
-- Material item IDs
-----------------------------------
xi.provingArms.item =
{
    -- Trial Shards (dropped from Tier Trial wave 5 clears)
    NASCENT_SHARD    = 3757,
    TEMPERED_SHARD   = 3758,
    FORGED_SHARD     = 3759,
    RESOLUTE_SHARD   = 3760,

    -- Endgame boss drops
    RESONANCE_KEY    = 0, -- TODO: T1 boss drop
    AWAKENING_SHARD  = 0, -- TODO: T2 boss drop
    AWAKENING_CRYSTAL = 0, -- TODO: T3 boss drop
    PRIMAL_REMNANT   = 0, -- TODO: T4 boss drop
}

-- Platinum Circuit Badge item ID (awarded by Circuit module)
xi.provingArms.BADGE_ITEM_ID = 0 -- TODO: assign item ID

-----------------------------------
-- Job → weapon family key
-- NIN can follow nodachi or caligo; default is kukri (rogue line).
-- The Forge NPC offers NIN players a choice at Tier V.
-- PLD has two parallel lines: spatha (weapon) and kite (shield).
-----------------------------------
xi.provingArms.jobFamily = function(job)
    local map =
    {
        [xi.job.WAR] = 'blade',       -- greatsword-class, shares blade line
        [xi.job.DRK] = 'blade',
        [xi.job.DRG] = 'blade',
        [xi.job.RDM] = 'blade',       -- RDM default; can also do spatha
        [xi.job.BRD] = 'blade',
        [xi.job.SAM] = 'nodachi',
        [xi.job.NIN] = 'kukri',       -- NIN default; Forge offers caligo at T5
        [xi.job.THF] = 'kukri',
        [xi.job.RNG] = 'kukri',
        [xi.job.COR] = 'kukri',
        [xi.job.DNC] = 'kukri',
        [xi.job.MNK] = 'cesti',
        [xi.job.PUP] = 'cesti',
        [xi.job.WHM] = 'rod',
        [xi.job.BLM] = 'rod',
        [xi.job.SMN] = 'rod',
        [xi.job.SCH] = 'rod',
        [xi.job.GEO] = 'rod',         -- GEO default; can also do sceptre
        [xi.job.BLU] = 'falchion',
        [xi.job.PLD] = 'spatha',      -- PLD default weapon line; kite is parallel
    }
    return map[job]
end

-----------------------------------
-- Weapon item IDs per tier and family
-- Tier I–IV: 20001–20036 (9 families × 4 tiers)
-- Kite Shields (PLD armor line): 23936–23939
-- Tier V capstones: 20037–20046
-- Tutela (PLD shield capstone): pending
-----------------------------------
xi.provingArms.WEAPONS =
{
    -- Tier I: Nascent (equip Lv28)
    [1] =
    {
        blade    = 20001,
        nodachi  = 20002,
        kukri    = 20003,
        cesti    = 20004,
        rod      = 20005,
        falchion = 20006,
        sceptre  = 20007,
        spatha   = 20008,
        kite     = 23936,
        caligo   = 20002, -- shares nodachi blank
    },
    -- Tier II: Tempered (equip Lv38)
    [2] =
    {
        blade    = 20010,
        nodachi  = 20011,
        kukri    = 20012,
        cesti    = 20013,
        rod      = 20014,
        falchion = 20015,
        sceptre  = 20016,
        spatha   = 20017,
        kite     = 23937,
        caligo   = 20011,
    },
    -- Tier III: Forged (equip Lv48)
    [3] =
    {
        blade    = 20019,
        nodachi  = 20020,
        kukri    = 20021,
        cesti    = 20022,
        rod      = 20023,
        falchion = 20024,
        sceptre  = 20025,
        spatha   = 20026,
        kite     = 23938,
        caligo   = 20020,
    },
    -- Tier IV: Resolute (equip Lv58)
    [4] =
    {
        blade    = 20028,
        nodachi  = 20029,
        kukri    = 20030,
        cesti    = 20031,
        rod      = 20032,
        falchion = 20033,
        sceptre  = 20034,
        spatha   = 20035,
        kite     = 23939,
        caligo   = 20029,
    },
    -- Tier V: Proven capstones (equip Lv73, augment slot)
    [5] =
    {
        blade    = 20037, -- Virtus
        nodachi  = 20038, -- Vox
        kukri    = 20039, -- Umbra
        cesti    = 20040, -- Fuga
        rod      = 20041, -- Vis
        falchion = 20042, -- Lux
        sceptre  = 20043, -- Arcana
        spatha   = 20044, -- Tellus
        kite     = 20045, -- Lex
        caligo   = 20046, -- Caligo (NIN-exclusive)
    },
}

-- Reverse lookup: itemId → { tier, family }
xi.provingArms.WEAPON_LOOKUP = {}

xi.provingArms.buildLookup = function()
    xi.provingArms.WEAPON_LOOKUP = {}
    for tier, families in pairs(xi.provingArms.WEAPONS) do
        for family, itemId in pairs(families) do
            if itemId > 0 then
                -- caligo shares IDs with nodachi for T1–T4; skip duplicate registration
                if not xi.provingArms.WEAPON_LOOKUP[itemId] then
                    xi.provingArms.WEAPON_LOOKUP[itemId] = { tier = tier, family = family }
                end
            end
        end
    end
end

-----------------------------------
-- Upgrade recipes: Tier I→II, II→III, III→IV, IV→V
-----------------------------------
xi.provingArms.getRecipe = function(fromTier)
    local item = xi.provingArms.item

    local recipes =
    {
        -- Nascent → Tempered
        [1] =
        {
            materials     = { { id = item.NASCENT_SHARD, qty = 3 } },
            markVar       = '[TierTrial]ValkurumMarks',
            markCost      = 1,
            circuitPoints = 0,
        },
        -- Tempered → Forged
        [2] =
        {
            materials     = { { id = item.TEMPERED_SHARD, qty = 3 } },
            markVar       = '[TierTrial]QufimMarks',
            markCost      = 1,
            circuitPoints = 0,
        },
        -- Forged → Resolute
        [3] =
        {
            materials     = { { id = item.FORGED_SHARD, qty = 3 } },
            markVar       = '[TierTrial]FauregandiMarks',
            markCost      = 1,
            circuitPoints = 5,
        },
        -- Resolute → Proven
        [4] =
        {
            materials     =
            {
                { id = item.RESOLUTE_SHARD,  qty = 5 },
                { id = item.RESONANCE_KEY,   qty = 1 },
            },
            requiresBadge = true,
            markVar       = nil,
            markCost      = 0,
            circuitPoints = 0,
        },
    }

    return recipes[fromTier]
end

-----------------------------------
-- Augment pools per origin tier
-----------------------------------
xi.provingArms.AUGMENT_POOLS =
{
    [30] = -- Nascent pool
    {
        { augId = 0, min = 4,  max = 8,  label = 'Accuracy'           }, -- TODO: xi.augment.ACCURACY
        { augId = 0, min = 4,  max = 8,  label = 'Evasion'            }, -- TODO: xi.augment.EVASION
        { augId = 0, min = 3,  max = 6,  label = 'Enmity'             }, -- TODO: xi.augment.ENMITY
        { augId = 0, min = 4,  max = 8,  label = 'Magic Attack Bonus' }, -- TODO: xi.augment.MAGIC_ATK_BONUS
    },
    [40] = -- Tempered pool
    {
        { augId = 0, min = 2,  max = 4,  label = 'Haste'              }, -- TODO: xi.augment.HASTE (%)
        { augId = 0, min = 4,  max = 8,  label = 'Subtle Blow'        }, -- TODO: xi.augment.SUBTLE_BLOW
        { augId = 0, min = 3,  max = 6,  label = 'Cure Potency'       }, -- TODO: xi.augment.CURE_POTENCY (%)
        { augId = 0, min = 4,  max = 8,  label = 'Magic Accuracy'     }, -- TODO: xi.augment.MAGIC_ACCURACY
    },
    [50] = -- Forged pool
    {
        { augId = 0, min = 2,  max = 4,  label = 'Crit Hit Rate'      }, -- TODO: xi.augment.CRIT_HIT_RATE (%)
        { augId = 0, min = 3,  max = 6,  label = 'Fast Cast'          }, -- TODO: xi.augment.FAST_CAST (%)
        { augId = 0, min = 4,  max = 8,  label = 'Store TP'           }, -- TODO: xi.augment.STORE_TP
        { augId = 0, min = 3,  max = 5,  label = 'Damage Taken'       }, -- TODO: xi.augment.DMG_TAKEN (negative %)
    },
    [60] = -- Resolute pool
    {
        { augId = 0, min = 2,  max = 4,  label = 'Double Attack'      }, -- TODO: xi.augment.DOUBLE_ATTACK (%)
        { augId = 0, min = 3,  max = 6,  label = 'Conserve MP'        }, -- TODO: xi.augment.CONSERVE_MP
        { augId = 0, min = 3,  max = 6,  label = 'Magic Burst Bonus'  }, -- TODO: xi.augment.MAGIC_BURST_BONUS (%)
        { augId = 0, min = 1,  max = 3,  label = 'Resist vs. Element' }, -- TODO: xi.augment.RESIST_ELEMENT (tier)
    },
}

-- Badge rerolls exclude the best augment in each pool
xi.provingArms.BADGE_EXCLUDED =
{
    [30] = 'Magic Attack Bonus',
    [40] = 'Haste',
    [50] = 'Crit Hit Rate',
    [60] = 'Double Attack',
}

-----------------------------------
-- Roll 3 augment options from a pool
-- badgeReroll: if true, exclude the top augment from the pool
-----------------------------------
xi.provingArms.rollAugments = function(originTier, badgeReroll)
    local pool = xi.provingArms.AUGMENT_POOLS[originTier]
    if not pool then return {} end

    local eligible = {}
    local excluded = badgeReroll and xi.provingArms.BADGE_EXCLUDED[originTier]

    for _, entry in ipairs(pool) do
        if not excluded or entry.label ~= excluded then
            table.insert(eligible, entry)
        end
    end

    local count   = math.min(3, #eligible)
    local results = {}
    local indices = {}
    for i = 1, #eligible do indices[i] = i end

    for i = 1, count do
        local pick  = math.random(i, #indices)
        indices[i], indices[pick] = indices[pick], indices[i]
        local entry = eligible[indices[i]]
        local value = math.random(entry.min, entry.max)
        table.insert(results, { augId = entry.augId, value = value, label = entry.label })
    end

    return results
end

-----------------------------------
-- Check if player has all materials for a recipe
-- Returns true/false and a list of missing items
-----------------------------------
xi.provingArms.checkMaterials = function(player, recipe)
    local missing = {}

    for _, mat in ipairs(recipe.materials) do
        if mat.id > 0 then
            local has = player:getItemCount(mat.id)
            if has < mat.qty then
                table.insert(missing, { id = mat.id, need = mat.qty, have = has })
            end
        else
            table.insert(missing, { id = 0, need = mat.qty, have = 0, unset = true })
        end
    end

    if recipe.markVar then
        local marks = player:getCharVar(recipe.markVar)
        if marks < recipe.markCost then
            table.insert(missing, { markVar = recipe.markVar, need = recipe.markCost, have = marks })
        end
    end

    if recipe.circuitPoints > 0 then
        local pts = player:getCharVar(xi.circuit and xi.circuit.POINT_VAR or '[Circuit]Points')
        if pts < recipe.circuitPoints then
            table.insert(missing, { circuitPoints = true, need = recipe.circuitPoints, have = pts })
        end
    end

    if recipe.requiresBadge then
        local badgeId = xi.provingArms.BADGE_ITEM_ID
        if badgeId > 0 and player:getItemCount(badgeId) < 1 then
            table.insert(missing, { id = badgeId, need = 1, have = 0 })
        end
    end

    return #missing == 0, missing
end

-----------------------------------
-- Consume materials for a recipe
-----------------------------------
xi.provingArms.consumeMaterials = function(player, recipe)
    for _, mat in ipairs(recipe.materials) do
        if mat.id > 0 then
            player:removeItem(mat.id, mat.qty)
        end
    end

    if recipe.markVar and recipe.markCost > 0 then
        local marks = player:getCharVar(recipe.markVar)
        player:setCharVar(recipe.markVar, marks - recipe.markCost)
    end

    if recipe.circuitPoints > 0 then
        local pointVar = xi.circuit and xi.circuit.POINT_VAR or '[Circuit]Points'
        local pts      = player:getCharVar(pointVar)
        player:setCharVar(pointVar, pts - recipe.circuitPoints)
    end

    if recipe.requiresBadge then
        local badgeId = xi.provingArms.BADGE_ITEM_ID
        if badgeId > 0 then
            player:removeItem(badgeId, 1)
        end
    end
end

-----------------------------------
-- Perform an upgrade: consume source weapon, give next tier
-----------------------------------
xi.provingArms.doUpgrade = function(player, fromItemId, fromTier, family)
    local toTier   = fromTier + 1
    local toItemId = xi.provingArms.WEAPONS[toTier] and xi.provingArms.WEAPONS[toTier][family]

    if not toItemId or toItemId == 0 then
        return false, 'Target weapon item ID not yet configured.'
    end

    player:removeItem(fromItemId, 1)
    player:addItem(toItemId, 1)
    return true
end

-----------------------------------
-- Apply a chosen augment to a Proven weapon in-place
-----------------------------------
xi.provingArms.applyAugment = function(player, weaponItemId, augEntry)
    if augEntry.augId == 0 then
        return false, 'Augment ID not yet configured for: ' .. augEntry.label
    end
    player:addAugment(weaponItemId, augEntry.augId, augEntry.value)
    return true
end

-----------------------------------
-- Load sub-files
-----------------------------------
require('modules/custom/proving_arms/lua/forge_npc')

xi.provingArms.buildLookup()

return m
