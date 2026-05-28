-----------------------------------
-- Area: Windurst Waters
--  NPC: Expedition Chronicler
-- !pos 40.0 -1.5 -55.0 238
-----------------------------------
require('scripts/globals/sync_buddy_milestones')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sb.onTrigger(player, npc)
end

return entity
