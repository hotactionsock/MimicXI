-----------------------------------
-- Mob Family Resistances
-- scripts/globals/mob_family_resistances.lua
-----------------------------------
-- Defines ecosystem-level damage-type weaknesses and resistances for combat
-- re-balance. Applied automatically to every mob on spawn before per-mob
-- scripts run, so individual scripts can still override specific values.
--
-- DESIGN
-- ------
-- Damage types covered:
--   Physical : Slashing, Piercing, Blunt (Impact), Hand-to-Hand
--   Magical  : Fire, Ice, Wind, Earth, Thunder, Water, Light, Dark
--
-- Each ecosystem entry is a table of { [xi.mod.X_SDT] = value } pairs.
-- SDT (Specific Damage Taken) uses base 10 000.
-- Formula: finalDamage = baseDamage * (1 + SDT / 10000)
--
--   WEAK   = +10000 → multiplier 2.0  (double damage)
--   RESIST = -5000  → multiplier 0.5  (half damage)
--
-- Only modifiers listed here are changed; everything else keeps the
-- database-loaded default (usually 0, i.e. 1.0× multiplier).
--
-- ADDING / CHANGING ENTRIES
-- -------------------------
-- 1. Find the ecosystem constant in scripts/enum/ecosystem.lua.
-- 2. Add or edit its table in xi.mob.resistances.ecosystemTable below.
-- 3. Use the WEAK / RESIST local constants for readability.
-- 4. Per-mob onMobSpawn scripts that call mob:setMod() after this module
--    runs will silently override any value set here for that specific mob.
-----------------------------------
-- scripts/enum/ files are loaded via safe_script_file (not require), so they
-- are NOT in package.loaded.  Explicitly require them here so xi.ecosystem
-- and xi.mod constants are guaranteed to exist when this file runs via the
-- conquest → garrison → mobs → mob_family_resistances require chain.
require('scripts/enum/ecosystem')
require('scripts/enum/mod')

xi = xi or {}
xi.mob = xi.mob or {}
xi.mob.resistances = xi.mob.resistances or {}

-- SDT value constants
local WEAK   = 10000  -- 2.0× damage taken
local RESIST = -5000  -- 0.5× damage taken

