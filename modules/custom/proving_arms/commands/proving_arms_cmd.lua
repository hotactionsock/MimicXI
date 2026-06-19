-----------------------------------
-- GM Commands: Proving Arms
--
-- !forge status              — show all weapon IDs and which are set
-- !forge lookup              — rebuild weapon reverse lookup table
-- !forge upgrade <tier> <job>— force-upgrade weapon for current tier/job
-- !forge augment <tier> <job>— force-activate augment on Proven weapon
--                              tier = origin pool tier (30/40/50/60)
-- !forge reroll <job>        — force-reroll augment (uses full pool)
-- !forge give <tier> <job>   — give Tier I–V weapon for testing
--                              tier = 1–5
-- !forge materials           — print player's current shard/mark/point counts
-----------------------------------

-- Renamed to forge.lua — this file is intentionally empty.
do return {} end

local CMD = {}

local FAMILY_NAMES =
{
    blade    = 'Blade',    nodachi  = 'Nodachi',
    kukri    = 'Kukri',   cesti    = 'Cesti',
    rod      = 'Rod',     falchion = 'Falchion',
    sceptre  = 'Sceptre', spatha   = 'Spatha',
    kite     = 'Kite',    caligo   = 'Caligo',
}

CMD['forge'] = function(player, command, args)
    local sub = args[1]

    if sub == 'status' then
        for tier = 1, 5 do
            local tierLabel = { 'Nascent', 'Tempered', 'Forged', 'Resolute', 'Proven' }
            player:PrintToPlayer('--- Tier ' .. tier .. ': ' .. tierLabel[tier] .. ' ---')
            for family, id in pairs(xi.provingArms.WEAPONS[tier] or {}) do
                local status = id > 0 and ('id=' .. id) or 'NOT SET'
                player:PrintToPlayer(string.format('  %-12s %s', FAMILY_NAMES[family] or family, status))
            end
        end

    elseif sub == 'lookup' then
        xi.provingArms.buildLookup()
        local count = 0
        for _ in pairs(xi.provingArms.WEAPON_LOOKUP) do count = count + 1 end
        player:PrintToPlayer('Lookup rebuilt. ' .. count .. ' weapons indexed.')

    elseif sub == 'upgrade' then
        local tier   = tonumber(args[2]) or 1
        local job    = tonumber(args[3]) or player:getMainJob()
        local family = xi.provingArms.jobFamily(job)
        if not family then
            player:PrintToPlayer('Unknown job: ' .. tostring(job))
            return
        end

        local fromId = xi.provingArms.WEAPONS[tier] and xi.provingArms.WEAPONS[tier][family]
        if not fromId or fromId == 0 then
            player:PrintToPlayer(string.format('Weapon ID not set for tier %d / %s', tier, family))
            return
        end

        if player:getItemCount(fromId) == 0 then
            player:addItem(fromId, 1)
            player:PrintToPlayer('Added source weapon for upgrade test.')
        end

        local ok, err = xi.provingArms.doUpgrade(player, fromId, tier, family)
        if ok then
            player:PrintToPlayer(string.format('Upgraded Tier %d → %d (%s)', tier, tier + 1, family))
        else
            player:PrintToPlayer('Upgrade failed: ' .. tostring(err))
        end

    elseif sub == 'augment' then
        local originTier = tonumber(args[2]) or 60
        local job        = tonumber(args[3]) or player:getMainJob()
        local family     = xi.provingArms.jobFamily(job)
        local provenId   = xi.provingArms.WEAPONS[5] and family and xi.provingArms.WEAPONS[5][family]

        if not provenId or provenId == 0 then
            player:PrintToPlayer('Proven weapon ID not set for family: ' .. tostring(family))
            return
        end

        if player:getItemCount(provenId) == 0 then
            player:addItem(provenId, 1)
            player:PrintToPlayer('Added Proven weapon for augment test.')
        end

        local rolls  = xi.provingArms.rollAugments(originTier, false)
        local chosen = rolls[1]
        if not chosen then
            player:PrintToPlayer('No augments available for origin tier ' .. originTier)
            return
        end

        local ok, err = xi.provingArms.applyAugment(player, provenId, chosen)
        if ok then
            player:PrintToPlayer(string.format(
                'Applied augment: %s +%d (origin tier %d)',
                chosen.label, chosen.value, originTier
            ))
        else
            player:PrintToPlayer('Augment failed: ' .. tostring(err))
        end

    elseif sub == 'reroll' then
        local job    = tonumber(args[2]) or player:getMainJob()
        local family = xi.provingArms.jobFamily(job)
        local provenId = xi.provingArms.WEAPONS[5] and family and xi.provingArms.WEAPONS[5][family]

        if not provenId or provenId == 0 then
            player:PrintToPlayer('Proven weapon ID not set for family: ' .. tostring(family))
            return
        end

        local rolls  = xi.provingArms.rollAugments(60, false)
        local chosen = rolls[math.random(#rolls)]
        if not chosen then
            player:PrintToPlayer('No augments available.')
            return
        end

        local ok, err = xi.provingArms.applyAugment(player, provenId, chosen)
        if ok then
            player:PrintToPlayer(string.format(
                'Rerolled to: %s +%d', chosen.label, chosen.value
            ))
        else
            player:PrintToPlayer('Reroll failed: ' .. tostring(err))
        end

    elseif sub == 'give' then
        local tier   = tonumber(args[2]) or 1
        local job    = tonumber(args[3]) or player:getMainJob()
        local family = xi.provingArms.jobFamily(job)
        if not family then
            player:PrintToPlayer('Unknown job: ' .. tostring(job))
            return
        end

        local itemId = xi.provingArms.WEAPONS[tier] and xi.provingArms.WEAPONS[tier][family]
        if not itemId or itemId == 0 then
            player:PrintToPlayer(string.format('Item ID not set for tier %d / %s', tier, family))
            return
        end

        player:addItem(itemId, 1)
        player:PrintToPlayer(string.format(
            'Gave Tier %d %s (id=%d)', tier, FAMILY_NAMES[family] or family, itemId
        ))

    elseif sub == 'materials' then
        local item = xi.provingArms.item
        local function qty(id)
            return id > 0 and player:getItemCount(id) or 'N/A (unset)'
        end
        player:PrintToPlayer('--- Proving Arms Materials ---')
        player:PrintToPlayer('Nascent Shard:    ' .. qty(item.NASCENT_SHARD))
        player:PrintToPlayer('Tempered Shard:   ' .. qty(item.TEMPERED_SHARD))
        player:PrintToPlayer('Forged Shard:     ' .. qty(item.FORGED_SHARD))
        player:PrintToPlayer('Resolute Shard:   ' .. qty(item.RESOLUTE_SHARD))
        player:PrintToPlayer('Resonance Key:    ' .. qty(item.RESONANCE_KEY))
        player:PrintToPlayer('Awakening Shard:  ' .. qty(item.AWAKENING_SHARD))
        player:PrintToPlayer('Awakening Crystal:' .. qty(item.AWAKENING_CRYSTAL))
        player:PrintToPlayer('Primal Remnant:   ' .. qty(item.PRIMAL_REMNANT))
        local badgeQty = xi.provingArms.BADGE_ITEM_ID > 0
            and player:getItemCount(xi.provingArms.BADGE_ITEM_ID) or 'N/A (unset)'
        player:PrintToPlayer('Platinum Badge:   ' .. badgeQty)
        -- Marks
        local tierVars =
        {
            { label='Valkurm Marks',    var='[TierTrial]ValkurumMarks'    },
            { label='Qufim Marks',      var='[TierTrial]QufimMarks'       },
            { label='Fauregandi Marks', var='[TierTrial]FauregandiMarks'  },
            { label="Pso'Xja Marks",    var='[TierTrial]PsoxjaMarks'      },
        }
        for _, entry in ipairs(tierVars) do
            player:PrintToPlayer(string.format('%-18s %d', entry.label .. ':', player:getCharVar(entry.var)))
        end
        local pts = player:getCharVar(xi.circuit and xi.circuit.POINT_VAR or '[Circuit]Points')
        player:PrintToPlayer('Circuit Points:   ' .. pts)

    else
        player:PrintToPlayer('Usage: !forge <status|lookup|upgrade|augment|reroll|give|materials>')
    end
end

return CMD
