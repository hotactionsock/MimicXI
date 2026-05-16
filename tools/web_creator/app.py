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


# ── Routes ────────────────────────────────────────────────────────────────────


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')

        if not username or not password:
            flash('Username and password are required.', 'error')
            return render_template('login.html')

        conn = get_connection()
        cur = conn.cursor()
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
            session['accid'] = row[0]
            session['username'] = username
            return redirect(url_for('characters'))

        flash('Invalid username or password.', 'error')

    return render_template('login.html')


@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
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


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5000
    app.run(debug=True, host='127.0.0.1', port=port)
