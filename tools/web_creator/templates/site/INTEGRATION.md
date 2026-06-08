# MimicXI Website × Character Creator — Integration Guide

The `site/` folder is a static HTML site. The character creator pages
(`signin.html`, `account.html`, `create-character.html`) talk to your
existing Flask app (`web_creator/app.py`) over HTTP using the session
cookie that Flask already issues.

You have two options for wiring this up — pick one.

---

## Option A — Serve the static site through Flask (simplest)

This is recommended. Everything ends up same-origin, so cookies, CSRF
and CORS all just work.

1. Copy the contents of `site/` into a folder beside `web_creator/app.py`,
   e.g. `web_creator/public/`.

2. Add this to the bottom of `app.py` (above the `if __name__ == '__main__':`
   block), or wherever you keep your routes:

   ```python
   from flask import send_from_directory

   PUBLIC_DIR = os.path.join(os.path.dirname(__file__), 'public')

   @app.route('/site/<path:filename>')
   def public(filename):
       return send_from_directory(PUBLIC_DIR, filename)

   @app.route('/')
   def home():
       # Override the existing index() to land on the marketing home.
       return send_from_directory(PUBLIC_DIR, 'index.html')
   ```

   (If you keep the existing `/` -> redirect-to-characters behaviour,
   just point users at `/site/index.html` instead.)

3. In each of the three account pages, `window.MIMIC_API_BASE` is already
   set to `""` (same-origin). Nothing to change.

4. Start Flask. Hit `http://127.0.0.1:5000/site/index.html`. Sign in works
   against your existing `/login` endpoint.

---

## Option B — Static site served separately (e.g. nginx, Pages)

If the marketing site is hosted elsewhere and only the Flask app handles
auth/characters, you'll need two things:

1. **Set the API base** in each account page. Edit the
   `<script>window.MIMIC_API_BASE = "";</script>` line near the top of
   `signin.html`, `account.html`, and `create-character.html`:

   ```html
   <script>window.MIMIC_API_BASE = "http://127.0.0.1:5000";</script>
   ```

2. **Enable CORS with credentials** in Flask. Install flask-cors:

   ```
   pip install flask-cors
   ```

   Then at the top of `app.py`:

   ```python
   from flask_cors import CORS
   CORS(app,
        supports_credentials=True,
        origins=["http://localhost:8000", "https://yourdomain.com"])
   ```

   Adjust `origins` to wherever the static site is served from.

3. **Cookie SameSite**: when the API is on a different origin, modern
   browsers require `SameSite=None; Secure` for cookies to be sent
   cross-origin. Add to `app.py` after the secret-key block:

   ```python
   app.config.update(
       SESSION_COOKIE_SAMESITE='None',
       SESSION_COOKIE_SECURE=True,    # requires HTTPS in production
   )
   ```

   For local development without HTTPS, you can leave `SECURE` False and
   keep `SameSite='Lax'` — but you must then run BOTH services on
   `localhost` (not 127.0.0.1 vs localhost — they count as different
   origins for cookies).

---

## Adding a registration endpoint

The current `app.py` doesn't have a `/api/register` route — the signin
page will surface a "registration isn't enabled" message if you try it.
To allow registering through the website, paste the snippet from
`site/flask-additions.py` into `app.py` (anywhere alongside the other
routes). It:

* validates account name (3–15 alphanumeric)
* validates password (8+ chars)
* bcrypt-hashes the password using the same parameters as `/login`
* inserts into `accounts` with `status = 1`
* logs the user in (sets `session['accid']`) so they land in the account
  hub straight away

The snippet is written to match the **actual LSB `accounts` schema**
(from `uploads/accounts.sql`):

| Column | Notes |
|---|---|
| `id` | NOT auto-increment — `flask-additions.py` computes the next id via `MAX(id)+1`, same pattern the existing `chars` table uses. |
| `login` | unique account name (3–15) |
| `password` | bcrypt hash, fits in `varchar(64)` |
| `current_email` / `registration_email` | both populated from the form's email field |
| `timecreate` / `timelastmodify` | set to `NOW()` explicitly |
| `status=1`, `priv=1`, `content_ids=16`, `expansions=4094`, `features=253` | written explicitly for safety under strict MariaDB modes |

---

## Database connection

Connection settings are read from `settings/network.lua` by `db.py`
(the loader walks two directories up from `web_creator/`, which is
where LSB keeps it). The values shown to me match what's expected:

```
SQL_HOST     = '127.0.0.1'
SQL_PORT     = 3308
SQL_LOGIN    = 'root'
SQL_PASSWORD = 'serious1'
SQL_DATABASE = 'xidb'
```

As long as `network.lua` lives at `../../settings/network.lua` relative
to `web_creator/app.py` (the default for an LSB checkout), no
configuration is needed — `db.py` will pick it up. To override the
location, set the `MIMIC_NETWORK_LUA` environment variable to the full
path before starting Flask:

```bash
# Windows (PowerShell)
$env:MIMIC_NETWORK_LUA = "C:\path\to\settings\network.lua"
python app.py

# macOS / Linux
MIMIC_NETWORK_LUA=/path/to/settings/network.lua python app.py
```

---

## Files

| File | Purpose |
|---|---|
| `signin.html` | Tabbed sign-in / register form. Posts to `/login` (form-encoded) and `/api/register` (JSON). |
| `account.html` | Character list. Calls `GET /api/characters`. Redirects to signin on 401. |
| `create-character.html` | Character creator. Calls `POST /api/create`. Light-theme port of the React version. |
| `auth.js` | Shared `MimicAuth` helper — wraps fetch with `credentials:'include'`. |
| `account.css` | Form, race-grid, face-grid, character-card styles. |
| `shell.js` | Site-wide header/footer. Auto-flips "Sign in" / "Account" based on `localStorage.mimic_username`. |

## Notes

* The `Sign in` / `Account` swap in the header is driven by
  `localStorage.mimic_username` — set on successful login, cleared on
  logout. This is purely cosmetic. The real source of truth is always
  the Flask session cookie.
* On logout, `auth.js` POSTs to `/logout` and then clears the local hint.
* The face-value encoding matches `web_creator/app.py` (A = `(n-1)*2`,
  B = `(n-1)*2+1`, C = `n+15`).
