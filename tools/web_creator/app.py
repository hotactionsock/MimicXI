#!/usr/bin/env python3
import os
import random
import re
import secrets
import sys
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


# ── Routes ────────────────────────────────────────────────────────────────────


def _check_credentials(username, password):
    """Return account row if credentials are valid, else None."""
    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT id, password FROM accounts WHERE login = ? AND status > 0",
            (username,),
        )
        row = cur.fetchone()
    finally:
        cur.close()
        conn.close()
    if row and bcrypt.checkpw(password.encode(), row[1].encode()):
        return row
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
            session['accid']    = row[0]
            session['username'] = username
            print(f'[mimic] login ok: accid={row[0]} username={username!r}')
            if request.is_json:
                return jsonify(accid=row[0], username=username), 200
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
        session['accid']    = row[0]
        session['username'] = username
        print(f'[mimic] /api/login ok: accid={row[0]} username={username!r}')
        return jsonify(accid=row[0], username=username), 200

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
    )


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

        # Job levels
        col_list = ','.join(c for c,_,_ in _JOB_COLS)
        cur.execute(f"SELECT {col_list} FROM char_jobs WHERE charid = ?", (charid,))
        jobs_row = cur.fetchone() or ([0] * len(_JOB_COLS))
        jobs = [
            {'col': col, 'name': name_, 'abbr': abbr, 'level': lvl}
            for (col, name_, abbr), lvl in zip(_JOB_COLS, jobs_row)
        ]

        # Fame and nation rank
        cur.execute(
            "SELECT rank_sandoria, rank_bastok, rank_windurst,"
            "  fame_sandoria, fame_bastok, fame_windurst,"
            "  fame_norg, fame_jeuno, fame_adoulin"
            " FROM char_profile WHERE charid = ?",
            (charid,),
        )
        prof = cur.fetchone()
        ranks = {}
        fame  = {}
        if prof:
            ranks = {'sandoria': prof[0], 'bastok': prof[1], 'windurst': prof[2]}
            for i, (key, label) in enumerate(_FAME_FIELDS):
                val = prof[3 + i]
                fame[key] = {'label': label, 'value': val, 'tier': _fame_tier(val)}

        result = {
            'charid':          cid,
            'name':            name,
            'nation':          nation,
            'nation_name':     NATIONS.get(nation, f'Nation {nation}'),
            'race_name':       ' '.join(p for p in RACES.get(race, ('?', '')) if p).strip(),
            'size':            SIZES.get(size, ''),
            'face_label':      _face_label(face),
            'playtime_hours':  (playtime or 0) // 3600,
            'playtime_mins':   ((playtime or 0) % 3600) // 60,
            'main_job':        _JOB_BY_ID.get(mjob_id, '???'),
            'main_job_level':  mlvl,
            'sub_job':         _JOB_BY_ID.get(sjob_id) if sjob_id else None,
            'sub_job_level':   slvl if sjob_id else None,
            'jobs':            jobs,
            'ranks':           ranks,
            'fame':            fame,
            'is_owner':        is_owner,
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

            cur.execute(
                "SELECT sandoria_cp, bastok_cp, windurst_cp"
                " FROM char_points WHERE charid = ?",
                (charid,),
            )
            cp = cur.fetchone()
            result['private'] = {
                'gil': gil,
                'conquest_points': {
                    'sandoria': cp[0] if cp else 0,
                    'bastok':   cp[1] if cp else 0,
                    'windurst': cp[2] if cp else 0,
                },
            }

        return jsonify(result)

    finally:
        cur.close()
        conn.close()


# ── Equipment ─────────────────────────────────────────────────────────────────

def _sf_icon_path(item_id: int):
    """Try common ShiningFantasia icon export path patterns."""
    candidates = [
        os.path.join(_SF_DIR, 'items', 'icons', f'{item_id}.png'),
        os.path.join(_SF_DIR, 'icons',           f'{item_id}.png'),
        os.path.join(_SF_DIR, 'items',            f'{item_id}.png'),
        os.path.join(_SF_DIR,                     f'{item_id}.png'),
        os.path.join(_SF_DIR, 'items', 'icons', f'{item_id:05d}.png'),
        os.path.join(_SF_DIR,                   f'{item_id:05d}.png'),
    ]
    for p in candidates:
        if os.path.isfile(p):
            return p
    return None


def _sf_json_path(item_id: int):
    candidates = [
        os.path.join(_SF_DIR, 'items', f'{item_id}.json'),
        os.path.join(_SF_DIR,          f'{item_id}.json'),
        os.path.join(_SF_DIR, 'items', f'{item_id:05d}.json'),
    ]
    for p in candidates:
        if os.path.isfile(p):
            return p
    return None


def _placeholder_svg(label: str) -> str:
    ch = (label[0] if label else '?').upper()
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">'
        '<rect width="64" height="64" fill="#111827" rx="6"/>'
        f'<text x="32" y="42" font-size="26" text-anchor="middle" '
        f'fill="#2d3748" font-family="sans-serif" font-weight="bold">{ch}</text>'
        '</svg>'
    )


