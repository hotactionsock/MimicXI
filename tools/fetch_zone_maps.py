#!/usr/bin/env python3
"""Download zone map images (Remapster renders) from the AscensionXI wiki,
used with the AscensionXI team's permission, and calibrate them for the live
bot view (tools/web_creator/site/watch.html).

Run it where the website lives - the images go into its maps/ folder, which
is git-ignored:

    python3 tools/fetch_zone_maps.py                 # every zone
    python3 tools/fetch_zone_maps.py --zones 103,104 # just these zone ids
    python3 tools/fetch_zone_maps.py --dry-run       # report, download nothing

Calibration comes for free: each zone page marks its NPCs on the map with
both the pixel position (on a 2048 px image) and the game coordinates (X, Z),
so every map image with two or more spread-out markers gets a least-squares
fit (pixel = a * world + b per axis) written to maps/calibration.json. Images
without markers are still downloaded - line those up by hand on mapcal.html.
Calibrations you made by hand (entries without "source") are kept unless you
pass --overwrite. Multi-floor zones get one entry per floor; set each floor's
height range on mapcal.html so the live view picks the right one.

Polite by default: one request at a time with a pause between them.
"""

import argparse
import html
import json
import os
import re
import struct
import sys
import time
import urllib.parse
import urllib.request

BASE        = 'https://www.ascensionffxi.com'
ZONES_PAGE  = BASE + '/wiki/Zones'
USER_AGENT  = 'MimicXI-zone-maps/1.0 (with the AscensionXI team\'s permission)'
CREDIT      = 'Maps: Remapster, via AscensionXI'
MAX_RMS_PX  = 4.0   # a fit worse than this (pixels) is reported, not saved

HERE      = os.path.dirname(os.path.abspath(__file__))
SITE_MAPS = os.path.join(HERE, 'web_creator', 'site', 'maps')

MARKER_RE = re.compile(
    r'data-npc-image="(?P<image>/maps/(?P<zone>\d+)-(?P<floor>\d+)\.(?P<ext>png|jpg|jpeg|webp))"\s+'
    r'data-npc-size="(?P<size>\d+)"\s+data-npc-px="(?P<px>[-\d.]+)"\s+data-npc-py="(?P<py>[-\d.]+)"'
    r'[^>]*?data-npc-sub="(?P<sub>[^"]*)"')
