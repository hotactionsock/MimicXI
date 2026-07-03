-----------------------------------
-- Nephalem Rift — LQS Module
-- Toggle: add RIFT = { ENABLED = false } to map settings to disable.
-----------------------------------
local m = Module:new("lqs_rift")

if xi.settings and xi.settings.main and xi.settings.main.RIFT and xi.settings.main.RIFT.ENABLED == false then
    return m
end

require('scripts/globals/rift')

-----------------------------------
-- Purveyor shop helpers
-----------------------------------

-- Opens a paginated LQS.simpleShop for one shard tier.
-- Each item in the catalogue is converted to { displayName (with cost), itemId, cost }
-- which is the format LQS.simpleShop expects.
local function openShop(player, npc, tier, currencyItemId)
    local catalogue  = xi.rift.PURVEYOR_SHOP[tier]
    local balance    = xi.rift.getPurveyorBalance(player, currencyItemId)
    local currName   = xi.rift.SHARD_NAME[currencyItemId]

    local shopList = {}
    for _, entry in ipairs(catalogue) do
        table.insert(shopList, { entry.name, entry.item, entry.cost })
    end

    local purchaseFunc = function(p, n, item)
        local cost = item[3]
        local bal  = xi.rift.getPurveyorBalance(p, currencyItemId)

        if cost > bal then
            p:sys(string.format("You need %d %s for that. You only have %d.", cost, currName, bal))
            return
        end

        -- Confirm menu before deducting
        p:timer(300, function(pArg)
            pArg:customMenu({
                title = string.format("Buy %s (%d %s)?", item[1], cost, currName),
                options =
                {
                    {
                        "No",
                        function() end,
                    },
                    {
                        "Yes",
                        function()
                            if npcUtil.giveItem(pArg, item[2]) then
                                xi.rift.addPurveyorShards(pArg, currencyItemId, -cost)
                                local remaining = xi.rift.getPurveyorBalance(pArg, currencyItemId)
                                pArg:sys(string.format(
                                    "You obtained %s. You have %d %s remaining.",
                                    item[1], remaining, currName))
                            end
                        end,
                    },
                },
            })
        end)
    end

    LQS.simpleShop(player, npc, shopList, purchaseFunc,
        string.format("%s Shop  [%d %s]", currName, balance, currName))
end

-- Opens a sub-menu listing all available trade-downs with current balances shown.
local function openTradeDown(player, npc)
    local options = {}

    for _, entry in ipairs(xi.rift.TRADE_DOWN) do
        local fromBal  = xi.rift.getPurveyorBalance(player, entry.from)
        local fromName = xi.rift.SHARD_NAME[entry.from]
        local toName   = xi.rift.SHARD_NAME[entry.to]
        local label    = string.format("%s → %dx %s  (have %d)", fromName, entry.ratio, toName, fromBal)

        -- Capture loop vars for the closure
        local capturedFrom  = entry.from
        local capturedRatio = entry.ratio
        local capturedTo    = entry.to

        table.insert(options, {
            label,
            function()
                local bal = xi.rift.getPurveyorBalance(player, capturedFrom)
                if bal < 1 then
                    player:sys(string.format("You don't have any %s to break down.", fromName))
                    return
                end
                xi.rift.addPurveyorShards(player, capturedFrom, -1)
                local gained  = capturedRatio
                xi.rift.addPurveyorShards(player, capturedTo, gained)
                local newFrom = xi.rift.getPurveyorBalance(player, capturedFrom)
                local newTo   = xi.rift.getPurveyorBalance(player, capturedTo)
                player:sys(string.format(
                    "Converted 1 %s into %d %s. You now have %d and %d respectively.",
                    fromName, gained, toName, newFrom, newTo))
            end,
        })
    end

    player:timer(300, function(p)
        p:customMenu({ title = "Break down shards (1 at a time)", options = options })
    end)
end

-----------------------------------
-- NPC callbacks
-----------------------------------

-- Surveyor: cycles available tiers and sends the player into the Rift.
local function surveyorTrigger(player, npc)
    xi.rift.onSurveyorTrigger(player, npc)
end

-- Purveyor: trade shards in to credit the stored balance.
local function purveyorTrade(player, npc, trade)
    local deposited = false

    for itemId, _ in pairs(xi.rift.PURVEYOR_VAR) do
        local qty = trade:getItemQty(itemId)
        if qty > 0 then
            trade:removeItem(itemId, qty)
            xi.rift.addPurveyorShards(player, itemId, qty)
            local newTotal  = xi.rift.getPurveyorBalance(player, itemId)
            local shardName = xi.rift.SHARD_NAME[itemId]
            if qty == 1 then
                player:messageText(npc, string.format(
                    "So, that's 1 %s. You've got %d in total now.",
                    shardName, newTotal))
            else
                player:messageText(npc, string.format(
                    "So, that's %d %ss, very nice. You've got %d in total now.",
                    qty, shardName, newTotal))
            end
            deposited = true
        end
    end

    if not deposited then
        player:messageText(npc, "Hmm, I'm afraid I can't do anything with that.")
    end
end

