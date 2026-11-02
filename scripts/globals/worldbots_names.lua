-----------------------------------
-- World bot names
-- Bots take names the way real players do: favourites from across the
-- Final Fantasy series or general player-style names, and when one is taken,
-- the usual workarounds - a doubled letter, a short prefix or suffix. Pure
-- syllable names are the last resort. FFXI's own NPC names are deliberately left out so a bot is never
-- mistaken for an NPC.
--
-- Names must be letters only, 3-15 characters (FFXI character name rules).
-----------------------------------
xi = xi or {}
xi.worldbotsNames = xi.worldbotsNames or {}

-- Reserved names: always handed out first. Whenever bots are generated, any
-- name here that isn't already taken is used before anything random (in random
-- order, so who gets which is a surprise). They're also exclusive - the random
-- pools never produce one of these, or a variant of it. Once every reserved
-- name is in use, generation carries on with the pools below; deleting a bot
-- frees its reserved name for the next generation.
-- Letters only, 3-15 characters, e.g. 'Mithrandir'.
local RESERVED =
{
'Fallen',
'Doomseer',
'Xerus',
'Viridescent',
}

local POOL =
{
    -- FFI - FFIII
    'Garland', 'Sarah', 'Astos', 'Matoya', 'Firion', 'Maria', 'Guy', 'Leon',
    'Minwu', 'Josef', 'Gordon', 'Leila', 'Ricard', 'Hilda', 'Scott', 'Luneth',
    'Arc', 'Refia', 'Ingus', 'Desch', 'Aria', 'Sara', 'Cid', 'Doga', 'Unei',
    -- FFIV
    'Cecil', 'Kain', 'Rosa', 'Rydia', 'Tellah', 'Edward', 'Yang', 'Palom',
    'Porom', 'Edge', 'Fusoya', 'Golbez', 'Ceodore', 'Zemus', 'Baigan',
    -- FFV
    'Bartz', 'Lenna', 'Galuf', 'Faris', 'Krile', 'Gilgamesh', 'Exdeath',
    'Xezat', 'Kelger', 'Dorgann', 'Boko', 'Syldra',
    -- FFVI
    'Terra', 'Locke', 'Celes', 'Edgar', 'Sabin', 'Cyan', 'Shadow', 'Gau',
    'Setzer', 'Mog', 'Strago', 'Relm', 'Gogo', 'Umaro', 'Kefka', 'Banon',
    'Leo', 'Interceptor', 'Ultros', 'Maduin', 'Rachel', 'Daryl',
    -- FFVII
    'Cloud', 'Tifa', 'Aerith', 'Barret', 'Vincent', 'Yuffie', 'Nanaki',
    'Sephiroth', 'Zack', 'Reno', 'Rude', 'Elena', 'Tseng', 'Rufus', 'Genesis',
    'Angeal', 'Marlene', 'Denzel', 'Jessie', 'Biggs', 'Wedge', 'Kadaj',
    'Yazoo', 'Loz', 'Lucrecia', 'Hojo', 'Zangan', 'Shelke', 'Cissnei',
    -- FFVIII
    'Squall', 'Rinoa', 'Quistis', 'Zell', 'Selphie', 'Irvine', 'Seifer',
    'Laguna', 'Kiros', 'Ward', 'Edea', 'Ellone', 'Fujin', 'Raijin', 'Ultimecia',
    'Xu', 'Nida', 'Julia', 'Raine', 'Odine',
    -- FFIX
    'Zidane', 'Garnet', 'Dagger', 'Vivi', 'Steiner', 'Freya', 'Quina',
    'Eiko', 'Amarant', 'Beatrix', 'Kuja', 'Tantalus', 'Marcus', 'Blank',
    'Cinna', 'Ruby', 'Baku', 'Fratley', 'Puck', 'Lani', 'Mikoto',
    -- FFX / X-2
    'Tidus', 'Yuna', 'Auron', 'Wakka', 'Lulu', 'Kimahri', 'Rikku', 'Seymour',
    'Jecht', 'Braska', 'Paine', 'Gippal', 'Baralai', 'Nooj', 'Brother',
    'Buddy', 'Shinra', 'Lenne', 'Shuyin', 'Belgemine', 'Dona', 'Isaaru',
    'Lucil', 'Elma', 'Clasko', 'Rin', 'Maechen', 'Leblanc', 'Logos', 'Ormi',
    -- FFXII
    'Vaan', 'Penelo', 'Balthier', 'Fran', 'Basch', 'Ashe', 'Ashelia', 'Larsa',
    'Vayne', 'Gabranth', 'Reks', 'Rasler', 'Montblanc', 'Reddas', 'Ondore',
    'Drace', 'Zargabaath', 'Bergan', 'Ghis', 'Venat', 'Cidolfus', 'Migelo',
    'Mjrn', 'Jote',
    -- FFXIII
    'Lightning', 'Snow', 'Vanille', 'Sazh', 'Hope', 'Fang', 'Serah', 'Noel',
    'Caius', 'Yeul', 'Cocoon', 'Barthandelus', 'Jihl', 'Yaag', 'Cid', 'Dajh',
    'Lebreau', 'Gadot', 'Yuj', 'Maqui', 'Lumina', 'Alyssa',
    -- FFXIV
    'Thancred', 'Yshtola', 'Urianger', 'Alphinaud', 'Alisaie', 'Tataru',
    'Estinien', 'Aymeric', 'Haurchefant', 'Ysayle', 'Lyse', 'Papalymo',
    'Minfilia', 'Raubahn', 'Nanamo', 'Krile', 'Graha', 'Emetselch',
    'Hythlodaeus', 'Venat', 'Zenos', 'Fandaniel', 'Gaius', 'Cid', 'Nero',
    'Merlwyb', 'Kanaeren', 'Hien', 'Gosetsu', 'Yugiri', 'Lyna', 'Ryne',
    'Gaia', 'Wuklamat', 'Koana', 'Zoraal', 'Erenville', 'Sphene', 'Bakool',
    'Moenbryda', 'Ardbert', 'Feo', 'Elidibus', 'Lahabrea', 'Igeyorhm',
    -- FFXV
    'Noctis', 'Gladiolus', 'Ignis', 'Prompto', 'Lunafreya', 'Ravus', 'Ardyn',
    'Cor', 'Iris', 'Aranea', 'Cindy', 'Regis', 'Clarus', 'Monica', 'Talcott',
    'Gentiana', 'Umbra', 'Pryna', 'Weskham', 'Sania', 'Dave', 'Takka',
    -- FFXVI
    'Clive', 'Jill', 'Joshua', 'Torgal', 'Dion', 'Benedikta', 'Barnabas',
    'Hugo', 'Gav', 'Mid', 'Tarja', 'Byron', 'Harpocrates', 'Otto', 'Charon',
    'Terence', 'Elwin', 'Anabella', 'Rosfield', 'Quinn', 'Goetz', 'Kupka',
    -- Tactics / Type-0 / other spin-offs
    'Ramza', 'Delita', 'Agrias', 'Mustadio', 'Orlandeau', 'Ovelia', 'Alma',
    'Gafgarion', 'Rapha', 'Marach', 'Beowulf', 'Reis', 'Meliadoul', 'Wiegraf',
    'Zalbaag', 'Dycedarg', 'Marche', 'Montblanc', 'Luso', 'Adelle', 'Ace',
    'Deuce', 'Trey', 'Cater', 'Cinque', 'Sice', 'Eight', 'Nine', 'Jack',
    'Queen', 'King', 'Machina', 'Rem', 'Kurasame', 'Warrior', 'Lann',
    'Reynn', 'Raine', 'Sherlotta', 'Ayeta', 'Celestia',
    -- Summons, monsters and lore names players love to take
    'Bahamut', 'Ifrit', 'Shiva', 'Ramuh', 'Titan', 'Leviathan', 'Odin',
    'Alexander', 'Phoenix', 'Carbuncle', 'Diabolos', 'Siren', 'Quetzalcoatl',
    'Pandemona', 'Doomtrain', 'Cerberus', 'Eden', 'Anima', 'Yojimbo',
    'Valefor', 'Ixion', 'Belias', 'Mateus', 'Zalera', 'Hashmal', 'Chaos',
    'Zodiark', 'Hydaelyn', 'Sleipnir', 'Tonberry', 'Cactuar', 'Chocobo',
    'Moogle', 'Behemoth', 'Malboro', 'Ochu', 'Coeurl', 'Mindflayer',
    'Ultima', 'Omega', 'Shinryu', 'Typhon', 'Orthros', 'Enkidu', 'Kujata',
    'Golem', 'Lich', 'Kraken', 'Tiamat', 'Marilith', 'Ragnarok', 'Excalibur',
    'Masamune', 'Murasame', 'Masamune', 'Kotetsu', 'Zantetsuken', 'Holy',
    'Flare', 'Meteor', 'Quake', 'Tornado', 'Mako', 'Lifestream', 'Materia',
    'Gysahl', 'Mythril', 'Adamantite', 'Orichalcum', 'Highwind', 'Ragnarok',
    'Invincible', 'Falcon', 'Nautilus', 'Enterprise', 'Blackjack', 'Strahl',
}

