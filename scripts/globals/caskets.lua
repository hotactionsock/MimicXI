-----------------------------------
-- Global Casket utility script
-----------------------------------
require('scripts/globals/casket_loot')
require('scripts/globals/roe')
-----------------------------------

-----------------------------------
-- Notes:
-----------------------------------
-- chest MiD's
-- 960  -- Basic Chest
-- 965  -- Blue Casket
-- 966  -- Brown Casket
-- 967  -- Bronze
-- 968  -- Red
-- 969  -- Gold
-- 1524 -- Odd Chest
-- 1932 -- Black with Red chest
-- 2425 -- Black with Red chest 2
-----------------------------------
xi = xi or {}
xi.caskets = xi.caskets or {}

local casketInfo =
{
    spawnStatus =
    {
        DESPAWNED      = 0,
        SPAWNED_CLOSED = 1,
        SPAWNED_OPEN   = 2,
    },
    messageOffset =
    {
        NO_COMBINATION           = 6,  -- You were unable to enter a combination.
        HUNCH_GREATER_LESS       = 7,  -- You have a hunch that the lock's combination is ≺0 = GREATER, 1 = LESS≻[greater/less] than ≺INPUT NUMBER≻.
        UNABLE_TO_OPEN_LOCK      = 8,  -- Player failed to open the lock.
        CORRECT_NUMBER_WAS       = 9,  -- It appears that the correct combination was ≺NUMBER≻.
        OPENED_LOCK              = 10, -- Player succeeded in opening the lock!
        HUNCH_SECOND_EVEN_ODD    = 11, -- You have a hunch that the second digit is ≺0 = EVEN, 1 = ODD≻[even/odd].
        HUNCH_FIRST_EVEN_ODD     = 12, -- You have a hunch that the first digit is ≺0 = EVEN, 1 = ODD≻[even/odd].
        COMBINATION_GREATER_LESS = 13, -- You have a hunch that the combination is greater than ≺NUMBER≻ and less than ≺NUMBER≻.
        COMBINATION_LESS_THAN    = 14, -- You have a hunch that the combination is less than ≺NUMBER≻.
        COMBINATION_GREATER_THAN = 15, -- You have a hunch that the combination is greater than ≺NUMBER≻.
        ONE_OF_TWO_DIGITS_IS     = 16, -- You have a hunch that one of the two digits is ≺NUMBER≻.
        SECOND_DIGIT_IS          = 17, -- You have a hunch that the second digit is ≺NUMBER≻, ≺NUMBER≻, or ≺NUMBER≻.
        FIRST_DIGIT_IS           = 18, -- You have a hunch that the first digit is ≺NUMBER≻, ≺NUMBER≻, or ≺NUMBER≻.
        UNABLE_TO_GET_HINT       = 19, -- You were unable to glean anything from your examination of the lock.
        MONSTER_CONCEALED_CHEST  = 21, -- The monster was concealing a treasure chest!
    },
    splitZones = set{
        xi.zone.ZERUHN_MINES,
        xi.zone.KORROLOKA_TUNNEL,
        xi.zone.DANGRUF_WADI,
        xi.zone.KING_RANPERRES_TOMB,
        xi.zone.ORDELLES_CAVES,
        xi.zone.OUTER_HORUTOTO_RUINS,
        xi.zone.GUSGEN_MINES,
        xi.zone.MAZE_OF_SHAKHRAMI
    },

    -- Due to storing itemId for chosen casket items as a localvar, simpler than coding quantity as another localvar
    -- These itemIds give 33 instead of a single
    multipleItems = set{
        xi.item.HANDFUL_OF_STONE_ARROWHEADS,
        xi.item.HANDFUL_OF_BONE_ARROWHEADS,
        xi.item.HANDFUL_OF_BRONZE_BOLT_HEADS,
        xi.item.HANDFUL_OF_MYTHRIL_BOLT_HEADS,
        xi.item.HANDFUL_OF_DARKSTEEL_BOLT_HEADS,
        xi.item.HANDFUL_OF_SILVER_ARROWHEADS,
        xi.item.BAG_OF_YAGUDO_FLETCHINGS,
        xi.item.HANDFUL_OF_PLATINUM_ARROWHEADS,
    },
    cs =
    {
        [0]  = 1000, [1]  = 1003, [2]  = 1006, [3]  = 1009, [4]  = 1012, [5]  = 1015,
        [6]  = 1018, [7]  = 1021, [8]  = 1024, [9]  = 1027, [10] = 1030, [11] = 1033,
        [12] = 1036, [13] = 1039, [14] = 1042, [15] = 1045, [16] = 1048
    },
    dropTypes =
    {
        TEMP      = 1,
        ITEM      = 2,
        EVOLITH   = 3, -- NOTE: not implemented! item id: 2783
        RARE_ITEM = 4, -- Gold casket: HQ gear with optional augments from xi.caskets.augmentPools
    },
    evolithAugs =
    {
        -- TODO: find all augments for evoliths.
    },
}

-----------------------------------
-- Desc: Helper function for making it easier to read time between spawns.
-- TODO: Simplify and deprecate this function, as its only used in timeElapsedCheck
-----------------------------------
local function convertTime(rawTime)
    local rawSeconds = tonumber(rawTime)
    local timeTable  = { '', '', '' }

    timeTable[1] = string.format('%02.f', math.floor(rawSeconds / 3600))
    timeTable[2] = string.format('%02.f', math.floor(rawSeconds / 60 - timeTable[1] * 60))
    timeTable[3] = string.format('%02.f', math.floor(rawSeconds - timeTable[1] * 3600 - timeTable[2] * 60))

    return timeTable
