-----------------------------------
-- Mob: Goblin Heckler
-- Zone: Buburimu Peninsula
-- Taunts nearby players while roaming
-- and insults their target by name
-- during combat.
-----------------------------------
local entity = {}

-- Ambient taunts broadcast to the area while roaming.
local roamTaunts =
{
    "Adventurers! More experience points for me!",
    "Did you travel all this way just to get embarrassed? How efficient!",
    "This beach is Goblin territory! Your face is making it ugly!",
    "Hey! Nice weapon! It will look much better in MY collection!",
    "I have seen Quadav with better posture than you lot!",
    "The smell of adventurer! Almost as bad as dead adventurer. Almost.",
    "Keep walking! Buburimu has a strict no-weaklings policy!",
    "Taru, Hume, Elvaan — equally pathetic! Goblins appreciate consistency!",
    "You look lost. The Dunes are back THAT way! Ha ha ha!",
    "My bombs go off faster than your reaction speed!",
    "Ooh, visitors! Do not worry, I will make it quick. I am very efficient.",
    "You lot smell like failure and bad crafting results. Mostly failure.",
    "If I wanted to see sad adventurers I would visit the auction house!",
    "Step right up and get humiliated for FREE! Limited time offer!",
}

-- Combat taunts. The target name is prepended at runtime.
-- Start with '!' if the prefix should be omitted (generic fallback).
local fightTaunts =
{
    { prefix = true,  msg = "! You fight like a Mandragora in a stiff breeze!" },
    { prefix = true,  msg = " is trying! It is almost CUTE!" },
    { prefix = true,  msg = "! My grandmother hit harder, and she never existed!" },
    { prefix = true,  msg = "! My bomb timer is longer than your attention span!" },
    { prefix = true,  msg = "! I have tanked more damage from rainstorms!" },
    { prefix = true,  msg = "! You call THAT a weapon? I have seen deadlier Crab claws!" },
    { prefix = true,  msg = "! The sea behind you is embarrassed on your behalf!" },
    { prefix = true,  msg = "! Keep swinging! You might hit something eventually!" },
    { prefix = true,  msg = "! Worst fight I have had all week. And I fought a Sea Leech yesterday." },
    { prefix = true,  msg = "! Did your linkshell dare you to come here? Did you LOSE?" },
    { prefix = false, msg = "Ha ha ha! Is this a fight or a comedy performance?" },
    { prefix = false, msg = "I have been hit harder by cooking smells!" },
    { prefix = false, msg = "Stop. You are making ME look bad just by association!" },
}

-- One-liners when first engaging a target.
local engageTaunts =
{
    "Oh GOOD. I was getting bored. Come here!",
    "Ha! Fresh meat! I accept all denominations of experience points!",
    "You want a piece of ME? Bold choice. Extremely bold. Almost impressive.",
    "Today is a good day to ruin someone else's day!",
    "Ooh, they are FIGHTING back! Love the confidence. Very misplaced, but I appreciate it!",
    "I am going to enjoy this. You are going to enjoy this significantly less.",
}

local ROAM_CHANCE   = 8   -- percent per roam tick
local FIGHT_CHANCE  = 12  -- percent per fight tick
local ENGAGE_CHANCE = 55  -- percent on first engage

local function say(mob, text)
    mob:printToArea(text, xi.chat.SAY, 30, mob:getName(), false)
end

entity.onMobEngaged = function(mob, target)
    if math.random(100) <= ENGAGE_CHANCE then
        say(mob, engageTaunts[math.random(#engageTaunts)])
    end
end

entity.onMobRoam = function(mob)
    if math.random(100) <= ROAM_CHANCE then
        say(mob, roamTaunts[math.random(#roamTaunts)])
    end
end

entity.onMobFight = function(mob, target)
    if math.random(100) <= FIGHT_CHANCE then
        local t = fightTaunts[math.random(#fightTaunts)]
        local msg
        if t.prefix and target and target:isPC() then
            msg = target:getName() .. t.msg
        else
            msg = t.msg
        end
        say(mob, msg)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    -- intentionally silent — keeps the last laugh with the player
end

return entity