-- Player-style names: the kinds of names that are common on FFXI servers -
-- mythology, plain given names, nature words, fantasy compounds, a little
-- anime/Japanese flavour. Written in the style of real servers, not copied from
-- any real player. Deliberately nothing chaotic: no xX decoration, keyboard
-- mash, joke names or l33t.
local PLAYER_POOL =
{
    -- Mythology and legend
    'Artemis', 'Apollo', 'Athena', 'Ares', 'Hermes', 'Hades', 'Persephone',
    'Selene', 'Helios', 'Eos', 'Nyx', 'Hecate', 'Medea', 'Ariadne', 'Theseus',
    'Achilles', 'Hector', 'Ajax', 'Odysseus', 'Penelope', 'Cassandra',
    'Orion', 'Atlas', 'Prometheus', 'Icarus', 'Daedalus', 'Perseus',
    'Andromeda', 'Calypso', 'Circe', 'Pandora', 'Electra', 'Freyja', 'Thor',
    'Loki', 'Baldur', 'Tyr', 'Heimdall', 'Frigg', 'Sif', 'Skadi', 'Idun',
    'Brynhild', 'Sigurd', 'Fenrir', 'Valkyrie', 'Ragnar', 'Bjorn', 'Leif',
    'Arthur', 'Merlin', 'Lancelot', 'Gawain', 'Percival', 'Tristan', 'Galahad',
    'Morgana', 'Guinevere', 'Isolde', 'Avalon', 'Mordred', 'Bedivere',
    'Cuchulainn', 'Morrigan', 'Brigid', 'Rhiannon', 'Oberon', 'Titania',
    'Anubis', 'Osiris', 'Isis', 'Horus', 'Bastet', 'Sekhmet', 'Amaterasu',
    'Susanoo', 'Tsukuyomi', 'Raijin', 'Inari', 'Benten', 'Gilgamesh',
    'Enkidu', 'Ishtar', 'Marduk', 'Lilith', 'Seraphim', 'Gabriel', 'Raphael',
    'Uriel', 'Michael', 'Azrael', 'Lucifer', 'Asmodeus', 'Mephisto',
    -- Plain given names
    'Alaric', 'Aldric', 'Cedric', 'Roland', 'Tristan', 'Gareth', 'Rowan',
    'Ronan', 'Darian', 'Kieran', 'Lucian', 'Adrian', 'Damien', 'Julian',
    'Sebastian', 'Gabriel', 'Elias', 'Silas', 'Matthias', 'Victor', 'Marcus',
    'Felix', 'Oscar', 'Hugo', 'Cassius', 'Magnus', 'Lucius', 'Aurelius',
    'Elric', 'Edmund', 'Godric', 'Wulfric', 'Osric', 'Leoric', 'Garrick',
    'Elena', 'Aria', 'Lyra', 'Mira', 'Nora', 'Iris', 'Luna', 'Stella',
    'Aurora', 'Celeste', 'Seraphina', 'Isabella', 'Sophia', 'Evelyn',
    'Amelia', 'Clara', 'Elise', 'Fiona', 'Helena', 'Ivy', 'Josephine',
    'Katarina', 'Lilia', 'Marina', 'Natalia', 'Ophelia', 'Rosalind',
    'Sabrina', 'Tatiana', 'Valeria', 'Vivienne', 'Yvette', 'Zara', 'Alina',
    'Anya', 'Elara', 'Kaela', 'Liora', 'Maren', 'Nadia', 'Rhea', 'Sasha',
    'Talia', 'Thalia', 'Willa', 'Yara', 'Eira', 'Freya', 'Ingrid', 'Astrid',
    -- Nature, sky and gems
    'Ember', 'Ash', 'Cinder', 'Blaze', 'Frost', 'Winter', 'Storm', 'Thunder',
    'Rain', 'River', 'Brook', 'Willow', 'Hazel', 'Aspen', 'Cedar', 'Rowan',
    'Sage', 'Fern', 'Heather', 'Lily', 'Rose', 'Violet', 'Daisy', 'Jasmine',
    'Lotus', 'Sakura', 'Raven', 'Falcon', 'Hawk', 'Wolf', 'Fox', 'Lynx',
    'Tiger', 'Panther', 'Dragon', 'Griffin', 'Wyvern', 'Sparrow', 'Robin',
    'Wren', 'Starling', 'Dawn', 'Dusk', 'Twilight', 'Eclipse', 'Comet',
    'Nova', 'Nebula', 'Solstice', 'Equinox', 'Zephyr', 'Sirocco', 'Tempest',
    'Onyx', 'Obsidian', 'Jade', 'Amber', 'Ruby', 'Sapphire', 'Emerald',
    'Topaz', 'Garnet', 'Opal', 'Pearl', 'Crystal', 'Diamond', 'Amethyst',
    'Silver', 'Cobalt', 'Crimson', 'Scarlet', 'Azure', 'Indigo', 'Ivory',
    -- Fantasy compounds
    'Shadowfox', 'Nightshade', 'Moonshadow', 'Stormwind', 'Starfall',
    'Ironheart', 'Lionheart', 'Wolfsbane', 'Dawnbreaker', 'Duskblade',
    'Frostfang', 'Silverleaf', 'Ravenwing', 'Swiftwind', 'Brightblade',
    'Stormcaller', 'Firebrand', 'Darkthorn', 'Thornwood', 'Ashborne',
    'Highmoor', 'Blackwood', 'Ravenhart', 'Ironwood', 'Wildfire',
    'Mistwalker', 'Sunstrider', 'Moonblade', 'Skyward', 'Windrunner',
    'Starlight', 'Moonlight', 'Nightfall', 'Daybreak', 'Wintermoon',
    'Emberheart', 'Goldleaf', 'Stonefist', 'Steelheart', 'Oakenshield',
    -- Anime / Japanese flavour, kept tasteful
    'Akira', 'Kenji', 'Hiro', 'Ryu', 'Kaito', 'Sora', 'Riku', 'Kairi',
    'Haru', 'Yuki', 'Hikari', 'Akane', 'Aoi', 'Asuka', 'Ayame', 'Chihiro',
    'Hana', 'Hotaru', 'Kaede', 'Kasumi', 'Kohaku', 'Mai', 'Midori', 'Misaki',
    'Nanami', 'Rei', 'Rin', 'Sakuya', 'Shizuka', 'Tomoe', 'Tsubaki', 'Yumi',
    'Kenshin', 'Musashi', 'Kojiro', 'Hanzo', 'Hattori', 'Benkei', 'Raiden',
    'Shinobi', 'Ronin', 'Kagura', 'Tenshi', 'Kitsune', 'Tengu', 'Ryuu',
    'Takeshi', 'Daisuke', 'Ichigo', 'Renji', 'Shiro', 'Kuro', 'Gin', 'Tetsu',
    -- Short, punchy handles
    'Zed', 'Kai', 'Jax', 'Rex', 'Vex', 'Nox', 'Lux', 'Ace', 'Kane', 'Dax',
    'Rook', 'Knox', 'Cole', 'Finn', 'Gage', 'Jett', 'Nash', 'Reed', 'Zane',
    'Vale', 'Skye', 'Jinx', 'Echo', 'Pixie', 'Mochi', 'Tofu', 'Kiwi', 'Mango',
    'Pepper', 'Ginger', 'Biscuit', 'Waffle', 'Muffin', 'Pudding', 'Sprout',
}

