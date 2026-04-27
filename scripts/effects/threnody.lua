-----------------------------------
-- xi.effect.THRENODY
-- Reduces a targets given elemental resistance.
-- MimicXI: Also builds elemental vulnerability stacks (1/tick, cap 10).
-- Each stack = +5% damage from the matching element; consumed on hit.
-- While caster has Troubadour active, stacks build at +2/tick instead.
-----------------------------------
---@type TEffect
local effectObject = {}

-- Lazy reverse map: MEVA mod ID -> element enum value.
local mevaToElement = nil
local function getMevaToElement()
    if mevaToElement then return mevaToElement end
    mevaToElement = {}
    for el = xi.element.FIRE, xi.element.DARK do
        local mevaMod = xi.data.element.getElementalMEVAModifier(el)
        if mevaMod ~= 0 then
            mevaToElement[mevaMod] = el
        end
    end
    return mevaToElement
end

local STACK_CAP = 10

effectObject.onEffectGain = function(target, effect)
    effect:addMod(effect:getSubPower(), -effect:getPower())
    local element = getMevaToElement()[effect:getSubPower()]
    if element then
        target:setLocalVar('THRENODY_STACKS_' .. tostring(element), 0)
    end
end

effectObject.onEffectTick = function(target, effect)
    local element = getMevaToElement()[effect:getSubPower()]
    if not element then return end

    local key     = 'THRENODY_STACKS_' .. tostring(element)
    local stacks  = target:getLocalVar(key)
    if stacks >= STACK_CAP then return end

    -- Troubadour resonance: stacks build twice as fast while caster has Troubadour.
    local increment = 1
    local origin = GetPlayerByID(effect:getOriginID())
    if origin and origin:hasStatusEffect(xi.effect.TROUBADOUR) then
        increment = 2
    end

    target:setLocalVar(key, math.min(stacks + increment, STACK_CAP))
end

effectObject.onEffectLose = function(target, effect)
    local element = getMevaToElement()[effect:getSubPower()]
    if element then
        target:setLocalVar('THRENODY_STACKS_' .. tostring(element), 0)
    end
end

return effectObject
