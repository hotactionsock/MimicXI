-----------------------------------
-- Ability: Quick Draw (NPC/Trust form)
-- Used by trust mobs that don't have access to elemental cards.
-- Deals dark-based magic damage and may dispel one effect.
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability, action)
    local bonusAcc = player:getStat(xi.mod.AGI) / 2
    local resist   = xi.combat.magicHitRate.calculateResistRate(player, target, 0, 0, 0, xi.element.DARK, 0, 0, bonusAcc)

    if resist < 0.25 then
        ability:setMsg(xi.msg.basic.JA_MISS_2)
        return 0
    end

    local dispelledEffect = target:dispelStatusEffect()
    if dispelledEffect ~= xi.effect.NONE then
        ability:setMsg(xi.msg.basic.JA_REMOVE_EFFECT_2)
    else
        ability:setMsg(xi.msg.basic.JA_NO_EFFECT_2)
    end

    target:updateClaim(player)
    return dispelledEffect
end

return abilityObject
