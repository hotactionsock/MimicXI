-----------------------------------
-- Casket Mimic module
--
-- When a Gold Casket's lock mini-game is failed there is a 25% chance the
-- chest transforms into a Casket Mimic.  The Mimic spawns at -9999 (dormant
-- SQL position) and is immediately snapped to the failed chest's coordinates.
-- On death the pre-rolled chest loot drops into the party treasure pool.
-- Augmented items are passed to addTreasure with their augment data so the
-- pool applies them at award time; augments are visible on the item itself.
--
-- SQL: modules/custom/sql/casket_mimic_spawns.sql (loaded by dbtool via init.txt)
-- Mob scripts: scripts/zones/<Zone>/mobs/Casket_Mimic.lua (one-liner stubs).
-----------------------------------

local m = Module:new('casket_mimic')

xi         = xi or {}
xi.caskets = xi.caskets or {}
xi.caskets.mimic = xi.caskets.mimic or {}

-----------------------------------
-- Mob ID lookup:  0x1000000 | (zoneId << 12) | 0x700
-- Local index 0x700: bit-11 clear so zoneutils::GetEntity decodes as id & 0xFFF
-- (matching the targid stored at load time).  Matches casket_mimic_spawns.sql.
-----------------------------------
local function getMimicMobId(zoneId)
    return 0x1000000 + (zoneId * 4096) + 0x700
end

-----------------------------------
-- Pending loot: [zoneId] = { items = {...}, expiry = epoch }
-- Cleared on Mimic death or expiry (10 min).
-----------------------------------
xi.caskets.mimic.pendingLoot = {}

-----------------------------------
-- mobCallbacks — returned by every scripts/zones/.../mobs/Casket_Mimic.lua
-----------------------------------
xi.caskets.mimic.mobCallbacks = {}

xi.caskets.mimic.mobCallbacks.onMobDeath = function(mob, player, isKiller, noKillIncrement)
    if not isKiller then return end

    local zoneId = mob:getZoneID()
    local loot   = xi.caskets.mimic.pendingLoot[zoneId]
    if not loot then return end

    if os.time() > loot.expiry then
        xi.caskets.mimic.pendingLoot[zoneId] = nil
        return
    end

    xi.caskets.mimic.pendingLoot[zoneId] = nil

    local hasPool = player:getTreasurePool() ~= nil

    -- Drop all loot into the party treasure pool.  addTreasure accepts an
    -- optional augments table (4th arg); the pool applies augments at award time.
    for _, item in ipairs(loot.items) do
        if hasPool then
            local augArg = (#item.augments > 0) and item.augments or nil
            player:addTreasure(item.id, mob, 1000, augArg)
        else
            if #item.augments > 0 then
                player:addItem(
                {
                    id     = item.id,
                    exdata =
                    {
                        augmentKind    = xi.augment.kind.HAS_AUGMENTS,
                        augmentSubKind = xi.augment.subKind.STANDARD,
                        augments       = item.augments,
                    },
                })
            else
                player:addItem(item.id, 1)
            end
        end
    end
end

-----------------------------------
-- Called from scripts/globals/caskets.lua when the last attempt is used.
-- Must be called BEFORE removeChest() so NPC local vars are still intact.
-----------------------------------
xi.caskets.mimic.onChestFail = function(player, npc)
    -- 25% chance to spawn a Mimic.
    if math.random(100) > 25 then return end

    local zoneId = player:getZoneID()

    -- One Mimic per zone at a time; skip if one is already pending.
    local existing = xi.caskets.mimic.pendingLoot[zoneId]
    if existing and os.time() <= existing.expiry then return end

    -- Extract loot from NPC vars before removeChest wipes them.
    local items = xi.caskets.extractNpcLoot(npc)
    if #items == 0 then return end

    local mimicId = getMimicMobId(zoneId)
    local mimic   = SpawnMob(mimicId)
    if not mimic then return end

    -- Snap to the chest's position so the Mimic appears in place.
    local pos = npc:getPos()
    mimic:setPos(pos.x, pos.y, pos.z, pos.rot)

    xi.caskets.mimic.pendingLoot[zoneId] =
    {
        items  = items,
        expiry = os.time() + 600, -- loot expires after 10 min
    }

    -- Notify the party.
    local zoneID = player:getZoneID()
    for _, member in ipairs(player:getAlliance()) do
        if member:getZoneID() == zoneID then
            member:printToPlayer(
                '[Gold Casket] The chest lurches — it\'s a Mimic! Defeat it to claim the loot.',
                xi.msg.channel.SYSTEM_3
            )
        end
    end
end

return m
