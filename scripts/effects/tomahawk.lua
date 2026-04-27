-----------------------------------
-- xi.effect.TOMAHAWK
-----------------------------------
---@type TEffect
local effectObject = {}

local SDT_BY_WEAPON_TYPE =
{
    [xi.damageType.SLASHING] = xi.mod.SLASH_SDT,
    [xi.damageType.PIERCING] = xi.mod.PIERCE_SDT,
    [xi.damageType.BLUNT]    = xi.mod.IMPACT_SDT,
    [xi.damageType.HTH]      = xi.mod.HTH_SDT,
}

local TOMAHAWK_SDT_VALUE = -2000 -- 20% vulnerability to the matched damage type

effectObject.onEffectGain = function(target, effect)
    local origin = GetPlayerByID(effect:getOriginID())
    if not origin then
        return
    end

    local weaponType = origin:getWeaponDamageType(xi.slot.MAIN)
    local sdtMod     = SDT_BY_WEAPON_TYPE[weaponType]
    if not sdtMod then
        return
    end

    effect:addMod(sdtMod, TOMAHAWK_SDT_VALUE)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
