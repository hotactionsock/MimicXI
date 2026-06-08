#!/usr/bin/env python3
import os
import random
import re
import secrets
import socket
import struct
import sys
import time
from datetime import datetime
from functools import wraps

import bcrypt
from flask import Flask, flash, jsonify, redirect, render_template, request, send_from_directory, session, url_for

from db import get_connection

app = Flask(__name__)

# Persist session secret key across restarts
_SECRET_FILE = os.path.join(os.path.dirname(__file__), '.flask_secret')
if os.path.exists(_SECRET_FILE):
    with open(_SECRET_FILE, 'rb') as _f:
        app.secret_key = _f.read()
else:
    app.secret_key = secrets.token_bytes(32)
    with open(_SECRET_FILE, 'wb') as _f:
        _f.write(app.secret_key)

# ── Server status / maintenance ─────────────────────────────────────────────
_MAINTENANCE_FLAG = os.path.join(os.path.dirname(__file__), '.maintenance')
# Optional: set GAME_CHECK_HOST + GAME_CHECK_PORT env vars to enable auto-offline detection.
_GAME_CHECK_HOST = os.environ.get('GAME_CHECK_HOST', '127.0.0.1')
# Defaults to the standard LandSandBoat map-server port so offline detection works
# without any configuration on a local install. Set GAME_CHECK_PORT= (empty) to disable.
_GAME_CHECK_PORT = os.environ.get('GAME_CHECK_PORT', '54230')
_ADMIN_PRIV = 5  # minimum priv value for admin access
_status_cache: dict = {'ts': 0.0, 'reachable': True}


def _maintenance_active() -> bool:
    return os.path.exists(_MAINTENANCE_FLAG)


def _check_game_server() -> bool:
    """TCP connect to game server. Cached 20 s. Returns True if reachable; False if down or timed out."""
    if not _GAME_CHECK_PORT:
        return True
    now = time.time()
    if now - _status_cache['ts'] < 20:
        return _status_cache['reachable']
    try:
        with socket.create_connection((_GAME_CHECK_HOST, int(_GAME_CHECK_PORT)), timeout=2):
            pass
        _status_cache.update({'ts': now, 'reachable': True})
        return True
    except OSError:
        _status_cache.update({'ts': now, 'reachable': False})
        return False


# ── Game data constants (must match server enums) ────────────────────────────

RACES = {
    1: ('Hume', 'Male'),
    2: ('Hume', 'Female'),
    3: ('Elvaan', 'Male'),
    4: ('Elvaan', 'Female'),
    5: ('Tarutaru', 'Male'),
    6: ('Tarutaru', 'Female'),
    7: ('Mithra', ''),
    8: ('Galka', ''),
}

JOBS = {
    1: 'Warrior',
    2: 'Monk',
    3: 'White Mage',
    4: 'Black Mage',
    5: 'Red Mage',
    6: 'Thief',
}

NATIONS = {
    0: "San d'Oria",
    1: 'Bastok',
    2: 'Windurst',
}

SIZES = {0: 'Small', 1: 'Medium', 2: 'Large'}

# Equipment slot IDs (matches SLOTTYPE enum in battleentity.h)
# Grid order: Main Sub Ranged Ammo / Head Neck EarL EarR / Body Hands RingL RingR / Back Waist Legs Feet
_EQUIP_GRID = [
    (0,  'Main'),    (1,  'Sub'),     (2,  'Ranged'),  (3,  'Ammo'),
    (4,  'Head'),    (9,  'Neck'),    (11, 'Ear L'),   (12, 'Ear R'),
    (5,  'Body'),    (6,  'Hands'),   (13, 'Ring L'),  (14, 'Ring R'),
    (15, 'Back'),    (10, 'Waist'),   (7,  'Legs'),    (8,  'Feet'),
]

# ── Classic FFXI endgame weapon rarity sets — edit these to tune classification ─
# Items whose base names appear here override the su_level-based rarity check.
# Add relic armor piece names (e.g. "Valor's Surcoat") to _RELIC_ITEM_NAMES, etc.

_RELIC_ITEM_NAMES = frozenset({
    # Classic relic weapons (100 Beastmen Seals / Dynamis path)
    'Spharai', 'Destroyers', 'Godhands',
    'Mandau', 'Carnwenhan',
    'Excalibur', 'Durandal', 'Caladbolg', 'Burtgang', 'Murgleis',
    'Ragnarok',
    'Bravura', 'Annihilator',
    'Apocalypse',
    'Gungnir',
    'Kikoku',
    'Mjolnir', 'Lament',
    'Nirvana', 'Chatoyant Staff',
    'Aegis',
    'Kenkonken',
    'Daurdabla', 'Armageddon', 'Gastraphetes',
})

_MYTHIC_ITEM_NAMES = frozenset({
    # Mythic weapons (Einherjar / Nyzul Isle)
    'Glanzfaust',
    'Vajra', 'Twashtar',
    'Almace', 'Tizona',
    'Laevateinn', 'Epeolatry',
    'Ukonvasara',
    'Liberator',
    'Ryunohige',
    'Nagi',
    'Yagrush', 'Aymur',
    'Tupsimati',
})

_EMPYREAN_ITEM_NAMES = frozenset({
    # Empyrean weapons (Voidwatch / Abyssea)
    'Verethragna',
    'Aeneas', 'Gandayah',
    'Sequence',
    'Farsha',
    'Redemption',
    'Rhongomiant',
    'Kannagi',
    'Bolelabunga',
    'Loxotic Mace',
    'Malevolence',
})

# Item IDs treated as exceptional (custom MimicXI end-game drops).
# Add integer item IDs here; they will show as "exceptional" rarity regardless of other flags.
EXCEPTIONAL_ITEM_IDS: frozenset = frozenset()

