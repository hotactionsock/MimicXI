"""A character's quests, missions and crafts, read straight from the game's own
tables - for the bot profile (bot.html). Works for any character; bots are
what it's used for today.

  quests   - chars.quests: 11 areas x (32 bytes "current" bits, 32 bytes "complete" bits)
             (questlog_t, src/common/mmo.h)
  missions - chars.missions: 15 logs x (uint16 current, uint16 statusUpper,
             uint16 statusLower, bool complete[64]) (missionlog_t)
  rank     - char_profile.rank_<nation>, rank_points
  crafts   - char_skills, skill ids 49 (Woodworking) .. 56 (Cooking): value is skill x10

Quest and mission names come from the server's own id tables
(scripts/globals/quests.lua, missions.lua), read once and cached.
"""

import os
import re
import struct

_HERE    = os.path.dirname(os.path.abspath(__file__))
_SCRIPTS = os.path.normpath(os.path.join(_HERE, '..', '..', 'scripts', 'globals'))

QUEST_AREAS = [  # quest log id order (xi.questLog)
    ('sandoria', "San d'Oria"), ('bastok', 'Bastok'), ('windurst', 'Windurst'), ('jeuno', 'Jeuno'),
    ('otherAreas', 'Other Areas'), ('outlands', 'Outlands'), ('ahtUrhgan', 'Aht Urhgan'),
    ('crystalWar', 'Crystal War'), ('abyssea', 'Abyssea'), ('adoulin', 'Adoulin'), ('coalition', 'Coalition'),
]

MISSION_LOGS = [  # mission log id order (xi.mission.log_id)
    ('sandoria', "San d'Oria Missions"), ('bastok', 'Bastok Missions'), ('windurst', 'Windurst Missions'),
    ('zilart', 'Rise of the Zilart'), ('toau', 'Treasures of Aht Urhgan'), ('wotg', 'Wings of the Goddess'),
    ('cop', 'Chains of Promathia'), ('assault', 'Assault'), ('campaign', 'Campaign'),
    ('acp', 'A Crystalline Prophecy'), ('amk', "A Moogle Kupo d'Etat"), ('asa', 'A Shantotto Ascension'),
    ('soa', 'Seekers of Adoulin'), ('rov', "Rhapsodies of Vana'diel"), ('tvr', 'The Voracious Resurgence'),
]
# Storylines shown on a profile (the rest - Assault, Campaign, add-on scenarios - are left out for now).
SHOWN_MISSIONS = {'zilart', 'toau', 'wotg', 'cop'}

CRAFTS = [(49, 'Woodworking'), (50, 'Smithing'), (51, 'Goldsmithing'), (52, 'Clothcraft'),
          (53, 'Leathercraft'), (54, 'Bonecraft'), (55, 'Alchemy'), (56, 'Cooking')]
CRAFT_RANKS = ['Amateur', 'Recruit', 'Initiate', 'Novice', 'Apprentice', 'Journeyman', 'Craftsman',
               'Artisan', 'Adept', 'Veteran', 'Expert']

NATIONS = ['sandoria', 'bastok', 'windurst']

_SMALL = {'a', 'an', 'and', 'at', 'for', 'from', 'in', 'of', 'on', 'or', 'the', 'to', 'with'}
_names = None


def _title(key):
    words = []
    for word in key.split('_'):
        lower = word.lower()
        if re.fullmatch(r'[IVX]+', word):
            words.append(word)
        elif words and lower in _SMALL:
            words.append(lower)
        else:
            words.append(lower[:1].upper() + lower[1:])
    return ' '.join(words)


def _read_tables(path, block_re):
    """{area key: {id: name}} from a Lua id table file. block_re matches the
    line opening an area's table (group 1 = its key); ['plain'] keys count too."""
    tables, current = {}, None
    try:
        with open(path, encoding='utf-8', errors='replace') as handle:
            for line in handle:
                start = re.match(block_re, line) or re.match(r"^\s{4}\['([a-zA-Z]+)'\]\s*=", line)
                if start:
                    current = tables.setdefault(start.group(1), {})
                    continue
                if current is not None and re.match(r'^\s{4}\},?\s*$', line):
                    current = None
                    continue
                entry = re.match(r'^\s+([A-Z][A-Z0-9_]*)\s*=\s*(\d+)', line)
                if current is not None and entry:
                    current.setdefault(int(entry.group(2)), _title(entry.group(1)))
    except OSError:
        pass
    return tables


