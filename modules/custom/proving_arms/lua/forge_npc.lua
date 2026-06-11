-----------------------------------
-- Resonance Forge NPC — shared logic
--
-- A single NPC in each entrance zone offers the full upgrade chain.
-- Usage from a zone NPC script:
--
--   local forge = require('modules/custom/proving_arms/lua/forge_npc')
--   entity.onTrigger    = forge.onTrigger
--   entity.onEventUpdate = forge.onEventUpdate
--   entity.onEventFinish = forge.onEventFinish
--
-- Menu flow:
--   Root menu → "Upgrade Weapon" | "Activate Augment" | "Reroll Augment" | "Leave"
--   Each path confirms materials before consuming anything.
--
-- State is tracked in player local vars prefixed 'RF_':
--   RF_Menu          current menu state
--   RF_WeaponId      item ID of weapon being worked on
--   RF_WeaponTier    tier of that weapon
--   RF_WeaponFamily  family key index (mapped to string at use)
--   RF_AugChoice1/2/3  rolled augment indices (into pool)
--   RF_AugValues1/2/3  rolled augment values
--   RF_IsReroll      1 if this is a reroll, 0 if first activation
--   RF_BadgeReroll   1 if rerolling with Badge (narrower pool)
-----------------------------------

local forge = {}

-- Menu state constants stored in RF_Menu
local MENU = {
    ROOT         = 0,
    UPGRADE      = 1,
    UPGRADE_CONFIRM = 2,
    AUGMENT      = 3,
    AUGMENT_PICK = 4,
    REROLL       = 5,
    REROLL_PICK  = 6,
}

-- CSIDs — TODO: assign per-zone cutscene IDs
local CSID =
{
    ROOT_MENU       = 0,
    UPGRADE_LIST    = 0,
    UPGRADE_CONFIRM = 0,
    NO_ELIGIBLE     = 0,
    AUGMENT_CHOOSE  = 0,
    AUGMENT_CONFIRM = 0,
    REROLL_CONFIRM  = 0,
    REROLL_CHOOSE   = 0,
    SUCCESS         = 0,
    FAIL_MATERIALS  = 0,
}

-----------------------------------
-- Scan inventory for any Proving Arms weapon that has an upgrade recipe
-- Returns list of { itemId, tier, family, recipe, canUpgrade }
-----------------------------------
local function findUpgradeable(player)
    local results = {}
    xi.provingArms.buildLookup()

    for itemId, info in pairs(xi.provingArms.WEAPON_LOOKUP) do
        if info.tier < 5 and player:getItemCount(itemId) > 0 then
            local recipe = xi.provingArms.getRecipe(info.tier)
            if recipe then
                local canUpgrade = xi.provingArms.checkMaterials(player, recipe)
                table.insert(results, {
                    itemId     = itemId,
                    tier       = info.tier,
                    family     = info.family,
                    recipe     = recipe,
                    canUpgrade = canUpgrade,
                })
            end
        end
    end

    return results
end

-----------------------------------
-- Scan inventory for Proven weapons (Tier V) that can have augments activated
-----------------------------------
local function findProvens(player)
    local results = {}
    xi.provingArms.buildLookup()

    for itemId, info in pairs(xi.provingArms.WEAPON_LOOKUP) do
        if info.tier == 5 and player:getItemCount(itemId) > 0 then
            -- Check if weapon already has augment active
            -- player:getAugment(itemId) returns augId or 0 if none
            local hasAugment = player:getAugment and player:getAugment(itemId, 1) ~= nil
            table.insert(results, {
                itemId     = itemId,
                family     = info.family,
                hasAugment = hasAugment,
            })
        end
    end

    return results
end

-----------------------------------
-- Store rolled augment options in player local vars
-----------------------------------
local function storeRolledAugments(player, rolls)
    for i = 1, 3 do
        local roll = rolls[i]
        if roll then
            player:setLocalVar('RF_AugChoice' .. i, roll.augId)
            player:setLocalVar('RF_AugValue'  .. i, roll.value)
            -- Label can't be stored in local var — reconstructed from augId at apply time
        else
            player:setLocalVar('RF_AugChoice' .. i, 0)
            player:setLocalVar('RF_AugValue'  .. i, 0)
        end
    end
end

-----------------------------------
-- NPC entry point
-----------------------------------
forge.onTrigger = function(player, npc)
    player:setLocalVar('RF_Menu', MENU.ROOT)
    player:startEvent(CSID.ROOT_MENU)
end

