-----------------------------------
-- xi.worldbots.magic - spellcasting for world bots (Phase 3).
--
-- Used by scripts/globals/worldbots.lua. Casting itself is engine-side
-- (CastBotSpell -> CPlayerController::Cast), so every player rule applies:
-- job/level gates, MP, recast, silence, range and interruption.
--
-- How a bot chooses a spell:
--   * Spells come in FAMILIES (Cure, Protect, Dia, Fire...), each a list of
--     tiers. A bot uses the best tier it knows, can afford and is off recast.
--   * Every bot uses what its spells allow for itself: cures, self-buffs,
--     Utsusemi. So a WAR/WHM cures itself and a NIN keeps shadows up.
--   * Offensive magic (nukes, enfeebles) depends on the main job's CASTER
--     PROFILE: what it nukes with, which enfeebles it opens a fight with, how
--     much MP it keeps back for cures, and whether it stands off at range.
--
-- State kept in the bot's worldbots scratch state (state.magic):
--   spells     = { [spellId] = { id, mpCost, ... } }  -- from GetBotSpells
--   level      = main level when the list was read (re-read on level-up)
--   job        = main job when the profile/range was applied
--   blocked    = { [spellId] = until }                 -- back-off after failed casts
--   fails      = { [spellId] = n }                     -- failures in a row (back-off doubles)
--   range      = stand-off range last sent to the engine
--   fight      = { targetId, tries = { [family] = n } } -- per-fight enfeeble bookkeeping
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.magic = xi.worldbots.magic or {}

local magic = xi.worldbots.magic

-- Engine cast results (botutils::BotCastResult)
local CAST_OK        = 0
local CAST_NOT_READY = 1
local CAST_NO_MP     = 2
local CAST_NO_TARGET = 3
local CAST_INVALID   = 4

local SPELL_REFRESH_SEC      = 5 * 60 -- re-read the spell list this often anyway (new scrolls learned)
local BLOCK_NOT_READY_SEC    = 2      -- back-off after a cast that couldn't start...
local BLOCK_MAX_SEC          = 120    -- ...doubling on each failure in a row, up to this
local BLOCK_NO_TARGET_SEC    = 2
local BLOCK_INVALID_SEC      = 60

local URGENT_CURE_HPP        = 45     -- in a fight, cure before anything else below this
local COMBAT_CURE_HPP        = 60     -- in a fight, cure when nothing better to do below this
local IDLE_CURE_HPP          = 75     -- between fights, cure instead of resting below this...
local IDLE_CURE_MIN_MPP      = 50     -- ...if MP is at least this
local DRAIN_BELOW_HPP        = 70
local ASPIR_BELOW_MPP        = 60
local ENFEEBLE_MAX_TRIES     = 2      -- per family per fight (resists cost MP)
local REST_BELOW_MPP         = 30     -- casters rest between fights below this MP%...
local REST_UNTIL_MPP         = 90     -- ...until back up to this

-- Rough HP restored per Cure tier: pick the smallest tier that covers the
-- missing HP, so a scratch doesn't cost a Cure IV.
local CURE_TIER_MISSING_HP   = { 0, 60, 140, 300, 500, 650 }