def names():
    global _names
    if _names is None:
        quest_keys   = {f'xi.questLog.{k}': a for k, a in zip(
            ['SANDORIA', 'BASTOK', 'WINDURST', 'JEUNO', 'OTHER_AREAS', 'OUTLANDS', 'AHT_URHGAN', 'CRYSTAL_WAR',
             'ABYSSEA', 'ADOULIN', 'COALITION'], [a for a, _ in QUEST_AREAS])}
        mission_keys = {f'xi.mission.log_id.{k.upper()}': a for a, _ in MISSION_LOGS for k in [a]}
        raw_q = _read_tables(os.path.join(_SCRIPTS, 'quests.lua'), r'^\s{4}\[xi\.quest\.area\[(xi\.questLog\.[A-Z_]+)\]\]\s*=')
        raw_m = _read_tables(os.path.join(_SCRIPTS, 'missions.lua'), r'^\s{4}\[xi\.mission\.area\[(xi\.mission\.log_id\.[A-Z_]+)\]\]\s*=')
        _names = {
            'quests':   {quest_keys.get(k, k): v for k, v in raw_q.items()},
            'missions': {mission_keys.get(k, k): v for k, v in raw_m.items()},
        }
    return _names


def _quests(blob):
    result = []
    blob = bytes(blob or b'')
    table = names()['quests']
    for index, (area, label) in enumerate(QUEST_AREAS):
        chunk = blob[index * 64:(index + 1) * 64]
        if len(chunk) < 64:
            break
        current  = [i for i in range(256) if chunk[i // 8] >> (i % 8) & 1]
        complete = [i for i in range(256) if chunk[32 + i // 8] >> (i % 8) & 1]
        if not current and not complete:
            continue
        area_names = table.get(area, {})
        result.append({
            'area': label,
            'completed': len(complete),
            'in_progress': [area_names.get(q, 'Quest #{}'.format(q)) for q in current],
        })
    return result


def _missions(blob, nation):
    result = []
    blob = bytes(blob or b'')
    table = names()['missions']
    for index, (area, label) in enumerate(MISSION_LOGS):
        if index <= 2 and index != nation:
            continue  # only its own nation's missions
        if index > 2 and area not in SHOWN_MISSIONS:
            continue
        chunk = blob[index * 70:(index + 1) * 70]
        if len(chunk) < 70:
            break
        current = struct.unpack_from('<H', chunk, 0)[0]
        done    = sum(1 for b in chunk[6:70] if b)
        none    = 65535 if index <= 2 else 0
        if current == none and not done:
            continue
        area_names = dict(table.get(area, {}))
        if index <= 2:
            for mid, name in table.get('nation', {}).items():
                area_names.setdefault(mid, name)
        result.append({
            'storyline': label,
            'completed': done,
            'current': None if current == none else area_names.get(current, 'Mission #{}'.format(current)),
        })
    return result


def character_progress(cur, charid):
    cur.execute('SELECT c.nation, c.quests, c.missions, p.rank_sandoria, p.rank_bastok, p.rank_windurst, p.rank_points '
                'FROM chars c LEFT JOIN char_profile p ON p.charid = c.charid WHERE c.charid = ?', (charid,))
    row = cur.fetchone()
    if not row:
        return None

    nation = int(row[0] or 0)
    ranks  = [row[3], row[4], row[5]]

    cur.execute('SELECT skillid, value, `rank` FROM char_skills WHERE charid = ? AND skillid BETWEEN 49 AND 56', (charid,))
    skills = {r[0]: (int(r[1] or 0), int(r[2] or 0)) for r in cur.fetchall()}
    crafts = []
    for skill_id, label in CRAFTS:
        value, rank = skills.get(skill_id, (0, 0))
        crafts.append({'craft': label, 'level': value // 10, 'rank': CRAFT_RANKS[rank] if rank < len(CRAFT_RANKS) else str(rank)})

    quests = _quests(row[1])
    return {
        'nation_rank':     int(ranks[nation] or 1) if nation < 3 else None,
        'rank_points':     int(row[6] or 0),
        'missions':        _missions(row[2], nation),
        'quests':          quests,
        'quests_completed': sum(q['completed'] for q in quests),
        'crafts':          crafts,
    }