-----------------------------------
-- Event update handler — drives the menu state machine
-- option meanings depend on current menu state (set by client event)
-----------------------------------
forge.onEventUpdate = function(player, csid, option, npc)
    local menu = player:getLocalVar('RF_Menu')

    -- Root menu: 0=Upgrade, 1=Augment, 2=Reroll, 3=Leave
    if menu == MENU.ROOT then
        if option == 3 then
            player:release()
            return false
        elseif option == 0 then
            player:setLocalVar('RF_Menu', MENU.UPGRADE)
        elseif option == 1 then
            player:setLocalVar('RF_Menu', MENU.AUGMENT)
        elseif option == 2 then
            player:setLocalVar('RF_Menu', MENU.REROLL)
        end
        return true

    -- Upgrade path: find eligible weapons and present list
    elseif menu == MENU.UPGRADE then
        local eligible = findUpgradeable(player)
        if #eligible == 0 then
            player:startEvent(CSID.NO_ELIGIBLE)
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        -- Store first eligible weapon (TODO: multi-weapon picker if player has >1)
        local entry = eligible[1]
        player:setLocalVar('RF_WeaponId',  entry.itemId)
        player:setLocalVar('RF_WeaponTier', entry.tier)
        player:setLocalVar('RF_Menu', MENU.UPGRADE_CONFIRM)

        -- Show confirmation: passes tier info so event can display material list
        player:updateEvent(entry.tier, entry.canUpgrade and 1 or 0)
        return true

    -- Upgrade confirmation: option 0 = confirm, 1 = cancel
    elseif menu == MENU.UPGRADE_CONFIRM then
        if option == 1 then
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        local weaponId = player:getLocalVar('RF_WeaponId')
        local tier     = player:getLocalVar('RF_WeaponTier')
        local info     = xi.provingArms.WEAPON_LOOKUP[weaponId]
        if not info then
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        local recipe   = xi.provingArms.getRecipe(tier)
        local ok, _    = xi.provingArms.checkMaterials(player, recipe)
        if not ok then
            player:startEvent(CSID.FAIL_MATERIALS)
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        xi.provingArms.consumeMaterials(player, recipe)
        local success, err = xi.provingArms.doUpgrade(player, weaponId, tier, info.family)

        if success then
            player:startEvent(CSID.SUCCESS)
        end

        player:setLocalVar('RF_Menu', MENU.ROOT)
        return true

    -- Augment activation path
    elseif menu == MENU.AUGMENT then
        local provens = findProvens(player)
        -- Filter to only those without an augment
        local eligible = {}
        for _, p in ipairs(provens) do
            if not p.hasAugment then
                table.insert(eligible, p)
            end
        end

        if #eligible == 0 then
            player:startEvent(CSID.NO_ELIGIBLE)
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        local entry = eligible[1]
        player:setLocalVar('RF_WeaponId', entry.itemId)
        player:setLocalVar('RF_IsReroll', 0)

        -- Determine origin tier from family (look up which tier's WEAPONS table this item is in)
        local originTier = 30 -- default; derived from weapon ID lookup
        for tier = 1, 5 do
            for fam, id in pairs(xi.provingArms.WEAPONS[tier] or {}) do
                if id == entry.itemId then
                    -- Map weapon tier to augment origin tier
                    -- Tier 5 weapons all come from the Tier IV shard path
                    -- Origin pool determined by the tier's cap: 1→30, 2→40, 3→50, 4→60
                    -- Proven (tier 5) inherits from its tier IV origin = cap 60... but
                    -- each weapon family has only one Proven item, so origin = Pso'Xja (60)
                    -- unless we add origin tracking. For now default to 60.
                    originTier = 60
                end
            end
        end

        -- Check for activation material (Awakening Shard ×3 or Crystal ×1)
        local item      = xi.provingArms.item
        local hasCrystal = item.AWAKENING_CRYSTAL > 0 and
                           player:getItemCount(item.AWAKENING_CRYSTAL) >= 1
        local hasShard   = item.AWAKENING_SHARD > 0 and
                           player:getItemCount(item.AWAKENING_SHARD) >= 3

        if not hasCrystal and not hasShard then
            player:startEvent(CSID.FAIL_MATERIALS)
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        -- Roll 3 augment options
        local rolls = xi.provingArms.rollAugments(originTier, false)
        storeRolledAugments(player, rolls)
        player:setLocalVar('RF_Menu', MENU.AUGMENT_PICK)

        -- Pass rolled augment labels to event for display
        -- option encoding: client expects augId*1000 + value for each slot
        player:updateEvent(
            rolls[1] and rolls[1].augId * 1000 + rolls[1].value or 0,
            rolls[2] and rolls[2].augId * 1000 + rolls[2].value or 0,
            rolls[3] and rolls[3].augId * 1000 + rolls[3].value or 0
        )
        return true

    -- Augment pick: option 0/1/2 = which of the 3 to apply
    elseif menu == MENU.AUGMENT_PICK then
        local choice   = option + 1  -- 1-indexed
        local weaponId = player:getLocalVar('RF_WeaponId')
        local augId    = player:getLocalVar('RF_AugChoice' .. choice)
        local augVal   = player:getLocalVar('RF_AugValue'  .. choice)

        if augId and augId > 0 then
            -- Consume activation material (Crystal preferred over Shards)
            local item = xi.provingArms.item
            if item.AWAKENING_CRYSTAL > 0 and player:getItemCount(item.AWAKENING_CRYSTAL) >= 1 then
                player:removeItem(item.AWAKENING_CRYSTAL, 1)
            elseif item.AWAKENING_SHARD > 0 then
                player:removeItem(item.AWAKENING_SHARD, 3)
            end

            xi.provingArms.applyAugment(player, weaponId, { augId = augId, value = augVal })
            player:startEvent(CSID.SUCCESS)
        end

        player:setLocalVar('RF_Menu', MENU.ROOT)
        return true

    -- Reroll path
    elseif menu == MENU.REROLL then
        local provens = findProvens(player)
        local eligible = {}
        for _, p in ipairs(provens) do
            if p.hasAugment then
                table.insert(eligible, p)
            end
        end

        if #eligible == 0 then
            player:startEvent(CSID.NO_ELIGIBLE)
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        -- Determine reroll material available
        local item         = xi.provingArms.item
        local hasRemnant   = item.PRIMAL_REMNANT > 0 and
                             player:getItemCount(item.PRIMAL_REMNANT) >= 1
        local hasBadge     = xi.provingArms.BADGE_ITEM_ID > 0 and
                             player:getItemCount(xi.provingArms.BADGE_ITEM_ID) >= 1

        if not hasRemnant and not hasBadge then
            player:startEvent(CSID.FAIL_MATERIALS)
            player:setLocalVar('RF_Menu', MENU.ROOT)
            return true
        end

        local entry      = eligible[1]
        local badgeReroll = not hasRemnant  -- Badge = narrower pool
        player:setLocalVar('RF_WeaponId',   entry.itemId)
        player:setLocalVar('RF_BadgeReroll', badgeReroll and 1 or 0)
        player:setLocalVar('RF_IsReroll',   1)

        local rolls = xi.provingArms.rollAugments(60, badgeReroll) -- TODO: track origin tier per weapon
        storeRolledAugments(player, rolls)
        player:setLocalVar('RF_Menu', MENU.REROLL_PICK)

        player:updateEvent(
            rolls[1] and rolls[1].augId * 1000 + rolls[1].value or 0,
            rolls[2] and rolls[2].augId * 1000 + rolls[2].value or 0,
            rolls[3] and rolls[3].augId * 1000 + rolls[3].value or 0
        )
        return true

    -- Reroll pick: same as augment pick but consumes reroll material
    elseif menu == MENU.REROLL_PICK then
        local choice     = option + 1
        local weaponId   = player:getLocalVar('RF_WeaponId')
        local augId      = player:getLocalVar('RF_AugChoice' .. choice)
        local augVal     = player:getLocalVar('RF_AugValue'  .. choice)
        local badgeReroll = player:getLocalVar('RF_BadgeReroll') == 1

        if augId and augId > 0 then
            -- Consume reroll material (Remnant preferred)
            local item = xi.provingArms.item
            if not badgeReroll and item.PRIMAL_REMNANT > 0 then
                player:removeItem(item.PRIMAL_REMNANT, 1)
            elseif xi.provingArms.BADGE_ITEM_ID > 0 then
                player:removeItem(xi.provingArms.BADGE_ITEM_ID, 1)
            end

            xi.provingArms.applyAugment(player, weaponId, { augId = augId, value = augVal })
            player:startEvent(CSID.SUCCESS)
        end

        player:setLocalVar('RF_Menu', MENU.ROOT)
        return true
    end

    return false
end

forge.onEventFinish = function(player, csid, option, npc)
    -- Clean up local vars on any exit path
    player:setLocalVar('RF_Menu',        0)
    player:setLocalVar('RF_WeaponId',    0)
    player:setLocalVar('RF_WeaponTier',  0)
    player:setLocalVar('RF_IsReroll',    0)
    player:setLocalVar('RF_BadgeReroll', 0)
    for i = 1, 3 do
        player:setLocalVar('RF_AugChoice' .. i, 0)
        player:setLocalVar('RF_AugValue'  .. i, 0)
    end
end

return forge
