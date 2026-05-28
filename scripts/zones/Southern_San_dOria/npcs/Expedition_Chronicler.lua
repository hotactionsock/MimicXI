-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Expedition Chronicler
-- !pos -80.0 1 -60.0 230
-----------------------------------
require('scripts/globals/sync_buddy_milestones')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sb.onTrigger(player, npc)
end

return entity