IMAGE_RE  = re.compile(r'/maps/(\d+)-(\d+)\.(png|jpg|jpeg|webp)')
COORDS_RE = re.compile(r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$')


def get(url, binary=False):
    request = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read()
    return data if binary else data.decode('utf-8', errors='replace')


def zone_pages():
    page  = get(ZONES_PAGE)
    links = sorted(set(re.findall(r'href="(/wiki/[^"#?]+)"', page)))
    return [html.unescape(link) for link in links if link not in ('/wiki/Zones', '/wiki')]


def markers(page):
    """{(zone, floor, ext): {'size': px, 'points': [(world_x, world_z, px, py)]}} plus
    every map image the page shows, even without markers."""
    found = {}
    for m in MARKER_RE.finditer(page):
        coords = COORDS_RE.search(html.unescape(m.group('sub')))
        if not coords:
            continue
        key   = (int(m.group('zone')), int(m.group('floor')), m.group('ext').lower())
        entry = found.setdefault(key, {'size': int(m.group('size')), 'points': set()})
        entry['points'].add((float(coords.group(1)), float(coords.group(2)), float(m.group('px')), float(m.group('py'))))

    for zone, floor, ext in IMAGE_RE.findall(page):
        found.setdefault((int(zone), int(floor), ext.lower()), {'size': 0, 'points': set()})
    return found


def fit_axis(pairs):
    n  = len(pairs)
    mx = sum(p[0] for p in pairs) / n
    my = sum(p[1] for p in pairs) / n
    sxx = sum((p[0] - mx) ** 2 for p in pairs)
    if sxx < 1.0:
        return None
    a = sum((p[0] - mx) * (p[1] - my) for p in pairs) / sxx
    return a, my - a * mx


def fit(points):
    """(ax, bx, az, bz, rms px) in the markers' pixel space, or None."""
    if len(points) < 2:
        return None
    fx = fit_axis([(x, px) for x, _, px, _ in points])
    fz = fit_axis([(z, py) for _, z, _, py in points])
    if not fx or not fz or fx[0] == 0 or fz[0] == 0:
        return None
    rms = (sum((fx[0] * x + fx[1] - px) ** 2 + (fz[0] * z + fz[1] - py) ** 2 for x, z, px, py in points) / len(points)) ** 0.5
    return fx[0], fx[1], fz[0], fz[1], rms


def image_width(data):
    """Pixel width of a PNG (0 if not a PNG or unreadable)."""
    if data[:8] == b'\x89PNG\r\n\x1a\n' and data[12:16] == b'IHDR':
        return struct.unpack('>I', data[16:20])[0]
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--maps-dir', default=SITE_MAPS, help='the website\'s maps/ folder (default: %(default)s)')
    parser.add_argument('--zones', help='comma-separated zone ids to fetch (default: all)')
    parser.add_argument('--delay', type=float, default=0.5, help='seconds between requests (default: %(default)s)')
    parser.add_argument('--refresh', action='store_true', help='download images again even if present')
    parser.add_argument('--overwrite', action='store_true', help='replace hand-made calibrations too')
    parser.add_argument('--dry-run', action='store_true', help='report only; download and write nothing')
    args = parser.parse_args()

    wanted = {int(z) for z in args.zones.split(',')} if args.zones else None
    os.makedirs(args.maps_dir, exist_ok=True)

    cal_path = os.path.join(args.maps_dir, 'calibration.json')
    try:
        with open(cal_path, encoding='utf-8') as handle:
            calibration = json.load(handle)
    except (OSError, ValueError):
        calibration = {}
    calibration.setdefault('zones', {})
    if calibration.get('credit') in (None, '', 'Maps: Remapster'):
        calibration['credit'] = CREDIT

    maps = {}
    pages = zone_pages()
    print('{} wiki pages to look at'.format(len(pages)))
    for i, link in enumerate(pages, 1):
        try:
            page = get(BASE + urllib.parse.quote(link, safe='/%[]\'_-.()'))
        except Exception as err:  # noqa: BLE001 - report and carry on
            print('  ! {}: {}'.format(link, err))
            continue
        for key, entry in markers(page).items():
            if wanted and key[0] not in wanted:
                continue
            merged = maps.setdefault(key, {'size': 0, 'points': set()})
            merged['size'] = merged['size'] or entry['size']
            merged['points'] |= entry['points']
        if i % 25 == 0:
            print('  {}/{} pages, {} map images so far'.format(i, len(pages), len(maps)))
        time.sleep(args.delay)

    calibrated = manual = uncalibrated = downloaded = 0
    for (zone, floor, ext), entry in sorted(maps.items()):
        name   = '{}_{}.{}'.format(zone, floor, ext)
        target = os.path.join(args.maps_dir, name)

        width = 0
        if os.path.exists(target) and not args.refresh:
            with open(target, 'rb') as handle:
                width = image_width(handle.read(32))
        elif not args.dry_run:
            data = get('{}/maps/{}-{}.{}'.format(BASE, zone, floor, ext), binary=True)
            with open(target, 'wb') as handle:
                handle.write(data)
            width = image_width(data)
            downloaded += 1
            time.sleep(args.delay)

        result = fit(sorted(entry['points']))
        zone_entries = calibration['zones'].setdefault(str(zone), [])
        existing = next((e for e in zone_entries if e.get('file') == name), None)

        if result is None or result[4] > MAX_RMS_PX:
            uncalibrated += 1
            why = 'not enough NPC markers' if result is None else 'markers disagree ({:.1f} px)'.format(result[4])
            print('  - {}: downloaded, calibrate by hand on mapcal.html ({})'.format(name, why))
            continue

        if existing and existing.get('source') != 'ascension' and not args.overwrite:
            manual += 1
            continue

        # Markers are in a size x size pixel space; rescale to the real image.
        scale = (width / entry['size']) if width and entry['size'] else 1.0
        ax, bx, az, bz, rms = result
        new = {'file': name, 'ax': ax * scale, 'bx': bx * scale, 'az': az * scale, 'bz': bz * scale,
               'label': existing.get('label', '') if existing else ('Map {}'.format(floor + 1) if floor else ''),
               'source': 'ascension'}
        for key in ('ymin', 'ymax'):
            if existing and key in existing:
                new[key] = existing[key]
        if existing:
            zone_entries[zone_entries.index(existing)] = new
        else:
            zone_entries.append(new)
        calibrated += 1

    calibration['zones'] = {z: e for z, e in calibration['zones'].items() if e}
    if not args.dry_run:
        tmp = cal_path + '.tmp'
        with open(tmp, 'w', encoding='utf-8') as handle:
            json.dump(calibration, handle, indent=2, sort_keys=True)
        os.replace(tmp, cal_path)

    print('{} map images: {} calibrated from NPC markers, {} kept your own calibration, {} need calibrating by hand; {} downloaded{}'.format(
        len(maps), calibrated, manual, uncalibrated, downloaded, ' (dry run)' if args.dry_run else ''))
    return 0


if __name__ == '__main__':
    sys.exit(main())
