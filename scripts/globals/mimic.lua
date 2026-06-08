-----------------------------------
-- Mimic system globals
-- Holds server-wide state for bonus
-- weekend events and other toggles.
-----------------------------------
xi       = xi       or {}
xi.mimic = xi.mimic or {}

xi.mimic.bonus =
{
    active   = false,
    exp      = 2.0,
    drop     = 2.0,
    capacity = 2.0,
}

xi.mimic.bonus.getMultipliers = function()
    if not xi.mimic.bonus.active then
        return { exp = 1.0, drop = 1.0, capacity = 1.0 }
    end
    return {
        exp      = xi.mimic.bonus.exp,
        drop     = xi.mimic.bonus.drop,
        capacity = xi.mimic.bonus.capacity,
    }
end
