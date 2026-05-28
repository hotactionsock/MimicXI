-----------------------------------
-- Area: Bastok Markets
--  NPC: Expedition Chronicler
-- !pos -334.0 -10 -184.0 235
-----------------------------------
require('scripts/globals/sync_buddy_milestones')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sb.onTrigger(player, npc)
end

return entity
