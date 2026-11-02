"""World bots on the website: who they are, what they're doing right now, and
their life story, read from the bots' activity log (world_bot_log - see
src/map/utils/botlog.h in the game server).

Pages (public) - the public site's bots.html / bot.html (site/), built on the
JSON below; the old /bots URLs redirect there:
    /bots.html              every bot, with what it's doing now, and a live feed
    /bot.html?id=<charid>   one bot: profile, status, stats and its timeline

JSON (public, read-only):
    /api/bots                       every bot with its status line
    /api/bots/<charid>              profile, status, stats and recent events
    /api/bots/<charid>/events       events, newest first (?limit, ?before, ?since, ?category)
    /api/bots/feed                  latest events across all bots, with names (?since=<id>, ?limit)

Every log row already carries a ready-to-show sentence; this module adds the
"what is it doing now" status, worked out from the latest events.
"""

import json
import time

from flask import Blueprint, abort, jsonify, redirect, request

from db import get_connection

bots = Blueprint('bots', __name__)

JOB_NAMES = [
    '', 'Warrior', 'Monk', 'White Mage', 'Black Mage', 'Red Mage', 'Thief', 'Paladin', 'Dark Knight',
    'Beastmaster', 'Bard', 'Ranger', 'Samurai', 'Ninja', 'Dragoon', 'Summoner', 'Blue Mage', 'Corsair',
    'Puppetmaster', 'Dancer', 'Scholar', 'Geomancer', 'Rune Fencer',
]
JOB_ABBR = [
    '', 'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 'SAM', 'NIN', 'DRG',
    'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN',
]
JOB_COLUMNS = [
    'war', 'mnk', 'whm', 'blm', 'rdm', 'thf', 'pld', 'drk', 'bst', 'brd', 'rng', 'sam', 'nin', 'drg',
    'smn', 'blu', 'cor', 'pup', 'dnc', 'sch', 'geo', 'run',
]

# An event older than this no longer counts as "right now".
STALE_AFTER_SEC = 2 * 60 * 60

# Events that say what a bot is doing, and how to phrase them as a status.
# {zone} is filled from the event's data.
STATUS_TEMPLATES = {
    'goal_level':   'Heading to {zone} to train',
    'goal_home':    'Heading home to {zone}',
    'goal_zone':    'Travelling to {zone}',
    'goal_sell':    'Heading to {zone} to sell loot',
    'goal_jobs':    'Heading to {zone} to change jobs',
    'goal_party':   'On the way to meet their party in {zone}',
    'arrived':      'In {zone}',
    'hunt_summary': 'Training in {zone}',
    'died':         'Recovering from a defeat in {zone}',
    'joined':       'Training with a party',
    'formed':       'Leading a party',
    'left':         'Back on their own',
    'changed_job':  'Getting used to a new job',
    'hired':        'Adventuring with {player}',
    'nm_camp':      'Hunting the notorious {nm} in {zone}',
    'nm_defeated':  'Just defeated the notorious {nm}',
    'goal_shop':    'Heading to {zone} to go shopping',
    'goal_nm':      'On the way to {zone} to hunt a notorious monster',
    'bought':       'Shopping in town',
    'dismissed':    'Back on their own',
    'left_for_player': 'Joining a player\'s party',
    'sold':         'Selling loot in town',
    'created':      'Just starting out in {zone}',
}


def _job(job_id):
    return JOB_NAMES[job_id] if 0 <= (job_id or 0) < len(JOB_NAMES) else ''


def _abbr(job_id):
    return JOB_ABBR[job_id] if 0 <= (job_id or 0) < len(JOB_ABBR) else ''


def _zone_name(raw):
    return (raw or 'Unknown').replace('_', ' ')


def _event_row(row):
    """(id, charid, ts, zone_id, category, event, message, data[, charname]) -> dict"""
    try:
        data = json.loads(row[7]) if row[7] else {}
    except ValueError:
        data = {}

    event = {
        'id':       row[0],
        'charid':   row[1],
        'ts':       row[2],
        'zone_id':  row[3],
        'category': row[4],
        'event':    row[5],
        'message':  row[6],
        'data':     data,
    }
    if len(row) > 8:
        event['name'] = row[8]
    return event


