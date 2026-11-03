"""World bots on the website: who they are, what they're doing right now, and
their life story, read from the bots' activity log (world_bot_log - see
src/map/utils/botlog.h in the game server).

Pages (public) - the public site's bots.html / bot.html (site/), built on the
JSON below; the old /bots URLs redirect there:
    /bots.html              every bot, with what it's doing now, and a live feed
    /bot.html?id=<charid>   one bot: profile, status, stats and its timeline
    /leaderboards.html      the top bots by level, kills, EXP, notorious monsters and more

JSON (public, read-only):
    /api/bots                       every bot with its status line
    /api/bots/<charid>              profile, status, stats, title, achievements and recent events
    /api/bots/<charid>/events       events, newest first (?limit, ?before, ?since, ?category)
    /api/bots/feed                  latest events across all bots, with names (?since=<id>, ?limit)
    /api/bots/leaderboards          top bots by level, kills, EXP, NMs, achievements, defeats... (?period=all|week, ?limit)

Every log row already carries a ready-to-show sentence; this module adds the
"what is it doing now" status, worked out from the latest events, and titles
and achievements (ACHIEVEMENTS) worked out from the whole log.
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
    'goal_logoff':  'Heading home to {zone} to log off',
    'logged_off':   'Logged off',
    'logged_on':    'Just logged on',
    'warp':         'Warping to {to}',
    'raised':       'Back on their feet after a raise',
}

# Achievements, worked out from the log and the character's job levels.
# Listed least to most prestigious: a bot's title is the last one it has.
# Each test takes the counts from _achievement_counts.
ACHIEVEMENTS = [
    ('first_steps',  'First Steps',           'the Fledgling',         'Reached level 10',                         lambda c: c['max_level'] >= 10),
    ('resilient',    'Back on Their Feet',    'the Resilient',         'Was raised by a party member',             lambda c: c['raised'] >= 1),
    ('seasoned',     'Seasoned',              'the Seasoned',          'Reached level 30',                         lambda c: c['max_level'] >= 30),
    ('companion',    'Hired Hand',            'the Companion',         'Adventured in a player\'s party',          lambda c: c['hired'] >= 1),
    ('team_player',  'Team Player',           'the Team Player',       'Took part in 25 parties',                  lambda c: c['parties'] >= 25),
    ('globetrotter', 'Globetrotter',          'the Globetrotter',      'Set foot in 30 different areas',           lambda c: c['zones'] >= 30),
    ('slayer',       'Slayer',                'the Slayer',            'Defeated 1,000 monsters',                  lambda c: c['kills'] >= 1000),
    ('nm_hunter',    'Notorious Hunter',      'the Notorious Hunter',  'Defeated a notorious monster',             lambda c: c['nm_defeated'] >= 1),
    ('veteran',      'Veteran',               'the Veteran',           'Reached level 50',                         lambda c: c['max_level'] >= 50),
    ('jack',         'Jack of All Trades',    'the Jack of All Trades', 'Levelled three jobs to 30',               lambda c: c['jobs_30'] >= 3),
    ('gilded',       'Gilded',                'the Gilded',            'Opened a gold treasure casket',            lambda c: c['gold_caskets'] >= 1),
    ('unbroken',     'Unbroken',              'the Unbroken',          'Reached level 50 with fewer than 10 defeats', lambda c: c['max_level'] >= 50 and c['deaths'] < 10),
    ('exterminator', 'Exterminator',          'the Exterminator',      'Defeated 10,000 monsters',                 lambda c: c['kills'] >= 10000),
    ('bane',         'Bane of the Notorious', 'Bane of the Notorious', 'Defeated 10 notorious monsters',           lambda c: c['nm_defeated'] >= 10),
    ('elite',        'Elite',                 'the Elite',             'Reached level 75',                         lambda c: c['max_level'] >= 75),
    ('master',       'Master',                'the Master',            'Reached level 99',                         lambda c: c['max_level'] >= 99),
]


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
        text = template.format(zone=zone, player=e['data'].get('player') or 'a player', nm=e['data'].get('nm') or 'monster',
                               to=e['data'].get('to') or 'somewhere')

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


def _achievement_counts(cur, charid=None):
    """{charid: counts} for the achievement tests: totals from the log plus
    the highest job level and how many jobs are at 30+."""
    where  = ' WHERE charid = ?' if charid is not None else ''
    params = (charid,) if charid is not None else ()

    cur.execute(
        'SELECT charid,'
        "  SUM(event = 'died'),"
        "  COALESCE(SUM(CASE WHEN event = 'hunt_summary' THEN JSON_VALUE(data, '$.kills') END), 0),"
        "  SUM(event = 'nm_defeated'),"
        "  SUM(event = 'casket' AND JSON_VALUE(data, '$.chest') = 4),"
        "  COUNT(DISTINCT CASE WHEN event = 'arrived' THEN JSON_VALUE(data, '$.zone_id') END),"
        "  SUM(event = 'hired'),"
        "  SUM(event = 'joined' OR event = 'formed'),"
        "  SUM(event = 'raised')"
        ' FROM world_bot_log' + where + ' GROUP BY charid',
        params,
    )
    counts = {}
    for r in cur.fetchall():
        counts[r[0]] = {
            'deaths':       int(r[1] or 0),
            'kills':        int(r[2] or 0),
            'nm_defeated':  int(r[3] or 0),
            'gold_caskets': int(r[4] or 0),
            'zones':        int(r[5] or 0),
            'hired':        int(r[6] or 0),
            'parties':      int(r[7] or 0),
            'raised':       int(r[8] or 0),
        }

    cur.execute(
        'SELECT j.charid, {} FROM char_jobs j INNER JOIN world_bots w ON w.charid = j.charid'.format(
            ', '.join('j.`{}`'.format(c) for c in JOB_COLUMNS)) + (' WHERE j.charid = ?' if charid is not None else ''),
        params,
    )
    for r in cur.fetchall():
        levels = [lvl or 0 for lvl in r[1:]]
        c = counts.setdefault(r[0], {
            'deaths': 0, 'kills': 0, 'nm_defeated': 0, 'gold_caskets': 0, 'zones': 0, 'hired': 0, 'parties': 0, 'raised': 0,
        })
        c['max_level'] = max(levels) if levels else 0
        c['jobs_30']   = sum(1 for lvl in levels if lvl >= 30)

    for c in counts.values():
        c.setdefault('max_level', 0)
        c.setdefault('jobs_30', 0)

    return counts


def achievements_for(counts):
    """(title, [achievement]) for one bot's counts. title is None until it
    has earned something."""
    result, title = [], None
    for key, name, achievement_title, description, test in ACHIEVEMENTS:
        earned = bool(counts) and test(counts)
        if earned:
            title = achievement_title
        result.append({'key': key, 'name': name, 'title': achievement_title, 'description': description, 'earned': earned})
    return title, result


# Leaderboards: (key, label, unit). 'level' (all time) and 'levels_gained'
# (a week) are the headline board; the rest count log events in the period.
LEADERBOARDS_ALL = [
    ('level',        'Highest level',                'level'),
    ('achievements', 'Most achievements',            'achievements'),
    ('kills',        'Monsters defeated',            'monsters'),
    ('exp',          'EXP earned',                   'EXP'),
    ('nm_defeated',  'Notorious monsters defeated',  'NMs'),
    ('zones',        'Areas explored',               'areas'),
    ('gold_caskets', 'Gold caskets opened',          'caskets'),
    ('parties',      'Parties joined',               'parties'),
    ('deaths',       'Most defeats',                 'defeats'),
]
LEADERBOARDS_WEEK = [
    ('levels_gained', 'Levels gained',               'levels'),
    ('kills',         'Monsters defeated',           'monsters'),
    ('exp',           'EXP earned',                  'EXP'),
    ('nm_defeated',   'Notorious monsters defeated', 'NMs'),
    ('zones',         'Areas explored',              'areas'),
    ('gold_caskets',  'Gold caskets opened',         'caskets'),
    ('parties',       'Parties joined',              'parties'),
    ('deaths',        'Most defeats',                'defeats'),
]
WEEK_SEC = 7 * 24 * 60 * 60


def _period_totals(cur, since):
    """{charid: totals} from the log, for rows at or after `since` (0 = all)."""
    cur.execute(
        'SELECT charid,'
        "  SUM(event = 'level_up'),"
        "  COALESCE(SUM(CASE WHEN event = 'hunt_summary' THEN JSON_VALUE(data, '$.kills') END), 0),"
        "  COALESCE(SUM(CASE WHEN event = 'hunt_summary' THEN JSON_VALUE(data, '$.exp') END), 0),"
        "  SUM(event = 'nm_defeated'),"
        "  COUNT(DISTINCT CASE WHEN event = 'arrived' THEN JSON_VALUE(data, '$.zone_id') END),"
        "  SUM(event = 'casket' AND JSON_VALUE(data, '$.chest') = 4),"
        "  SUM(event = 'joined' OR event = 'formed'),"
        "  SUM(event = 'died')"
        ' FROM world_bot_log WHERE ts >= ? GROUP BY charid',
        (since,),
    )
    totals = {}
    for r in cur.fetchall():
        totals[r[0]] = {
            'levels_gained': int(r[1] or 0),
            'kills':         int(r[2] or 0),
            'exp':           int(r[3] or 0),
            'nm_defeated':   int(r[4] or 0),
            'zones':         int(r[5] or 0),
            'gold_caskets':  int(r[6] or 0),
            'parties':       int(r[7] or 0),
            'deaths':        int(r[8] or 0),
        }
    return totals


def leaderboards(cur, period='all', limit=10, now=None):
    """{'period', 'boards': [{key, label, unit, entries: [{rank, charid, name, title, main_abbr,
    main_level, value}]}]}. Bots with nothing to show (value 0) are left off a board; ties share
    a rank, broken by name for order."""
    week    = period == 'week'
    since   = (now or int(time.time())) - WEEK_SEC if week else 0
    limit   = max(1, min(int(limit), 50))
    bots    = {p['charid']: p for p in _bot_profiles(cur)}
    totals  = _period_totals(cur, since)
    counts  = _achievement_counts(cur)

    def value_of(key, charid):
        if key == 'level':
            return bots[charid]['main_level']
        if key == 'achievements':
            _, achievements = achievements_for(counts.get(charid))
            return sum(1 for a in achievements if a['earned'])
        return totals.get(charid, {}).get(key, 0)

    boards = []
    for key, label, unit in (LEADERBOARDS_WEEK if week else LEADERBOARDS_ALL):
        scored = [(value_of(key, charid), bot['name'], charid) for charid, bot in bots.items()]
        scored = sorted((row for row in scored if row[0] > 0), key=lambda row: (-row[0], row[1]))[:limit]

        entries, rank, previous = [], 0, None
        for index, (value, name, charid) in enumerate(scored):
            if value != previous:
                rank, previous = index + 1, value
            bot = bots[charid]
            entries.append({
                'rank':       rank,
                'charid':     charid,
                'name':       name,
                'title':      achievements_for(counts.get(charid))[0],
                'main_abbr':  bot['main_abbr'],
                'main_level': bot['main_level'],
                'race':       bot['race'],
                'face':       bot['face'],
                'value':      value,
            })

        boards.append({'key': key, 'label': label, 'unit': unit, 'entries': entries})

    return {'period': 'week' if week else 'all', 'boards': boards}


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
    counts   = _achievement_counts(cur)
    for p in profiles:
        events      = latest.get(p['charid'], [])
        p['status'] = describe_now(events)
        p['latest'] = events[0]['message'] if events else None
        p['title'], _ = achievements_for(counts.get(p['charid']))
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
    bot['title'], bot['achievements'] = achievements_for(_achievement_counts(cur, charid).get(charid))
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


@bots.route('/api/bots/leaderboards')
def api_bots_leaderboards():
    period = request.args.get('period', default='all')
    limit  = request.args.get('limit', default=10, type=int)
    return jsonify(_with_connection(lambda cur: leaderboards(cur, period=period, limit=limit)))


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
