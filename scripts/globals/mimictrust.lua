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

-- mainJob is the raw JOBTYPE value (see src/common/mmo.h JOBTYPE) of the
-- mimicked character's main job.
xi.mimicTrust.applyGenericGambits = function(mob, mainJob)
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)

    if healerJobs[mainJob] then
        mob:addGambit(ai.t.SELF,  { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
        mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    end
end