end

-----------------------------------
-- Desc: Check for time elapsed since last spawned
-- NOTE: will NOT allow a spawn if time since last spanwed is under 5 mins.
-----------------------------------
local function timeElapsedCheck(npc)
    local spawnTime = GetSystemTime() + 360000 -- Default time in case no var set.
    local timeTable = { 0, 0, 0 }              -- Hours, Minutes, Seconds.

    if npc == nil then
        return false
    end

    if npc:getLocalVar('[caskets]SPAWNTIME') then
        spawnTime = npc:getLocalVar('[caskets]SPAWNTIME')
    end

    local lastSpawned = GetSystemTime() - spawnTime

    timeTable = convertTime(lastSpawned)

    if
        tonumber(timeTable[1]) >= 01 or
        tonumber(timeTable[1]) < 01 and
        tonumber(timeTable[2]) >= 05
    then
        return true
    end

    return false
end

-----------------------------------
-- Desc: Grabs an id for a casket if one is available if not, no casket will spawn.
-----------------------------------
local function getCasketID(mob)
    local zone    = mob:getZone()
    -- Get a list of all entities in this zone that have the name 'Treasure_Casket'
    local caskets = zone:queryEntitiesByName('Treasure_Casket')
    -- If there are none, bail out
    if #caskets == 0 then
        return 0
    end

    -- Iterate directly over known casket entities to avoid calling GetNPCByID
    -- with out-of-range IDs that belong to unrelated NPCs.
    for _, casket in ipairs(caskets) do
        if timeElapsedCheck(casket) then
            local status = casket:getLocalVar('[caskets]SPAWNSTATUS')
            if status == casketInfo.spawnStatus.DESPAWNED or status == 0 then
                return casket:getID()
            end
        end
    end

    return 0
end

-----------------------------------
-- Desc: Drop rate check, calculates all drop rate modifiers.
-----------------------------------
local function dropChance(player)
    -----------------------------------
    -- NOTES: 10% base drop rate.
    -- Super Kupowers(Myriad Mystery Boxes) adds 10% drop rate to the base rate.
    -- GoV Prowess Increased Treasure Casket Discovery adds 5% per level (max 5 levels)
    -- for a total of 25% increase. -- NOTE this needs to be confirmed!
    -----------------------------------
    --local kupowerMMBEffect    = player:getStatusEffect(xi.effect.KUPOWERS_MYRIAD_MYSTERY_BOXES)  -- Super Kupowers Myriad Mystery Boxes not implimented yet.
    local casketProwessEffect = player:getStatusEffect(xi.effect.PROWESS_CASKET_RATE)
    local kupowersMMBPower    = 0
    local prowessCasketsPower = 0

    --if player:hasStatusEffect(xi.effect.KUPOWERS_MYRIAD_MYSTERY_BOXES) then                       -- Super Kupowers Myriad Mystery Boxes not implimented yet.
    --     kupowersMMBPower = kupowerMMBEffect:getPower()
    --end

    if player:hasStatusEffect(xi.effect.PROWESS_CASKET_RATE) then
        prowessCasketsPower = casketProwessEffect:getPower() / 100
    end

    local rand = math.random()
    if rand < utils.clamp(xi.settings.main.CASKET_DROP_RATE + kupowersMMBPower + prowessCasketsPower, 0, 1) then
        return true
    end

    return false
end

-----------------------------------
-- Desc: Sends the message: 'The monster was concealing a treasure chest!' to all in party/alliance
-----------------------------------
local function sendChestDropMessage(player)
    local ID          = zones[player:getZoneID()]
    local dropMessage = ID.text.PLAYER_OBTAINS_TEMP_ITEM + casketInfo.messageOffset.MONSTER_CONCEALED_CHEST
    local party       = {}

    party = player:getAlliance()

    for _, member in pairs(party) do
        if member:getZoneID() == player:getZoneID() then
            member:messageSpecial(dropMessage , 0)
        end
    end
end

-----------------------------------
-- Desc: Despawn a chest and reset its local var's
-----------------------------------
local function removeChest(npc)
    npc:setAnimationSub(0, false)
    npc:setStatus(xi.status.DISAPPEAR)
    npc:resetLocalVars()
end