# ── Mod ID → display name (for augment stat labels) ──────────────────────────
_MOD_NAMES = {
    # Core stats
    1:   'DEF',
    2:   'HP',    3: 'HP%',
    5:   'MP',    6: 'MP%',
    8:   'STR',   9: 'DEX',  10: 'VIT',  11: 'AGI',
    12:  'INT',  13: 'MND',  14: 'CHR',
    # Elemental magic evasion
    15: 'Fire Magic Evasion',   16: 'Ice Magic Evasion',
    17: 'Wind Magic Evasion',   18: 'Earth Magic Evasion',
    19: 'Thunder Magic Evasion', 20: 'Water Magic Evasion',
    21: 'Light Magic Evasion',  22: 'Dark Magic Evasion',
    # Offensive stats
    23: 'Attack',       24: 'Rng.Atk.',
    25: 'Accuracy',     26: 'Rng.Acc.',
    27: 'Enmity',
    28: 'Magic Atk. Bonus',   29: 'Magic Def. Bonus',
    30: 'Magic Accuracy',     31: 'Magic Evasion',
    48: 'Weaponskill Acc.',
    62: 'Attack%',  63: 'Defense%',  66: 'Rng.Atk.%',
    68: 'Evasion',  69: 'Rng.Def.',  70: 'Rng.Eva.',
    71: 'MP Regen While Healing',  72: 'HP Regen While Healing',
    73: 'Store TP',
    76: 'Movement Speed',
    # Weapon skills
    80: 'H2H Skill',       81: 'Dagger Skill',
    82: 'Sword Skill',     83: 'Great Sword Skill',
    84: 'Axe Skill',       85: 'Great Axe Skill',
    86: 'Scythe Skill',    87: 'Polearm Skill',
    88: 'Katana Skill',    89: 'Great Katana Skill',
    90: 'Club Skill',      91: 'Staff Skill',
    94: 'Meditate Duration',
    96: 'Souleater',
    101: 'Auto. Melee Skill',  102: 'Auto. Range Skill',  103: 'Auto. Magic Skill',
    104: 'Archery Skill',      105: 'Marksmanship Skill',
    106: 'Throwing Skill',     107: 'Guard Skill',
    108: 'Evasion Skill',      109: 'Shield Skill',       110: 'Parry Skill',
    # Magic skills
    111: 'Divine Magic Skill',       112: 'Healing Magic Skill',
    113: 'Enhancing Magic Skill',    114: 'Enfeebling Magic Skill',
    115: 'Elemental Magic Skill',    116: 'Dark Magic Skill',
    117: 'Summoning Magic Skill',    118: 'Ninjutsu Skill',
    119: 'Singing Skill',            120: 'String Instrument Skill',
    121: 'Wind Instrument Skill',    122: 'Blue Magic Skill',
    123: 'Geomancy Skill',           124: 'Handbell Skill',
    126: 'Blood Pact Dmg.',
    138: 'Barrage +1 shot',   139: 'Waltz Cost',
    # Damage taken
    160: 'Dmg. Taken',        161: 'Phys. Dmg. Taken',
    162: 'Breath Dmg. Taken', 163: 'Magic Dmg. Taken',
    164: 'Rng. Dmg. Taken',
    165: 'Critical Hit Rate',  166: 'Crit. Hit Evasion',
    168: 'Spell Interrupt Rate',
    170: 'Fast Cast',
    171: 'Delay',  172: 'Rng. Delay',  173: 'Martial Arts',
    175: 'Skillchain Dmg.',
    # Status resist
    240: 'Resist Sleep',    241: 'Resist Poison',    242: 'Resist Paralyze',
    243: 'Resist Blind',    244: 'Resist Silence',   245: 'Resist Virus',
    246: 'Resist Petrify',  247: 'Resist Bind',      248: 'Resist Curse',
    249: 'Resist Gravity',  250: 'Resist Slow',      251: 'Resist Stun',
    252: 'Resist Charm',
    259: 'Dual Wield',
    273: 'Call Beast Delay',   287: 'DMG',
    288: 'Double Attack',      289: 'Subtle Blow',
    291: 'Counter',            292: 'Kick Attack',
    296: 'Conserve MP',
    302: 'Triple Attack',      303: 'Treasure Hunter',
    305: 'Recycle',            306: 'Zanshin',        308: 'Ninja Tool Cost',
    311: 'Magic Dmg. Bonus',   315: 'Drain/Aspir Bonus',
    # Endgame bonuses
    345: 'TP Bonus',           346: 'Perpetuation Cost',
    347: 'Fire Staff Bonus',   348: 'Ice Staff Bonus',
    349: 'Wind Staff Bonus',   350: 'Earth Staff Bonus',
    351: 'Thunder Staff Bonus', 352: 'Water Staff Bonus',
    353: 'Light Staff Bonus',  354: 'Dark Staff Bonus',
    357: 'Blood Pact Delay',   359: 'Rapid Shot',
    365: 'Snapshot',
    369: 'Refresh',            370: 'Regen',
    374: 'Cure Potency',       375: 'Cure Potency Rcvd.',
    376: 'Rng. Dmg.',          380: 'Delay%',
    384: 'Haste',              391: 'Charm+',
    421: 'Critical Dmg.',      430: 'Quad. Attack',
    432: 'Enspell Dmg.',       452: 'All Songs +',
    455: 'Song Cast Time',     477: 'Helix Duration',
    485: 'Shield Mastery TP',  487: 'Magic Burst Bonus',
    491: 'Waltz Potency',      497: 'Waltz Delay',
    518: 'Shield Block Rate',  519: 'Cure Cast Time',
    540: 'Elemental Siphon+',
    544: 'Fire WS fTP',        545: 'Ice WS fTP',
    546: 'Wind WS fTP',        547: 'Earth WS fTP',
    548: 'Thunder WS fTP',     549: 'Water WS fTP',
    550: 'Light WS fTP',       551: 'Dark WS fTP',
    562: 'Magic Crit Rate',    563: 'Magic Crit Dmg.',
    833: 'Song Recast',        880: 'Save TP',
    890: 'Enhancing Duration', 897: 'Gilfinder',
    902: 'Occult Acumen',      909: 'Quick Magic',
    911: 'Daken',              913: 'Blood Boon',
    915: 'Capacity Bonus',     944: 'Conserve TP',
    958: 'Status Resist',      960: 'Indi Duration',
    963: 'Inquartata',         989: 'Regen Bonus',
    1081: 'Damage Limit+',     1146: 'Elemental Magic Recast',
    1182: 'Phalanx+',
    1183: 'Healing Magic Recast',     1184: 'Enfeebling Magic Recast',
    1185: 'Enhancing Magic Recast',
}

# Path to ShiningFantasia data for item icons and JSON details.
# Override with SHINING_FANTASIA_PATH environment variable.
_SF_DIR = os.environ.get('SHINING_FANTASIA_PATH', r'G:\Games\FFXI\ShiningFantasia')

# All 22 jobs — order matches char_jobs column order
_JOB_COLS = [
    ('war','Warrior','WAR'), ('mnk','Monk','MNK'),
    ('whm','White Mage','WHM'), ('blm','Black Mage','BLM'),
    ('rdm','Red Mage','RDM'), ('thf','Thief','THF'),
    ('pld','Paladin','PLD'), ('drk','Dark Knight','DRK'),
    ('bst','Beastmaster','BST'), ('brd','Bard','BRD'),
    ('rng','Ranger','RNG'), ('sam','Samurai','SAM'),
    ('nin','Ninja','NIN'), ('drg','Dragoon','DRG'),
    ('smn','Summoner','SMN'), ('blu','Blue Mage','BLU'),
    ('cor','Corsair','COR'), ('pup','Puppetmaster','PUP'),
    ('dnc','Dancer','DNC'), ('sch','Scholar','SCH'),
    ('geo','Geomancer','GEO'), ('run','Rune Fencer','RUN'),
]
_JOB_BY_ID = {
    1:'WAR', 2:'MNK', 3:'WHM', 4:'BLM', 5:'RDM', 6:'THF',
    7:'PLD', 8:'DRK', 9:'BST', 10:'BRD', 11:'RNG', 12:'SAM',
    13:'NIN', 14:'DRG', 15:'SMN', 16:'BLU', 17:'COR', 18:'PUP',
    19:'DNC', 20:'SCH', 21:'GEO', 22:'RUN',
}
_FAME_FIELDS = [
    ('sandoria', "San d'Oria"), ('bastok', 'Bastok'),
    ('windurst', 'Windurst'), ('norg', 'Norg'),
    ('jeuno', 'Jeuno'), ('adoulin', 'Adoulin'),
]

# Skill categories: display name → list of skillids
_SKILL_CATEGORIES = [
    ('Weapons',  list(range(1,  13))),   # H2H … Staff
    ('Ranged',   list(range(25, 28))),   # Archery, Marksmanship, Throwing
    ('Defense',  list(range(28, 32))),   # Guard, Evasion, Shield, Parry
    ('Magic',    list(range(32, 46))),   # Divine … Handbell
]

# Craft skills (skillids 48-57)
_CRAFT_SKILLS = [
    (48, 'Fishing'), (49, 'Woodworking'), (50, 'Smithing'),
    (51, 'Goldsmithing'), (52, 'Clothcraft'), (53, 'Leathercraft'),
    (54, 'Bonecraft'), (55, 'Alchemy'), (56, 'Cooking'), (57, 'Synergy'),
]

# JS CURRENCY_META id → char_points column name
_CURRENCY_MAP = [
    ('sandoria_cp',           'sandoria_cp'),
    ('bastok_cp',             'bastok_cp'),
    ('windurst_cp',           'windurst_cp'),
    ('obsidian_fragment',     'obsidian_fragment'),
    ('allied_notes',          'allied_notes'),
    ('bayld',                 'bayld'),
    ('cruor',                 'cruor'),
    ('imperial_standing',     'imperial_standing'),
    ('sparks',                'spark_of_eminence'),
    ('therion_ichor',         'therion_ichor'),
    ('voidstone',             'voidstones'),
    ('cinders',               'cinder'),
    ('coalition_imprimaturs', 'imprimaturs'),
]

# LQS quest pack directory and area display names
_LQS_QUEST_DIR = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    '..', '..', 'modules', 'custom', 'LQS', 'questpack',
))
_LQS_AREA_MAP = {
    'aht_urhgan': 'Aht Urhgan',
    'bastok':     'Bastok',
    'sandoria':   "San d'Oria",
    'windurst':   'Windurst',
    'other_areas': 'Various',
    'dailies':    'Daily',
}
_lqs_catalog: dict | None = None


def _count_lua_steps(text: str) -> int:
    """Count top-level step blocks inside the Lua steps = { ... } table."""
    m = re.search(r'\bsteps\s*=\s*\{', text)
    if not m:
        return 0
    pos = m.end()
    depth, count = 1, 0
    while pos < len(text) and depth > 0:
        c = text[pos]
        if c == '{':
            depth += 1
            if depth == 2:
                count += 1
        elif c == '}':
            depth -= 1
        pos += 1
    return count


def _load_lqs_catalog() -> dict:
    """Parse LQS Lua files into a cached quest catalog."""
    global _lqs_catalog
    if _lqs_catalog is not None:
        return _lqs_catalog

    import glob as _glob_mod
    regular: list = []
    dailies: list = []

    for fpath in _glob_mod.glob(os.path.join(_LQS_QUEST_DIR, '**', '*.lua'), recursive=True):
        try:
            with open(fpath, encoding='utf-8') as f:
                text = f.read()
        except Exception:
            continue

        name_m = re.search(r'\bname\s*=\s*"([^"]+)"', text)
        var_m  = re.search(r'\bvar\s*=\s*"([^"]+)"', text)
        if not name_m or not var_m:
            continue

        name    = name_m.group(1)
        var     = var_m.group(1)
        dirpart = os.path.basename(os.path.dirname(fpath))
        area    = _LQS_AREA_MAP.get(dirpart, dirpart)
        steps   = _count_lua_steps(text)
        lvl_m   = re.search(r'LQS\.checks\s*\(\s*\{[^}]*\blevel\s*=\s*(\d+)', text, re.DOTALL)
        min_lvl = int(lvl_m.group(1)) if lvl_m else 1

        entry = {'name': name, 'var': var, 'area': area, 'steps': steps, 'min_level': min_lvl}
        if dirpart == 'dailies':
            dailies.append(entry)
        else:
            regular.append(entry)

    regular.sort(key=lambda q: (q['area'], q['name']))
    _lqs_catalog = {'regular': regular, 'dailies': dailies}
    print(f'[mimic] LQS catalog: {len(regular)} regular quests, {len(dailies)} dailies')
    return _lqs_catalog


