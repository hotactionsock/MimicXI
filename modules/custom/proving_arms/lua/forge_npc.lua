-----------------------------------
-- Resonance Forge NPC — shared logic
--
-- A single NPC in each entrance zone offers the full upgrade chain.
-- Usage from a zone NPC script:
--
--   local forge = require('modules/custom/proving_arms/lua/forge_npc')
--   entity.onTrigger = forge.onTrigger
-----------------------------------

local forge = {}

local TIER_LABEL = { 'Nascent', 'Tempered', 'Forged', 'Resolute', 'Proven' }

local FAMILY_LABEL =
{
    blade    = 'Blade',    nodachi  = 'Nodachi',
    kukri    = 'Kukri',   cesti    = 'Cesti',
    rod      = 'Rod',     falchion = 'Falchion',
    sceptre  = 'Sceptre', spatha   = 'Spatha',
    kite     = 'Kite',    caligo   = 'Caligo',
}

local function msg(player, text)
    player:printToPlayer(text, xi.msg.channel.SYSTEM_3)
end

-----------------------------------
-- Augment pick menu
-- rolls: list of { augId, value, label }
-- onPick: function(player, roll)
-----------------------------------
local function showAugmentPick(player, rolls, onPick)
    local options = {}
    for _, roll in ipairs(rolls) do
        local r = roll
        table.insert(options, {
            string.format('%s +%d', r.label, r.value),
            function(p) onPick(p, r) end,
        })
    end
    table.insert(options, { 'Cancel', function() end })

    player:timer(100, function(p)
        p:customMenu({ title = 'Choose Augment', options = options })
    end)
end

-----------------------------------
-- Upgrade path
-----------------------------------
local function showUpgradeMenu(player)
    xi.provingArms.buildLookup()
    local eligible = {}

    for itemId, info in pairs(xi.provingArms.WEAPON_LOOKUP) do
        if info.tier < 5 and player:getItemCount(itemId) > 0 then
            local recipe = xi.provingArms.getRecipe(info.tier)
            if recipe then
                local canDo, _ = xi.provingArms.checkMaterials(player, recipe)
                table.insert(eligible, {
                    itemId = itemId, tier = info.tier,
                    family = info.family, recipe = recipe, canDo = canDo,
                })
            end
        end
    end

    if #eligible == 0 then
        msg(player, 'No upgradeable weapons found.')
        return
    end

    local options = {}
    for _, entry in ipairs(eligible) do
        local e = entry
        local tierName  = TIER_LABEL[e.tier] or ('Tier '..e.tier)
        local famName   = FAMILY_LABEL[e.family] or e.family
        local readyMark = e.canDo and '' or ' [!]'
        table.insert(options, {
            string.format('%s %s->%s%s', famName, tierName,
                TIER_LABEL[e.tier+1] or '?', readyMark),
            function(p)
                local ok, missing = xi.provingArms.checkMaterials(p, e.recipe)
                if not ok then
                    msg(p, 'Missing materials for this upgrade.')
                    return
                end

                -- Confirm sub-menu
                player:timer(100, function(pp)
                    pp:customMenu({
                        title = string.format('%s->%s Confirm',
                            tierName, TIER_LABEL[e.tier+1] or '?'),
                        options = {
                            { 'Upgrade', function(ppp)
                                xi.provingArms.consumeMaterials(ppp, e.recipe)
                                local success, err = xi.provingArms.doUpgrade(
                                    ppp, e.itemId, e.tier, e.family)
                                if success then
                                    msg(ppp, string.format('%s %s complete.',
                                        famName, TIER_LABEL[e.tier+1] or ''))
                                else
                                    msg(ppp, 'Upgrade failed: ' .. tostring(err))
                                end
                            end },
                            { 'Cancel', function() end },
                        },
                    })
                end)
            end,
        })
    end
    table.insert(options, { 'Back', function(p) forge.onTrigger(p, nil) end })

    player:timer(100, function(p)
        p:customMenu({ title = 'Upgrade Weapon', options = options })
    end)
end