-----------------------------------
-- Desc: Sets all the base localVar's, type of chest and if locked, sets the random number.
-----------------------------------
local function setCasketData(player, x, y, z, r, npc, partyID, mobLvl)
    -- Early return.
    if npc == nil then
        return
    end

    local chestStyle = 965
    local correctNum = math.random(10, 99)
    local attempts   = math.random(4, 6)

    -- Get casket type.
    local kupowersBonus  = 0 -- TODO: Kupowers add a 20% chance.
    local zoneId         = player:getZoneID()
    local zoneItems      = xi.casket_loot.casketItems[zoneId]
    local zoneHasRarePol = xi.caskets.rarePools ~= nil and xi.caskets.rarePools[zoneId] ~= nil
    local roll           = math.random(1, 100)

    if zoneHasRarePol and roll <= 5 then
        chestStyle = 969 -- Gold: rare HQ casket (5% in zones with a rareItems pool)
    elseif roll <= (zoneHasRarePol and 20 or 15) + kupowersBonus then
        chestStyle = 966 -- Brown locked (15% standard / 15% in rare-pool zones after the 5% above)
    else
        chestStyle = 965 -- Blue
    end

    npc:resetLocalVars()
    npc:setAnimation(0)
    npc:setAnimationSub(4)
    -----------------------------------
    -- Chest data
    -----------------------------------
    npc:setLocalVar('[caskets]PARTYID', partyID)
    npc:setLocalVar('[caskets]ITEMS_SET', 0)
    npc:setLocalVar('[caskets]MOBLVL', mobLvl)

    -- Gold rare casket.
    if chestStyle == 969 then
        npc:setLocalVar('[caskets]ATTEMPTS', attempts)
        npc:setLocalVar('[caskets]CORRECT_NUM', correctNum)
        npc:setLocalVar('[caskets]FAILED_ATEMPTS', 0)
        npc:setLocalVar('[caskets]LOCKED', 1)
        npc:setLocalVar('[caskets]LOOT_TYPE', casketInfo.dropTypes.RARE_ITEM)
        npc:setLocalVar('[caskets]HINTS_TABLE', 1234567)
    -- Brown locked casket.
    elseif chestStyle == 966 then
        npc:setLocalVar('[caskets]ATTEMPTS', attempts)
        npc:setLocalVar('[caskets]CORRECT_NUM', correctNum)
        npc:setLocalVar('[caskets]FAILED_ATEMPTS', 0)
        npc:setLocalVar('[caskets]LOCKED', 1)
        npc:setLocalVar('[caskets]LOOT_TYPE', casketInfo.dropTypes.ITEM)
        npc:setLocalVar('[caskets]HINTS_TABLE', 1234567)
    else
        npc:setLocalVar('[caskets]LOCKED', 0)
        npc:setLocalVar('[caskets]LOOT_TYPE', casketInfo.dropTypes.TEMP)
    end

    npc:setLocalVar('[caskets]SPAWNSTATUS', casketInfo.spawnStatus.SPAWNED_CLOSED)
    npc:setLocalVar('[caskets]SPAWNTIME', GetSystemTime())
    npc:setPos(x, y, z, r)
    npc:setStatus(xi.status.NORMAL)
    npc:entityAnimationPacket(xi.animationString.STATUS_VISIBLE)
    npc:setModelId(chestStyle)
    sendChestDropMessage(player)
    -----------------------------------
    -- Despawn chest after 3 Mins
    -----------------------------------
    npc:timer(1000 * 60 * 3, function(npcArg)
        removeChest(npcArg)
    end)
end

-----------------------------------
-- Desc: Checks to see if all the items have been removed from the casket then removes it.
-----------------------------------
local function checkItemChestIsEmpty(npc)
    local item1 = npc:getLocalVar('[caskets]ITEM1')
    local item2 = npc:getLocalVar('[caskets]ITEM2')
    local item3 = npc:getLocalVar('[caskets]ITEM3')
    local item4 = npc:getLocalVar('[caskets]ITEM4')

    if item1 == 0 and item2 == 0 and item3 == 0 and item4 == 0 then
        removeChest(npc)
    end
end

-----------------------------------
-- ******Additional Functions******
-----------------------------------

-----------------------------------
-- Desc: Messages sent to all players in a party in the zone
-----------------------------------
local function messageChest(player, messageString, param1, param2, param3, param4, npc)
    local zoneId      = player:getZoneID()
    local ID          = zones[zoneId]
    local baseMessage = ID.text.PLAYER_OBTAINS_TEMP_ITEM
    local msg         = 0

    if messageString == 'UNABLE_TO_OPEN_LOCK' then
        msg = baseMessage + casketInfo.messageOffset.UNABLE_TO_OPEN_LOCK
    elseif messageString == 'OPENED_LOCK' then
        msg = baseMessage + casketInfo.messageOffset.OPENED_LOCK
    elseif messageString == 'PLAYER_OBTAINS_ITEM' then
        msg = ID.text.PLAYER_OBTAINS_ITEM
    elseif messageString == 'PLAYER_OBTAINS_TEMP_ITEM' then
        msg = ID.text.PLAYER_OBTAINS_TEMP_ITEM
    end

    local alliance = player:getAlliance()
    for _, member in pairs(alliance) do
        if member:getZoneID() == player:getZoneID() then
            member:messageName(msg, player, param1, param2, param3, param4, nil)
        end
    end
end

-----------------------------------
-- Desc: Checks attempts and despawns the chest if all attempts have been used up.
-----------------------------------
local function checkRemainingAttempts(player, npc, remaining, correctNumber)
    local zoneId      = player:getZoneID()
    local ID          = zones[zoneId]
    local baseMessage = ID.text.PLAYER_OBTAINS_TEMP_ITEM

    if remaining == 1 then
        player:messageSpecial(baseMessage + casketInfo.messageOffset.CORRECT_NUMBER_WAS, correctNumber, 0, 0, 0, 0)
        messageChest(player, 'UNABLE_TO_OPEN_LOCK', 0, 0, 0, 0, npc)
        removeChest(npc)
    end
end

-----------------------------------
-- Desc: Removes hint so they are not repeated, is no hints left, this enables the message,
--       'You were unable to glean anything from your examination of the lock.'
-----------------------------------
local function removeHint(npc, hintNum)
    local hintVar       = npc:getLocalVar('[caskets]HINTS_TABLE')
    local hintString    = tostring(hintVar)
    local newHintString = ''

    if #hintString > 1 then
        newHintString = hintString:gsub(tostring(hintNum), '')
    else
        newHintString = '0'
    end

    npc:setLocalVar('[caskets]HINTS_TABLE', tonumber(newHintString))
end

-----------------------------------
-- Desc: Sets the items id in a local variable for the casket.
-----------------------------------
local function setItems(npc, item1, item2, item3, item4)
    npc:setLocalVar('[caskets]ITEM1', item1)
    npc:setLocalVar('[caskets]ITEM2', item2)
    npc:setLocalVar('[caskets]ITEM3', item3)
    npc:setLocalVar('[caskets]ITEM4', item4)
    npc:setLocalVar('[caskets]ITEMS_SET', 1)
