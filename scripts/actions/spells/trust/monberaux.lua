-----------------------------------
-- Trust: Monberaux
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    -- TODO: Mix: Insomniant (MS 4256) disabled — animation ID is wrong; needs correct value.
    local finalElixir = mob:getMaster():getCharVar('finalElixir') -- CVar: Elixir donation count.
    local potAoe      = mob:getMaster():getCharVar('monbAoe')     -- CVar: AoE unlock via gil donation.

    if potAoe == 0 then
        if finalElixir == 0 then
            xi.trust.message(mob, xi.trust.messageOffset.SPAWN)
        elseif finalElixir == 1 then
            xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_1) -- 1 Elixir
        else
            xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_2) -- 2 Elixirs
        end
    else
        if finalElixir == 0 then
            xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_3) -- Gil donation (AoE)
        elseif finalElixir == 1 then
            xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_4) -- 1 Elixir + Gil
        else
            xi.trust.message(mob, xi.trust.messageOffset.TEAMWORK_5) -- All donations
        end
    end

    local healCooldown = math.random(3, 4) -- Mix I / status removal: 3–4s
    local buffCooldown = 60               -- Mix II: 60s
    local mpCooldown   = 90               -- Mix III: 90s

    -- MobMods
    -- MPP -90%: high stamina, magic penalty (Chemist/PLD trait).
    -- SLEEPRES/LULLABYRES 100: Negate Sleep (PLD/RUN trait, via Mix: Insomniant passive).
    -- STATUSRES 15: approximates Tenacity (PLD trait, general status resistance).
    mob:setMod(xi.mod.MPP,        -90)
    mob:setMod(xi.mod.SLEEPRES,   100)
    mob:setMod(xi.mod.LULLABYRES, 100)
    mob:setMod(xi.mod.STATUSRES,   15)

    -- Guard Drink is always the first ability cast (Protect 220 def + Shell -29% MDT, AoE, 5 min).
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MS, ai.s.SPECIFIC, 4255 }, healCooldown)
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL   }, { ai.r.MS, ai.s.SPECIFIC, 4255 }, healCooldown)

    -- Cover: used when the master has drawn enmity and is being targeted.
    -- Requires the player to stand behind Monberaux; he holds position (NO_MOVE).
    mob:addGambit(ai.t.MASTER, { ai.c.HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.COVER })

    -- Final Elixir: fully restores HP/MP in an AoE when a party member is asleep (max 2 uses).
    if finalElixir ~= 0 then
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SLEEP_I }, { ai.r.MS, ai.s.SPECIFIC, 4231 }, healCooldown)
    end

    -- Top-priority heals
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 40 }, { ai.r.MS, ai.s.SPECIFIC, 4237 }, healCooldown) -- Mix: Max Potion (700 HP)
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 55 }, { ai.r.MS, ai.s.SPECIFIC, 4236 }, healCooldown) -- Max Potion (500 HP)

    -- Mix I status removal (single-target or AoE depending on donation unlock)
    if potAoe == 0 then
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.BLINDNESS     }, { ai.r.MS, ai.s.SPECIFIC, 4248 }, healCooldown) -- Mix: Eye Drops
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.POISON        }, { ai.r.MS, ai.s.SPECIFIC, 4246 }, healCooldown) -- Mix: Antidote
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.SILENCE       }, { ai.r.MS, ai.s.SPECIFIC, 4249 }, healCooldown) -- Echo Drops
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.PARALYSIS     }, { ai.r.MS, ai.s.SPECIFIC, 4247 }, healCooldown) -- Mix: Para-B-Gone
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE  }, { ai.r.MS, ai.s.SPECIFIC, 4253 }, healCooldown) -- Mix: Panacea-1
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.PLAGUE        }, { ai.r.MS, ai.s.SPECIFIC, 4251 }, healCooldown) -- Vaccine
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.PETRIFICATION }, { ai.r.MS, ai.s.SPECIFIC, 4252 }, healCooldown) -- Mix: Gold Needle
        mob:addGambit(ai.t.PARTY, {
            ai.l.OR({ ai.c.STATUS, xi.effect.CURSE_I }, { ai.c.STATUS, xi.effect.CURSE_II }, { ai.c.STATUS, xi.effect.BANE }, { ai.c.STATUS, xi.effect.DOOM })
        }, { ai.r.MS, ai.s.SPECIFIC, 4242 }, healCooldown) -- Holy Water
    else
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.BLINDNESS     }, { ai.r.MS, ai.s.SPECIFIC, 4240 }, healCooldown) -- AoE Mix: Eye Drops
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.POISON        }, { ai.r.MS, ai.s.SPECIFIC, 4238 }, healCooldown) -- AoE Mix: Antidote
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.SILENCE       }, { ai.r.MS, ai.s.SPECIFIC, 4241 }, healCooldown) -- AoE Echo Drops
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.PARALYSIS     }, { ai.r.MS, ai.s.SPECIFIC, 4239 }, healCooldown) -- AoE Mix: Para-B-Gone
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS_FLAG, xi.effectFlag.ERASABLE  }, { ai.r.MS, ai.s.SPECIFIC, 4245 }, healCooldown) -- AoE Mix: Panacea-1
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.PLAGUE        }, { ai.r.MS, ai.s.SPECIFIC, 4243 }, healCooldown) -- AoE Mix: Vaccine
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS,      xi.effect.PETRIFICATION }, { ai.r.MS, ai.s.SPECIFIC, 4244 }, healCooldown) -- AoE Mix: Gold Needle
        mob:addGambit(ai.t.PARTY, {
            ai.l.OR({ ai.c.STATUS, xi.effect.CURSE_I }, { ai.c.STATUS, xi.effect.CURSE_II }, { ai.c.STATUS, xi.effect.BANE }, { ai.c.STATUS, xi.effect.DOOM })
        }, { ai.r.MS, ai.s.SPECIFIC, 4242 }, healCooldown) -- AoE Holy Water
    end

    -- Mix II (60s cooldown): party buffs
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.REGEN           }, { ai.r.MS, ai.s.SPECIFIC, 4257 }, buffCooldown) -- Mix: Life Water (Regen 20/tick, 1 min AoE)
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.STR_BOOST       }, { ai.r.MS, ai.s.SPECIFIC, 4261 }, buffCooldown) -- Mix: Samson's Strength (all stats +10, 1 min AoE)
    mob:addGambit(ai.t.PARTY,  { ai.c.NOT_STATUS, xi.effect.MAGIC_DEF_BOOST }, { ai.r.MS, ai.s.SPECIFIC, 4259 }, buffCooldown) -- Mix: Dragon Shield (MDB +10, 1 min AoE)
    mob:addGambit(ai.t.CASTER, { ai.c.NOT_STATUS, xi.effect.MAGIC_ATK_BOOST }, { ai.r.MS, ai.s.SPECIFIC, 4258 }, buffCooldown) -- Mix: Elemental Power (MAB +20, 1 min AoE)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS,                             0 }, { ai.r.MS, ai.s.SPECIFIC, 4260 }, buffCooldown) -- Mix: Dark Potion (666 dark damage, ignores resistance)

    -- Mix III (90s cooldown): MP restore
    mob:addGambit(ai.t.CASTER, { ai.c.MPP_LT, 50 }, { ai.r.MS, ai.s.SPECIFIC, 4254 }, mpCooldown) -- Mix: Dry Ether Concoction (+160 MP)

    -- Lower-priority heals
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 65 }, { ai.r.MS, ai.s.SPECIFIC, 4235 }, healCooldown) -- Hyper Potion (250 HP)
    -- Disabled to prevent spam at high HP thresholds:
    -- mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MS, ai.s.SPECIFIC, 4234 }, healCooldown) -- X-Potion (150 HP)
    -- mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 85 }, { ai.r.MS, ai.s.SPECIFIC, 4232 }, healCooldown) -- Potion (50 HP)

    -- Weaponskill event handlers (consolidated)
    local STATUS_REMOVAL_SKILLS = {
        [4238] = true, [4239] = true, [4240] = true, [4241] = true,
        [4242] = true, [4243] = true, [4244] = true, [4245] = true,
        [4246] = true, [4247] = true, [4248] = true, [4249] = true,
        [4250] = true, [4251] = true, [4252] = true, [4253] = true,
    }

    mob:addListener('WEAPONSKILL_USE', 'MONBERAUX_WEAPONSKILL_USE', function(mobArg, targetArg, skill, tp, action)
        local skillId = skill:getID()

        -- Correct combat log category so ability names display properly.
        action:setCategory(xi.action.category.MOBABILITY_FINISH)

        -- Decrement Final Elixir charge on use.
        if skillId == xi.mobSkill.MIX_FINAL_ELIXIR then
            local master = mobArg:getMaster()
            if master then
                master:setCharVar('finalElixir', master:getCharVar('finalElixir') - 1)
            end

        -- Mix: Dragon Shield special flavour message.
        elseif skillId == 4259 then
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)

        -- Status removal flavour message.
        elseif STATUS_REMOVAL_SKILLS[skillId] then
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_2)
        end
    end)

    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)

    -- Monberaux never builds TP (his item uses count as weaponskills mechanically,
    -- but he must not accumulate TP naturally to avoid interfering with gambit logic).
    mob:addListener('COMBAT_TICK', 'MONBERAUX_CTICK', function(mobArg)
        mobArg:setTP(0)
    end)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
