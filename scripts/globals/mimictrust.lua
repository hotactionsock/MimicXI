-----------------------------------
-- Mimic Trust
-- Generic Phase-1 AI applied to trusts built from a player's own offline alt
-- characters (see trustutils::BuildMimicTrust). Deliberately simple: normal
-- melee/ranged auto-attacks (and their added effects) already work without
-- any gambits at all - this just gives job-appropriate healers a baseline
-- self-preservation behavior. Per-job/personality gambit tuning is left for
-- a later pass.
-----------------------------------
require('scripts/globals/magic')
require('scripts/globals/gambitrules')
require('scripts/globals/trust')
-----------------------------------
xi = xi or {}
xi.mimicTrust = xi.mimicTrust or {}

local healerJobs =
{
    [xi.job.WHM] = true,
    [xi.job.RDM] = true,
    [xi.job.SCH] = true,
    [xi.job.PLD] = true,
}

-- "Mage" jobs (FFXI's own colloquial split, not a JOBTYPE category): pure/
-- support casters with weak melee that gain nothing from being in weapon
-- range. Deliberately excludes PLD/DRK/RUN/NIN/BLU - those are melee-primary
-- despite carrying real spell lists, and should keep fighting at MELEE like
-- any other physical job. Real trust NPCs of these jobs follow the same
-- split (see e.g. shantotto.lua/kupipi.lua: setAutoAttackEnabled(false) +
-- NO_MOVE; contrast e.g. curilla.lua/zeid.lua (PLD/DRK), which set neither).
local mageJobs =
{
    [xi.job.WHM] = true,
    [xi.job.BLM] = true,
    [xi.job.RDM] = true,
    [xi.job.SCH] = true,
    [xi.job.GEO] = true,
    [xi.job.SMN] = true,
    [xi.job.BRD] = true,
}

-- Physical ranged jobs: also gain nothing from melee range, but (unlike
-- mageJobs) still want to be landing hits - just via their ranged weapon
-- rather than closing to swing, so ranged auto-attack stays on.
local rangedJobs =
{
    [xi.job.RNG] = true,
    [xi.job.COR] = true,
}

-- Applies job-appropriate positioning/auto-attack behaviour so a caster or
-- ranged-DD mimic doesn't run into melee range and feed the mob TP for
-- nothing. Runs unconditionally (even when a player-authored gambit set is
-- assigned, see applyGenericGambits below) - this is a physical-AI concern,
-- not a gambit-list concern, so a custom rule set should never have to fight
-- the trust's own positioning to keep a BLM out of melee.
local function applyCombatStance(mob, mainJob)
    if mageJobs[mainJob] then
        mob:setAutoAttackEnabled(false)
        mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
    elseif rangedJobs[mainJob] then
        mob:setAutoAttackEnabled(false)
        mob:setRangedAttackEnabled(true)
        mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)
    end
    -- Everything else keeps the engine default (auto-attack on, TRUST_DISTANCE MELEE).
end

-- mainJob is the raw JOBTYPE value (see src/common/mmo.h JOBTYPE) of the
-- mimicked character's main job. master/altCharId identify whose gambit
-- assignment (see scripts/globals/gambitrules.lua) applies, if any - a
-- custom assigned set replaces the generic gambit list below entirely (it
-- does not affect applyCombatStance, which always runs first).
-- Note: trustutils::loadMimicWeaponSkills (native side, called just before
-- this) already defaults tp_trigger/tp_select to ASAP/RANDOM, so nothing
-- further is needed here for the fallback case - applyAssigned overrides
-- both the gambit list and the tp-skill settings when a custom set exists.
xi.mimicTrust.applyGenericGambits = function(mob, mainJob, master, altCharId)
    applyCombatStance(mob, mainJob)

    if xi.gambitRules.applyAssigned(mob, master, altCharId, mainJob) then
        return
    end

    if healerJobs[mainJob] then
        mob:addGambit(ai.t.SELF,  { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
        mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    end
end