end

-----------------------------------
-- Desc: Sets the temp items id in a local variable for the casket.
-----------------------------------
local function setTempItems(npc, temp1, temp2, temp3)
    npc:setLocalVar('[caskets]TEMP1', temp1)
    npc:setLocalVar('[caskets]TEMP2', temp2)
    npc:setLocalVar('[caskets]TEMP3', temp3)
    npc:setLocalVar('[caskets]ITEMS_SET', 1)
end

-----------------------------------
-- Grab random drops from zone item or temp tables depending on type of chest
-----------------------------------
local function getDrops(npc, dropType, zoneId)
    if npc:getLocalVar('[caskets]ITEMS_SET') == 1 then
        return
    end

    -----------------------------------
    -- Temp drops
    -----------------------------------
    if dropType == casketInfo.dropTypes.TEMP then
        -- Get item table.
        local tempDrops = xi.casket_loot.casketItems[zoneId].temps
        if casketInfo.splitZones[zoneId] then
            local mobLvl = npc:getLocalVar('[caskets]MOBLVL')
            if mobLvl > 50 then
                tempDrops = xi.casket_loot.casketItems[zoneId].tempsHi
            else
                tempDrops = xi.casket_loot.casketItems[zoneId].tempsLow
            end
        end

        -- Get number of items in casket.
        local randomTable = { 1, 3, 1, 2, 1, 2, 1, 1, 3, 1, 2, 1 }
        local itemCount = utils.randomEntry(randomTable)

        local temps = { 0, 0, 0 }

        -- roll for items
        for i = 1, itemCount do
            temps[i] = xi.itemUtils.pickItemRandom(tempDrops)
        end

        setTempItems(npc, temps[1], temps[2], temps[3])
    -----------------------------------
    -- Item drops
    -----------------------------------
    elseif dropType == casketInfo.dropTypes.ITEM then
        -- Get item table.
        local drops = xi.casket_loot.casketItems[zoneId].items
        if casketInfo.splitZones[zoneId] then
            local mobLvl = npc:getLocalVar('[caskets]MOBLVL')
            if mobLvl > 50 then
                drops = xi.casket_loot.casketItems[zoneId].itemsHi
            else
                drops = xi.casket_loot.casketItems[zoneId].itemsLow
            end
        end

        -- Get number of items in casket.
        local randomTable = { 1, 4, 1, 3, 1, 1, 2, 1, 3, 1, 2, 1 }
        local itemCount = utils.randomEntry(randomTable)

        local items = { 0, 0, 0, 0 }

        -- roll for items and give a chance for a regional item for every dropped item
        for i = 1, itemCount do
            local itemId = xi.itemUtils.pickItemRandom(drops)

            if math.random(1, 100) <= 5 then
                items[1] = utils.randomEntry(xi.casket_loot.casketItems[zoneId].regionalItems)
            else
                items[i] = itemId
            end
        end

        setItems(npc, items[1], items[2], items[3], items[4])
    -----------------------------------
    -- Rare HQ item drops (Gold casket)
    -----------------------------------
    elseif dropType == casketInfo.dropTypes.RARE_ITEM then
        -- Primary source: xi.caskets.rarePools populated by the casket loot module
        -- at load time. Falls back to the zone's regular items pool so the chest
        -- is never permanently empty even if no rare pool is defined for this zone.
        local pool = xi.caskets.rarePools and xi.caskets.rarePools[zoneId]
        if not pool then
            local zoneItems = xi.casket_loot.casketItems[zoneId]
            if zoneItems then
                if casketInfo.splitZones[zoneId] then
                    local mobLvl = npc:getLocalVar('[caskets]MOBLVL')
                    pool = mobLvl > 50 and zoneItems.itemsHi or zoneItems.itemsLow
                else
                    pool = zoneItems.items
                end
            end
        end

        if not pool then
            return
        end

        local randomTable = { 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2 }
        local itemCount   = utils.randomEntry(randomTable)
        local items       = { 0, 0, 0, 0 }

        for i = 1, itemCount do
            items[i] = xi.itemUtils.pickItemRandom(pool)
        end

        setItems(npc, items[1], items[2], items[3], items[4])

        -- Pre-roll augments now so the preview message and the actual grant
        -- always show the same values.
        for slot = 1, itemCount do
            local itemId  = items[slot]
            local augPool = xi.caskets.augmentPools and xi.caskets.augmentPools[itemId]
            if itemId ~= 0 and augPool and #augPool > 0 then
                local available = {}
                for _, aug in ipairs(augPool) do
                    available[#available + 1] = aug
                end
                local numAugs = math.random(1, math.min(2, #available))
                npc:setLocalVar(string.format('[caskets]ITEM%dNUMAUGS', slot), numAugs)
                for j = 1, numAugs do
                    local idx   = math.random(1, #available)
                    local aug   = available[idx]
                    local value = math.random(aug.min, aug.max)
                    npc:setLocalVar(string.format('[caskets]ITEM%dAUG%dID',  slot, j), aug.id)
                    npc:setLocalVar(string.format('[caskets]ITEM%dAUG%dVAL', slot, j), value)
                    table.remove(available, idx)
                end
            end
        end
    -----------------------------------
    -- Evolith drops
    -----------------------------------
    elseif dropType == casketInfo.dropTypes.EVOLITH then
        -- local evolith = 2783
        -- NOTE: Not implimented yet and will be incorperated into items once implimented.
        -- this is mainly here as a means of testing before implimentation.
    end
end

-----------------------------------
-- Desc: Prints a Gold Casket contents preview to the triggering player so
--       they can see pre-rolled augments before committing to obtain an item.
-----------------------------------
local function showRareItemContents(player, npc)
    for slot = 1, 4 do
        local itemId  = getChestItem(npc, slot)
        local numAugs = npc:getLocalVar(string.format('[caskets]ITEM%dNUMAUGS', slot))
        if itemId ~= 0 and numAugs and numAugs > 0 then
            local parts = {}
            for j = 1, numAugs do
                local augId  = npc:getLocalVar(string.format('[caskets]ITEM%dAUG%dID',  slot, j))
                local augVal = npc:getLocalVar(string.format('[caskets]ITEM%dAUG%dVAL', slot, j))
                local name   = (xi.augments and xi.augments.name and xi.augments.name[augId]) or tostring(augId)
                parts[#parts + 1] = string.format('%s+%d', name, augVal)
            end
            player:printToPlayer(
                string.format('[Gold Casket] Slot %d augment(s): %s', slot, table.concat(parts, ', ')),
                xi.msg.channel.SYSTEM_3
            )
        end
    end
end

-----------------------------------
-- Temp item functions
-----------------------------------

-----------------------------------
-- Desc: Returns an temp items id based on the the local variable i.e. npc:getLocalVariable('TEMP1').
-----------------------------------
local function getTempDrop(npc, tempNum)
    local query = string.format('[caskets]TEMP' ..tempNum.. '')
    local var   = npc:getLocalVar(query)

    if var == nil then
        return 0
    else
        return var
    end
end

-----------------------------------
-- Desc: Checks to see if the casket is empty after a player removes an item, if so, despawns the casket
-----------------------------------
local function checkTempChestIsEmpty(npc)
    local temp1 = npc:getLocalVar('[caskets]TEMP1')
    local temp2 = npc:getLocalVar('[caskets]TEMP2')
    local temp3 = npc:getLocalVar('[caskets]TEMP3')

    if temp1 == 0 and temp2 == 0 and temp3 == 0 then
        removeChest(npc)
    end
end

-----------------------------------
-- Desc: Gives the player the temp item from a casket based on the selection of the csid
-----------------------------------
local function giveTempItem(player, npc, tempNum, subOption)
    local tempQuery   = string.format('[caskets]TEMP' ..tempNum.. '')
    local tempID      = npc:getLocalVar(tempQuery)
    local zoneId      = player:getZoneID()
    local ID          = zones[zoneId]
    local spawnStatus = npc:getLocalVar('[caskets]SPAWNSTATUS')

    if spawnStatus == casketInfo.spawnStatus.DESPAWNED then
        return
    end

    -- 2 = "do not obtain"
    -- 1 = "obtain"
    -- 0 = "None of them"
    if subOption == 2 or subOption == 0 then
        return
    end

    if tempID == 0 then
        player:messageSpecial(ID.text.UNABLE_TO_OBTAIN_ITEM)
        return
    else
        if player:hasItem(tempID, xi.inventoryLocation.TEMPITEMS) then
            return player:messageSpecial(ID.text.ALREADY_POSSESS_TEMP)
        else
            if player:addTempItem(tempID) then
                messageChest(player, 'PLAYER_OBTAINS_TEMP_ITEM', tempID, 0, 0, 0)
                npc:setLocalVar(tempQuery, 0)
                checkTempChestIsEmpty(npc)
            end
        end
    end
end

-----------------------------------
-- Basic item functions
-----------------------------------

-----------------------------------
-- Desc: Returns an items id based on the the local variable i.e. npc:getLocalVariable('ITEM1').
-----------------------------------
local function getChestItem(npc, slot)
    local query = string.format('[caskets]ITEM' ..slot.. '')
    local var   = npc:getLocalVar(query)

    if var == nil then
        return 0
    else
        return var
    end
end

-----------------------------------
-- Desc: Gives the player the item from a casket based on the selection of the csid
-----------------------------------
local function giveItem(player, npc, itemNum, subOption)
    local itemQuery   = string.format('[caskets]ITEM' ..itemNum.. '')
    local itemID      = npc:getLocalVar(itemQuery)
    local zoneId      = player:getZoneID()
    local ID          = zones[zoneId]
    local spawnStatus = npc:getLocalVar('[caskets]SPAWNSTATUS')

    if spawnStatus == casketInfo.spawnStatus.DESPAWNED then
        return
    end

    -- 2 = "do not obtain"
    -- 1 = "obtain"
    -- 0 = "None of them"
    if subOption == 2 or subOption == 0 then
        return
    end

    if itemID == 0 then
        player:messageSpecial(ID.text.UNABLE_TO_OBTAIN_ITEM)
        return
    else
        if player:getFreeSlotsCount() == 0 then
            player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, itemID)
            return
        elseif player:getFreeSlotsCount() > 0 then
            if itemID ~= 0 then
                local quantity = 1
                if casketInfo.multipleItems[itemID] then
                    quantity = 33
                end

                if player:addItem(itemID, quantity) then
                    -- TODO is the message supposed to give some indication if quantity > 1?
                    messageChest(player, 'PLAYER_OBTAINS_ITEM', itemID, 0, 0, 0)
                    npc:setLocalVar(itemQuery, 0)
                    checkItemChestIsEmpty(npc)
                end
            end
        end
    end
end

-----------------------------------
-- Desc: Gives a rare (HQ) item, optionally with augments from xi.caskets.augmentPools.
-- The augment pool table has the form: [itemId] = { { id, min, max }, ... }
-- and is populated externally (e.g. by the casket_loot_starter_zones module).
-----------------------------------
local function giveRareItem(player, npc, itemNum, subOption)
    local itemQuery   = string.format('[caskets]ITEM' .. itemNum .. '')
    local itemID      = npc:getLocalVar(itemQuery)
    local zoneId      = player:getZoneID()
    local ID          = zones[zoneId]
    local spawnStatus = npc:getLocalVar('[caskets]SPAWNSTATUS')

    if spawnStatus == casketInfo.spawnStatus.DESPAWNED then
        return
    end

    if subOption == 2 or subOption == 0 then
        return
    end

    if itemID == 0 then
        player:messageSpecial(ID.text.UNABLE_TO_OBTAIN_ITEM)
        return
    end

    if player:getFreeSlotsCount() == 0 then
        player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, itemID)
        return
    end

    -- Use augments that were pre-rolled when the chest was first opened so
    -- the player always receives exactly what the preview message showed.
    local numAugs = npc:getLocalVar(string.format('[caskets]ITEM%dNUMAUGS', itemNum))

    if numAugs and numAugs > 0 then
        local augments = {}
        for j = 1, numAugs do
            augments[j] =
            {
                id    = npc:getLocalVar(string.format('[caskets]ITEM%dAUG%dID',  itemNum, j)),
                value = npc:getLocalVar(string.format('[caskets]ITEM%dAUG%dVAL', itemNum, j)),
            }
        end

        if player:addItem({ id = itemID, exdata = { augmentKind = xi.augment.kind.HAS_AUGMENTS, augmentSubKind = xi.augment.subKind.STANDARD, augments = augments } }) then
            messageChest(player, 'PLAYER_OBTAINS_ITEM', itemID, 0, 0, 0)
            npc:setLocalVar(itemQuery, 0)
            checkItemChestIsEmpty(npc)
        end
    else
        if player:addItem(itemID, 1) then
            messageChest(player, 'PLAYER_OBTAINS_ITEM', itemID, 0, 0, 0)
            npc:setLocalVar(itemQuery, 0)
            checkItemChestIsEmpty(npc)
        end
    end
end

-----------------------------------
-- Desc: Casket spawn checks, runs through all checks before spawning
-----------------------------------
-- Expose drop type constants so external modules can reference them.
xi.caskets.dropTypes = casketInfo.dropTypes

xi.caskets.spawnCasket = function(player, mob, x, y, z, r)
    local chestId = getCasketID(mob)

    if chestId == 0 then
        return
    end

    local npc        = GetNPCByID(chestId)
    local chestOwner = player:getLeaderID()

    if dropChance(player) then
        setCasketData(player, x, y, z, r, npc, chestOwner, mob:getMainLvl())
    end
end

-----------------------------------
-- Main public casket functions
-----------------------------------
xi.caskets.onTrigger = function(player, npc)
    -----------------------------------
    -- Basic chest var's
    -----------------------------------
    local chestId           = npc:getID()                             -- ID of the chest
    local dropType          = npc:getLocalVar('[caskets]LOOT_TYPE')   -- Chest Type from casketInfo.dropTypes
    local locked            = npc:getLocalVar('[caskets]LOCKED')      -- enter two-digit combination (10~99).
    local chestOwner        = npc:getLocalVar('[caskets]PARTYID')     -- the id of the party that has rights to the chest.
    local leaderId          = player:getLeaderID()
    --local aumentflag      = 0x0202                                  -- Used for Evoliths (not implemented yet).
    local zone              = npc:getZone()
    -- Get a list of all entities in this zone that have the name 'Treasure_Casket'
    local caskets           = zone:queryEntitiesByName('Treasure_Casket')
    -- Get the ID of the first entry and use that as our base ID to offset against
    local eventBase         = caskets[1]:getID() -- base id of the current chest.
    local lockedEvent       = casketInfo.cs[chestId - eventBase] + 2  -- Chest locked cs's.
    local unlockedEvent     = casketInfo.cs[chestId - eventBase]      -- Chest unlocked cs's.

    -----------------------------------
    -- Locked chest var's
    -----------------------------------
    local attemptsAllowed   = npc:getLocalVar('[caskets]ATTEMPTS')
    local failedAtempts     = npc:getLocalVar('[caskets]FAILED_ATEMPTS')
    local remainingAttempts = attemptsAllowed - failedAtempts

    if leaderId ~= chestOwner then
        return
    end

    getDrops(npc, dropType, player:getZoneID())

    -----------------------------------
    -- Chest Locked
    -----------------------------------
    if locked ~= 0 then
        player:startEvent(lockedEvent, remainingAttempts, 0, 0, 0, 0, 0, 0, 0) -- Start the minigame if locked.
    else
    -----------------------------------
    -- Chest Unlocked
    -----------------------------------
        if npc:getLocalVar('[caskets]SPAWNSTATUS') == casketInfo.spawnStatus.SPAWNED_CLOSED then      -- is the chest shut?, then open it.
            npc:setAnimationSub(1)
            npc:setLocalVar('[caskets]SPAWNSTATUS', casketInfo.spawnStatus.SPAWNED_OPEN)
            -- RoE Timed Record #4019 - Crack Tresure Caskets
            if player:getEminenceProgress(4019) then
                xi.roe.onRecordTrigger(player, 4019)
            end
        end

        if dropType == casketInfo.dropTypes.TEMP then
            player:startEvent(unlockedEvent + 1,
                getTempDrop(npc, 1),
                getTempDrop(npc, 2),
                getTempDrop(npc, 3),
                0, 0, 0, 0, 0)
        elseif dropType == casketInfo.dropTypes.ITEM then
            player:startEvent(unlockedEvent,
                getChestItem(npc, 1),
                getChestItem(npc, 2),
                getChestItem(npc, 3),
                getChestItem(npc, 4),
                0, 0, 0, 0)
        elseif dropType == casketInfo.dropTypes.RARE_ITEM then
            showRareItemContents(player, npc)
            player:startEvent(unlockedEvent,
                getChestItem(npc, 1),
                getChestItem(npc, 2),
                getChestItem(npc, 3),
                getChestItem(npc, 4),
                0, 0, 0, 0)
        end
    end
end

-----------------------------------
-- Retail notes: from wiki
-- Thieves can use tools to gain a free hint, without expending one of their attempts.
-- The only clues that you can obtain via Thief's Tools is a hint that tells you it's between 2 numbers,
-- (e.g. its between 24 and 58) its usually a good idea to start with this clue.
-- Multiple tools may be used, however there is a low rate of success after the first.
-----------------------------------
xi.caskets.onTrade = function(player, npc, trade)
    local zoneId            = player:getZoneID()
    local ID                = zones[zoneId]
    local baseMessage       = ID.text.PLAYER_OBTAINS_TEMP_ITEM
    local locked            = npc:getLocalVar('[caskets]LOCKED')
    local correctNumber     = npc:getLocalVar('[caskets]CORRECT_NUM')
    local chestOwner        = npc:getLocalVar('[caskets]PARTYID')         -- the id of the player, party or alliance that has rights to the chest.
    local leaderId          = player:getLeaderID()

    -- NOTE: The client blocks actions like this while invisible, but it's very easy to inject an action packet to get
    -- around this restriction. Strip invisible to make sure that case is covered.
    player:delStatusEffect(xi.effect.INVISIBLE)

    if leaderId ~= chestOwner then
        return
    end

    if locked == 1 then
        if
            player:getMainJob() == xi.job.THF and
            npcUtil.tradeHasExactly(trade, xi.item.SET_OF_THIEFS_TOOLS)
        then
            local splitNumbers = {}
            local tradeAttempt = math.random()
            local firstAttempt = npc:getLocalVar('[caskets]HINT_TRADE')
            local canGetHint   = false

            for digit in string.gmatch(tostring(correctNumber), '%d') do
                table.insert(splitNumbers, tonumber(digit))
            end

            if firstAttempt == 0 or firstAttempt == nil then
                npc:setLocalVar('[caskets]HINT_TRADE', 1)
                canGetHint = true
            else
                if tradeAttempt < 0.2 then
                    canGetHint = true
                else
                    canGetHint = false
                end
            end

            if canGetHint then
                local highNum = 0
                local lowNum  = 0

                if splitNumbers[1] == 1 then
                    lowNum  = 10
                    highNum = 20 + math.random(1, 9)
                elseif splitNumbers[1] > 1 and splitNumbers[1] < 9 then
                    lowNum  = splitNumbers[1] * 10 - 10 + math.random(1, 9)
                    highNum = splitNumbers[1] * 10 + 10 + math.random(1, 9)
                elseif splitNumbers[1] == 9 then
                    lowNum  = 80 + math.random(1, 9)
                    highNum = 99
                end

                player:messageSpecial(baseMessage + casketInfo.messageOffset.COMBINATION_GREATER_LESS, lowNum, highNum, 0, 0)
            else
                player:messageSpecial(baseMessage + casketInfo.messageOffset.UNABLE_TO_GET_HINT, 0, 0, 0, 0)
            end

            player:confirmTrade()
        end
    end
end

xi.caskets.onEventFinish = function(player, csid, option, npc)
    local zoneId = player:getZoneID()
    local ID = zones[zoneId]
    local baseMessage = ID.text.PLAYER_OBTAINS_TEMP_ITEM
    -----------------------------------
    -- Basic chest var's
    -----------------------------------
    local chestObj          = player:getEventTarget()
    local spawnStatus       = chestObj:getLocalVar('[caskets]SPAWNSTATUS')
    local locked            = chestObj:getLocalVar('[caskets]LOCKED')
    local dropType          = chestObj:getLocalVar('[caskets]LOOT_TYPE')
    local lockedChoice      = bit.lshift(1, option -1)
    local inputNumber       = bit.rshift(option, 16)

    -----------------------------------
    -- Chest Locked var's
    -----------------------------------
    local correctNumber     = chestObj:getLocalVar('[caskets]CORRECT_NUM')
    local attemptsAllowed   = chestObj:getLocalVar('[caskets]ATTEMPTS')
    local failedAtempts     = chestObj:getLocalVar('[caskets]FAILED_ATEMPTS')
    local remainingAttempts = attemptsAllowed - failedAtempts

    -----------------------------------
    -- Minigame
    -----------------------------------
    local splitNumbers   = {}
    local hintsVar       = chestObj:getLocalVar('[caskets]HINTS_TABLE')
    local availableHints = {}

    if hintsVar ~= 0 then
        for hint in string.gmatch(tostring(hintsVar), '%d') do
            table.insert(availableHints, hint)
        end
    end

    for digit in string.gmatch(tostring(correctNumber), '%d') do
        table.insert(splitNumbers, tonumber(digit))
    end

    if locked == 1 then
        if option > 0 and spawnStatus ~= casketInfo.spawnStatus.SPAWNED_CLOSED then -- prevent minigame from working if chest is opened.
            return
        end

        -----------------------------------
        -- Hints
        -----------------------------------
        if lockedChoice == 2 then -- Examine chest
            if option == 258 then
                local randText = tonumber(availableHints[math.random(#availableHints)])

                if randText == 0 or randText == nil then
                    player:messageSpecial(baseMessage + casketInfo.messageOffset.UNABLE_TO_GET_HINT, 0, 0, 0, 0)
                    return
                elseif randText <= 2 then
                    local oddEventParam = splitNumbers[randText] % 2
                    local messageId     = baseMessage + casketInfo.messageOffset.HUNCH_SECOND_EVEN_ODD - (randText - 2)

                    player:messageSpecial(messageId, oddEventParam, 0, 0, 0)
                    chestObj:setLocalVar('[caskets]FAILED_ATEMPTS', failedAtempts + 1)
                elseif randText <= 4 then
                    -- NOTE: Second digit ID is one lower than First Digit ID, but our randText is opposite that.  If randText == 3, then
                    -- we expect it to be the FIRST_DIGIT_IS message.  Therefore, the below function intends to add 1 to second digit
                    -- if it is the first.

                    local splitIndex = randText - 2
                    local messageId = baseMessage + casketInfo.messageOffset.SECOND_DIGIT_IS - (splitIndex - 2)

                    if splitNumbers[splitIndex] <= 6 then
                        player:messageSpecial(messageId,
                            splitNumbers[splitIndex],
                            splitNumbers[splitIndex] + 1,
                            splitNumbers[splitIndex] + 2, 0)
                    elseif splitNumbers[splitIndex] == 9 then
                        player:messageSpecial(messageId,
                            splitNumbers[splitIndex] - 2,
                            splitNumbers[splitIndex] - 1,
                            splitNumbers[splitIndex], 0)
                    else
                        player:messageSpecial(messageId,
                            splitNumbers[splitIndex] - 1,
                            splitNumbers[splitIndex],
                            splitNumbers[splitIndex] + 1, 0)
                    end

                    chestObj:setLocalVar('[caskets]FAILED_ATEMPTS', failedAtempts + 1)
                elseif randText <= 6 then
                    local splitIndex = randText - 4

                    player:messageSpecial(baseMessage + casketInfo.messageOffset.ONE_OF_TWO_DIGITS_IS, splitNumbers[splitIndex], 0, 0, 0)
                    chestObj:setLocalVar('[caskets]FAILED_ATEMPTS', failedAtempts + 1)
                elseif randText == 7 then
                    local highNum = 0
                    local lowNum  = 0

                    if splitNumbers[1] == 1 then
                        lowNum  = 10
                        highNum = 20 + math.random(1, 9)
                    elseif splitNumbers[1] == 9 then
                        lowNum  = 80 + math.random(1, 9)
                        highNum = 99
                    else
                        lowNum  = splitNumbers[1] * 10 - 10 + math.random(1, 9)
                        highNum = splitNumbers[1] * 10 + 10 + math.random(1, 9)
                    end

                    player:messageSpecial(baseMessage + casketInfo.messageOffset.COMBINATION_GREATER_LESS, lowNum, highNum, 0, 0)
                    chestObj:setLocalVar('[caskets]FAILED_ATEMPTS', failedAtempts + 1)
                else
                    player:messageSpecial(baseMessage + casketInfo.messageOffset.UNABLE_TO_GET_HINT, 0, 0, 0, 0)
                end

                checkRemainingAttempts(player, chestObj, remainingAttempts, correctNumber)
                removeHint(chestObj, randText)
            end

        -----------------------------------
        -- Inputs
        -----------------------------------
        elseif lockedChoice == 1 then -- Input a number
            if inputNumber > 9 and inputNumber < 100 then
                if locked == 0 then
                    player:messageSpecial(baseMessage + casketInfo.messageOffset.NO_COMBINATION, 0, 0, 0, 0)
                elseif inputNumber == correctNumber then
                    messageChest(player, 'OPENED_LOCK', 0 , 0, 0, 0, chestObj)
                    chestObj:setLocalVar('[caskets]LOCKED', 0)

                    if chestObj:getLocalVar('[caskets]SPAWNSTATUS') == casketInfo.spawnStatus.SPAWNED_CLOSED then  -- is the chest shut?, then open it.
                        chestObj:setAnimationSub(1)
                        chestObj:setLocalVar('[caskets]SPAWNSTATUS', casketInfo.spawnStatus.SPAWNED_OPEN)

                        -- RoE Timed Record #4019 - Crack Tresure Caskets (Progress is verified in onRecordTrigger function)
                        xi.roe.onRecordTrigger(player, 4019)
                    end
                else
                    local isGreater = inputNumber > correctNumber and 1 or 0

                    player:messageSpecial(baseMessage + casketInfo.messageOffset.HUNCH_GREATER_LESS, inputNumber, isGreater, 0, 0, 0)
                    chestObj:setLocalVar('[caskets]FAILED_ATEMPTS', failedAtempts + 1)
                    checkRemainingAttempts(player, chestObj, remainingAttempts, correctNumber)
                end
            end
        end

    elseif locked == 0 then
        local itemPos   = bit.band(option, 0x7)
        local subOption = bit.band(bit.rshift(option, 16), 0x3) -- 2 bit mask

        if dropType == casketInfo.dropTypes.TEMP then
            giveTempItem(player, chestObj, itemPos, subOption)
        elseif dropType == casketInfo.dropTypes.ITEM then
            giveItem(player, chestObj, itemPos, subOption)
        elseif dropType == casketInfo.dropTypes.RARE_ITEM then
            giveRareItem(player, chestObj, itemPos, subOption)
        end
    end
end