-- ---------------------------------------------------------------------------
-- Ecosystem resistance / weakness table
-- ---------------------------------------------------------------------------
-- Each key is an xi.ecosystem constant.
-- Each value is a flat table of { [xi.mod.X_SDT] = WEAK|RESIST } entries.
-- ---------------------------------------------------------------------------
xi.mob.resistances.ecosystemTable =
{
    -- AMORPH: Gelatinous bodies (slimes, puddings, oozes, leeches, worms).
    -- Amorphous mass absorbs and deflects physical strikes; extreme temperatures
    -- and electricity disrupt their molecular structure.
    [xi.ecosystem.AMORPH] =
    {
        [xi.mod.SLASH_SDT]   = RESIST, -- blades pass through without grip
        [xi.mod.PIERCE_SDT]  = RESIST, -- punctures seal instantly
        [xi.mod.IMPACT_SDT]  = RESIST, -- blunt force disperses harmlessly
        [xi.mod.HTH_SDT]     = RESIST, -- fists sink in without effect
        [xi.mod.FIRE_SDT]    = WEAK,   -- heat coagulates and burns the mass
        [xi.mod.ICE_SDT]     = WEAK,   -- freezing shatters the gel
        [xi.mod.THUNDER_SDT] = WEAK,   -- electricity conducts through fluid body
    },

    -- AQUAN: Water-adapted creatures (fish, crabs, sea monks, soulflayers).
    -- Hydrated bodies resist fire and are at home in earth; conductive water
    -- makes them vulnerable to lightning, and freezing water damages them.
    [xi.ecosystem.AQUAN] =
    {
        [xi.mod.FIRE_SDT]    = RESIST, -- bodies are saturated with water
        [xi.mod.EARTH_SDT]   = RESIST, -- at home in aquatic environments
        [xi.mod.THUNDER_SDT] = WEAK,   -- water conducts electricity
        [xi.mod.ICE_SDT]     = WEAK,   -- freezing water is lethal
    },

    -- ARCANA: Magical constructs (bombs, spheres, dolls, fomors).
    -- Entities of condensed magical energy; physical weapons pass through or
    -- shatter against their form. Pure magical opposition disrupts them.
    [xi.ecosystem.ARCANA] =
    {
        [xi.mod.SLASH_SDT]   = RESIST, -- blades find no purchase on magic
        [xi.mod.PIERCE_SDT]  = RESIST,
        [xi.mod.IMPACT_SDT]  = RESIST,
        [xi.mod.HTH_SDT]     = RESIST,
        [xi.mod.DARK_SDT]    = WEAK,   -- void energy unravels magic
        [xi.mod.LIGHT_SDT]   = WEAK,   -- divine light dispels constructs
    },

    -- ARCHAICMACHINE: Ancient mechanical constructs (iron giants, gears).
    -- Dense metal frames shrug off temperature extremes and wind; exposed
    -- circuitry and hydraulics are devastated by electricity and water.
    [xi.ecosystem.ARCHAICMACHINE] =
    {
        [xi.mod.ICE_SDT]     = RESIST, -- metal is unaffected by cold
        [xi.mod.WIND_SDT]    = RESIST, -- solid frames ignore wind
        [xi.mod.EARTH_SDT]   = RESIST, -- machines do not tire or corrode easily
        [xi.mod.THUNDER_SDT] = WEAK,   -- electricity fries internal mechanisms
        [xi.mod.WATER_SDT]   = WEAK,   -- water shorts out arcane circuitry
    },

    -- AVATAR: Summoned spirits and divine beasts (avatars, spirits).
    -- Celestial entities partially manifest in the physical world; they repel
    -- dark energy by nature but are grounded by earth and opposed by void light.
    [xi.ecosystem.AVATAR] =
    {
        [xi.mod.SLASH_SDT]   = RESIST, -- semi-physical form deflects blades
        [xi.mod.DARK_SDT]    = RESIST, -- divine nature resists darkness
        [xi.mod.EARTH_SDT]   = WEAK,   -- celestial beings are rooted by earth
        [xi.mod.LIGHT_SDT]   = WEAK,   -- opposing divine force destabilises them
    },

    -- BEAST: Natural predators and wildlife (tigers, wolves, rabbits, sheep).
    -- Hardy natural bodies and thick fur resist temperature extremes poorly;
    -- well-grounded musculature shrugs off lightning and earth.
    [xi.ecosystem.BEAST] =
    {
        [xi.mod.THUNDER_SDT] = RESIST, -- instinctive grounding reduces shock
        [xi.mod.EARTH_SDT]   = RESIST, -- native terrain adaptation
        [xi.mod.FIRE_SDT]    = WEAK,   -- fur and flesh burn readily
        [xi.mod.ICE_SDT]     = WEAK,   -- cold slows and damages warm-blooded bodies
    },

    -- BEASTMEN: Intelligent monster races (goblins, orcs, yagudo, quadav).
    -- Battle-hardened warriors adapted to rough terrain; open flame and divine
    -- power are their traditional banes.
    [xi.ecosystem.BEASTMEN] =
    {
        [xi.mod.EARTH_SDT]   = RESIST, -- grown up fighting on brutal terrain
        [xi.mod.DARK_SDT]    = RESIST, -- accustomed to dark dwellings
        [xi.mod.FIRE_SDT]    = WEAK,   -- primal fear of fire
        [xi.mod.LIGHT_SDT]   = WEAK,   -- divine power cuts through brutish nature
    },

    -- BIRD: Flying creatures (rocs, ravens, ziz, birds of paradise).
    -- Aerial hunters are at home in wind and resist earth; lightning in open
    -- skies and ice freezing wings are classic predators of the skies.
    [xi.ecosystem.BIRD] =
    {
        [xi.mod.WIND_SDT]    = RESIST, -- native to the sky
        [xi.mod.EARTH_SDT]   = RESIST, -- light bones, little contact with ground
        [xi.mod.ICE_SDT]     = WEAK,   -- cold freezes wing joints and feathers
        [xi.mod.THUNDER_SDT] = WEAK,   -- lightning strikes flyers in open air
    },

    -- DEMON: Dark supernatural entities (demons, dark knights, shadow fiends).
    -- Creatures of hell and fire; divine light and extreme cold pierce their
    -- infernal nature. They are born of flame and darkness.
    [xi.ecosystem.DEMON] =
    {
        [xi.mod.FIRE_SDT]    = RESIST, -- born in and of hellfire
        [xi.mod.DARK_SDT]    = RESIST, -- native to dark planes
        [xi.mod.LIGHT_SDT]   = WEAK,   -- holy power is anathema
        [xi.mod.ICE_SDT]     = WEAK,   -- cold opposes their infernal nature
    },

    -- DRAGON: Wyrms, wyverns, and serpents (dragons, lindwurms, pteryx).
    -- Ancient scaled beasts with fireproof hides; their cold-blooded nature
    -- and draconic pride makes them vulnerable to ice and heavenly thunder.
    [xi.ecosystem.DRAGON] =
    {
        [xi.mod.FIRE_SDT]    = RESIST, -- fire-resistant scales
        [xi.mod.SLASH_SDT]   = RESIST, -- overlapping scales deflect blades
        [xi.mod.ICE_SDT]     = WEAK,   -- cold penetrates draconic hide
        [xi.mod.THUNDER_SDT] = WEAK,   -- lightning cracks through armour
    },

    -- ELEMENTAL: Pure elemental beings (fire, ice, wind, earth elementals).
    -- Composed of raw magical energy; physical weapons have no purchase on
    -- a body that is literally made of force. Their specific elemental
    -- immunity is handled per-mob by individual scripts or the database.
    [xi.ecosystem.ELEMENTAL] =
    {
        [xi.mod.SLASH_SDT]   = RESIST,
        [xi.mod.PIERCE_SDT]  = RESIST,
        [xi.mod.IMPACT_SDT]  = RESIST,
        [xi.mod.HTH_SDT]     = RESIST,
    },

    -- EMPTY: Void-born entities from Promyvion (shadows, reapers, gorgers).
    -- Creatures of absence; light and warmth dissolve their null-form while
    -- they absorb darkness. Physical weapons pierce but do not catch.
    [xi.ecosystem.EMPTY] =
    {
        [xi.mod.PIERCE_SDT]  = RESIST, -- void form is hard to skewer
        [xi.mod.SLASH_SDT]   = RESIST, -- blades pass through shadow
        [xi.mod.DARK_SDT]    = RESIST, -- void absorbs dark energy
        [xi.mod.LIGHT_SDT]   = WEAK,   -- light dissolves emptiness
        [xi.mod.FIRE_SDT]    = WEAK,   -- warmth drives back the void
    },

    -- HUMANOID: Human-like fighters (soldiers, bandits, Elvaan, Galka foes).
    -- Adaptable and balanced; no innate elemental affinities or physical bias.
    -- No modifiers applied — individual scripts handle any special cases.
    [xi.ecosystem.HUMANOID] = {},

    -- LIZARD: Cold-blooded reptiles (raptors, basilisks, iguions, peistes).
    -- Ectothermic bodies love warmth and are at home in earthy terrain;
    -- cold and water chill and slow them, threatening their life functions.
    [xi.ecosystem.LIZARD] =
    {
        [xi.mod.FIRE_SDT]    = RESIST, -- cold-blooded metabolism thrives in heat
        [xi.mod.EARTH_SDT]   = RESIST, -- reptiles are grounded and territorial
        [xi.mod.ICE_SDT]     = WEAK,   -- cold blood stiffens in the freeze
        [xi.mod.WATER_SDT]   = WEAK,   -- chill wetness slows cold-blooded bodies
    },

    -- LUMINIAN: Ancient transcendent beings (luminians, Lu Shang relics).
    -- Archaic entities of condensed will; tough outer shells rebuff physical
    -- force while electricity and heavenly energy pierce their form.
    [xi.ecosystem.LUMINIAN] =
    {
        [xi.mod.SLASH_SDT]   = RESIST,
        [xi.mod.PIERCE_SDT]  = RESIST,
        [xi.mod.IMPACT_SDT]  = RESIST,
        [xi.mod.THUNDER_SDT] = WEAK,
        [xi.mod.LIGHT_SDT]   = WEAK,
    },

    -- LUMINION: Escha transcendent creatures (ghrahs, zdeis, phuabos).
    -- Partially ethereal; dark energy is absorbed into their form and physical
    -- strikes clip rather than connect. Light and thunder cut through them.
    [xi.ecosystem.LUMINION] =
    {
        [xi.mod.SLASH_SDT]   = RESIST,
        [xi.mod.PIERCE_SDT]  = RESIST,
        [xi.mod.DARK_SDT]    = RESIST,
        [xi.mod.LIGHT_SDT]   = WEAK,
        [xi.mod.THUNDER_SDT] = WEAK,
    },

    -- PLANTOID: Plant creatures (mandragoras, treants, flytraps, sabotenders).
    -- Fed by water and rooted in earth; fire, extreme cold, cutting wind, and
    -- bladed weapons all exploit the vulnerability of plant matter.
    [xi.ecosystem.PLANTOID] =
    {
        [xi.mod.WATER_SDT]   = RESIST, -- photosynthesis and hydration
        [xi.mod.EARTH_SDT]   = RESIST, -- rooted in the ground
        [xi.mod.FIRE_SDT]    = WEAK,   -- plant matter ignites readily
        [xi.mod.ICE_SDT]     = WEAK,   -- frost kills plant tissue
        [xi.mod.WIND_SDT]    = WEAK,   -- gales shred leaves and branches
        [xi.mod.SLASH_SDT]   = WEAK,   -- cutting implements cleave plant flesh
    },

    -- UNCLASSIFIED: Miscellaneous unique creatures.
    -- No ecosystem-level assumptions; rely on per-mob scripts / database.
    [xi.ecosystem.UNCLASSIFIED] = {},

    -- UNDEAD: Animated dead (skeletons, ghosts, zombies, vampires).
    -- Undead do not feel cold, are empowered by darkness, and are hard to
    -- pierce or slash (bones or ethereal). Holy light and fire destroy them;
    -- blunt force shatters skeletal frames.
    [xi.ecosystem.UNDEAD] =
    {
        [xi.mod.ICE_SDT]     = RESIST, -- undead do not feel the cold
        [xi.mod.DARK_SDT]    = RESIST, -- animated by dark energy
        [xi.mod.PIERCE_SDT]  = RESIST, -- skewering bones or passing through ghosts
        [xi.mod.SLASH_SDT]   = RESIST, -- blades catch little on bone or ether
        [xi.mod.LIGHT_SDT]   = WEAK,   -- holy power undoes undead existence
        [xi.mod.FIRE_SDT]    = WEAK,   -- fire burns even unliving flesh and bone
        [xi.mod.IMPACT_SDT]  = WEAK,   -- blunt force shatters skeletal structures
    },

    -- VERMIN: Insects, crawlers, and colony creatures (bees, beetles, flies).
    -- Chitinous exoskeletons and natural grounding handle earth and shock;
    -- temperature extremes and wind are deadly to small, fragile bodies.
    [xi.ecosystem.VERMIN] =
    {
        [xi.mod.EARTH_SDT]   = RESIST, -- chitinous exoskeleton from the earth
        [xi.mod.THUNDER_SDT] = RESIST, -- exoskeleton insulates from shock
        [xi.mod.FIRE_SDT]    = WEAK,   -- small bodies ignite quickly
        [xi.mod.ICE_SDT]     = WEAK,   -- cold is lethal to insects
        [xi.mod.WIND_SDT]    = WEAK,   -- gales disrupt swarms and flight
    },

    -- VORAGEAN: Alien otherworldly entities (bhoot, murex, lurker types).
    -- Exotic biology makes them impervious to conventional weapons; cosmic
    -- energy in the forms of thunder and light can disrupt their alien form.
    [xi.ecosystem.VORAGEAN] =
    {
        [xi.mod.SLASH_SDT]   = RESIST,
        [xi.mod.PIERCE_SDT]  = RESIST,
        [xi.mod.IMPACT_SDT]  = RESIST,
        [xi.mod.HTH_SDT]     = RESIST,
        [xi.mod.THUNDER_SDT] = WEAK,
        [xi.mod.LIGHT_SDT]   = WEAK,
    },
}

-- ---------------------------------------------------------------------------
-- xi.mob.resistances.apply(mob)
-- ---------------------------------------------------------------------------
-- Reads the mob's ecosystem and applies the matching SDT modifiers.
-- Called automatically via xi.mob.onMobSpawn in scripts/globals/mobs.lua,
-- which itself is invoked by the C++ OnMobSpawn hook before per-mob scripts.
--
-- Can also be called manually from any mob script:
--   require('scripts/globals/mob_family_resistances')
--   xi.mob.resistances.apply(mob)
-- ---------------------------------------------------------------------------
xi.mob.resistances.apply = function(mob)
    local ecosystem = mob:getEcosystem()
    local mods      = xi.mob.resistances.ecosystemTable[ecosystem]

    if not mods then
        return
    end

    for mod, value in pairs(mods) do
        mob:setMod(mod, value)
    end
end

return xi.mob.resistances
