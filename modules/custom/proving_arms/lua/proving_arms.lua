-----------------------------------
-- Module: proving_arms
--
-- The Proving Arms weapon upgrade system. Players evolve a single weapon
-- through five tiers (Nascent → Tempered → Forged → Resolute → Proven)
-- by spending materials earned from Tier Trials and The Circuit.
-- The Resonance Forge NPC handles all upgrades and augment activation.
--
-- Augment pools (Tier V+ slot):
--   Valkurm (30):   Accuracy · Evasion · Enmity+/- · Magic Attack Bonus
--   Qufim (40):     Haste · Subtle Blow · Cure Potency · Magic Accuracy
--   Fauregandi (50):Crit Hit Rate · Fast Cast · Store TP · Damage Taken-
--   Pso'Xja (60):   Double Attack · Conserve MP · Magic Burst Bonus · Resist vs. Element
--
-- Toggle: comment/uncomment entries in modules/init.txt
--
-- Dependencies: tier_trials module (shard items), circuit module (badge item)
--   Both can be toggled independently — forge simply won't show recipes
--   whose materials aren't defined.
-----------------------------------
require('modules/module_utils')

local m = Module:new('mimic_proving_arms')

xi              = xi or {}
xi.provingArms  = xi.provingArms or {}

-----------------------------------
-- Material item IDs
-- Shards and marks are spent here; weapons are consumed/produced.
-- All weapon item IDs are TODO until item generation is complete.
-- Shard/Badge/Key IDs are also TODO — set to 0 as safe sentinel.
-----------------------------------
xi.provingArms.item =
{
    -- Trial Shards (dropped from Tier Trial wave 5 clears)
    VALKURM_SHARD    = 0, -- TODO: xi.item.VALKURM_TRIAL_SHARD
    QUFIM_SHARD      = 0, -- TODO: xi.item.QUFIM_TRIAL_SHARD
    FAUREGANDI_SHARD = 0, -- TODO: xi.item.FAUREGANDI_TRIAL_SHARD
    PSOXJA_SHARD     = 0, -- TODO: xi.item.PSOXJA_TRIAL_SHARD

    -- Endgame boss drops (stubbed — wired in boss system iteration)
    RESONANCE_KEY    = 0, -- TODO: T1 boss drop
    AWAKENING_SHARD  = 0, -- TODO: T2 boss drop
    AWAKENING_CRYSTAL = 0, -- TODO: T3 boss drop
    PRIMAL_REMNANT   = 0, -- TODO: T4 boss drop
}

-- Platinum Circuit Badge item ID (awarded by Circuit module)
-- Read from circuit module if loaded, else fallback to 0
xi.provingArms.BADGE_ITEM_ID = 0 -- TODO: assign item ID

-----------------------------------
-- Job family → weapon family key
-----------------------------------
xi.provingArms.jobFamily = function(job)
    local map =
    {
        [xi.job.WAR] = 'greatsword',  [xi.job.DRK] = 'greatsword',
        [xi.job.DRG] = 'greatsword',
        [xi.job.MNK] = 'handtohand',  [xi.job.PUP] = 'handtohand',
        [xi.job.WHM] = 'staff_heal',  [xi.job.SCH] = 'staff_heal',
        [xi.job.BLM] = 'staff_magic', [xi.job.SMN] = 'staff_magic',
        [xi.job.RDM] = 'sword',       [xi.job.BRD] = 'sword',
        [xi.job.THF] = 'dagger',      [xi.job.NIN] = 'dagger',
        [xi.job.RNG] = 'ranged',      [xi.job.COR] = 'ranged',
        [xi.job.PLD] = 'sword_shield',
        [xi.job.SAM] = 'greatkatana',
        [xi.job.BST] = 'axe',
    }
    return map[job]
end

