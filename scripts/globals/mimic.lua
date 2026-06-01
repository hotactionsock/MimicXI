-----------------------------------
-- Mimic server-event state
-- Holds runtime state for all !mimic
-- subcommands. Loaded at startup via
-- globals; survives for the session.
-----------------------------------
xi       = xi       or {}
xi.mimic = xi.mimic or {}

-----------------------------------
-- Bonus weekend state
-----------------------------------
xi.mimic.bonus =
{
    active   = false,
    exp      = 2.0,
    drop     = 2.0,
    capacity = 2.0,
}

xi.mimic.bonus.getMultipliers = function()
    if xi.mimic.bonus.active then
        return
        {
            exp      = xi.mimic.bonus.exp,
            drop     = xi.mimic.bonus.drop,
            capacity = xi.mimic.bonus.capacity,
        }
    end
    return { exp = 1.0, drop = 1.0, capacity = 1.0 }
end
