# Paste these into web_creator/app.py to enable website registration.
#
# Imports already present in app.py: bcrypt, jsonify, request, session
# You may also need: from datetime import datetime
#
# Matches the actual schema in uploads/accounts.sql:
#   accounts(id, login, password, current_email, registration_email,
#            timecreate, timelastmodify, content_ids, expansions, features,
#            status, priv)
#
# Notes:
#   * `id` is NOT auto-increment in this schema, so we compute the next id
#     ourselves (same pattern as the `chars` table in /create).
#   * Passwords are bcrypt hashes (60 chars). The column is varchar(64).
#   * status=1 (active), priv=1 (player), expansions=4094, features=253,
#     content_ids=16 — all left at their schema defaults; we set them
#     explicitly here to be safe across MariaDB strict modes.

import re
from datetime import datetime


@app.route('/api/register', methods=['POST'])
def api_register():
    data = request.get_json(force=True, silent=True) or {}
    username = str(data.get('username', '')).strip()
    password = str(data.get('password', ''))
    email    = str(data.get('email', '')).strip()

    # Validation — keep these in sync with signin.html's client checks.
    if not re.fullmatch(r'[A-Za-z0-9]{3,15}', username):
        return jsonify(error='Account name must be 3–15 letters or numbers.'), 400
    if len(password) < 8:
        return jsonify(error='Password must be at least 8 characters.'), 400
    if email and not re.fullmatch(r'[^@\s]+@[^@\s]+\.[^@\s]+', email):
        return jsonify(error='Email address looks invalid.'), 400

    pw_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

    conn = get_connection()
    cur = conn.cursor()
    try:
        # Unique login check
        cur.execute("SELECT id FROM accounts WHERE login = ?", (username,))
        if cur.fetchone():
            return jsonify(error='That account name is already taken.'), 409

        # Allocate next id manually (schema has no AUTO_INCREMENT)
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

        # Log the new account in straight away.
        session['accid']    = new_id
        session['username'] = username
        return jsonify(accid=new_id, username=username), 201

    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        cur.close()
        conn.close()


# ── (optional) JSON session info endpoint ────────────────────────────
# Useful if you want a cheap auth check that doesn't pull the character
# list. The website doesn't strictly need it, but it's handy.

@app.route('/api/session')
def api_session():
    if 'accid' not in session:
        return jsonify(authenticated=False), 200
    return jsonify(
        authenticated=True,
        accid=session['accid'],
        username=session.get('username'),
    )