-- Opens a quantity picker then withdraws physical shard items to inventory.
local function openWithdraw(player, npc, currencyItemId)
    local bal      = xi.rift.getPurveyorBalance(player, currencyItemId)
    local currName = xi.rift.SHARD_NAME[currencyItemId]

    if bal < 1 then
        player:sys(string.format("You have no %s stored.", currName))
        return
    end

    -- Build quantity options up to the player's balance.
    local presets = { 1, 5, 10, 25, 50 }
    local options = {}
    for _, qty in ipairs(presets) do
        if qty <= bal then
            table.insert(options, {
                string.format("%d", qty),
                function()
                    if npcUtil.giveItem(player, { currencyItemId, qty }) then
                        xi.rift.addPurveyorShards(player, currencyItemId, -qty)
                        local remaining = xi.rift.getPurveyorBalance(player, currencyItemId)
                        player:sys(string.format(
                            "Withdrew %d %s. You have %d stored.", qty, currName, remaining))
                    end
                end,
            })
        end
    end

    -- "All" option — always present when bal >= 1.
    if bal > 0 and (#options == 0 or presets[#presets] ~= bal) then
        table.insert(options, {
            string.format("All (%d)", bal),
            function()
                if npcUtil.giveItem(player, { currencyItemId, bal }) then
                    xi.rift.addPurveyorShards(player, currencyItemId, -bal)
                    player:sys(string.format("Withdrew all %d %s.", bal, currName))
                end
            end,
        })
    end

    player:timer(300, function(p)
        p:customMenu({
            title   = string.format("Withdraw %s  (stored: %d)", currName, bal),
            options = options,
        })
    end)
end

-- Sub-menu: pick which shard tier to withdraw.
local function openWithdrawMenu(player, npc)
    local tiers =
    {
        { xi.rift.NASCENT_SHARD  },
        { xi.rift.TEMPERED_SHARD },
        { xi.rift.FORGED_SHARD   },
        { xi.rift.RESOLUTE_SHARD },
    }

    local options = {}
    for _, t in ipairs(tiers) do
        local itemId  = t[1]
        local name    = xi.rift.SHARD_NAME[itemId]
        local bal     = xi.rift.getPurveyorBalance(player, itemId)
        local capturedId = itemId
        table.insert(options, {
            string.format("%s  [%d]", name, bal),
            function() openWithdraw(player, npc, capturedId) end,
        })
    end

    player:timer(300, function(p)
        p:customMenu({ title = "Withdraw which shard?", options = options })
    end)
end

-- Purveyor trigger: show balance summary then open the top-level menu.
local function purveyorTrigger(player, npc)
    local nascent  = xi.rift.getPurveyorBalance(player, xi.rift.NASCENT_SHARD)
    local tempered = xi.rift.getPurveyorBalance(player, xi.rift.TEMPERED_SHARD)
    local forged   = xi.rift.getPurveyorBalance(player, xi.rift.FORGED_SHARD)
    local resolute = xi.rift.getPurveyorBalance(player, xi.rift.RESOLUTE_SHARD)

    player:timer(300, function(p)
        p:customMenu({
            title = string.format(
                "Nascent: %d  Tempered: %d  Forged: %d  Resolute: %d",
                nascent, tempered, forged, resolute),
            options =
            {
                {
                    string.format("Nascent Shop  [%d]", nascent),
                    function() openShop(p, npc, "nascent",  xi.rift.NASCENT_SHARD)  end,
                },
                {
                    string.format("Tempered Shop  [%d]", tempered),
                    function() openShop(p, npc, "tempered", xi.rift.TEMPERED_SHARD) end,
                },
                {
                    string.format("Forged Shop  [%d]", forged),
                    function() openShop(p, npc, "forged",   xi.rift.FORGED_SHARD)   end,
                },
                {
                    "Break down shards",
                    function() openTradeDown(p, npc) end,
                },
                {
                    "Withdraw shards",
                    function() openWithdrawMenu(p, npc) end,
                },
            },
        })
    end)
end

-----------------------------------
-- Register NPC entities via LQS
-----------------------------------

LQS.npc(m, {
    Xarcabard =
    {
        -- Rift Surveyor — tier selection and entry.
        -- Replace pos with /pos output before going live.
        {
            name       = "Rift_Surveyor",
            packetName = "Rift Surveyor",
            look       = 0x0000B009, -- placeholder model
            pos        = { -285.0, -100.0, 196.0, 0 },
            namevis    = 1,
            onTrigger  = surveyorTrigger,
        },

        -- Rift Purveyor — shard storage, trade-down, and shop.
        -- Positioned next to the Surveyor (4 units east). Replace before going live.
        {
            name       = "Rift_Purveyor",
            packetName = "Rift Purveyor",
            look       = 0x0000B009, -- placeholder model
            pos        = { -281.0, -100.0, 196.0, 0 },
            namevis    = 1,
            onTrigger  = purveyorTrigger,
            onTrade    = purveyorTrade,
        },
    },
})

-----------------------------------
-- Walk of Echoes — detect pending tier on zone-in and enter layer.
-----------------------------------

m:addOverride("xi.zones.Walk_of_Echoes.Zone.onZoneIn", function(player, prevZone)
    local cs = super(player, prevZone)
    xi.rift.onZoneIn(player)
    return cs
end)

return m
