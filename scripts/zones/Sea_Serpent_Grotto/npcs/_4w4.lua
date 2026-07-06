-----------------------------------
-- Area: Sea Serpent Grotto
--  NPC: Gold Beastcoin Door
-- !pos 60 8.55 -80 176
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    return npc:openDoor(5)
end

return entity