-- Keep the random pools clear of reserved names (and so of their variants).
local reservedSet = {}
for _, name in ipairs(RESERVED) do
    reservedSet[name:lower()] = true
end

local function withoutReserved(pool)
    local kept = {}
    for _, name in ipairs(pool) do
        if not reservedSet[name:lower()] then
            table.insert(kept, name)
        end
    end

    return kept
end

POOL        = withoutReserved(POOL)
PLAYER_POOL = withoutReserved(PLAYER_POOL)

-- Short tags real players bolt on when their first choice is gone.
local PREFIXES = { 'X', 'Z', 'Lil', 'Mr', 'Sir', 'Dark', 'Neo', 'Kid', 'Old', 'Big' }
local SUFFIXES = { 'x', 'z', 'y', 'ie', 'ii', 'kun', 'chan', 'xi', 'ffxi', 'jr', 'san' }

local function validName(name)
    return #name >= 3 and #name <= 15 and name:match('^%a+$') ~= nil
end

local function capitalise(name)
    return name:sub(1, 1):upper() .. name:sub(2):lower()
end

-- A "taken" workaround for base: doubled last letter, prefix or suffix.
local function variant(base)
    local roll = math.random(3)
    if roll == 1 and base:sub(-1) ~= base:sub(-2, -2) then -- never "Nightfalll"
        return base .. base:sub(-1)
    elseif roll == 2 then
        return PREFIXES[math.random(#PREFIXES)] .. base:lower()
    else
        return base .. SUFFIXES[math.random(#SUFFIXES)]
    end
end

-- Last resort: two or three random syllables.
local ONSETS = { 'b', 'd', 'f', 'g', 'k', 'l', 'm', 'n', 'r', 's', 't', 'v', 'z', 'br', 'dr', 'gr', 'kr', 'th', 'tr', '' }
local VOWELS = { 'a', 'e', 'i', 'o', 'u', 'a', 'e', 'ia', 'ou' }
local CODAS  = { '', '', '', 'n', 'r', 's', 'l', 'th', 'x', 'k', 'd' }

local function syllableName()
    local name = ''
    for _ = 1, math.random(2, 3) do
        name = name .. ONSETS[math.random(#ONSETS)] .. VOWELS[math.random(#VOWELS)]
    end

    return capitalise((name .. CODAS[math.random(#CODAS)]):sub(1, 12))
end

-- Candidate names for one bot, in the order to try them: every reserved name
-- (shuffled), then a pool name as-is, then player-style variants of pool names,
-- then syllable names. The caller tries each until one isn't taken, so the
-- first free reserved name always wins. count = how many non-reserved names.
xi.worldbotsNames.candidates = function(count)
    count = count or 10

    local list = {}

    local reserved = {}
    for _, name in ipairs(RESERVED) do
        name = capitalise(name)
        if validName(name) then
            table.insert(reserved, math.random(#reserved + 1), name)
        end
    end

    for _, name in ipairs(reserved) do
        table.insert(list, name)
    end

    local function add(name)
        name = capitalise(name)
        if validName(name) and not reservedSet[name:lower()] then
            table.insert(list, name)
        end
    end

    -- Roughly half of bots pick a Final Fantasy name, half a general player-style
    -- one; each bot sticks to one style for its variants too.
    local pool = math.random() < 0.5 and POOL or PLAYER_POOL

    add(pool[math.random(#pool)])
    add(pool[math.random(#pool)])

    while #list < #reserved + count - 2 do
        add(variant(pool[math.random(#pool)]))
    end

    add(syllableName())
    add(syllableName())

    return list
end
