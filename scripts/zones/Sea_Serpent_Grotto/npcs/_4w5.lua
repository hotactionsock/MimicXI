-----------------------------------
-- Area: Sea Serpent Grotto
--  NPC: Silver Beastcoin Door
-- !pos 280 18.549 -100 176
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    return npc:openDoor(5)
end

return entity