def _fame_tier(v):
    for threshold, tier in [(1500,8),(1000,7),(650,6),(400,5),(200,4),(100,3),(50,2)]:
        if v >= threshold:
            return tier
    return 1

# Starting zones per nation — matches login_helpers.cpp
_STARTING_ZONES = {
    0: [0xE6, 0xE7, 0xE8],
    1: [0xEA, 0xEB, 0xEC],
    2: [0xEE, 0xF0, 0xF1],
}

# Face grid: (face_num 1-8) × (variant A/B/C) → face byte value
# A = (face_num-1)*2, B = (face_num-1)*2+1, C = face_num+15
FACE_GRID = [
    {'num': n, 'variant': v, 'value': val, 'custom': v == 'C'}
    for n in range(1, 9)
    for v, val in [('A', (n - 1) * 2), ('B', (n - 1) * 2 + 1), ('C', n + 15)]
]


def _face_label(value: int) -> str:
    if 0 <= value <= 15:
        return f"Face {value // 2 + 1}{'A' if value % 2 == 0 else 'B'}"
    if 16 <= value <= 23:
        return f"Face {value - 15}C"
    return f"Face {value}"


# ── Face portrait icons (sourced from FFXIclopedia, cached locally) ───────────
import hashlib
import urllib.request as _urllib_req

_FACE_CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'face-cache')
os.makedirs(_FACE_CACHE, exist_ok=True)

_FACE_PREFIX = {1: 'Hm', 2: 'Hf', 3: 'Em', 4: 'Ef', 5: 'Tm', 6: 'Tf', 7: 'M', 8: 'G'}


def _face_icon_filename(race: int, face: int) -> str | None:
    prefix = _FACE_PREFIX.get(race)
    if not prefix or face is None:
        return None
    if 0 <= face <= 15:
        num = face // 2 + 1
        var = 'a' if face % 2 == 0 else 'b'
        return f'{prefix}{num}{var}.jpg'
    if 16 <= face <= 23:
        num = face - 15
        return f'{prefix}{num}c.jpg'
    return None


@app.route('/face-icon/<int:race>/<int:face>')
def face_icon_route(race, face):
    filename = _face_icon_filename(race, face)
    if not filename:
        from flask import abort; abort(404)
    cached = os.path.join(_FACE_CACHE, filename)
    if not os.path.exists(cached):
        h = hashlib.md5(filename.encode()).hexdigest()
        wiki_url = f'https://static.wikia.nocookie.net/ffxi/images/{h[0]}/{h[0:2]}/{filename}'
        try:
            req = _urllib_req.Request(wiki_url, headers={'User-Agent': 'Mozilla/5.0'})
            with _urllib_req.urlopen(req, timeout=8) as resp:
                data = resp.read()
            with open(cached, 'wb') as f:
                f.write(data)
        except Exception as e:
            app.logger.warning("face icon fetch failed %s: %s", filename, e)
            from flask import abort; abort(404)
    return send_from_directory(_FACE_CACHE, filename)


# ── Auth helper ───────────────────────────────────────────────────────────────

def login_required(f):
    @wraps(f)
    def _inner(*args, **kwargs):
        if 'accid' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return _inner


# ── Static site (Option A — same-origin, no CORS needed) ─────────────────────
# Checks these directories in order and uses the first one that contains
# an index.html, so it works wherever you put the design files.

def _find_public_dir():
    here = os.path.dirname(os.path.abspath(__file__))
    candidates = [
        os.path.join(here, 'public'),
        os.path.join(here, 'site'),
        os.path.join(here, 'templates', 'site'),
    ]
    for path in candidates:
        if os.path.isfile(os.path.join(path, 'index.html')):
            return path
    # None found — return the default so os.makedirs still works
    return candidates[0]

PUBLIC_DIR = _find_public_dir()
os.makedirs(PUBLIC_DIR, exist_ok=True)
print(f'[mimic] static site dir: {PUBLIC_DIR}')
print(f'[mimic] index.html present: {os.path.isfile(os.path.join(PUBLIC_DIR, "index.html"))}')


@app.route('/')
def index():
    index_html = os.path.join(PUBLIC_DIR, 'index.html')
    if os.path.exists(index_html):
        return send_from_directory(PUBLIC_DIR, 'index.html')
    # Fallback while no site files are present yet
    return redirect(url_for('login') if 'accid' not in session else url_for('characters'))


@app.route('/site/<path:filename>')
def public_site(filename):
    return send_from_directory(PUBLIC_DIR, filename)


@app.route('/<path:filename>')
def public_root(filename):
    """Serve site assets (CSS, JS, images, fonts) at the root path.

    The design pages use relative hrefs like `account.css`, so when
    index.html is served from `/` the browser fetches `/account.css`.
    Flask checks all explicit routes first, so /login, /logout, /api/*
    etc. are never intercepted here — only unmatched paths reach this.
    """
    filepath = os.path.join(PUBLIC_DIR, filename)
    if os.path.isfile(filepath):
        return send_from_directory(PUBLIC_DIR, filename)
    from flask import abort
    abort(404)


_ICONS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'icons')


@app.route('/nation-icon/<path:filename>')
def nation_icon(filename):
    return send_from_directory(_ICONS_DIR, filename)


# ── Routes ────────────────────────────────────────────────────────────────────


def _check_credentials(username, password):
    """Return (id, priv) if credentials are valid, else None."""
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT id, password, priv FROM accounts WHERE login = ? AND status > 0",
            (username,),
        )
        row = cur.fetchone()
    finally:
        cur.close()
        conn.close()
    if row and bcrypt.checkpw(password.encode(), row[1].encode()):
        return (row[0], row[2])  # (id, priv)
    return None


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # Accept both form-encoded (Jinja UI) and JSON (design site fetch calls)
        if request.is_json:
            data     = request.get_json(silent=True) or {}
            username = str(data.get('username', '')).strip()
            password = str(data.get('password', ''))
        else:
            username = request.form.get('username', '').strip()
            password = request.form.get('password', '')

        print(f'[mimic] login attempt: username={username!r} json={request.is_json}')

        if not username or not password:
            if request.is_json:
                return jsonify(error='Username and password are required.'), 400
            flash('Username and password are required.', 'error')
            return render_template('login.html')

        row = _check_credentials(username, password)
        if row:
            accid, priv = row
            session['accid']    = accid
            session['username'] = username
            session['is_admin'] = priv >= _ADMIN_PRIV
            print(f'[mimic] login ok: accid={accid} username={username!r}')
            if request.is_json:
                return jsonify(accid=accid, username=username), 200
            return redirect(url_for('characters'))

        print(f'[mimic] login failed: username={username!r}')
        if request.is_json:
            return jsonify(error='Invalid username or password.'), 401
        flash('Invalid username or password.', 'error')

    return render_template('login.html')


@app.route('/api/login', methods=['POST'])
def api_login():
    """JSON login endpoint — used by the design site's signin.html."""
    data     = request.get_json(force=True, silent=True) or {}
    username = str(data.get('username', '')).strip()
    password = str(data.get('password', ''))

    print(f'[mimic] /api/login attempt: username={username!r}')

    if not username or not password:
        return jsonify(error='Username and password are required.'), 400

    row = _check_credentials(username, password)
    if row:
        accid, priv = row
        session['accid']    = accid
        session['username'] = username
        session['is_admin'] = priv >= _ADMIN_PRIV
        print(f'[mimic] /api/login ok: accid={accid} username={username!r}')
        return jsonify(accid=accid, username=username), 200

    print(f'[mimic] /api/login failed: username={username!r}')
    return jsonify(error='Invalid username or password.'), 401


@app.route('/logout', methods=['POST', 'GET'])
def logout():
    print(f'[mimic] logout: clearing session for accid={session.get("accid")}')
    session.clear()
    if request.is_json or request.args.get('json'):
        return jsonify(ok=True), 200
    return redirect(url_for('login'))


@app.route('/characters')
@login_required
def characters():
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT c.charid, c.charname, cl.race, cl.face, c.nation "
            "FROM chars c INNER JOIN char_look cl USING(charid) "
            "WHERE c.accid = ? ORDER BY c.charid",
            (session['accid'],),
        )
        rows = cur.fetchall()
    finally:
        cur.close()
        conn.close()

    chars = [
        {
            'charid': r[0],
            'name': r[1],
            'race': '{} {}'.format(*RACES[r[2]]).strip() if r[2] in RACES else f'Race {r[2]}',
            'face': _face_label(r[3]),
            'nation': NATIONS.get(r[4], f'Nation {r[4]}'),
        }
        for r in rows
    ]
    return render_template('characters.html', characters=chars)


