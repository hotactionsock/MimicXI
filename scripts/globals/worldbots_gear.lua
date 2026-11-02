-----------------------------------
-- xi.worldbots.gear - gear sets for world bots (Phase 3).
--
-- Like a player, a bot keeps several sets and swaps between them:
--   idle     - out of combat (defence, HP, Refresh/Regen)
--   engaged  - meleeing (or tanking, for tank jobs)
--   ws       - put on just before a weapon skill
--   nuke     - elemental nukes, Drain/Aspir
--   cure     - cures
--   enfeeble - enfeebles
-- Each set is a table of stat weights (per point of the stat). The engine
-- (PlanBotGear) picks each set's best armour from what the bot carries, during
-- inventory upkeep; EquipBotGearSet swaps a set on. Weapons are chosen once by
-- the job's weapon set and never swapped mid-fight (that would cost TP).
--
-- Tuning: everything is data here. Weights are rough "how much is one point
-- worth to this job" values, not a simulation - change them freely.
-----------------------------------
xi = xi or {}
xi.worldbots = xi.worldbots or {}
xi.worldbots.gear = xi.worldbots.gear or {}

local gear = xi.worldbots.gear

-- Stat weights by set. Names are xi.mod keys, resolved on first use. Negative
-- weights are for mods where lower is better (damage taken: DMG, DMGPHYS...).
-- HASTE_GEAR is stored in hundredths of a percent, hence its small weight.
local WEIGHTS =
{
    idle =
    {
        DEF = 1, HP = 0.3, MP = 0.1, VIT = 0.5, EVA = 0.5,
        REFRESH = 15, REGEN = 10, DMG = -3, DMGPHYS = -3, DMGMAGIC = -2,
    },

    melee =
    {
        weaponDps = 4,
        ACC = 1.5, ATT = 1, STR = 1, DEX = 1.5, AGI = 0.3,
        HASTE_GEAR = 0.03, DOUBLE_ATTACK = 4, TRIPLE_ATTACK = 6, STORETP = 1.5,
        CRITHITRATE = 2, DUAL_WIELD = 1, DEF = 0.2, HP = 0.05,
    },

    tank =
    {
        weaponDps = 2,
        DEF = 1, HP = 0.5, VIT = 1, EVA = 1, ACC = 0.5, ENMITY = 3,
        DMG = -4, DMGPHYS = -4, DMGMAGIC = -2, HASTE_GEAR = 0.02, SHIELDBLOCKRATE = 2,
    },

    ws =
    {
        STR = 2, DEX = 1.5, ATT = 1.5, ACC = 0.8, WSACC = 1,
        ALL_WSDMG_ALL_HITS = 5, ALL_WSDMG_FIRST_HIT = 4, CRIT_DMG_INCREASE = 2,
    },

    nuke =
    {
        INT = 2, MATT = 2, MACC = 1, ELEM = 1.5, MAGIC_DAMAGE = 1, MP = 0.05,
    },

    cure =
    {
        MND = 2, CURE_POTENCY = 5, HEALING = 1.5, VIT = 0.5, MP = 0.05, CONSERVE_MP = 1,
    },

    enfeeble =
    {
        MACC = 2, ENFEEBLE = 1.5, MND = 1.5, INT = 1, MP = 0.05,
    },

    -- Weapon pick for casters that still melee solo (WHM, RDM...): some damage,
    -- some casting stats.
    casterWeapon =
    {
        weaponDps = 2, MND = 1, INT = 1, MATT = 1, CURE_POTENCY = 2, ACC = 0.5,
    },
}

-- Weapon-skill stat emphasis by main job (replaces ws STR/DEX weights).
local WS_STATS =
{
    WAR = { STR = 2.5, DEX = 1 },
    MNK = { STR = 2, DEX = 2 },
    THF = { DEX = 2.5, AGI = 1.5 },
    PLD = { STR = 2, MND = 1.5 },
    DRK = { STR = 2.5, INT = 1 },
    SAM = { STR = 2.5, DEX = 0.5 },
    DRG = { STR = 2, VIT = 1.5 },
    NIN = { DEX = 2, AGI = 1.5 },
    DNC = { DEX = 2, CHR = 1.5 },
    RNG = { AGI = 2.5, STR = 1 },
    COR = { AGI = 2, STR = 1 },
    RDM = { STR = 1.5, MND = 1.5 },
    BRD = { CHR = 1.5, DEX = 1.5 },
    RUN = { STR = 1.5, DEX = 1.5 },
}

