-----------------------------------
-- Leaden Salute
-- Sword weapon skill
-- Skill Level: N/A
-- Delivers a Twofold attack. Damage varies with TP. Death Penalty: Aftermath effect varies with TP.
-- Available only after completing the Unlocking a Myth (Corsair) quest.
-- Aligned with the Shadow Gorget, Soil Gorget & Light Gorget.
-- Aligned with the Shadow Belt, Soil Belt & Light Belt.
-- Element: Darkness
-- Modifiers: AGI:30%
-- 100%TP    200%TP    300%TP
-- 4.00      4.25      4.75
-----------------------------------
---@type TWeaponSkill
local weaponskillObject = {}

weaponskillObject.onUseWeaponSkill = function(player, target, wsID, tp, primary, action, taChar)
    local params = {}
    params.ftpMod = { 4.0, 4.25, 4.75 }
    params.agi_wsc = 0.3
    params.ele = xi.element.DARK
    params.skill = xi.skill.MARKSMANSHIP
    params.includemab = true
    params.dStat = xi.mod.AGI

    if xi.settings.main.USE_ADOULIN_WEAPON_SKILL_CHANGES then
        params.ftpMod = { 4.0, 6.7, 10.0 }
        params.agi_wsc = 1.0
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

    -- Apply Aftermath
    xi.aftermath.addStatusEffect(player, tp, xi.slot.RANGED, xi.aftermath.type.MYTHIC)

    local damage, criticalHit, tpHits, extraHits = xi.weaponskills.doMagicWeaponskill(player, target, wsID, params, tp, action, primary)

    return tpHits, extraHits, criticalHit, damage
end

return weaponskillObject
