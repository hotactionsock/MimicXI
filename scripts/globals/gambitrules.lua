-----------------------------------
-- xi.gambitRules - player-authored trust gambits: v1 whitelist + resolution
--
-- The native engine (mob:addGambit, scripts/globals/gambits.lua's ai.t/c/r/s)
-- is much larger than what we let a player author from a chat command. This
-- module is the whitelist: the finite set of targets/conditions/reactions a
-- rule may use, plus the string<->id resolution for the two action kinds
-- (spells via MA, job abilities via JA). Rows are stored RAW (the native
-- ai.* ints) in account_gambit_rule; squadutils/the C++ CRUD layer is
-- deliberately meaning-blind about them - this table is the only place that
-- decides what a player is allowed to type.
--
-- Deliberately small for v1 (see [[project_mgambits]] in the dev's memory):
-- no second AND/OR condition, no retry cooldown, no TP-skill triggers yet.
-- Growing this table later needs no schema change - only a wider whitelist.
-----------------------------------
require('scripts/globals/gambits')
require('scripts/globals/magic')
-----------------------------------
xi = xi or {}
xi.gambitRules = xi.gambitRules or {}

local rules = xi.gambitRules

-- name -> ai.t value
rules.TARGETS =
{
    self   = ai.t.SELF,
    party  = ai.t.PARTY,
    target = ai.t.TARGET,
    master = ai.t.MASTER,
    tank   = ai.t.TANK,
}

rules.TARGET_NAME = {}
for name, id in pairs(rules.TARGETS) do
    rules.TARGET_NAME[id] = name
end

-- name -> display label, wire order for the vocab dump (see squad.lua's
-- msqGambitVocab). Order matters here (it is the dropdown order); the name
-- tables above are unordered pairs() iteration and must not be used for that.
rules.TARGET_LIST =
{
    { name = 'self',   label = 'Self' },
    { name = 'party',  label = 'Party' },
    { name = 'target', label = 'Target' },
    { name = 'master', label = 'Master' },
    { name = 'tank',   label = 'Tank' },
}

-- name -> { id = ai.c value, arg = 'none' | 'percent' | 'tp' | 'status' }
rules.CONDITIONS =
{
    always    = { id = ai.c.ALWAYS,     arg = 'none' },
    hpplt     = { id = ai.c.HPP_LT,     arg = 'percent' },
    hppgte    = { id = ai.c.HPP_GTE,    arg = 'percent' },
    mpplt     = { id = ai.c.MPP_LT,     arg = 'percent' },
    mppgte    = { id = ai.c.MPP_GTE,    arg = 'percent' },
    tplt      = { id = ai.c.TP_LT,      arg = 'tp' },
    tpgte     = { id = ai.c.TP_GTE,     arg = 'tp' },
    status    = { id = ai.c.STATUS,     arg = 'status' },
    notstatus = { id = ai.c.NOT_STATUS, arg = 'status' },
    random    = { id = ai.c.RANDOM,     arg = 'percent' }, -- percent chance to fire
}

rules.CONDITION_NAME = {}
for name, def in pairs(rules.CONDITIONS) do
    rules.CONDITION_NAME[def.id] = name
end

-- Wire order + display labels for the vocab dump.
rules.CONDITION_LIST =
{
    { name = 'always',    label = 'Always' },
    { name = 'hpplt',     label = 'HP% below' },
    { name = 'hppgte',    label = 'HP% at or above' },
    { name = 'mpplt',     label = 'MP% below' },
    { name = 'mppgte',    label = 'MP% at or above' },
    { name = 'tplt',      label = 'TP below' },
    { name = 'tpgte',     label = 'TP at or above' },
    { name = 'status',    label = 'Has status' },
    { name = 'notstatus', label = 'Lacks status' },
    { name = 'random',    label = 'Random chance %' },
}

-- Curated status-effect whitelist for the status/notstatus condition. Kept
-- small on purpose (xi.effect has ~700 entries): this is what the addon's
-- dropdown offers AND what validateRaw accepts from it. A chat-typed rule
-- (resolveCondition below) is limited to the same list, so what you can type
-- and what you can click always agree. Covers both debuffs (has X - dispel/
-- -na triggers) and buffs (LACKS X - e.g. a WHM keeping Haste up checks
-- "party notstatus:haste"): STATUS/NOT_STATUS is the same generic engine
-- condition either way, this list is just which effects are exposed.
rules.STATUSES =
{
    { name = 'weakness',      label = 'Weakness',      id = xi.effect.WEAKNESS },
    { name = 'sleep',         label = 'Sleep',         id = xi.effect.SLEEP_I },
    { name = 'poison',        label = 'Poison',        id = xi.effect.POISON },
    { name = 'paralysis',     label = 'Paralysis',     id = xi.effect.PARALYSIS },
    { name = 'blindness',     label = 'Blindness',     id = xi.effect.BLINDNESS },
    { name = 'silence',       label = 'Silence',       id = xi.effect.SILENCE },
    { name = 'petrification', label = 'Petrification', id = xi.effect.PETRIFICATION },
    { name = 'curse',         label = 'Curse',         id = xi.effect.CURSE_I },
    { name = 'stun',          label = 'Stun',          id = xi.effect.STUN },
    { name = 'bind',          label = 'Bind',          id = xi.effect.BIND },
    { name = 'doom',          label = 'Doom',          id = xi.effect.DOOM },
    { name = 'haste',         label = 'Haste',         id = xi.effect.HASTE },
    { name = 'protect',       label = 'Protect',       id = xi.effect.PROTECT },
    { name = 'shell',         label = 'Shell',         id = xi.effect.SHELL },
    { name = 'regen',         label = 'Regen',         id = xi.effect.REGEN },
    { name = 'refresh',       label = 'Refresh',       id = xi.effect.REFRESH },
    { name = 'blink',         label = 'Blink',         id = xi.effect.BLINK },
    { name = 'stoneskin',     label = 'Stoneskin',     id = xi.effect.STONESKIN },
}

rules.STATUS_NAME = {}
for _, s in ipairs(rules.STATUSES) do
    rules.STATUS_NAME[s.id] = s.name
end

-- name -> ai.r value. selector is always resolved alongside the action token
-- (see resolveAction below): 'ma' takes a spellFamily key (-> HIGHEST) or a
-- specific spell name (-> SPECIFIC); 'ja' takes a jobAbility key (-> SPECIFIC).
rules.REACTIONS = { ma = ai.r.MA, ja = ai.r.JA }

rules.REACTION_NAME = {}
for name, id in pairs(rules.REACTIONS) do
    rules.REACTION_NAME[id] = name
end

-- Spell-family vocab for the addon's "ma" action picker (HIGHEST selector
-- only - a specific-spell pick is chat-only for v1, see resolveAction).
-- xi.magic.spellFamily.NONE (0) is excluded; wire order = table order below,
-- built once from xi.magic.spellFamily's own (unordered) pairs() so adding a
-- family there needs no change here.
rules.FAMILY_LIST = {}
do
    local seen = {}
    for name, id in pairs(xi.magic.spellFamily) do
        if id ~= 0 and not seen[id] then
            seen[id] = true
            rules.FAMILY_LIST[#rules.FAMILY_LIST + 1] = { id = id, name = name }
        end
    end
    table.sort(rules.FAMILY_LIST, function(a, b) return a.name < b.name end)
end

rules.MAX_SETS_PER_ACCOUNT  = 8
rules.MAX_RULES_PER_SET     = 10
rules.MAX_NAME_LENGTH       = 24

-----------------------------------
-- Weaponskill (TP-skill) config, per SET rather than per-rule - it maps onto
-- mob:setTrustTPSkillSettings(trigger, select[, value]), which is a single
-- setting on the trust's whole gambit container, not a gambit list entry.
-- The actual candidate weaponskills come from trustutils::
-- loadMimicWeaponSkills (native side) - this only controls WHEN a trust
-- attempts one and, for "specific", WHICH.
-----------------------------------

-- name -> ai.tp value.
rules.TP_TRIGGERS = { asap = ai.tp.ASAP, random = ai.tp.RANDOM, opener = ai.tp.OPENER, closer = ai.tp.CLOSER, closeruntiltp = ai.tp.CLOSER_UNTIL_TP }

rules.TP_TRIGGER_NAME = {}
for name, id in pairs(rules.TP_TRIGGERS) do
    rules.TP_TRIGGER_NAME[id] = name
end

rules.TP_TRIGGER_LIST =
{
    { name = 'asap',          label = 'ASAP' },
    { name = 'random',        label = 'Random' },
    { name = 'opener',        label = 'Skillchain opener' },
    { name = 'closer',        label = 'Skillchain closer (hold TP)' },
    { name = 'closeruntiltp', label = 'Closer until TP threshold' },
}

-- name -> ai.s value. A much smaller slice of ai.s than gambit reactions use -
-- only the selectors TryTrustSkill (gambits_container.cpp) actually resolves
-- generically for a weaponskill pick.
rules.TP_SELECTORS = { random = ai.s.RANDOM, specific = ai.s.SPECIFIC, bestagainsttarget = ai.s.BEST_AGAINST_TARGET }

rules.TP_SELECTOR_NAME = {}
for name, id in pairs(rules.TP_SELECTORS) do
    rules.TP_SELECTOR_NAME[id] = name
end

rules.TP_SELECTOR_LIST =
{
    { name = 'random',             label = 'Random' },
    { name = 'specific',           label = 'Specific weaponskill' },
    { name = 'bestagainsttarget',  label = 'Best for the skillchain' },
}

-- Validates a (trigger, selector, actionid) triple. actionid only matters
-- for 'specific' - checked as a plausible weaponskill id (1-255), not against
-- a name list: the client already builds its "specific" dropdown from its
-- own DAT resources (mirrors dwgambits' weaponSkillPicks), same as the JA
-- action list, so there is nothing server-side to look the name up against.
rules.validateTpSkill = function(trigger, selector, actionid)
    if rules.TP_TRIGGER_NAME[trigger] == nil then
        return false, 'unknown weaponskill trigger'
    end
    if rules.TP_SELECTOR_NAME[selector] == nil then
        return false, 'unknown weaponskill selector'
    end
    if selector == ai.s.SPECIFIC and (actionid < 1 or actionid > 255) then
        return false, 'weaponskill id out of range'
    end
    return true
end

-- token -> percent/tp/status numeric arg, or nil + why. Condition kind decides
-- how the token is read: percent is 0-100, tp is 0-3000, status is an
-- xi.effect key (case-insensitive) or a bare numeric id.
local function resolveConditionArg(kind, token)
    if kind == 'none' then
        return 0
    end

    if kind == 'percent' then
        local n = tonumber(token)
        if n == nil or n < 0 or n > 100 then
            return nil, 'expected a percent 0-100'
        end
        return math.floor(n)
    end

    if kind == 'tp' then
        local n = tonumber(token)
        if n == nil or n < 0 or n > 3000 then
            return nil, 'expected a TP value 0-3000'
        end
        return math.floor(n)
    end

    if kind == 'status' then
        for _, s in ipairs(rules.STATUSES) do
            if s.name == string.lower(token or '') then
                return s.id
            end
        end
        return nil, string.format('unknown status "%s" (see !squad gambit statuses)', tostring(token))
    end

    return nil, 'unknown condition argument kind'
end

-- Resolve "<condition>[:<arg>]" (e.g. "hpplt:75", "status:poison", "always")
-- into { cond = ai.c value, arg = numeric }, or nil + why.
rules.resolveCondition = function(text)
    local name, argText = string.match(text or '', '^(%a+):?(.*)$')
    local def = name and rules.CONDITIONS[string.lower(name)]
    if def == nil then
        return nil, string.format('unknown condition "%s"', tostring(text))
    end

    if def.arg == 'none' then
        return { cond = def.id, arg = 0 }
    end

    local arg, why = resolveConditionArg(def.arg, argText)
    if arg == nil then
        return nil, why
    end

    return { cond = def.id, arg = arg }
end

-- Resolve "<reaction> <name>" (e.g. "ma cure", "ma spell:cure_ii", "ja provoke")
-- into { reaction, selector, actionid }, or nil + why.
rules.resolveAction = function(reactionText, nameText)
    local reactionId = rules.REACTIONS[string.lower(reactionText or '')]
    if reactionId == nil then
        return nil, string.format('unknown reaction "%s"', tostring(reactionText))
    end

    local key = string.lower(nameText or '')

    if reactionId == ai.r.MA then
        local specific = string.match(key, '^spell:(.+)$')
        if specific ~= nil then
            local id = xi.magic.spell[string.upper(specific)]
            if id == nil then
                return nil, string.format('unknown spell "%s"', specific)
            end
            return { reaction = ai.r.MA, selector = ai.s.SPECIFIC, actionid = id }
        end

        local familyId = xi.magic.spellFamily[string.upper(key)]
        if familyId == nil then
            return nil, string.format('unknown spell family "%s" (try spell:<name> for a specific spell)', nameText)
        end
        return { reaction = ai.r.MA, selector = ai.s.HIGHEST, actionid = familyId }
    end

    -- ai.r.JA
    local id = xi.jobAbility[string.upper(key)]
    if id == nil then
        return nil, string.format('unknown job ability "%s"', nameText)
    end
    return { reaction = ai.r.JA, selector = ai.s.SPECIFIC, actionid = id }
end

-- Validates a rule already resolved to raw ints (the addon's path: it picks
-- target/condition/action from the vocab dump and its own client DAT
-- resources, then sends the resolved ints directly - see msq.lua's
-- "gambit addraw"). Returns true, or false + why. The chat path never needs
-- this: resolveCondition/resolveAction only ever produce whitelisted values
-- by construction.
rules.validateRaw = function(target, cond, arg, reaction, selector, actionid)
    if rules.TARGET_NAME[target] == nil then
        return false, 'unknown target'
    end

    local condName = rules.CONDITION_NAME[cond]
    if condName == nil then
        return false, 'unknown condition'
    end

    local def = rules.CONDITIONS[condName]
    if def.arg == 'percent' and (arg < 0 or arg > 100) then
        return false, 'percent out of range (0-100)'
    elseif def.arg == 'tp' and (arg < 0 or arg > 3000) then
        return false, 'TP out of range (0-3000)'
    elseif def.arg == 'status' and rules.STATUS_NAME[arg] == nil then
        return false, 'unknown status'
    end

    if reaction == ai.r.MA and selector == ai.s.HIGHEST then
        if rules.spellFamilyName(actionid) == nil then
            return false, 'unknown spell family'
        end
    elseif reaction == ai.r.MA and selector == ai.s.SPECIFIC then
        if rules.spellName(actionid) == nil then
            return false, 'unknown spell'
        end
    elseif reaction == ai.r.JA and selector == ai.s.SPECIFIC then
        if rules.jobAbilityName(actionid) == nil then
            return false, 'unknown job ability'
        end
    else
        return false, 'unknown reaction/selector combination'
    end

    return true
end

-- Render a stored rule row back into readable text, for `show`.
rules.describe = function(row)
    local target = rules.TARGET_NAME[row.target] or ('#' .. row.target)
    local cname  = rules.CONDITION_NAME[row.cond] or ('#' .. row.cond)
    local cond   = cname

    local def = rules.CONDITIONS[cname]
    if def ~= nil and def.arg == 'status' then
        cond = string.format('%s:%s', cname, rules.STATUS_NAME[row.arg] or ('#' .. row.arg))
    elseif def ~= nil and def.arg ~= 'none' then
        cond = string.format('%s:%d', cname, row.arg)
    end

    local action
    if row.reaction == ai.r.MA and row.selector == ai.s.HIGHEST then
        action = string.format('ma %s', rules.spellFamilyName(row.actionid) or ('#' .. row.actionid))
    elseif row.reaction == ai.r.MA then
        action = string.format('ma spell:%s', rules.spellName(row.actionid) or ('#' .. row.actionid))
    elseif row.reaction == ai.r.JA then
        action = string.format('ja %s', rules.jobAbilityName(row.actionid) or ('#' .. row.actionid))
    else
        action = string.format('reaction %d/%d/%d', row.reaction, row.selector, row.actionid)
    end

    return string.format('%s %s -> %s', target, cond, action)
end

local spellFamilyById, spellById, jobAbilityById

rules.spellFamilyName = function(id)
    if spellFamilyById == nil then
        spellFamilyById = {}
        for name, value in pairs(xi.magic.spellFamily) do
            spellFamilyById[value] = name
        end
    end
    return spellFamilyById[id]
end

rules.spellName = function(id)
    if spellById == nil then
        spellById = {}
        for name, value in pairs(xi.magic.spell) do
            spellById[value] = name
        end
    end
    return spellById[id]
end

rules.jobAbilityName = function(id)
    if jobAbilityById == nil then
        jobAbilityById = {}
        for name, value in pairs(xi.jobAbility) do
            jobAbilityById[value] = name
        end
    end
    return jobAbilityById[id]
end

-- Installs the rule set assigned to (charId, mjob) onto a freshly-built mimic
-- trust: its rules (mob:addGambit, possibly zero of them) AND its
-- weaponskill config (mob:setTrustTPSkillSettings). Returns true if a set is
-- assigned at all - caller should skip its own generic fallback gambits even
-- for an assigned set with zero rules (e.g. "weaponskills only, no gambits").
rules.applyAssigned = function(mob, master, charId, mjob)
    if master == nil then
        return false
    end

    local setName = master:getGambitAssign(charId, mjob)
    if setName == nil or setName == '' then
        return false
    end

    local setRow = nil
    for _, s in ipairs(master:getGambitSets()) do
        if s.name == setName then
            setRow = s
            break
        end
    end
    if setRow == nil then
        return false
    end

    mob:setTrustTPSkillSettings(setRow.tpTrigger, setRow.tpSelector, setRow.tpActionId)

    for _, row in ipairs(master:getGambitRules(setName)) do
        mob:addGambit(row.target, { row.cond, row.arg }, { row.reaction, row.selector, row.actionid })
    end

    return true
end