@app.route('/create', methods=['GET', 'POST'])
@login_required
def create():
    ctx = dict(races=RACES, jobs=JOBS, nations=NATIONS, sizes=SIZES, face_grid=FACE_GRID)

    if request.method != 'POST':
        return render_template('create.html', **ctx)

    name   = request.form.get('name', '').strip()
    race   = int(request.form.get('race', 0))
    face   = int(request.form.get('face', 0))
    size   = int(request.form.get('size', 1))
    job    = int(request.form.get('job', 1))
    nation = int(request.form.get('nation', 0))

    errors = []
    if not name or not (3 <= len(name) <= 15):
        errors.append('Name must be 3–15 characters.')
    elif not name.isalpha():
        errors.append('Name may only contain letters.')
    if not 1 <= race <= 8:
        errors.append('Invalid race selection.')
    if not 0 <= face <= 23:
        errors.append('Invalid face selection.')
    if not 0 <= size <= 2:
        errors.append('Invalid size selection.')
    if not 1 <= job <= 6:
        errors.append('Invalid starting job.')
    if not 0 <= nation <= 2:
        errors.append('Invalid nation.')

    if errors:
        for e in errors:
            flash(e, 'error')
        return render_template('create.html', **ctx)

    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT charid FROM chars WHERE charname = ?", (name,))
        if cur.fetchone():
            flash('That character name is already taken.', 'error')
            return render_template('create.html', **ctx)

        cur.execute("SELECT COALESCE(MAX(charid), 0) + 1 FROM chars")
        charid   = cur.fetchone()[0]
        pos_zone = random.choice(_STARTING_ZONES[nation])

        conn.autocommit = False
        cur.execute(
            "INSERT INTO chars(charid,accid,charname,pos_zone,nation) VALUES(?,?,?,?,?)",
            (charid, session['accid'], name, pos_zone, nation),
        )
        cur.execute(
            "INSERT INTO char_look(charid,face,race,size) VALUES(?,?,?,?)",
            (charid, face, race, size),
        )
        cur.execute("INSERT INTO char_stats(charid,mjob) VALUES(?,?)", (charid, job))
        cur.execute(
            "INSERT INTO char_exp(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid",
            (charid,),
        )
        cur.execute(
            "INSERT INTO char_flags(charid) VALUES(?) ON DUPLICATE KEY UPDATE disconnecting=disconnecting",
            (charid,),
        )
        cur.execute(
            "INSERT INTO char_jobs(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid",
            (charid,),
        )
        cur.execute(
            "INSERT INTO char_points(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid",
            (charid,),
        )
        cur.execute(
            "INSERT INTO char_unlocks(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid",
            (charid,),
        )
        cur.execute(
            "INSERT INTO char_profile(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid",
            (charid,),
        )
        cur.execute(
            "INSERT INTO char_storage(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid",
            (charid,),
        )
        cur.execute("DELETE FROM char_inventory WHERE charid=?", (charid,))
        cur.execute("INSERT INTO char_inventory(charid) VALUES(?)", (charid,))
        conn.commit()

        flash(f"Character '{name}' created successfully!", 'success')
        return redirect(url_for('characters'))

    except Exception as e:
        conn.rollback()
        flash(f'Character creation failed: {e}', 'error')
        return render_template('create.html', **ctx)
    finally:
        cur.close()
        conn.autocommit = True
        conn.close()


# ── Registration & session ────────────────────────────────────────────────────

@app.route('/api/register', methods=['POST'])
def api_register():
    data     = request.get_json(force=True, silent=True) or {}
    username = str(data.get('username', '')).strip()
    password = str(data.get('password', ''))
    email    = str(data.get('email', '')).strip()

    if not re.fullmatch(r'[A-Za-z0-9]{3,15}', username):
        return jsonify(error='Account name must be 3–15 letters or numbers.'), 400
    if len(password) < 8:
        return jsonify(error='Password must be at least 8 characters.'), 400
    if email and not re.fullmatch(r'[^@\s]+@[^@\s]+\.[^@\s]+', email):
        return jsonify(error='Email address looks invalid.'), 400

    pw_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT id FROM accounts WHERE login = ?", (username,))
        if cur.fetchone():
            return jsonify(error='That account name is already taken.'), 409

        cur.execute("SELECT COALESCE(MAX(id), 0) + 1 FROM accounts")
        new_id = cur.fetchone()[0]

        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        cur.execute(
            "INSERT INTO accounts("
            "  id, login, password, current_email, registration_email,"
            "  timecreate, timelastmodify,"
            "  content_ids, expansions, features, status, priv"
            ") VALUES (?, ?, ?, ?, ?, ?, ?, 16, 4094, 253, 1, 1)",
            (new_id, username, pw_hash, email, email, now, now),
        )

        session['accid']    = new_id
        session['username'] = username
        return jsonify(accid=new_id, username=username), 201

    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        cur.close()
        conn.close()


@app.route('/api/session')
def api_session():
    if 'accid' not in session:
        return jsonify(authenticated=False), 200
    return jsonify(
        authenticated=True,
        accid=session['accid'],
        username=session.get('username'),
        is_admin=session.get('is_admin', False),
    )


@app.route('/api/online')
def api_online():
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT c.charid, c.charname, cs.mjob, cs.mlvl, z.name"
            " FROM accounts_sessions s"
            " INNER JOIN chars c ON c.charid = s.charid"
            " INNER JOIN char_stats cs ON cs.charid = s.charid"
            " LEFT JOIN zone_settings z ON z.zoneid = c.pos_zone"
            " ORDER BY c.charname",
        )
        rows = cur.fetchall()
    finally:
        cur.close()
        conn.close()

    players = [
        {
            'charid': r[0],
            'name':   r[1],
            'job':    _JOB_BY_ID.get(r[2], '???'),
            'level':  r[3],
            'zone':   (r[4] or 'Unknown').replace('_', ' '),
        }
        for r in rows
    ]
    return jsonify({'count': len(players), 'players': players})


@app.route('/api/server-status')
def api_server_status():
    if _maintenance_active():
        return jsonify({'mode': 'maintenance', 'count': 0, 'players': []})
    if not _check_game_server():
        return jsonify({'mode': 'offline', 'count': 0, 'players': []})
    conn = cur = None
    try:
        conn = get_connection()
        cur  = conn.cursor()
        cur.execute(
            "SELECT c.charid, c.charname, cs.mjob, cs.mlvl, z.name"
            " FROM accounts_sessions s"
            " INNER JOIN chars c ON c.charid = s.charid"
            " INNER JOIN char_stats cs ON cs.charid = s.charid"
            " LEFT JOIN zone_settings z ON z.zoneid = c.pos_zone"
            " ORDER BY c.charname",
        )
        rows = cur.fetchall()
    except Exception as e:
        app.logger.warning("server-status query failed: %s", e)
        rows = []
    finally:
        if cur:  cur.close()
        if conn: conn.close()
    players = [
        {
            'charid': r[0],
            'name':   r[1],
            'job':    _JOB_BY_ID.get(r[2], '???'),
            'level':  r[3],
            'zone':   (r[4] or 'Unknown').replace('_', ' '),
        }
        for r in rows
    ]
    return jsonify({'mode': 'online', 'count': len(players), 'players': players})


@app.route('/api/server-status/maintenance', methods=['POST'])
def api_set_maintenance():
    if 'accid' not in session:
        return jsonify(error='Not authenticated'), 401
    if not session.get('is_admin', False):
        return jsonify(error='Not authorized'), 403
    data   = request.get_json(force=True, silent=True) or {}
    enable = bool(data.get('enabled', True))
    if enable:
        open(_MAINTENANCE_FLAG, 'w').close()
    else:
        try:
            os.remove(_MAINTENANCE_FLAG)
        except FileNotFoundError:
            pass
    mode = 'maintenance' if enable else 'online'
    app.logger.info("maintenance mode %s by accid=%s", "ON" if enable else "OFF", session['accid'])
    return jsonify({'mode': mode, 'enabled': enable})


# ── JSON API (consumed by React / CharacterCreator.jsx) ───────────────────────

def _api_login_required(f):
    @wraps(f)
    def _inner(*args, **kwargs):
        if 'accid' not in session:
            return jsonify(error='Not authenticated'), 401
        return f(*args, **kwargs)
    return _inner


@app.route('/api/characters')
@_api_login_required
def api_characters():
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(
            "SELECT c.charid, c.charname, cl.race, cl.face, c.nation "
            "FROM chars c INNER JOIN char_look cl USING(charid) "
            "WHERE c.accid = ? ORDER BY c.charid",
            (session['accid'],),
        )
        rows = cur.fetchall()
    finally:
        cur.close()
        conn.close()

    return jsonify([
        {
            'charid': r[0],
            'name':   r[1],
            'race':   r[2],
            'face':   r[3],
            'nation': r[4],
        }
        for r in rows
    ])