-----------------------------------
-- Families (names resolved to ids on first use, so enum load order doesn't matter)
-----------------------------------

-- kind: 'cure', 'buff' (self, keyed by effect), 'shadows', 'enfeeble' (enemy,
--       keyed by effect), 'nuke', 'drain', 'aspir', 'song' (self, in combat)
-- prebuff: cast between fights when missing (otherwise in-combat upkeep only)
local FAMILY_DEFS =
{
    cure      = { kind = 'cure',     spells = { 'CURE', 'CURE_II', 'CURE_III', 'CURE_IV', 'CURE_V', 'CURE_VI' } },

    protect   = { kind = 'buff', prebuff = true, effect = 'PROTECT',    spells = { 'PROTECT', 'PROTECT_II', 'PROTECT_III', 'PROTECT_IV', 'PROTECT_V' } },
    shell     = { kind = 'buff', prebuff = true, effect = 'SHELL',      spells = { 'SHELL', 'SHELL_II', 'SHELL_III', 'SHELL_IV', 'SHELL_V' } },
    stoneskin = { kind = 'buff', prebuff = true, effect = 'STONESKIN',  spells = { 'STONESKIN' } },
    blink     = { kind = 'buff', prebuff = true, effect = 'BLINK',      spells = { 'BLINK' } },
    aquaveil  = { kind = 'buff', prebuff = true, effect = 'AQUAVEIL',   spells = { 'AQUAVEIL' } },
    phalanx   = { kind = 'buff', prebuff = true, effect = 'PHALANX',    spells = { 'PHALANX' } },
    refresh   = { kind = 'buff', prebuff = true, effect = 'REFRESH',    spells = { 'REFRESH', 'REFRESH_II', 'REFRESH_III' } },
    haste     = { kind = 'buff', prebuff = true, effect = 'HASTE',      spells = { 'HASTE', 'HASTE_II' } },
    spikes    = { kind = 'buff', prebuff = true, effect = 'BLAZE_SPIKES', spells = { 'BLAZE_SPIKES' } },
    regen     = { kind = 'buff', effect = 'REGEN',                      spells = { 'REGEN', 'REGEN_II', 'REGEN_III', 'REGEN_IV', 'REGEN_V' } },

    utsusemi  = { kind = 'shadows', prebuff = true,                     spells = { 'UTSUSEMI_ICHI', 'UTSUSEMI_NI', 'UTSUSEMI_SAN' } },

    minuet    = { kind = 'song', effect = 'MINUET',   spells = { 'VALOR_MINUET', 'VALOR_MINUET_II', 'VALOR_MINUET_III', 'VALOR_MINUET_IV', 'VALOR_MINUET_V' } },
    madrigal  = { kind = 'song', effect = 'MADRIGAL', spells = { 'SWORD_MADRIGAL', 'BLADE_MADRIGAL' } },

    dia       = { kind = 'enfeeble', effect = 'DIA',       spells = { 'DIA', 'DIA_II', 'DIA_III' } },
    bio       = { kind = 'enfeeble', effect = 'BIO',       spells = { 'BIO', 'BIO_II', 'BIO_III' } },
    paralyze  = { kind = 'enfeeble', effect = 'PARALYSIS', spells = { 'PARALYZE', 'PARALYZE_II' } },
    slow      = { kind = 'enfeeble', effect = 'SLOW',      spells = { 'SLOW', 'SLOW_II' } },
    poison    = { kind = 'enfeeble', effect = 'POISON',    spells = { 'POISON', 'POISON_II' } },

    fire      = { kind = 'nuke', spells = { 'FIRE', 'FIRE_II', 'FIRE_III', 'FIRE_IV', 'FIRE_V', 'FIRE_VI' } },
    blizzard  = { kind = 'nuke', spells = { 'BLIZZARD', 'BLIZZARD_II', 'BLIZZARD_III', 'BLIZZARD_IV', 'BLIZZARD_V', 'BLIZZARD_VI' } },
    aero      = { kind = 'nuke', spells = { 'AERO', 'AERO_II', 'AERO_III', 'AERO_IV', 'AERO_V', 'AERO_VI' } },
    stone     = { kind = 'nuke', spells = { 'STONE', 'STONE_II', 'STONE_III', 'STONE_IV', 'STONE_V', 'STONE_VI' } },
    thunder   = { kind = 'nuke', spells = { 'THUNDER', 'THUNDER_II', 'THUNDER_III', 'THUNDER_IV', 'THUNDER_V', 'THUNDER_VI' } },
    water     = { kind = 'nuke', spells = { 'WATER', 'WATER_II', 'WATER_III', 'WATER_IV', 'WATER_V', 'WATER_VI' } },
    banish    = { kind = 'nuke', undeadOnly = true, spells = { 'BANISH', 'BANISH_II', 'BANISH_III', 'BANISH_IV', 'BANISH_V' } },

    drain     = { kind = 'drain', spells = { 'DRAIN', 'DRAIN_II', 'DRAIN_III' } },
    aspir     = { kind = 'aspir', spells = { 'ASPIR', 'ASPIR_II', 'ASPIR_III' } },
}

-- Self-buff upkeep order (most valuable first).
local BUFF_ORDER    = { 'protect', 'shell', 'phalanx', 'refresh', 'haste', 'stoneskin', 'blink', 'aquaveil', 'spikes' }
local NUKE_FAMILIES = { 'fire', 'blizzard', 'aero', 'stone', 'thunder', 'water' }

-- Caster profiles by MAIN job. Jobs not listed only cast for themselves
-- (cures, buffs, shadows) - e.g. a WAR/WHM or a NIN.
--   nuke       - casts elemental nukes ('divine' = Banish on undead only)
--   enfeebles  - families to open a fight with (once landed, not recast)
--   songs      - song families to keep up in a fight
--   drain      - uses Drain/Aspir
--   reserve    - fraction of max MP kept back for cures (offence stops below it)
--   standoff   - yalms to stay away from the target (0 = melee)
local PROFILES = nil

local function profiles()
    if PROFILES then
        return PROFILES
    end

    PROFILES =
    {
        [xi.job.WHM] = { nuke = 'divine', enfeebles = { 'dia', 'paralyze', 'slow' }, reserve = 0.35, standoff = 0 },
        [xi.job.BLM] = { nuke = true, enfeebles = {}, drain = true, reserve = 0.15, standoff = 15 },
        [xi.job.RDM] = { nuke = true, enfeebles = { 'dia', 'paralyze', 'slow' }, reserve = 0.3, standoff = 0 },
        [xi.job.SCH] = { nuke = true, enfeebles = { 'dia' }, reserve = 0.3, standoff = 15 },
        [xi.job.PLD] = { nuke = 'divine', enfeebles = {}, reserve = 0.35, standoff = 0 },
        [xi.job.DRK] = { nuke = false, enfeebles = { 'bio' }, drain = true, reserve = 0.2, standoff = 0 },
        [xi.job.BRD] = { nuke = false, enfeebles = {}, songs = { 'minuet', 'madrigal' }, reserve = 0, standoff = 0 },
        [xi.job.RUN] = { nuke = false, enfeebles = {}, reserve = 0.2, standoff = 0 },
    }

    return PROFILES
end

-- Resolved families: name -> { def, ids = { tier1, tier2, ... } }
local FAMILIES = nil

local function families()
    if FAMILIES then
        return FAMILIES
    end

    FAMILIES = {}
    for name, def in pairs(FAMILY_DEFS) do
        local ids = {}
        for _, spellName in ipairs(def.spells) do
            local id = xi.magic.spell[spellName]
            if id then
                table.insert(ids, id)
            end
        end

        FAMILIES[name] =
        {
            def    = def,
            ids    = ids,
            effect = def.effect and xi.effect[def.effect] or nil,
        }
    end

    return FAMILIES
end

-----------------------------------
-- Spell list
-----------------------------------

local function magicState(state)
    state.magic = state.magic or { spells = {}, blocked = {}, fails = {}, level = -1, job = -1, readAt = 0, range = -1 }
    return state.magic
end

-- Re-reads the bot's castable spells on level-up, job change, or every few
-- minutes (scrolls get learned by inventory upkeep). Also applies the main
-- job's stand-off range.
function magic.refresh(bot, charId, state, now, force)
    local m     = magicState(state)
    local level = bot:getMainLvl()
    local job   = bot:getMainJob()

    if
        force or
        m.level ~= level or
        m.job ~= job or
        now >= m.readAt + SPELL_REFRESH_SEC
    then
        m.spells = {}
        for _, spell in ipairs(GetBotSpells(charId)) do
            m.spells[spell.id] = spell
        end

        m.level  = level
        m.readAt = now
    end

    m.job = job
end

-- Stand off at the profile's range while there's MP to cast with; out of MP,
-- close in and melee instead of standing there.
local function updateRange(bot, charId, m, profile, canCast)
    local range = (profile and canCast) and profile.standoff or 0
    if range ~= m.range then
        SetBotCombatRange(charId, range)
        m.range = range
    end
end

local function profileOf(bot)
    return profiles()[bot:getMainJob()]
end

local function knowsAny(m, family)
    for _, id in ipairs(family.ids) do
        if m.spells[id] then
            return true
        end
    end

    return false
end

-- Best tier of a family the bot knows, can afford and isn't backing off from.
-- maxTier caps the tier (cures sized to the damage).
local function bestOf(bot, m, family, now, maxTier)
    local mp   = bot:getMP()
    local last = maxTier and math.min(maxTier, #family.ids) or #family.ids

    for tier = last, 1, -1 do
        local id    = family.ids[tier]
        local spell = m.spells[id]
        if spell and spell.mpCost <= mp and now >= (m.blocked[id] or 0) then
            return id
        end
    end

    -- Nothing at or under the cap: any affordable tier above it beats nothing.
    if maxTier then
        for tier = last + 1, #family.ids do
            local id    = family.ids[tier]
            local spell = m.spells[id]
            if spell and spell.mpCost <= mp and now >= (m.blocked[id] or 0) then
                return id
            end
        end
    end

    return nil
end

-- Casts spellId, backing off from it if the engine says no. True if cast.
local function cast(bot, charId, m, spellId, now)
    local result = CastBotSpell(charId, spellId)
    if result == CAST_OK then
        m.fails[spellId] = nil
        return true
    end

    if result == CAST_NOT_READY then
        -- Doubles on each failure in a row: a spell that can never start (no
        -- ninja tools for Utsusemi, say) stops being retried every couple of seconds.
        local fails        = (m.fails[spellId] or 0) + 1
        m.fails[spellId]   = fails
        m.blocked[spellId] = now + math.min(BLOCK_NOT_READY_SEC * 2 ^ (fails - 1), BLOCK_MAX_SEC)
    elseif result == CAST_NO_TARGET then
        m.blocked[spellId] = now + BLOCK_NO_TARGET_SEC
    elseif result == CAST_INVALID then
        -- Lost the spell (level/job change): re-read the list soon.
        m.blocked[spellId] = now + BLOCK_INVALID_SEC
        m.readAt           = 0
    end

    -- CAST_NO_MP: bestOf already filters by MP; nothing to back off from.

    return false
end

-- MP the bot must keep for cures (0 if it can't cure).
local function mpReserve(bot, m, profile)
    if not knowsAny(m, families().cure) then
        return 0
    end

    return bot:getMaxMP() * (profile and profile.reserve or 0.3)
end

local function canSpend(bot, m, profile, spellId)
    local spell = m.spells[spellId]
    return spell ~= nil and bot:getMP() - spell.mpCost >= mpReserve(bot, m, profile)
end

-----------------------------------
-- Individual decisions
-----------------------------------

local function tryCure(bot, charId, m, now, belowHpp)
    if bot:getHPP() >= belowHpp then
        return false
    end

    local missing = bot:getMaxHP() - bot:getHP()
    local tier    = 1
    for i, need in ipairs(CURE_TIER_MISSING_HP) do
        if missing >= need then
            tier = i
        end
    end

    local id = bestOf(bot, m, families().cure, now, tier)
    return id ~= nil and cast(bot, charId, m, id, now)
end

local function hasShadows(bot)
    return bot:hasStatusEffect(xi.effect.COPY_IMAGE) or
        bot:hasStatusEffect(xi.effect.COPY_IMAGE_2) or
        bot:hasStatusEffect(xi.effect.COPY_IMAGE_3) or
        bot:hasStatusEffect(xi.effect.COPY_IMAGE_4)
end

local function tryShadows(bot, charId, m, now)
    if hasShadows(bot) then
        return false
    end

    local id = bestOf(bot, m, families().utsusemi, now)
    return id ~= nil and cast(bot, charId, m, id, now)
end

-- Missing self-buffs, in BUFF_ORDER. prebuffOnly: only families marked prebuff.
local function tryBuffs(bot, charId, m, now, names, prebuffOnly)
    local all = families()
    for _, name in ipairs(names) do
        local family = all[name]
        if
            family and
            family.effect and
            (not prebuffOnly or family.def.prebuff) and
            not bot:hasStatusEffect(family.effect)
        then
            local id = bestOf(bot, m, family, now)
            if id and cast(bot, charId, m, id, now) then
                return true
            end
        end
    end

    return false
end

local function fightState(m, target)
    local targetId = target:getID()
    if m.fight == nil or m.fight.targetId ~= targetId then
        m.fight = { targetId = targetId, tries = {} }
    end

    return m.fight
end

local function tryEnfeebles(bot, charId, m, profile, target, now)
    if not profile or #profile.enfeebles == 0 then
        return false
    end

    local fight = fightState(m, target)
    local all   = families()

    for _, name in ipairs(profile.enfeebles) do
        local family = all[name]
        local tries  = fight.tries[name] or 0
        if
            family and
            tries < ENFEEBLE_MAX_TRIES and
            not target:hasStatusEffect(family.effect)
        then
            local id = bestOf(bot, m, family, now)
            if id and canSpend(bot, m, profile, id) and cast(bot, charId, m, id, now) then
                fight.tries[name] = tries + 1
                return true
            end
        end
    end

    return false
end

local function tryNuke(bot, charId, m, profile, target, now)
    if not profile or not profile.nuke then
        return false
    end

    local all = families()

    if profile.nuke == 'divine' then
        if not target:isUndead() then
            return false
        end

        local id = bestOf(bot, m, all.banish, now)
        return id ~= nil and canSpend(bot, m, profile, id) and cast(bot, charId, m, id, now)
    end

    -- Highest tier available across the elements; a random element among
    -- equals, so a bot doesn't spam one element all day.
    local bestTier, choices = 0, {}
    for _, name in ipairs(NUKE_FAMILIES) do
        local family = all[name]
        local id     = bestOf(bot, m, family, now)
        if id and canSpend(bot, m, profile, id) then
            local tier = 0
            for i, tierId in ipairs(family.ids) do
                if tierId == id then
                    tier = i
                end
            end

            if tier > bestTier then
                bestTier, choices = tier, { id }
            elseif tier == bestTier then
                table.insert(choices, id)
            end
        end
    end

    if #choices == 0 then
        return false
    end

    return cast(bot, charId, m, choices[math.random(1, #choices)], now)
end

local function tryDrains(bot, charId, m, profile, now)
    if not profile or not profile.drain then
        return false
    end

    local all = families()

    if bot:getHPP() < DRAIN_BELOW_HPP then
        local id = bestOf(bot, m, all.drain, now)
        if id and cast(bot, charId, m, id, now) then
            return true
        end
    end

    if bot:getMPP() < ASPIR_BELOW_MPP then
        local id = bestOf(bot, m, all.aspir, now)
        if id and cast(bot, charId, m, id, now) then
            return true
        end
    end

    return false
end

local function trySongs(bot, charId, m, profile, now)
    if not profile or not profile.songs then
        return false
    end

    return tryBuffs(bot, charId, m, now, profile.songs, false)
end

-----------------------------------
-- Entry points (called from xi.worldbots)
-----------------------------------

-- In a fight, before anything else: an urgent cure or lost shadows.
function magic.urgent(bot, charId, state, now)
    local m = magicState(state)
    return tryCure(bot, charId, m, now, URGENT_CURE_HPP) or tryShadows(bot, charId, m, now)
end

-- Can the bot afford any of its offensive spells right now?
local function canAffordOffence(bot, m, profile)
    if not profile then
        return false
    end

    local all   = families()
    local names = {}
    for _, name in ipairs(profile.enfeebles) do
        table.insert(names, name)
    end

    if profile.nuke and profile.nuke ~= 'divine' then
        for _, name in ipairs(NUKE_FAMILIES) do
            table.insert(names, name)
        end
    end

    for _, name in ipairs(names) do
        for _, id in ipairs(all[name].ids) do
            if m.spells[id] and canSpend(bot, m, profile, id) then
                return true
            end
        end
    end

    return false
end

-- In a fight, after weapon skills: the job's normal spell rotation. True if it cast.
function magic.combat(bot, charId, state, now)
    local m       = magicState(state)
    local profile = profileOf(bot)
    local target  = bot:getTarget()

    updateRange(bot, charId, m, profile, canAffordOffence(bot, m, profile))

    if tryCure(bot, charId, m, now, COMBAT_CURE_HPP) then
        return true
    end

    if trySongs(bot, charId, m, profile, now) then
        return true
    end

    if target and not target:isDead() then
        if tryEnfeebles(bot, charId, m, profile, target, now) then
            return true
        end

        if tryNuke(bot, charId, m, profile, target, now) then
            return true
        end
    end

    if tryDrains(bot, charId, m, profile, now) then
        return true
    end

    -- Short buffs that wear off mid-fight.
    return tryBuffs(bot, charId, m, now, { 'stoneskin', 'blink', 'regen' }, false)
end

-- Between fights, before resting or looking for prey: cure up, then put
-- missing pre-fight buffs on. True if it cast (the caller should wait).
function magic.idle(bot, charId, state, now)
    local m = magicState(state)

    -- Set the stand-off range before the next pull, not after the first swing.
    local profile = profileOf(bot)
    updateRange(bot, charId, m, profile, canAffordOffence(bot, m, profile))

    if
        bot:getMPP() >= IDLE_CURE_MIN_MPP and
        tryCure(bot, charId, m, now, IDLE_CURE_HPP)
    then
        return true
    end

    if tryShadows(bot, charId, m, now) then
        return true
    end

    return tryBuffs(bot, charId, m, now, BUFF_ORDER, true)
end

-- Should the bot rest (/heal) for MP? Only bots that actually use MP for
-- offence or healing - a WAR/NIN with a few MP for Utsusemi doesn't camp out.
function magic.wantsRest(bot, state)
    if bot:getMaxMP() == 0 then
        return false
    end

    local m = magicState(state)
    if not profileOf(bot) and not knowsAny(m, families().cure) then
        return false
    end

    return bot:getMPP() < REST_BELOW_MPP
end

-- Is the bot rested enough on MP to stop /heal?
function magic.restedMP(bot, state)
    if bot:getMaxMP() == 0 then
        return true
    end

    local m = magicState(state)
    if not profileOf(bot) and not knowsAny(m, families().cure) then
        return true
    end

    return bot:getMPP() >= REST_UNTIL_MPP
end

return magic