def describe_now(events, now=None):
    """What a bot is doing, from its latest events (newest first).

    Returns {'text', 'since', 'stale'}: the first event that says what it's up
    to, phrased as a status. An arrival right after setting off to train there
    reads as training; anything older than STALE_AFTER_SEC is marked stale
    (the bot may be parked or the server down).
    """
    now = now or int(time.time())
    for index, e in enumerate(events):
        template = STATUS_TEMPLATES.get(e['event'])
        if template is None:
            continue

        zone = e['data'].get('zone') or 'somewhere'
        text = template.format(zone=zone, player=e['data'].get('player') or 'a player', nm=e['data'].get('nm') or 'monster')

        # "In Valkurm Dunes" after "set off for Valkurm Dunes to train" = training there.
        if e['event'] == 'arrived':
            for older in events[index + 1:]:
                if older['event'].startswith('goal_'):
                    if older['event'] == 'goal_level' and older['data'].get('zone_id') == e['data'].get('zone_id'):
                        text = 'Training in {}'.format(zone)
                    break

        return {'text': text, 'since': e['ts'], 'stale': now - e['ts'] > STALE_AFTER_SEC}

    return {'text': 'No activity recorded yet', 'since': None, 'stale': True}


def _fetch_events(cur, charid=None, limit=50, before=None, category=None, since=None):
    sql = (
        'SELECT l.id, l.charid, l.ts, l.zone_id, l.category, l.event, l.message, l.data, c.charname'
        ' FROM world_bot_log l LEFT JOIN chars c ON c.charid = l.charid WHERE 1=1'
    )
    params = []
    if charid is not None:
        sql += ' AND l.charid = ?'
        params.append(charid)
    if before:
        sql += ' AND l.id < ?'
        params.append(before)
    if since:
        sql += ' AND l.id > ?'
        params.append(since)
    if category:
        sql += ' AND l.category = ?'
        params.append(category)

    sql += ' ORDER BY l.id DESC LIMIT ?'
    params.append(max(1, min(int(limit), 200)))

    cur.execute(sql, tuple(params))
    return [_event_row(r) for r in cur.fetchall()]


def _bot_profiles(cur, charid=None):
    sql = (
        'SELECT c.charid, c.charname, c.nation, cs.mjob, cs.sjob, cs.mlvl, cs.slvl, z.name, w.active, w.career_job,'
        ' (s.charid IS NOT NULL) AS online, cl.race, cl.face'
        ' FROM world_bots w'
        ' INNER JOIN chars c ON c.charid = w.charid'
        ' LEFT JOIN char_stats cs ON cs.charid = w.charid'
        ' LEFT JOIN char_look cl ON cl.charid = w.charid'
        ' LEFT JOIN zone_settings z ON z.zoneid = c.pos_zone'
        ' LEFT JOIN accounts_sessions s ON s.charid = w.charid'
    )
    params = ()
    if charid is not None:
        sql += ' WHERE w.charid = ?'
        params = (charid,)

    sql += ' ORDER BY c.charname'
    cur.execute(sql, params)

    profiles = []
    for r in cur.fetchall():
        profiles.append({
            'charid':     r[0],
            'name':       r[1],
            'nation':     ["San d'Oria", 'Bastok', 'Windurst'][r[2]] if r[2] in (0, 1, 2) else '',
            'main_job':   _job(r[3]),
            'main_abbr':  _abbr(r[3]),
            'sub_job':    _job(r[4]),
            'sub_abbr':   _abbr(r[4]),
            'main_level': r[5] or 0,
            'sub_level':  r[6] or 0,
            'zone':       _zone_name(r[7]),
            'active':     bool(r[8]),
            'career':     _job(r[9]),
            'online':     bool(r[10]),
            'race':       r[11],
            'face':       r[12],
        })

    return profiles


def _latest_events_by_bot(cur, per_bot=12):
    """Each bot's latest few events, for status lines in the list view."""
    cur.execute(
        'SELECT id, charid, ts, zone_id, category, event, message, data FROM ('
        '  SELECT l.*, ROW_NUMBER() OVER (PARTITION BY charid ORDER BY id DESC) AS rn FROM world_bot_log l'
        ') t WHERE rn <= ? ORDER BY charid, id DESC',
        (per_bot,),
    )
    result = {}
    for r in cur.fetchall():
        result.setdefault(r[1], []).append(_event_row(r))
    return result


