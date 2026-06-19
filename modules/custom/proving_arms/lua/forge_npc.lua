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
-- Upgrade / acquire path
-- Shows ALL weapon families. Players choose which path to pursue regardless
-- of current job. Families with no weapon show an Acquire option; families
-- with a T1-T4 weapon show the next upgrade; T5 families are omitted (complete).
-----------------------------------
local FAMILIES =
{
    'blade', 'nodachi', 'kukri', 'cesti', 'rod',
    'falchion', 'sceptre', 'spatha', 'kite', 'caligo',
}

local function showUpgradeMenu(player)
    xi.provingArms.buildLookup()

    local options = {}

    for _, family in ipairs(FAMILIES) do
        local fam     = family
        local famName = FAMILY_LABEL[family] or family

        -- Find the highest tier the player owns for this family
        local currentTier   = 0
        local currentItemId = nil
        for tier = 5, 1, -1 do
            local id = xi.provingArms.WEAPONS[tier] and xi.provingArms.WEAPONS[tier][fam]
            if id and id > 0 and player:getItemCount(id) > 0 then
                currentTier   = tier
                currentItemId = id
                break
            end
        end

        if currentTier == 0 then
            -- No weapon in this family — offer Tier 1 acquisition
            local recipe = xi.provingArms.getAcquireRecipe(1)
            local canDo  = recipe and xi.provingArms.checkMaterials(player, recipe)
            table.insert(options, {
                string.format('%s: Acquire Nascent%s', famName, canDo and '' or ' [!]'),
                function(p)
                    local ok = recipe and xi.provingArms.checkMaterials(p, recipe)
                    if not ok then
                        msg(p, 'Need 1 Nascent Shard + 1 Valkurm Mark to start this path.')
                        return
                    end
                    local t1Id = xi.provingArms.WEAPONS[1] and xi.provingArms.WEAPONS[1][fam]
                    if not t1Id or t1Id == 0 then
                        msg(p, famName .. ' Tier 1 not yet configured.')
                        return
                    end
                    p:timer(100, function(pp)
                        pp:customMenu({
                            title   = 'Acquire ' .. famName,
                            options =
                            {
                                { 'Acquire Nascent', function(ppp)
                                    xi.provingArms.consumeMaterials(ppp, recipe)
                                    ppp:addItem(t1Id, 1)
                                    msg(ppp, famName .. ' Nascent acquired.')
                                end },
                                { 'Cancel', function() end },
                            },
                        })
                    end)
                end,
            })

        elseif currentTier < 5 then
            -- Player has T1-T4 of this family — offer the next upgrade
            local recipe = xi.provingArms.getRecipe(currentTier)
            if recipe then
                local e =
                {
                    itemId = currentItemId,
                    tier   = currentTier,
                    family = fam,
                    recipe = recipe,
                }
                local canDo    = xi.provingArms.checkMaterials(player, recipe)
                local tierName = TIER_LABEL[e.tier] or ('Tier '..e.tier)
                local nextName = TIER_LABEL[e.tier + 1] or '?'
                table.insert(options, {
                    string.format('%s %s->%s%s', famName, tierName, nextName, canDo and '' or ' [!]'),
                    function(p)
                        local ok, _ = xi.provingArms.checkMaterials(p, e.recipe)
                        if not ok then
                            msg(p, 'Missing materials for this upgrade.')
                            return
                        end
                        p:timer(100, function(pp)
                            pp:customMenu({
                                title   = string.format('%s %s->%s Confirm', famName, tierName, nextName),
                                options =
                                {
                                    { 'Upgrade', function(ppp)
                                        xi.provingArms.consumeMaterials(ppp, e.recipe)
                                        local success, err = xi.provingArms.doUpgrade(ppp, e.itemId, e.tier, e.family)
                                        if success then
                                            msg(ppp, string.format('%s %s complete.', famName, nextName))
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
        end
        -- T5 (Proven) families omitted — use Activate/Reroll Augment menus
    end

    if #options == 0 then
        msg(player, 'All weapon paths at Proven tier. Use Activate/Reroll Augment.')
        return
    end

    table.insert(options, { 'Back', function(p) forge.onTrigger(p, nil) end })

    player:timer(100, function(p)
        p:customMenu({ title = 'Weapon Paths', options = options })
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
            local hasAug = player:getAugment(itemId, 1) ~= nil
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
            local hasAug = player:getAugment(itemId, 1) ~= nil
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