@app.route('/api/create', methods=['POST'])
@_api_login_required
def api_create():
    data   = request.get_json(force=True)
    name   = str(data.get('name', '')).strip()
    race   = int(data.get('race', 0))
    face   = int(data.get('face', 0))
    size   = int(data.get('size', 1))
    job    = int(data.get('job', 1))
    nation = int(data.get('nation', 0))

    if not name or not (3 <= len(name) <= 15) or not name.isalpha():
        return jsonify(error='Name must be 3–15 letters only.'), 400
    if not 1 <= race <= 8:
        return jsonify(error='Invalid race.'), 400
    if not 0 <= face <= 23:
        return jsonify(error='Invalid face.'), 400
    if not 0 <= size <= 2:
        return jsonify(error='Invalid size.'), 400
    if not 1 <= job <= 6:
        return jsonify(error='Invalid job.'), 400
    if not 0 <= nation <= 2:
        return jsonify(error='Invalid nation.'), 400

    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT charid FROM chars WHERE charname = ?", (name,))
        if cur.fetchone():
            return jsonify(error='That character name is already taken.'), 409

        cur.execute("SELECT COALESCE(MAX(charid), 0) + 1 FROM chars")
        charid   = cur.fetchone()[0]
        pos_zone = random.choice(_STARTING_ZONES[nation])

        conn.autocommit = False
        cur.execute(
            "INSERT INTO chars(charid,accid,charname,pos_zone,nation) VALUES(?,?,?,?,?)",
            (charid, session['accid'], name, pos_zone, nation),
        )
        cur.execute(
            "INSERT INTO char_look(charid,face,race,size) VALUES(?,?,?,?)",
            (charid, face, race, size),
        )
        cur.execute("INSERT INTO char_stats(charid,mjob) VALUES(?,?)", (charid, job))
        cur.execute(
            "INSERT INTO char_exp(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid", (charid,))
        cur.execute(
            "INSERT INTO char_flags(charid) VALUES(?) ON DUPLICATE KEY UPDATE disconnecting=disconnecting", (charid,))
        cur.execute(
            "INSERT INTO char_jobs(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid", (charid,))
        cur.execute(
            "INSERT INTO char_points(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid", (charid,))
        cur.execute(
            "INSERT INTO char_unlocks(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid", (charid,))
        cur.execute(
            "INSERT INTO char_profile(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid", (charid,))
        cur.execute(
            "INSERT INTO char_storage(charid) VALUES(?) ON DUPLICATE KEY UPDATE charid=charid", (charid,))
        cur.execute("DELETE FROM char_inventory WHERE charid=?", (charid,))
        cur.execute("INSERT INTO char_inventory(charid) VALUES(?)", (charid,))
        conn.commit()

        return jsonify(charid=charid, name=name), 201

    except Exception as e:
        conn.rollback()
        return jsonify(error=str(e)), 500
    finally:
        cur.close()
        conn.autocommit = True
        conn.close()


# ── Character profile ─────────────────────────────────────────────────────────

@app.route('/character')
def character_page():
    return render_template('character.html')