-----------------------------------
-- Weapon item IDs per tier and family
-- All 0 until item generation pass is complete.
-- Format: WEAPONS[tier][family] = itemId
-----------------------------------
xi.provingArms.WEAPONS =
{
    -- Tier I: Nascent weapons (equip Lv28)
    [1] =
    {
        greatsword   = 0, handtohand   = 0,
        staff_heal   = 0, staff_magic  = 0,
        sword        = 0, dagger       = 0,
        ranged       = 0, sword_shield = 0,
        greatkatana  = 0, axe          = 0,
    },
    -- Tier II: Tempered weapons (equip Lv38)
    [2] =
    {
        greatsword   = 0, handtohand   = 0,
        staff_heal   = 0, staff_magic  = 0,
        sword        = 0, dagger       = 0,
        ranged       = 0, sword_shield = 0,
        greatkatana  = 0, axe          = 0,
    },
    -- Tier III: Forged weapons (equip Lv48)
    [3] =
    {
        greatsword   = 0, handtohand   = 0,
        staff_heal   = 0, staff_magic  = 0,
        sword        = 0, dagger       = 0,
        ranged       = 0, sword_shield = 0,
        greatkatana  = 0, axe          = 0,
    },
    -- Tier IV: Resolute weapons (equip Lv58)
    [4] =
    {
        greatsword   = 0, handtohand   = 0,
        staff_heal   = 0, staff_magic  = 0,
        sword        = 0, dagger       = 0,
        ranged       = 0, sword_shield = 0,
        greatkatana  = 0, axe          = 0,
    },
    -- Tier V: Proven weapons (equip Lv73, augment slot locked)
    [5] =
    {
        greatsword   = 0, handtohand   = 0,
        staff_heal   = 0, staff_magic  = 0,
        sword        = 0, dagger       = 0,
        ranged       = 0, sword_shield = 0,
        greatkatana  = 0, axe          = 0,
    },
}

-- Reverse lookup: itemId → { tier, family }
-- Built at load time once weapon IDs are populated
xi.provingArms.WEAPON_LOOKUP = {}

xi.provingArms.buildLookup = function()
    xi.provingArms.WEAPON_LOOKUP = {}
    for tier, families in pairs(xi.provingArms.WEAPONS) do
        for family, itemId in pairs(families) do
            if itemId > 0 then
                xi.provingArms.WEAPON_LOOKUP[itemId] = { tier = tier, family = family }
            end
        end
    end
end

-----------------------------------
-- Upgrade recipes: Tier I→II, II→III, III→IV, IV→V
-- materials: list of { itemId (resolved at runtime), qty }
-- circuitPoints: Circuit Points to deduct (Tier III→IV only)
-----------------------------------
xi.provingArms.getRecipe = function(fromTier)
    local item = xi.provingArms.item

    local recipes =
    {
        -- Nascent → Tempered
        [1] =
        {
            materials     = { { id = item.QUFIM_SHARD, qty = 3 } },
            markVar       = '[TierTrial]QufimMarks',
            markCost      = 1,
            circuitPoints = 0,
        },
        -- Tempered → Forged
        [2] =
        {
            materials     = { { id = item.FAUREGANDI_SHARD, qty = 3 } },
            markVar       = '[TierTrial]FauregandiMarks',
            markCost      = 1,
            circuitPoints = 0,
        },
        -- Forged → Resolute
        [3] =
        {
            materials     = { { id = item.PSOXJA_SHARD, qty = 3 } },
            markVar       = '[TierTrial]PsoxjaMarks',
            markCost      = 1,
            circuitPoints = 5,
        },
        -- Resolute → Proven
        [4] =
        {
            materials     =
            {
                { id = item.PSOXJA_SHARD,    qty = 5 },
                { id = item.RESONANCE_KEY,   qty = 1 },
                -- Badge handled separately via BADGE_ITEM_ID
            },
            requiresBadge = true,
            markVar       = nil, -- no mark cost at this step
            markCost      = 0,
            circuitPoints = 0,
        },
    }

    return recipes[fromTier]
end

