-----------------------------------
-- Hot Shot
-- Marksmanship weapon skill
-- Skill Level: 5
-- Deals fire elemental damage to enemy.
-- Aligned with the Flame Gorget & Light Gorget.
-- Aligned with the Flame Belt & Light Belt.
-- Element: Fire
-- Modifiers: AGI:30%
-- 100%TP    200%TP    300%TP
-- 0.50      0.75      1.00
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.numHits = 1
    params.ftpMod = { 0.5, 0.75, 1.0 }
    params.agi_wsc = 0.3
    params.hybridWS = true
    params.ele = xi.element.FIRE
    params.skill = xi.skill.MARKSMANSHIP
    params.includemab = true

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 0.5, 1.55, 2.1 }
        params.agi_wsc = 0.7
    end

    -- Dead Aim: consume stacks from Quick Draw hits for bonus fTP (COR main only)
    local deadAimStacks = player:getLocalVar('DEAD_AIM_STACKS')
    if deadAimStacks > 0 and player:getMainJob() == xi.job.COR then
        local bonus = 1 + deadAimStacks * 0.12
        for i, v in ipairs(params.ftpMod) do
            params.ftpMod[i] = v * bonus
        end
        player:setLocalVar('DEAD_AIM_STACKS', 0)
        player:delStatusEffectSilent(xi.effect.DEAD_AIM)
        if xi.settings.map.MIMIC_COMBAT_NOTIFICATIONS then
            player:printToPlayer(string.format('Dead Aim: %d stacks (+%d%% fTP)', deadAimStacks, deadAimStacks * 12), xi.msg.channel.SYSTEM_3, '')
        end
    end

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doRangedWeaponskill(player, target, wsID, params, tp, action, primary)
    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