@app.route('/api/character/<int:charid>')
def api_character(charid):
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT c.charid, c.accid, c.charname, c.nation, c.playtime,"
            "  cs.mjob, cs.sjob, cs.mlvl, cs.slvl,"
            "  cl.race, cl.face, cl.size"
            " FROM chars c"
            " INNER JOIN char_stats cs USING(charid)"
            " INNER JOIN char_look  cl USING(charid)"
            " WHERE c.charid = ?",
            (charid,),
        )
        row = cur.fetchone()
        if not row:
            return jsonify(error='Character not found.'), 404

        (cid, accid, name, nation, playtime,
         mjob_id, sjob_id, mlvl, slvl, race, face, size) = row

        is_owner = (session.get('accid') == accid)

        # ── Job levels + EXP ────────────────────────────────────────────────
        col_list = ','.join(c for c,_,_ in _JOB_COLS)
        cur.execute(f"SELECT {col_list} FROM char_jobs WHERE charid = ?", (charid,))
        jobs_row = cur.fetchone() or ([0] * len(_JOB_COLS))

        # Cumulative EXP per job
        try:
            cur.execute(f"SELECT {col_list} FROM char_exp WHERE charid = ?", (charid,))
            exp_row = cur.fetchone() or ([0] * len(_JOB_COLS))
        except Exception:
            exp_row = [0] * len(_JOB_COLS)

        # exp_base: level → cumulative EXP to reach that level
        exp_base: dict = {}
        try:
            cur.execute("SELECT level, exp FROM exp_base ORDER BY level")
            exp_base = {r[0]: r[1] for r in cur.fetchall()}
        except Exception:
            pass

        jobs = []
        for i, ((col, name_, abbr), lvl) in enumerate(zip(_JOB_COLS, jobs_row)):
            exp_total = exp_row[i] if i < len(exp_row) else 0
            if lvl >= 75:
                exp_earned  = 0
                exp_to_next = 0
            elif lvl > 0 and exp_base:
                base_now  = exp_base.get(lvl,     0)
                base_next = exp_base.get(lvl + 1, base_now)
                exp_earned  = max(0, exp_total - base_now)
                exp_to_next = max(0, base_next  - exp_total)
            else:
                exp_earned  = 0
                exp_to_next = None
            jobs.append({
                'col':        col,
                'name':       name_,
                'abbr':       abbr,
                'level':      lvl,
                'exp':        exp_earned,
                'exp_to_next': exp_to_next,
            })

        # ── Fame and nation ranks ────────────────────────────────────────────
        cur.execute(
            "SELECT rank_sandoria, rank_bastok, rank_windurst,"
            "  fame_sandoria, fame_bastok, fame_windurst,"
            "  fame_norg, fame_jeuno, fame_adoulin"
            " FROM char_profile WHERE charid = ?",
            (charid,),
        )
        prof = cur.fetchone()
        ranks = {}
        fame  = []
        if prof:
            ranks = {'sandoria': prof[0], 'bastok': prof[1], 'windurst': prof[2]}
            for i, (key, label) in enumerate(_FAME_FIELDS):
                val = prof[3 + i] or 0
                fame.append({'area': label, 'level': _fame_tier(val), 'points': val})

        # ── Skills ──────────────────────────────────────────────────────────
        skills: dict = {}
        try:
            cur.execute(
                "SELECT cs.skillid, cs.value, sr.name"
                " FROM char_skills cs"
                " INNER JOIN skill_ranks sr ON cs.skillid = sr.skillid"
                " WHERE cs.charid = ? AND cs.skillid BETWEEN 1 AND 45",
                (charid,),
            )
            skill_map = {r[0]: (r[1] // 10, r[2]) for r in cur.fetchall()}
            for cat_name, skillids in _SKILL_CATEGORIES:
                cat_list = [
                    {'name': skill_map[sid][1], 'level': skill_map[sid][0], 'cap': 276}
                    for sid in skillids if sid in skill_map
                ]
                if cat_list:
                    skills[cat_name] = cat_list
        except Exception:
            pass

        # ── Crafts ──────────────────────────────────────────────────────────
        crafts: list = []
        try:
            cur.execute(
                "SELECT skillid, value FROM char_skills"
                " WHERE charid = ? AND skillid BETWEEN 48 AND 57",
                (charid,),
            )
            craft_map = {r[0]: r[1] // 10 for r in cur.fetchall()}
            crafts = [
                {'name': cname, 'level': craft_map.get(sid, 0)}
                for sid, cname in _CRAFT_SKILLS
            ]
        except Exception:
            crafts = [{'name': cname, 'level': 0} for _, cname in _CRAFT_SKILLS]

        # ── Currencies ──────────────────────────────────────────────────────
        currencies: list = []
        try:
            db_cols = ', '.join(db_col for _, db_col in _CURRENCY_MAP)
            cur.execute(f"SELECT {db_cols} FROM char_points WHERE charid = ?", (charid,))
            cp_row = cur.fetchone()
            if cp_row:
                currencies = [
                    {'id': js_id, 'amount': cp_row[i] or 0}
                    for i, (js_id, _) in enumerate(_CURRENCY_MAP)
                ]
        except Exception as e:
            app.logger.warning("currency query failed: %s", e)

        # ── History (derived) ────────────────────────────────────────────────
        jobs_mastered = sum(1 for lvl in jobs_row if lvl >= 75)
        total_levels  = sum(lvl for lvl in jobs_row if lvl > 0)
        skills_at_cap = sum(
            1 for cat_list in skills.values()
            for s in cat_list if s['level'] >= 276
        )
        total_cp = sum(
            next((c['amount'] for c in currencies if c['id'] == k), 0)
            for k in ('sandoria_cp', 'bastok_cp', 'windurst_cp')
        )

        ch: dict = {}
        try:
            cur.execute(
                "SELECT enemies_defeated, times_knocked_out, mh_entrances, "
                "joined_parties, joined_alliances, spells_cast, abilities_used, "
                "ws_used, items_used, chats_sent, npc_interactions, "
                "battles_fought, distance_travelled "
                "FROM char_history WHERE charid = ?",
                (charid,)
            )
            ch_row = cur.fetchone()
            if ch_row:
                keys = [
                    'enemies_defeated', 'times_knocked_out', 'mh_entrances',
                    'joined_parties', 'joined_alliances', 'spells_cast',
                    'abilities_used', 'ws_used', 'items_used', 'chats_sent',
                    'npc_interactions', 'battles_fought', 'distance_travelled',
                ]
                ch = {k: (int(v) if v is not None else 0) for k, v in zip(keys, ch_row)}
        except Exception as e:
            app.logger.warning("char_history query failed: %s", e)

        fate_completions = 0
        try:
            cur.execute(
                "SELECT COALESCE(SUM(value), 0) FROM char_vars "
                "WHERE charid = ? AND varname LIKE '[FATE][%]Progress'",
                (charid,)
            )
            fate_row = cur.fetchone()
            if fate_row and fate_row[0] is not None:
                fate_completions = int(fate_row[0])
        except Exception as e:
            app.logger.warning("fate completions query failed: %s", e)

        history = {
            'jobs_mastered':      jobs_mastered,
            'total_levels':       total_levels,
            'skills_at_cap':      skills_at_cap,
            'total_cp':           total_cp,
            'playtime_hours':     (playtime or 0) // 3600,
            'enemies_defeated':   ch.get('enemies_defeated'),
            'battles_fought':     ch.get('battles_fought'),
            'ws_used':            ch.get('ws_used'),
            'times_knocked_out':  ch.get('times_knocked_out'),
            'spells_cast':        ch.get('spells_cast'),
            'abilities_used':     ch.get('abilities_used'),
            'items_used':         ch.get('items_used'),
            'joined_parties':     ch.get('joined_parties'),
            'joined_alliances':   ch.get('joined_alliances'),
            'npc_interactions':   ch.get('npc_interactions'),
            'chats_sent':         ch.get('chats_sent'),
            'mh_entrances':       ch.get('mh_entrances'),
            'distance_travelled': ch.get('distance_travelled'),
            'fate_completions':   fate_completions,
        }

        result = {
            'charid':           cid,
            'name':             name,
            'race':             race,
            'race_name':        ' '.join(p for p in RACES.get(race, ('?', '')) if p).strip(),
            'nation':           nation,
            'nation_name':      NATIONS.get(nation, f'Nation {nation}'),
            'size':             SIZES.get(size, ''),
            'face':             face,
            'face_label':       _face_label(face),
            'playtime_seconds': playtime or 0,
            'playtime_hours':   (playtime or 0) // 3600,
            'playtime_mins':    ((playtime or 0) % 3600) // 60,
            'mjob':             mjob_id,
            'sjob':             sjob_id or None,
            'mjob_level':       mlvl,
            'sjob_level':       slvl if sjob_id else None,
            'main_job':         _JOB_BY_ID.get(mjob_id, '???'),
            'main_job_level':   mlvl,
            'sub_job':          _JOB_BY_ID.get(sjob_id) if sjob_id else None,
            'sub_job_level':    slvl if sjob_id else None,
            'jobs':             jobs,
            'ranks':            ranks,
            'fame':             fame,
            'currencies':       currencies,
            'skills':           skills,
            'crafts':           crafts,
            'history':          history,
            'is_owner':         is_owner,
        }

        if is_owner:
            gil = 0
            try:
                cur.execute(
                    "SELECT quantity FROM char_inventory"
                    " WHERE charid = ? AND itemid = 65535 LIMIT 1",
                    (charid,),
                )
                gr = cur.fetchone()
                if gr:
                    gil = gr[0]
            except Exception:
                pass

            cp_sandoria = next((c['amount'] for c in currencies if c['id'] == 'sandoria_cp'), 0)
            cp_bastok   = next((c['amount'] for c in currencies if c['id'] == 'bastok_cp'),   0)
            cp_windurst = next((c['amount'] for c in currencies if c['id'] == 'windurst_cp'), 0)
            result['private'] = {
                'gil':          gil,
                'cp_sandoria':  cp_sandoria,
                'cp_bastok':    cp_bastok,
                'cp_windurst':  cp_windurst,
            }

        return jsonify(result)

    finally:
        cur.close()
        conn.close()


@app.route('/api/character/<int:charid>/quests')
def api_character_quests(charid):
    catalog = _load_lqs_catalog()

    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute("SELECT mlvl FROM char_stats WHERE charid = ?", (charid,))
        row = cur.fetchone()
        char_level = row[0] if row else 1

        cur.execute(
            "SELECT varname, value FROM char_vars WHERE charid = ?",
            (charid,),
        )
        vars_map = {r[0]: r[1] for r in cur.fetchall()}

        regular = []
        for q in catalog['regular']:
            var_val = vars_map.get(q['var'], 0)
            steps   = q['steps']
            if steps > 0 and var_val >= steps:
                status = 'completed'
            elif var_val > 0:
                status = 'in_progress'
            elif char_level >= q['min_level']:
                status = 'available'
            else:
                status = 'not_started'
            regular.append({
                'name':   q['name'],
                'area':   q['area'],
                'status': status,
                'value':  var_val,
                'finish': steps,
            })

        dailies = []
        for q in catalog['dailies']:
            var_val = vars_map.get(q['var'], 0)
            status  = 'available' if var_val == 0 else 'in_progress'
            dailies.append({
                'name':   q['name'],
                'area':   q['area'],
                'status': status,
            })

        return jsonify(regular=regular, dailies=dailies)

    finally:
        cur.close()
        conn.close()


# ── Equipment ─────────────────────────────────────────────────────────────────

# Field names ShiningFantasia uses — tried in order for icon, description, etc.
# After running /api/sf-debug you can update these to match the actual keys.
_SF_ICON_KEYS = ['icon', 'Icon', 'iconData', 'icon_data', 'ImageData', 'image', 'img']
_SF_DESC_KEYS = ['description', 'Description', 'rawDescription', 'raw_description', 'desc', 'text', 'log_en', 'logEn']
_SF_NAME_KEYS = ['name', 'Name', 'itemName', 'item_name', 'en', 'enName', 'name_en', 'english']
_SF_LV_KEYS   = ['level', 'Level', 'lv', 'reqLevel', 'req_level', 'LevelReq', 'elvl']
_SF_JOBS_KEYS = ['jobs', 'Jobs', 'jobFlags', 'job_flags', 'usableJobs', 'JobRestrictions']
# Field names that might hold the item ID inside a bulk array/dict
_SF_ID_KEYS   = ['id', 'Id', 'ID', 'itemId', 'item_id', 'ItemId', 'itemID']

# Bulk JSON files that contain all items (large aggregates, no per-item files)
_SF_BULK_FILES = ['mydata', 'myarmor', 'armor2']

# In-memory cache: {item_id: raw_dict} populated lazily on first request.
# None = not yet attempted; {} = loaded but empty.
_sf_bulk_cache: dict | None = None


def _load_sf_bulk() -> dict:
    """Parse all bulk JSON files into a single {item_id: raw_dict} map."""
    global _sf_bulk_cache
    if _sf_bulk_cache is not None:
        return _sf_bulk_cache

    import json as _json
    _sf_bulk_cache = {}

    for fname in _SF_BULK_FILES:
        fpath = os.path.join(_SF_DIR, f'{fname}.json')
        if not os.path.isfile(fpath):
            continue
        try:
            with open(fpath, encoding='utf-8') as f:
                data = _json.load(f)

            if isinstance(data, list):
                # Array of item dicts — look for an id-like field in each
                for item in data:
                    if not isinstance(item, dict):
                        continue
                    for id_key in _SF_ID_KEYS:
                        if id_key in item:
                            try:
                                iid = int(item[id_key])
                                _sf_bulk_cache.setdefault(iid, item)
                                break
                            except (ValueError, TypeError):
                                pass

            elif isinstance(data, dict):
                # Could be {"10375": {...}, ...} or {"items": [...]}
                for k, v in data.items():
                    try:
                        iid = int(k)
                        # Top-level key is the item ID
                        if isinstance(v, dict):
                            _sf_bulk_cache.setdefault(iid, v)
                        continue
                    except (ValueError, TypeError):
                        pass
                    # Non-integer key — might be a wrapper like "items"
                    if isinstance(v, list):
                        for item in v:
                            if not isinstance(item, dict):
                                continue
                            for id_key in _SF_ID_KEYS:
                                if id_key in item:
                                    try:
                                        iid = int(item[id_key])
                                        _sf_bulk_cache.setdefault(iid, item)
                                        break
                                    except (ValueError, TypeError):
                                        pass

        except Exception as exc:
            print(f'[mimic] Failed to load {fpath}: {exc}')

    print(f'[mimic] ShiningFantasia bulk cache: {len(_sf_bulk_cache)} items from {_SF_DIR}')
    return _sf_bulk_cache


def _pick(d: dict, keys: list, default=None):
    for k in keys:
        if k in d:
            return d[k]
    return default


def _extract_icon_bytes(data: dict):
    """Return (bytes, mime_type) or (None, None) from a ShiningFantasia item dict."""
    import base64
    raw = _pick(data, _SF_ICON_KEYS)
    if not raw or not isinstance(raw, str):
        return None, None
    try:
        if raw.startswith('data:'):
            header, b64 = raw.split(',', 1)
            mime = header.split(':')[1].split(';')[0]
            return base64.b64decode(b64), mime
        else:
            return base64.b64decode(raw), 'image/png'
    except Exception:
        return None, None


def _placeholder_svg(label: str = '?') -> str:
    ch = (label[0] if label else '?').upper()
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">'
        '<rect width="64" height="64" fill="#111827" rx="6"/>'
        f'<text x="32" y="42" font-size="26" text-anchor="middle" '
        f'fill="#2d3748" font-family="sans-serif" font-weight="bold">{ch}</text>'
        '</svg>'
    )


def _sf_item_detail(item_id: int):
    """Return a normalised item dict from ShiningFantasia bulk cache, or None."""
    cache = _load_sf_bulk()
    raw = cache.get(item_id)
    if not raw:
        return None

    # englishText is a 5-element array: [display_name, count, singular, plural, stat_text]
    et = raw.get('englishText', '')
    stat_text = et[4] if isinstance(et, list) and len(et) > 4 else (et if isinstance(et, str) else '')

    return {
        'item_id':     item_id,
        'name':        et[0] if isinstance(et, list) and et else _pick(raw, _SF_NAME_KEYS, f'Item #{item_id}'),
        'description': stat_text,
        'level':       _pick(raw, _SF_LV_KEYS, 0),
        'jobs':        raw.get('jobs', ''),
        'stats':       _parse_sf_stats(stat_text),
        'sf_flags':    raw.get('flags', ''),
        'sf_ilvl':     raw.get('ilvl', 0) or raw.get('ilevel', 0),
        '_raw':        raw,
    }


_QUOTED_STAT   = re.compile(r'"([A-Za-z][^"\n]*)"(?:[^+\-\d\n]*)([+\-])(\d+(?:\.\d+)?%?)')
_INLINE_STAT   = re.compile(r'^([A-Za-z][A-Za-z .]*?)([+\-:])(\d+(?:\.\d+)?%?)$')
_BARE_SIGN     = re.compile(r'^([+\-])(\d+(?:\.\d+)?%?)$')
# A word (or phrase) followed by a bare colon and nothing else — e.g. "Assault:", "Campaign:"
_SECTION_LABEL = re.compile(r'^[A-Z][A-Za-z /]{3,}:$')

# Strip trailing quality/variant markers: "(75)", "+1", "+2 Aug" etc.
_NAME_VARIANT  = re.compile(r'\s*[\(\+].*$')


def _base_item_name(name: str) -> str:
    """Strip variant suffixes to get canonical weapon name for rarity lookup."""
    return _NAME_VARIANT.sub('', name or '').strip()


def _parse_sf_stats(text: str) -> dict:
    """Parse FFXI stat text (SF englishText[4]) into {name: value_string}.

    Three token formats:
      1. KEY:VALUE          — DEF:77, DMG:45, Delay:224
      2. KEY+/-VALUE[%]     — HP+57, Haste+3%, STR-5, Magic Evasion+63
      3. "Quoted Key"+VALUE — "Magic Def. Bonus"+2, "Store TP"+1

    ShiningFantasia stores newlines as the literal two-char sequence \\n
    (0x5c 0x6e), not as actual newline bytes — normalise first.
    Scope qualifiers (e.g. "Assault:", "Wyvern:") prefix subsequent stats
    on the same line rather than acting as section dividers.
    """
    if not text:
        return {}

    # Normalise literal escape sequences to real characters
    text = text.replace('\\n', '\n').replace('\\r', '')

    # ShiningFantasia encodes elemental magic evasion stats as \uEFxx symbols
    text = (text
        .replace('\\uEF1F', 'Fire MEVA')
        .replace('\\uEF20', 'Ice MEVA')
        .replace('\\uEF21', 'Wind MEVA')
        .replace('\\uEF22', 'Earth MEVA')
        .replace('\\uEF23', 'Thunder MEVA')
        .replace('\\uEF24', 'Water MEVA')
        .replace('\\uEF25', 'Light MEVA')
        .replace('\\uEF26', 'Dark MEVA')
    )

    stats = {}

    # Pass 1: strip and capture quoted-key stats ("Store TP"+1, "Double Attack"+2%)
    clean = _QUOTED_STAT.sub(
        lambda m: (stats.update({m.group(1).strip(): m.group(2) + m.group(3)}) or ''),
        text,
    )

    # Pass 2: line-by-line with scope-prefix accumulation
    # scope persists across lines (e.g. "Assault:" on its own line scopes subsequent lines)
    scope = ''
    for line in clean.split('\n'):
        line = line.strip()
        if not line:
            continue
        prefix = ''   # reset per line; scope carries over

        for tok in line.split():
            # Scope label: single token ending in ':' with no digit (e.g. "Assault:", "Wyvern:")
            if _SECTION_LABEL.fullmatch(tok):
                # Flush any accumulated prefix as a scoped text note
                if prefix:
                    key = f'{scope}: {prefix}' if scope else prefix
                    if key not in stats:
                        stats[key] = ''
                    prefix = ''
                scope = tok[:-1]  # strip trailing colon
                continue

            # Stat with embedded sign/colon: KEY+VALUE or KEY:VALUE
            m = _INLINE_STAT.fullmatch(tok)
            if m:
                base = (prefix + ' ' + m.group(1)).strip() if prefix else m.group(1).strip()
                key  = f'{scope}: {base}' if scope else base
                val  = m.group(3) if m.group(2) == ':' else m.group(2) + m.group(3)
                if key and key not in stats:
                    stats[key] = val
                prefix = ''
                continue

            # Bare sign immediately following an accumulated prefix: prefix +VALUE
            m2 = _BARE_SIGN.fullmatch(tok)
            if m2 and prefix:
                key = f'{scope}: {prefix}' if scope else prefix
                if key not in stats:
                    stats[key] = m2.group(1) + m2.group(2)
                prefix = ''
                continue

            # Ordinary word — accumulate into prefix
            prefix = (prefix + ' ' + tok).strip() if prefix else tok

        # Store any trailing text as a note (scoped or plain, e.g. 'Enhances X effect')
        if prefix:
            key = f'{scope}: {prefix}' if scope else prefix
            if key not in stats:
                stats[key] = ''

    return stats


def _item_rarity(name: str, su_level: int, ilevel: int, sf_flags, req_level: int) -> str:
    """Classify item rarity. Name-based sets override su_level for classic FFXI weapons."""
    base = _base_item_name(name)
    if base in _EMPYREAN_ITEM_NAMES:
        return 'empyrean'
    if base in _MYTHIC_ITEM_NAMES:
        return 'mythic'
    if base in _RELIC_ITEM_NAMES:
        return 'relic'

    flags = set(sf_flags) if isinstance(sf_flags, list) else set((sf_flags or '').split())
    if su_level >= 4:
        return 'exceptional'
    if su_level == 3:
        return 'empyrean'
    if su_level == 2:
        return 'mythic'
    if su_level == 1:
        return 'relic'
    if ilevel >= 100:
        return 'rare'
    if ilevel > 0:
        return 'uncommon'
    if 'EX' in flags:
        if req_level >= 75:
            return 'rare'
        if req_level >= 50:
            return 'uncommon'
    return 'common'


def _sf_icon_path(item_id: int):
    here = os.path.dirname(os.path.abspath(__file__))
    local = os.path.join(here, 'site', 'icons', f'{item_id}.png')
    if os.path.isfile(local):
        return local
    sf_path = os.path.join(_SF_DIR, 'icons', f'{item_id}.png')
    return sf_path if os.path.isfile(sf_path) else None


@app.route('/api/character/<int:charid>/equipment')
def api_equipment(charid):
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT ce.equipslotid, ci.itemId,"
            "  COALESCE(ie.name, ib.name) AS name,"
            "  COALESCE(ie.level, 0)      AS req_level,"
            "  COALESCE(ie.ilevel, 0)     AS ilevel,"
            "  COALESCE(ie.su_level, 0)   AS su_level,"
            "  ci.extra"
            " FROM char_equip ce"
            " INNER JOIN char_inventory ci"
            "   ON ci.charid = ce.charid"
            "   AND ci.location = ce.containerid"
            "   AND ci.slot = ce.slotid"
            " LEFT JOIN item_equipment ie ON ie.itemId = ci.itemId"
            " LEFT JOIN item_basic     ib ON ib.itemId = ci.itemId"
            " WHERE ce.charid = ? AND ce.equipslotid <= 15",
            (charid,),
        )
        rows = cur.fetchall()

        # Parse augments from extra blob.
        # Struct layout (packed, 24 bytes):
        #   byte 0:     AugmentKind flags
        #   byte 1:     AugmentSubKind flags
        #   bytes 2-11: Augments[5], each uint16 = Id(11 bits) | Value(5 bits)
        #   bytes 12-23: Signature
        slot_augs: dict[int, list[tuple[int, int]]] = {}  # slot_id → [(aug_id, aug_val), ...]
        all_aug_ids: set[int] = set()
        for r in rows:
            extra_raw = r[6]
            if extra_raw is None:
                continue
            extra_b = bytes(extra_raw) if not isinstance(extra_raw, (bytes, bytearray)) else bytes(extra_raw)
            if len(extra_b) < 4:
                continue
            pairs = []
            for i in range(5):
                offset = 2 + i * 2
                if offset + 2 > len(extra_b):
                    break
                raw16 = struct.unpack_from('<H', extra_b, offset)[0]
                aug_id  = raw16 & 0x07FF        # lower 11 bits
                aug_val = (raw16 >> 11) & 0x1F  # upper 5 bits
                if aug_id != 0:
                    pairs.append((aug_id, aug_val))
                    all_aug_ids.add(aug_id)
            if pairs:
                slot_augs[r[0]] = pairs

        # augmentId → [(multiplier, modId, base_value), ...]
        aug_mods: dict[int, list[tuple[int, int, int]]] = {}
        if all_aug_ids:
            ph = ','.join('?' * len(all_aug_ids))
            cur.execute(
                f"SELECT augmentId, multiplier, modId, value FROM augments"
                f" WHERE augmentId IN ({ph}) ORDER BY augmentId, multiplier",
                list(all_aug_ids),
            )
            for aug_id, mult, mod_id, base_val in cur.fetchall():
                aug_mods.setdefault(int(aug_id), []).append(
                    (int(mult), int(mod_id), int(base_val))
                )

    finally:
        cur.close()
        conn.close()

    def _augment_stats(slot_id: int) -> dict:
        """Return augment stats using the server's formula:
        mod_value = (base +/- aug_val) * max(multiplier, 1)"""
        combined: dict[str, int] = {}
        for aug_id, aug_val in slot_augs.get(slot_id, []):
            for mult, mod_id, base_val in aug_mods.get(aug_id, []):
                if base_val > 0:
                    mod_value = (base_val + aug_val)
                else:
                    mod_value = (base_val - aug_val)
                if mult > 1:
                    mod_value *= mult
                key = _MOD_NAMES.get(mod_id, f'Mod{mod_id}')
                combined[key] = combined.get(key, 0) + mod_value
        return {k: ('+' if v >= 0 else '') + str(v) for k, v in combined.items()}

    equipped = {
        r[0]: {
            'item_id':   r[1],
            'name':      r[2] or f'Item #{r[1]}',
            'req_level': int(r[3]),
            'ilevel':    int(r[4]),
            'su_level':  int(r[5]),
        }
        for r in rows
    }

    slots = []
    for slot_id, slot_name in _EQUIP_GRID:
        item = equipped.get(slot_id)
        sf   = _sf_item_detail(item['item_id']) if item else None

        if item:
            item_id   = item['item_id']
            item_name = (sf['name'] if sf else None) or item['name']
            aug_stats = _augment_stats(slot_id)

            if item_id in EXCEPTIONAL_ITEM_IDS:
                rarity = 'exceptional'
            else:
                rarity = _item_rarity(
                    item_name,
                    item['su_level'], item['ilevel'],
                    sf['sf_flags'] if sf else '',
                    item['req_level'],
                )

            base_stats = sf['stats'] if sf else {}
            # augments is an array so JS aggregateStats can add them to totals
            # separately from base stats (avoids double-counting).
            aug_list = [aug_stats] if aug_stats else []
        else:
            item_id = item_name = rarity = None
            base_stats = {}
            aug_list   = []

        slots.append({
            'slot_id':     slot_id,
            'slot_name':   slot_name,
            'item_id':     item_id,
            'name':        item_name,
            'req_level':   item['req_level'] if item else None,
            'ilevel':      item['ilevel']    if item else None,
            'icon_url':    f'/item-icon/{item_id}' if item else None,
            'rarity':      rarity,
            'stats':       base_stats,
            'augments':    aug_list,
            'description': '',
        })
    return jsonify({'slots': slots})


@app.route('/item-icon/<int:item_id>')
def item_icon(item_id):
    # 1 — physical PNG (SF iconTextureBase64 is a text label, not image data)
    path = _sf_icon_path(item_id)
    if path:
        return send_from_directory(os.path.dirname(path), os.path.basename(path))

    # 2 — SVG placeholder
    return _placeholder_svg(), 200, {
        'Content-Type': 'image/svg+xml',
        'Cache-Control': 'max-age=3600',
    }


@app.route('/item-data/<int:item_id>')
def item_data_route(item_id):
    """Full item detail for tooltip — ShiningFantasia JSON first, DB fallback."""
    detail = _sf_item_detail(item_id)
    if detail:
        return jsonify({
            'item_id':     detail['item_id'],
            'name':        detail['name'],
            'description': detail['description'],
            'level':       detail['level'],
            'jobs':        detail['jobs'],
        })

    # DB fallback
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT COALESCE(ie.name, ib.name), ie.level, ie.ilevel"
            " FROM item_equipment ie"
            " LEFT JOIN item_basic ib USING(itemId)"
            " WHERE ie.itemId = ?",
            (item_id,),
        )
        row = cur.fetchone()
        if not row:
            cur.execute("SELECT name FROM item_basic WHERE itemId = ?", (item_id,))
            r2 = cur.fetchone()
            return jsonify({'item_id': item_id, 'name': r2[0] if r2 else f'Item #{item_id}',
                            'description': '', 'level': 0, 'jobs': ''})
        return jsonify({'item_id': item_id, 'name': row[0], 'description': '',
                        'level': row[1], 'ilevel': row[2], 'jobs': ''})
    finally:
        cur.close()
        conn.close()