-----------------------------------
-- Augment pools per origin tier
-- Format: list of { augId, min, max, label }
-- augId references xi.augment constants — fill when augment IDs confirmed
-----------------------------------
xi.provingArms.AUGMENT_POOLS =
{
    [30] = -- Valkurm
    {
        { augId = 0, min = 4,  max = 8,  label = 'Accuracy'          }, -- TODO: xi.augment.ACCURACY
        { augId = 0, min = 4,  max = 8,  label = 'Evasion'           }, -- TODO: xi.augment.EVASION
        { augId = 0, min = 3,  max = 6,  label = 'Enmity'            }, -- TODO: xi.augment.ENMITY (pos or neg randomly)
        { augId = 0, min = 4,  max = 8,  label = 'Magic Attack Bonus' }, -- TODO: xi.augment.MAGIC_ATK_BONUS
    },
    [40] = -- Qufim
    {
        { augId = 0, min = 2,  max = 4,  label = 'Haste'             }, -- TODO: xi.augment.HASTE (%)
        { augId = 0, min = 4,  max = 8,  label = 'Subtle Blow'       }, -- TODO: xi.augment.SUBTLE_BLOW
        { augId = 0, min = 3,  max = 6,  label = 'Cure Potency'      }, -- TODO: xi.augment.CURE_POTENCY (%)
        { augId = 0, min = 4,  max = 8,  label = 'Magic Accuracy'    }, -- TODO: xi.augment.MAGIC_ACCURACY
    },
    [50] = -- Fauregandi
    {
        { augId = 0, min = 2,  max = 4,  label = 'Crit Hit Rate'     }, -- TODO: xi.augment.CRIT_HIT_RATE (%)
        { augId = 0, min = 3,  max = 6,  label = 'Fast Cast'         }, -- TODO: xi.augment.FAST_CAST (%)
        { augId = 0, min = 4,  max = 8,  label = 'Store TP'          }, -- TODO: xi.augment.STORE_TP
        { augId = 0, min = 3,  max = 5,  label = 'Damage Taken'      }, -- TODO: xi.augment.DMG_TAKEN (negative %)
    },
    [60] = -- Pso'Xja
    {
        { augId = 0, min = 2,  max = 4,  label = 'Double Attack'     }, -- TODO: xi.augment.DOUBLE_ATTACK (%)
        { augId = 0, min = 3,  max = 6,  label = 'Conserve MP'       }, -- TODO: xi.augment.CONSERVE_MP
        { augId = 0, min = 3,  max = 6,  label = 'Magic Burst Bonus' }, -- TODO: xi.augment.MAGIC_BURST_BONUS (%)
        { augId = 0, min = 1,  max = 3,  label = 'Resist vs. Element' }, -- TODO: xi.augment.RESIST_ELEMENT (tier)
    },
}

-- Narrower pool for Badge rerolls (excludes top-end picks per tier)
-- Badge can't roll the best augment in each pool — Primal Remnant can
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
    local pool     = xi.provingArms.AUGMENT_POOLS[originTier]
    if not pool then return {} end

    local eligible = {}
    local excluded = badgeReroll and xi.provingArms.BADGE_EXCLUDED[originTier]

    for _, entry in ipairs(pool) do
        if not excluded or entry.label ~= excluded then
            table.insert(eligible, entry)
        end
    end

    -- Shuffle eligible pool and pick 3 (or all if fewer than 3)
    local count   = math.min(3, #eligible)
    local results = {}
    local indices = {}
    for i = 1, #eligible do indices[i] = i end

    for i = 1, count do
        local pick  = math.random(i, #indices)
        indices[i], indices[pick] = indices[pick], indices[i]
        local entry = eligible[indices[i]]
        -- Roll a value within the augment's range
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
            -- Item ID not yet set — always block
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
-- Perform an upgrade: consume from weapon, swap to next tier
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
-- (Proven → Awakened is not an item swap — augment is applied to same item)
-----------------------------------
xi.provingArms.applyAugment = function(player, weaponItemId, augEntry)
    if augEntry.augId == 0 then
        -- Augment ID not yet configured — stub
        return false, 'Augment ID not yet configured for: ' .. augEntry.label
    end
    -- player:addAugment(itemId, augId, value) — confirm API signature with engine
    player:addAugment(weaponItemId, augEntry.augId, augEntry.value)
    return true
end

-----------------------------------
-- Load sub-files
-----------------------------------
require('modules/custom/proving_arms/lua/forge_npc')

-- Build weapon reverse lookup (will be empty until item IDs are filled in,
-- but calling it here ensures it runs once at module load)
xi.provingArms.buildLookup()

return m
