-----------------------------------
-- Area: Sea Serpent Grotto
--  NPC: Mythril Beastcoin Door
-- !pos 40 8.6 20.012 176
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    return npc:openDoor(5)
end

return entity