def _job_levels(cur, charid):
    cur.execute('SELECT {} FROM char_jobs WHERE charid = ?'.format(', '.join('`{}`'.format(c) for c in JOB_COLUMNS)), (charid,))
    row = cur.fetchone()
    if not row:
        return []
    return [{'job': JOB_NAMES[i + 1], 'abbr': JOB_ABBR[i + 1], 'level': lvl} for i, lvl in enumerate(row) if lvl]


def _stats(cur, charid):
    """Lifetime totals worked out from the log."""
    cur.execute(
        'SELECT'
        "  SUM(event = 'level_up'),"
        "  SUM(event = 'died'),"
        "  SUM(event = 'obtained'),"
        "  SUM(event = 'learned_spell'),"
        "  COALESCE(SUM(CASE WHEN event = 'hunt_summary' THEN JSON_VALUE(data, '$.kills') END), 0),"
        "  COALESCE(SUM(CASE WHEN event = 'hunt_summary' THEN JSON_VALUE(data, '$.exp') END), 0),"
        "  COALESCE(SUM(CASE WHEN event = 'sold' THEN JSON_VALUE(data, '$.gil') END), 0),"
        "  SUM(event = 'joined' OR event = 'formed'),"
        '  MIN(ts)'
        ' FROM world_bot_log WHERE charid = ?',
        (charid,),
    )
    r = cur.fetchone() or [0] * 9
    return {
        'level_ups':       int(r[0] or 0),
        'deaths':          int(r[1] or 0),
        'items_obtained':  int(r[2] or 0),
        'spells_learned':  int(r[3] or 0),
        'monsters_defeated': int(r[4] or 0),
        'exp_earned':      int(r[5] or 0),
        'gil_from_sales':  int(r[6] or 0),
        'parties':         int(r[7] or 0),
        'first_seen':      r[8],
    }


def _with_connection(fn):
    conn = get_connection()
    cur  = conn.cursor()
    try:
        return fn(cur)
    finally:
        cur.close()
        conn.close()


def _all_bots(cur):
    profiles = _bot_profiles(cur)
    latest   = _latest_events_by_bot(cur)
    for p in profiles:
        events      = latest.get(p['charid'], [])
        p['status'] = describe_now(events)
        p['latest'] = events[0]['message'] if events else None
    return profiles


def _one_bot(cur, charid):
    profiles = _bot_profiles(cur, charid)
    if not profiles:
        return None

    bot           = profiles[0]
    events        = _fetch_events(cur, charid=charid, limit=50)
    bot['status'] = describe_now(events)
    bot['jobs']   = _job_levels(cur, charid)
    bot['stats']  = _stats(cur, charid)
    bot['events'] = events
    return bot


# ── JSON ─────────────────────────────────────────────────────────────────────

@bots.route('/api/bots')
def api_bots():
    return jsonify({'bots': _with_connection(_all_bots)})


@bots.route('/api/bots/feed')
def api_bots_feed():
    since = request.args.get('since', type=int)
    limit = request.args.get('limit', default=50, type=int)
    return jsonify({'events': _with_connection(lambda cur: _fetch_events(cur, limit=limit, since=since))})


@bots.route('/api/bots/<int:charid>')
def api_bot(charid):
    bot = _with_connection(lambda cur: _one_bot(cur, charid))
    if bot is None:
        abort(404)
    return jsonify(bot)


@bots.route('/api/bots/<int:charid>/events')
def api_bot_events(charid):
    args = request.args
    events = _with_connection(lambda cur: _fetch_events(
        cur, charid=charid,
        limit=args.get('limit', default=50, type=int),
        before=args.get('before', type=int),
        since=args.get('since', type=int),
        category=args.get('category') or None,
    ))
    return jsonify({'events': events})


# ── Pages ────────────────────────────────────────────────────────────────────

# The pages live on the public site (site/bots.html, site/bot.html); these
# keep the old URLs working.

@bots.route('/bots')
def bots_page():
    return redirect('/bots.html')


@bots.route('/bots/<int:charid>')
def bot_page(charid):
    return redirect('/bot.html?id={}'.format(charid))
