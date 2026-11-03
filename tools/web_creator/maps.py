"""Zone map images for the live bot view (watch.html) - e.g. Remapster's HD
maps - and their calibration against game coordinates.

Images are not in git: drop them into the site's maps/ folder (see
site/maps/README.md), named <zoneid>.png, or <zoneid>_<n>.png for zones with
several maps (floors). calibration.json in the same folder says how each image
lines up with the game's coordinates, per axis:

    pixel_x = ax * world_x + bx        pixel_y = az * world_z + bz

so it captures scale, offset and which way is north in one go. A floor can
carry ymin/ymax (world height) so the live view picks the right map for where
the bot is standing. Calibrate in the browser with mapcal.html (admins save
it; anyone can copy the JSON).

JSON:
    GET  /api/maps                   zones that have map images, and which are calibrated
    GET  /api/maps/<zoneid>          that zone's images and calibration
    POST /api/maps/<zoneid>          save that zone's calibration (admin accounts only)
"""

import json
import os
import re
import threading

from flask import Blueprint, abort, jsonify, request, session

maps = Blueprint('maps', __name__)

_HERE      = os.path.dirname(os.path.abspath(__file__))
_FILE_RE   = re.compile(r'^(\d+)(?:_(\d+))?\.(png|jpg|jpeg|webp)$', re.IGNORECASE)
_save_lock = threading.Lock()


def maps_dir():
    """The site's maps/ folder (same site folder the app serves), or
    MIMIC_MAPS_DIR if set."""
    if os.environ.get('MIMIC_MAPS_DIR'):
        return os.environ['MIMIC_MAPS_DIR']

    for name in ('public', 'site', os.path.join('templates', 'site')):
        site = os.path.join(_HERE, name)
        if os.path.isfile(os.path.join(site, 'index.html')):
            return os.path.join(site, 'maps')

    return os.path.join(_HERE, 'site', 'maps')


def _calibration_path():
    return os.path.join(maps_dir(), 'calibration.json')


def _load_calibration():
    try:
        with open(_calibration_path(), encoding='utf-8') as handle:
            data = json.load(handle)
            return data if isinstance(data, dict) else {}
    except (OSError, ValueError):
        return {}


def _images():
    """{zone_id: [file names]} for every map image in the folder."""
    found = {}
    try:
        names = os.listdir(maps_dir())
    except OSError:
        return found

    for name in sorted(names):
        match = _FILE_RE.match(name)
        if match:
            found.setdefault(int(match.group(1)), []).append(name)

    return found


def zone_maps(zone_id):
    calibration = _load_calibration()
    files       = _images().get(zone_id, [])
    entries     = [e for e in calibration.get('zones', {}).get(str(zone_id), []) if e.get('file') in files]
    return {
        'zone_id': zone_id,
        'files':   files,
        'maps':    entries,
        'credit':  calibration.get('credit', ''),
    }


@maps.route('/api/maps')
def api_maps():
    calibration = _load_calibration().get('zones', {})
    zones = []
    for zone_id, files in sorted(_images().items()):
        done = {e.get('file') for e in calibration.get(str(zone_id), [])}
        zones.append({'zone_id': zone_id, 'files': files, 'calibrated': [f for f in files if f in done]})
    return jsonify({'zones': zones, 'admin': bool(session.get('is_admin', False))})


@maps.route('/api/maps/<int:zone_id>')
def api_zone_maps(zone_id):
    return jsonify(zone_maps(zone_id))


def _number(value, name):
    try:
        number = float(value)
    except (TypeError, ValueError):
        abort(400, '{} must be a number'.format(name))
    if number != number or number in (float('inf'), float('-inf')):
        abort(400, '{} must be a number'.format(name))
    return number


@maps.route('/api/maps/<int:zone_id>', methods=['POST'])
def api_save_zone_maps(zone_id):
    if not session.get('is_admin', False):
        abort(403)

    body    = request.get_json(silent=True) or {}
    files   = set(_images().get(zone_id, []))
    entries = []
    for raw in body.get('maps', []):
        if raw.get('file') not in files:
            abort(400, 'unknown map file')

        entry = {'file': raw['file']}
        for key in ('ax', 'bx', 'az', 'bz'):
            entry[key] = _number(raw.get(key), key)
        if entry['ax'] == 0 or entry['az'] == 0:
            abort(400, 'scale cannot be 0')
        for key in ('ymin', 'ymax'):
            if raw.get(key) not in (None, ''):
                entry[key] = _number(raw.get(key), key)
        entry['label'] = str(raw.get('label') or '')[:40]
        # Calibrations from tools/fetch_zone_maps.py keep their source, so a
        # later run can refresh them; one saved here by hand has none.
        if raw.get('source') == 'ascension':
            entry['source'] = 'ascension'
        entries.append(entry)

    with _save_lock:
        data = _load_calibration()
        data.setdefault('zones', {})[str(zone_id)] = entries
        os.makedirs(maps_dir(), exist_ok=True)
        tmp = _calibration_path() + '.tmp'
        with open(tmp, 'w', encoding='utf-8') as handle:
            json.dump(data, handle, indent=2, sort_keys=True)
        os.replace(tmp, _calibration_path())

    return jsonify(zone_maps(zone_id))