-- What each main job carries: set name -> weights key, plus the weapon set.
local ARCHETYPES =
{
    melee  = { sets = { idle = 'idle', engaged = 'melee', ws = 'ws' }, weapon = 'engaged' },
    tank   = { sets = { idle = 'idle', engaged = 'tank', ws = 'ws', cure = 'cure' }, weapon = 'engaged' },
    healer = { sets = { idle = 'idle', engaged = 'melee', ws = 'ws', cure = 'cure', enfeeble = 'enfeeble', nuke = 'nuke', weapon = 'casterWeapon' }, weapon = 'weapon' },
    nuker  = { sets = { idle = 'idle', engaged = 'melee', nuke = 'nuke', enfeeble = 'enfeeble', cure = 'cure', weapon = 'nuke' }, weapon = 'weapon' },
    hybrid = { sets = { idle = 'idle', engaged = 'melee', ws = 'ws', nuke = 'nuke', enfeeble = 'enfeeble', cure = 'cure', weapon = 'casterWeapon' }, weapon = 'weapon' },
}

local JOB_ARCHETYPE =
{
    WAR = 'melee', MNK = 'melee', THF = 'melee', DRK = 'melee', SAM = 'melee', DRG = 'melee',
    DNC = 'melee', RNG = 'melee', COR = 'melee', BST = 'melee', BLU = 'melee', PUP = 'melee',
    PLD = 'tank', NIN = 'tank', RUN = 'tank',
    WHM = 'healer',
    BLM = 'nuker', SCH = 'nuker', SMN = 'nuker', GEO = 'nuker',
    RDM = 'hybrid', BRD = 'hybrid',
}

-- Spell kinds (worldbots_magic families) -> the set to cast them in.
local SPELL_SET =
{
    cure     = 'cure',
    nuke     = 'nuke',
    drain    = 'nuke',
    aspir    = 'nuke',
    enfeeble = 'enfeeble',
}

local function jobName(jobId)
    for name, id in pairs(xi.job) do
        if id == jobId then
            return name
        end
    end

    return nil
end

-- Builds the PlanBotGear argument for a main job: { [set] = { mods, weaponDps } }.
local function buildSets(jobId)
    local job       = jobName(jobId)
    local archetype = ARCHETYPES[JOB_ARCHETYPE[job] or 'melee']
    local sets      = {}

    for setName, weightsKey in pairs(archetype.sets) do
        local source = WEIGHTS[weightsKey]
        local mods   = {}
        local merged = {}

        for k, v in pairs(source) do
            merged[k] = v
        end

        if setName == 'ws' and WS_STATS[job] then
            merged.STR, merged.DEX = nil, nil
            for k, v in pairs(WS_STATS[job]) do
                merged[k] = v
            end
        end

        for k, v in pairs(merged) do
            if k ~= 'weaponDps' and xi.mod[k] then
                mods[xi.mod[k]] = v
            end
        end

        sets[setName] = { mods = mods, weaponDps = merged.weaponDps or 0 }
    end

    return sets, archetype.weapon
end

local function gearState(state)
    state.gear = state.gear or { worn = nil, planned = false }
    return state.gear
end

-- Re-plans every set from what the bot carries now and equips its weapons.
-- Call during inventory upkeep, out of combat.
function gear.plan(bot, charId, state)
    local g                = gearState(state)
    local sets, weaponSet  = buildSets(bot:getMainJob())

    PlanBotGear(charId, sets, weaponSet)
    g.planned = true
    g.worn    = nil -- force the next wear() to apply the fresh plan
end

-- Puts on a named set (no-op if it's already the one worn).
function gear.wear(charId, state, name)
    local g = gearState(state)
    if not g.planned or g.worn == name then
        return
    end

    EquipBotGearSet(charId, name)
    g.worn = name
end

-- The set for what the bot is doing right now: engaged or idle. Called after a
-- weapon skill or spell to swap back from the action's set.
function gear.base(bot, charId, state)
    gear.wear(charId, state, bot:isEngaged() and 'engaged' or 'idle')
end

-- Just before a weapon skill.
function gear.forWeaponSkill(charId, state)
    gear.wear(charId, state, 'ws')
end

-- Just before a spell of the given worldbots_magic family kind.
function gear.forSpell(charId, state, kind)
    local set = SPELL_SET[kind]
    if set then
        gear.wear(charId, state, set)
    end
end

return gear