@app.route('/api/character/<int:charid>/equipment')
def api_equipment(charid):
    conn = get_connection()
    cur  = conn.cursor()
    try:
        # Join char_equip → char_inventory → item data
        cur.execute(
            "SELECT ce.equipslotid, ci.itemId,"
            "  COALESCE(ie.name, ib.name) AS name,"
            "  COALESCE(ie.level, 0)      AS req_level,"
            "  COALESCE(ie.ilevel, 0)     AS ilevel"
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
    finally:
        cur.close()
        conn.close()

    equipped = {r[0]: {'item_id': r[1], 'name': r[2] or f'Item #{r[1]}',
                        'req_level': r[3], 'ilevel': r[4]} for r in rows}

    slots = []
    for slot_id, slot_name in _EQUIP_GRID:
        item = equipped.get(slot_id)
        slots.append({
            'slot_id':   slot_id,
            'slot_name': slot_name,
            'item_id':   item['item_id']   if item else None,
            'name':      item['name']      if item else None,
            'req_level': item['req_level'] if item else None,
            'ilevel':    item['ilevel']    if item else None,
        })

    return jsonify(slots)


@app.route('/item-icon/<int:item_id>')
def item_icon(item_id):
    path = _sf_icon_path(item_id)
    if path:
        return send_from_directory(os.path.dirname(path), os.path.basename(path))
    # Fallback: named placeholder SVG
    slot_name = next((s for _, s in _EQUIP_GRID), '?')
    return _placeholder_svg('?'), 200, {'Content-Type': 'image/svg+xml', 'Cache-Control': 'max-age=3600'}


@app.route('/item-data/<int:item_id>')
def item_data_route(item_id):
    """Return item detail JSON — ShiningFantasia file first, DB fallback."""
    import json as _json
    sf_path = _sf_json_path(item_id)
    if sf_path:
        with open(sf_path, encoding='utf-8') as f:
            return jsonify(_json.load(f))

    conn = get_connection()
    cur  = conn.cursor()
    try:
        cur.execute(
            "SELECT COALESCE(ie.name, ib.name), ie.level, ie.ilevel, ie.jobs"
            " FROM item_equipment ie"
            " LEFT JOIN item_basic ib USING(itemId)"
            " WHERE ie.itemId = ?",
            (item_id,),
        )
        row = cur.fetchone()
        if not row:
            cur.execute("SELECT name FROM item_basic WHERE itemId = ?", (item_id,))
            row2 = cur.fetchone()
            return jsonify({'name': row2[0] if row2 else f'Item #{item_id}'})
        return jsonify({'name': row[0], 'req_level': row[1], 'ilevel': row[2], 'jobs_mask': row[3]})
    finally:
        cur.close()
        conn.close()


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5000
    print(f'[mimic] ShiningFantasia path: {_SF_DIR} (exists: {os.path.isdir(_SF_DIR)})')
    app.run(debug=True, host='127.0.0.1', port=port)