-----------------------------------
-- Augment activation path (first-time, Proven weapons without augment)
-----------------------------------
local function showAugmentMenu(player)
    xi.provingArms.buildLookup()
    local eligible = {}

    for itemId, info in pairs(xi.provingArms.WEAPON_LOOKUP) do
        if info.tier == 5 and player:getItemCount(itemId) > 0 then
            local hasAug = player:getAugment and player:getAugment(itemId, 1) ~= nil
            if not hasAug then
                table.insert(eligible, { itemId=itemId, family=info.family })
            end
        end
    end

    if #eligible == 0 then
        msg(player, 'No Proven weapons available for augment.')
        return
    end

    local item       = xi.provingArms.item
    local hasCrystal = item.AWAKENING_CRYSTAL > 0 and
                       player:getItemCount(item.AWAKENING_CRYSTAL) >= 1
    local hasShard   = item.AWAKENING_SHARD > 0 and
                       player:getItemCount(item.AWAKENING_SHARD) >= 3

    if not hasCrystal and not hasShard then
        msg(player, 'Need Awakening Crystal x1 or Shard x3.')
        return
    end

    local entry  = eligible[1]
    local rolls  = xi.provingArms.rollAugments(60, false)

    showAugmentPick(player, rolls, function(p, chosen)
        -- Consume material (Crystal preferred)
        if item.AWAKENING_CRYSTAL > 0 and p:getItemCount(item.AWAKENING_CRYSTAL) >= 1 then
            p:removeItem(item.AWAKENING_CRYSTAL, 1)
        elseif item.AWAKENING_SHARD > 0 then
            p:removeItem(item.AWAKENING_SHARD, 3)
        end

        local ok, err = xi.provingArms.applyAugment(p, entry.itemId, chosen)
        if ok then
            msg(p, string.format('Augment applied: %s +%d', chosen.label, chosen.value))
        else
            msg(p, 'Augment failed: ' .. tostring(err))
        end
    end)
end

-----------------------------------
-- Reroll path (Proven weapons that already have an augment)
-----------------------------------
local function showRerollMenu(player)
    xi.provingArms.buildLookup()
    local eligible = {}

    for itemId, info in pairs(xi.provingArms.WEAPON_LOOKUP) do
        if info.tier == 5 and player:getItemCount(itemId) > 0 then
            local hasAug = player:getAugment and player:getAugment(itemId, 1) ~= nil
            if hasAug then
                table.insert(eligible, { itemId=itemId, family=info.family })
            end
        end
    end

    if #eligible == 0 then
        msg(player, 'No augmented Proven weapons found.')
        return
    end

    local item       = xi.provingArms.item
    local hasRemnant = item.PRIMAL_REMNANT > 0 and
                       player:getItemCount(item.PRIMAL_REMNANT) >= 1
    local hasBadge   = xi.provingArms.BADGE_ITEM_ID > 0 and
                       player:getItemCount(xi.provingArms.BADGE_ITEM_ID) >= 1

    if not hasRemnant and not hasBadge then
        msg(player, 'Need Primal Remnant x1 or Platinum Badge x1.')
        return
    end

    local badgeReroll = not hasRemnant
    local entry       = eligible[1]
    local rolls       = xi.provingArms.rollAugments(60, badgeReroll)

    if badgeReroll then
        msg(player, 'Using Badge: premium augments excluded.')
    end

    showAugmentPick(player, rolls, function(p, chosen)
        if not badgeReroll and item.PRIMAL_REMNANT > 0 then
            p:removeItem(item.PRIMAL_REMNANT, 1)
        elseif xi.provingArms.BADGE_ITEM_ID > 0 then
            p:removeItem(xi.provingArms.BADGE_ITEM_ID, 1)
        end

        local ok, err = xi.provingArms.applyAugment(p, entry.itemId, chosen)
        if ok then
            msg(p, string.format('Rerolled to: %s +%d', chosen.label, chosen.value))
        else
            msg(p, 'Reroll failed: ' .. tostring(err))
        end
    end)
end

-----------------------------------
-- Root menu
-----------------------------------
forge.onTrigger = function(player, npc)
    player:timer(100, function(p)
        p:customMenu({
            title = 'Resonance Forge',
            options = {
                { 'Upgrade Weapon',   function(pp) showUpgradeMenu(pp)  end },
                { 'Activate Augment', function(pp) showAugmentMenu(pp)  end },
                { 'Reroll Augment',   function(pp) showRerollMenu(pp)   end },
                { 'Leave',            function() end                        },
            },
        })
    end)
end

return forge
