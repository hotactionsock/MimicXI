-----------------------------------
-- GM Command: !forge
--
-- !forge status              — show all weapon IDs and which are set
-- !forge lookup              — rebuild weapon reverse lookup table
-- !forge upgrade <tier> <job>— force-upgrade weapon for current tier/job
-- !forge augment <tier> <job>— force-activate augment on Proven weapon
-- !forge reroll <job>        — force-reroll augment
-- !forge give <tier> <job>   — give Tier I–V weapon for testing
-- !forge materials           — print player's current shard/mark/point counts
-----------------------------------
local commandObj = {}

local FAMILY_NAMES =
{
    blade    = 'Blade',    nodachi  = 'Nodachi',
    kukri    = 'Kukri',    cesti    = 'Cesti',
    rod      = 'Rod',      falchion = 'Falchion',
    sceptre  = 'Sceptre',  spatha   = 'Spatha',
    kite     = 'Kite',     caligo   = 'Caligo',
}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss',
}

commandObj.onTrigger = function(player, sub, arg1, arg2)
    if sub == 'status' then
        local tierLabel = { 'Nascent', 'Tempered', 'Forged', 'Resolute', 'Proven' }
        for tier = 1, 5 do
            player:printToPlayer('--- Tier ' .. tier .. ': ' .. tierLabel[tier] .. ' ---')
            for family, id in pairs(xi.provingArms.WEAPONS[tier] or {}) do
                local status = id > 0 and ('id=' .. id) or 'NOT SET'
                player:printToPlayer(string.format('  %-12s %s', FAMILY_NAMES[family] or family, status))
            end
        end

    elseif sub == 'lookup' then
        xi.provingArms.buildLookup()
        local count = 0
        for _ in pairs(xi.provingArms.WEAPON_LOOKUP) do count = count + 1 end
        player:printToPlayer('Lookup rebuilt. ' .. count .. ' weapons indexed.')

    elseif sub == 'upgrade' then
        local tier   = tonumber(arg1) or 1
        local job    = tonumber(arg2) or player:getMainJob()
        local family = xi.provingArms.jobFamily(job)
        if not family then
            player:printToPlayer('Unknown job: ' .. tostring(job))
            return
        end
        local fromId = xi.provingArms.WEAPONS[tier] and xi.provingArms.WEAPONS[tier][family]
        if not fromId or fromId == 0 then
            player:printToPlayer(string.format('Weapon ID not set for tier %d / %s', tier, family))
            return
        end
        if player:getItemCount(fromId) == 0 then
            player:addItem(fromId, 1)
            player:printToPlayer('Added source weapon for upgrade test.')
        end
        local ok, err = xi.provingArms.doUpgrade(player, fromId, tier, family)
        if ok then
            player:printToPlayer(string.format('Upgraded Tier %d → %d (%s)', tier, tier + 1, family))
        else
            player:printToPlayer('Upgrade failed: ' .. tostring(err))
        end

    elseif sub == 'augment' then
        local originTier = tonumber(arg1) or 60
        local job        = tonumber(arg2) or player:getMainJob()
        local family     = xi.provingArms.jobFamily(job)
        local provenId   = xi.provingArms.WEAPONS[5] and family and xi.provingArms.WEAPONS[5][family]
        if not provenId or provenId == 0 then
            player:printToPlayer('Proven weapon ID not set for family: ' .. tostring(family))
            return
        end
        if player:getItemCount(provenId) == 0 then
            player:addItem(provenId, 1)
            player:printToPlayer('Added Proven weapon for augment test.')
        end
        local rolls  = xi.provingArms.rollAugments(originTier, false)
        local chosen = rolls[1]
        if not chosen then
            player:printToPlayer('No augments available for origin tier ' .. originTier)
            return
        end
        local ok, err = xi.provingArms.applyAugment(player, provenId, chosen)
        if ok then
            player:printToPlayer(string.format('Applied augment: %s +%d (origin tier %d)', chosen.label, chosen.value, originTier))
        else
            player:printToPlayer('Augment failed: ' .. tostring(err))
        end

    elseif sub == 'reroll' then
        local job      = tonumber(arg1) or player:getMainJob()
        local family   = xi.provingArms.jobFamily(job)
        local provenId = xi.provingArms.WEAPONS[5] and family and xi.provingArms.WEAPONS[5][family]
        if not provenId or provenId == 0 then
            player:printToPlayer('Proven weapon ID not set for family: ' .. tostring(family))
            return
        end
        local rolls  = xi.provingArms.rollAugments(60, false)
        local chosen = rolls[math.random(#rolls)]
        if not chosen then
            player:printToPlayer('No augments available.')
            return
        end
        local ok, err = xi.provingArms.applyAugment(player, provenId, chosen)
        if ok then
            player:printToPlayer(string.format('Rerolled to: %s +%d', chosen.label, chosen.value))
        else
            player:printToPlayer('Reroll failed: ' .. tostring(err))
        end

    elseif sub == 'give' then
        local tier   = tonumber(arg1) or 1
        local job    = tonumber(arg2) or player:getMainJob()
        local family = xi.provingArms.jobFamily(job)
        if not family then
            player:printToPlayer('Unknown job: ' .. tostring(job))
            return
        end
        local itemId = xi.provingArms.WEAPONS[tier] and xi.provingArms.WEAPONS[tier][family]
        if not itemId or itemId == 0 then
            player:printToPlayer(string.format('Item ID not set for tier %d / %s', tier, family))
            return
        end
        player:addItem(itemId, 1)
        player:printToPlayer(string.format('Gave Tier %d %s (id=%d)', tier, FAMILY_NAMES[family] or family, itemId))

    elseif sub == 'materials' then
        local item = xi.provingArms.item
        local function qty(id)
            return id > 0 and player:getItemCount(id) or 'N/A (unset)'
        end
        player:printToPlayer('--- Proving Arms Materials ---')
        player:printToPlayer('Nascent Shard:     ' .. qty(item.NASCENT_SHARD))
        player:printToPlayer('Tempered Shard:    ' .. qty(item.TEMPERED_SHARD))
        player:printToPlayer('Forged Shard:      ' .. qty(item.FORGED_SHARD))
        player:printToPlayer('Resolute Shard:    ' .. qty(item.RESOLUTE_SHARD))
        player:printToPlayer('Resonance Key:     ' .. qty(item.RESONANCE_KEY))
        player:printToPlayer('Awakening Shard:   ' .. qty(item.AWAKENING_SHARD))
        player:printToPlayer('Awakening Crystal: ' .. qty(item.AWAKENING_CRYSTAL))
        player:printToPlayer('Primal Remnant:    ' .. qty(item.PRIMAL_REMNANT))
        local badgeQty = xi.provingArms.BADGE_ITEM_ID > 0
            and player:getItemCount(xi.provingArms.BADGE_ITEM_ID) or 'N/A (unset)'
        player:printToPlayer('Platinum Badge:    ' .. badgeQty)
        local tierVars =
        {
            { label = 'Valkurm Marks',    var = '[TierTrial]ValkurumMarks'   },
            { label = 'Qufim Marks',      var = '[TierTrial]QufimMarks'      },
            { label = 'Fauregandi Marks', var = '[TierTrial]FauregandiMarks' },
            { label = "Pso'Xja Marks",    var = '[TierTrial]PsoxjaMarks'     },
        }
        for _, entry in ipairs(tierVars) do
            player:printToPlayer(string.format('%-18s %d', entry.label .. ':', player:getCharVar(entry.var)))
        end
        local pts = player:getCharVar(xi.circuit and xi.circuit.POINT_VAR or '[Circuit]Points')
        player:printToPlayer('Circuit Points:    ' .. pts)

    else
        player:printToPlayer('Usage: !forge <status|lookup|upgrade|augment|reroll|give|materials>')
    end
end

return commandObj
