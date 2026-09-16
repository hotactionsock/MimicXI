---@param player CClientEntityPair
---@param mob CTestEntity
---@param kills integer
---@return { [number]: number }
local function simulateDrops(player, mob, kills)
    local dropsGotten = {}

    for killIteration = 1, kills do
        player:delContainerItems(xi.inv.INVENTORY)
        assert(#player:getItems() == 1, 'Player inventory is not empty')

        mob:spawn()
        mob.assert:isAlive()

        player:claimAndKillMob(mob, { waitForDespawn = true })
        for _, item in ipairs(player:getItems()) do
            dropsGotten[item:getID()] = (dropsGotten[item:getID()] or 0) + 1
        end
    end

    return dropsGotten
end

describe('Treasure Hunter', function()
    ---@type CClientEntityPair
    local player

    before_each(function()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.WAR, level = 75 })
    end)

    it('equals TH0 for any job with no milestones completed', function()
        xi.player.onGameIn(player, false, false)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 0)
    end)

    it('equals TH1 after reaching Rank 3 in one nation', function()
        player:setNation(xi.nation.SANDORIA)
        player:setRank(3)

        xi.player.onGameIn(player, false, false)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 1)
    end)

    it('equals TH2 after reaching Rank 3 and Rank 6 in different nations (no triple-dip from switching allegiance)', function()
        player:setNation(xi.nation.SANDORIA)
        player:setRank(3)
        player:setNation(xi.nation.BASTOK)
        player:setRank(6)

        xi.player.onGameIn(player, false, false)
        -- Two distinct thresholds reached (rank 3, rank 6) via two different nations
        -- should be worth exactly TH2, not TH4 (which a naive per-nation sum would give).
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 2)
    end)

    it('equals TH1 after unlocking Ru\'Aun Gardens alone (Zilart - The Gate of the Gods)', function()
        player:addMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
        player:completeMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)

        xi.player.onGameIn(player, false, false)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 1)
    end)

    it('equals TH1 after unlocking Al\'Taieu alone, with no Zilart progress (out-of-order completion)', function()
        -- CoP mission completion is tracked as "current mission id > target" rather
        -- than a complete[] bitfield (see hasCompletedMission), so simulate having
        -- moved past The Warrior's Path by setting current to the next mission.
        player:addMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_WARRIORS_PATH + 1)

        xi.player.onGameIn(player, false, false)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 1)
    end)

    it('equals TH3 after jumping straight to Rank 10 (credits the Rank 3/6/10 thresholds all at once)', function()
        player:setNation(xi.nation.WINDURST)
        player:setRank(10)

        xi.player.onGameIn(player, false, false)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 3)
    end)

    it('equals TH5 after completing all five milestones in a scrambled order', function()
        -- Order deliberately scrambled: mission unlocks before rank-ups, Rank 10
        -- reached before Rank 3/6 are individually checked, etc. The result must
        -- only ever depend on final state, never on the order these were granted.
        player:addMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_WARRIORS_PATH + 1)

        player:setNation(xi.nation.WINDURST)
        player:setRank(10)

        player:addMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)
        player:completeMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.THE_GATE_OF_THE_GODS)

        xi.player.onGameIn(player, false, false)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 5)
    end)

    it('equals TH2 with Thiefs Knife on top of a Rank 3 mission baseline', function()
        -- Assassin's Armlets (used in the next test) is THF-exclusive equipment,
        -- so use a THF player here too for consistency between the two.
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.THF, level = 75 })
        player:setNation(xi.nation.SANDORIA)
        player:setRank(3) -- only the rank-3 threshold, for a clean TH1 baseline
        xi.player.onGameIn(player, false, false)

        player:addItem(xi.item.THIEFS_KNIFE)
        player:equipItem(xi.item.THIEFS_KNIFE, nil, xi.slot.MAIN)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 2)
    end)

    it('equals TH3 with Thiefs Knife and Assassins Armlets on top of a Rank 3 mission baseline', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.THF, level = 75 })
        player:setNation(xi.nation.SANDORIA)
        player:setRank(3)
        xi.player.onGameIn(player, false, false)

        player:addItem(xi.item.THIEFS_KNIFE)
        player:equipItem(xi.item.THIEFS_KNIFE, nil, xi.slot.MAIN)
        player:addItem(xi.item.ASSASSINS_ARMLETS)
        player:equipItem(xi.item.ASSASSINS_ARMLETS)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 3)
    end)

    it('increases drop rates #long', function()
        -- Rank 6 satisfies both the rank-3 and rank-6 thresholds (TH2 baseline),
        -- matching the TH4 total (with Knife + Armlets) these expected rates were
        -- calibrated against.
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.THF, level = 75 })
        player:setNation(xi.nation.SANDORIA)
        player:setRank(6)
        xi.player.onGameIn(player, false, false)

        player:addItem(xi.item.THIEFS_KNIFE)
        player:equipItem(xi.item.THIEFS_KNIFE, nil, xi.slot.MAIN)
        player:addItem(xi.item.ASSASSINS_ARMLETS)
        player:equipItem(xi.item.ASSASSINS_ARMLETS)

        local checkTable =
        {
            [xi.zone.KUFTAL_TUNNEL] =
            {
                -- item, expected drop rate, tolerance
                -- TODO: Tolerance needs to be tighter
                [17489925] =
                {                                                 -- Devil Manta
                    [xi.item.PIECE_OF_ANGEL_SKIN] = { 8, 10.0 },  -- Expect 8% angel skins (5% base)
                    [xi.item.SHALL_SHELL]         = { 18, 10.0 }, -- Expect 18% shall shells (10% base)
                    [xi.item.MANTA_SKIN]          = { 45, 10.0 }, -- Expect 45% manta skins (15% base)
                },
            },
        }

        local iterations = 2000 -- should be 10,000

        for zone, mobs in pairs(checkTable) do
            player:gotoZone(zone)
            for mobId, drops in pairs(mobs) do
                local mob = player.entities:get(mobId)
                assert(mob)
                local dropsGotten = simulateDrops(player, mob, iterations)
                for itemId, dropInfo in pairs(drops) do
                    local expectedRate, tolerance = dropInfo[1], dropInfo[2]
                    local observedRate = dropsGotten[itemId] / iterations * 100.0
                    local diff = math.abs(expectedRate - observedRate)

                    assert(diff <= tolerance,
                        string.format('Expected droprate of %.2f%%, but observed %.2f%% for item %d', expectedRate,
                            observedRate, itemId))
                end
            end
        end
    end)
end)