@app.route('/api/sf-debug')
def sf_debug():
    """Peek at the bulk JSON file structure (first item per file) to confirm field names."""
    import json as _json

    result = {'sf_dir': _SF_DIR, 'sf_dir_exists': os.path.isdir(_SF_DIR), 'files': {}}
    for fname in _SF_BULK_FILES:
        fpath = os.path.join(_SF_DIR, f'{fname}.json')
        if not os.path.isfile(fpath):
            result['files'][fname] = {'exists': False}
            continue
        try:
            with open(fpath, encoding='utf-8') as f:
                data = _json.load(f)

            def _sample(d):
                return {k: (f'<string len={len(v)}>' if isinstance(v, str) and len(v) > 100 else v)
                        for k, v in d.items()} if isinstance(d, dict) else str(type(d))

            if isinstance(data, list):
                first = data[0] if data else {}
                result['files'][fname] = {
                    'type': 'array', 'count': len(data),
                    'first_keys': list(first.keys()) if isinstance(first, dict) else [],
                    'first_sample': _sample(first),
                }
            elif isinstance(data, dict):
                first_k = next(iter(data), None)
                first_v = data[first_k] if first_k is not None else {}
                result['files'][fname] = {
                    'type': 'object', 'count': len(data),
                    'first_key': first_k,
                    'first_value_keys': list(first_v.keys()) if isinstance(first_v, dict) else [],
                    'first_value_sample': _sample(first_v) if isinstance(first_v, dict) else str(first_v)[:200],
                }
        except Exception as exc:
            result['files'][fname] = {'error': str(exc)}

    return jsonify(result)


@app.route('/api/item-debug/<int:item_id>')
def item_debug(item_id):
    """Return the ShiningFantasia data for one item (truncated blobs)."""
    cache = _load_sf_bulk()
    raw = cache.get(item_id)
    if not raw:
        bulk_info = []
        for fname in _SF_BULK_FILES:
            fp = os.path.join(_SF_DIR, f'{fname}.json')
            bulk_info.append({'file': fname, 'exists': os.path.isfile(fp)})
        return jsonify(
            error=f'Item {item_id} not found in ShiningFantasia bulk cache',
            sf_dir=_SF_DIR,
            sf_dir_exists=os.path.isdir(_SF_DIR),
            bulk_cache_size=len(cache),
            bulk_files=bulk_info,
        ), 404

    summary = {k: (f'<string len={len(v)}>' if isinstance(v, str) and len(v) > 120 else v)
               for k, v in raw.items()}
    return jsonify({'item_id': item_id, 'keys': list(raw.keys()), 'values': summary})


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5000
    print(f'[mimic] ShiningFantasia path: {_SF_DIR} (exists: {os.path.isdir(_SF_DIR)})')
    app.run(debug=False, host='0.0.0.0', port=port)
