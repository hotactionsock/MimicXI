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
        player = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.THF, level = 75 })
        -- TH is no longer a job trait; it is granted by mission progression.
        -- Complete ZM17 to grant TH+2 as the baseline for these tests.
        player:completeMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.AWAKENING)
    end)

    it('equals TH0 for any job with no missions completed', function()
        local freshPlayer = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.WAR, level = 75 })
        freshPlayer.assert:hasModifier(xi.mod.TREASURE_HUNTER, 0)
    end)

    it('equals TH1 after completing the Shadow Lord mission', function()
        local missionPlayer = xi.test.world:spawnPlayer({ zone = xi.zone.KUFTAL_TUNNEL, job = xi.job.WAR, level = 75 })
        missionPlayer:completeMission(xi.mission.log_id.SANDORIA, xi.mission.id.sandoria.THE_SHADOW_LORD)
        missionPlayer.assert:hasModifier(xi.mod.TREASURE_HUNTER, 1)
    end)

    it('equals TH2 for a naked THF75 with ZM17 completed', function()
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 2)
    end)

    it('equals TH3 with Thiefs Knife', function()
        player:addItem(xi.item.THIEFS_KNIFE)
        player:equipItem(xi.item.THIEFS_KNIFE, nil, xi.slot.MAIN)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 3)
    end)

    it('equals TH4 with Thiefs Knife and Assassins Armlets', function()
        player:addItem(xi.item.THIEFS_KNIFE)
        player:equipItem(xi.item.THIEFS_KNIFE, nil, xi.slot.MAIN)
        player:addItem(xi.item.ASSASSINS_ARMLETS)
        player:equipItem(xi.item.ASSASSINS_ARMLETS)
        player.assert:hasModifier(xi.mod.TREASURE_HUNTER, 4)
    end)

    it('increases drop rates #long', function()
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
