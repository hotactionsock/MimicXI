#!/usr/bin/env python3
"""Decode iconTextureBase64 from ShiningFantasia JSON and write PNGs to site/icons/.

Usage:
    python update_icons.py [--all] [--dry-run] [--force]

Options:
    --all       Process all SF bulk files (default: armor2.json only)
    --dry-run   Report what would change without writing files
    --force     Overwrite site/icons/ files even if they already exist

The site/icons/ directory is checked first by the web app, before the
ShiningFantasia/icons/ directory. Run this script whenever you update
custom item icons in the ShiningFantasia editor so the web app picks
up the new icons.
"""

import base64
import json
import os
import struct
import sys
from typing import Optional

# ── BMP2 decoder (ported from ShiningFantasia/ffxi_item_editor.py) ────────────

def _e5(v: int) -> int: return v * 255 // 31
def _e6(v: int) -> int: return v * 255 // 63


def _dxt1_decode(data: bytes, w: int, h: int, out: bytearray) -> None:
    pitch = w * 4
    ioff = off = 0
    for _y in range(0, h, 4):
        for _x in range(0, w, 4):
            c0 = data[ioff] | (data[ioff+1] << 8)
            c1 = data[ioff+2] | (data[ioff+3] << 8)
            c0r, c0g, c0b = _e5(c0>>11), _e6((c0>>5)&63), _e5(c0&31)
            c1r, c1g, c1b = _e5(c1>>11), _e6((c1>>5)&63), _e5(c1&31)
            if c0 > c1:
                cols = [(c0r,c0g,c0b,255),(c1r,c1g,c1b,255),
                        ((2*c0r+c1r)//3,(2*c0g+c1g)//3,(2*c0b+c1b)//3,255),
                        ((c0r+2*c1r)//3,(c0g+2*c1g)//3,(c0b+2*c1b)//3,255)]
            else:
                cols = [(c0r,c0g,c0b,255),(c1r,c1g,c1b,255),
                        ((c0r+c1r)//2,(c0g+c1g)//2,(c0b+c1b)//2,255),(0,0,0,0)]
            for row in range(4):
                rb = data[ioff+4+row]
                boff = off + row * pitch
                for col in range(4):
                    r,g,b,a = cols[(rb >> (col*2)) & 3]
                    out[boff]=r; out[boff+1]=g; out[boff+2]=b; out[boff+3]=a
                    boff += 4
            ioff += 8; off += 16
        off += pitch * 3


def _dxt3_decode(data: bytes, w: int, h: int, out: bytearray) -> None:
    pitch = w * 4
    ioff = off = 0
    for _y in range(0, h, 4):
        for _x in range(0, w, 4):
            alpha = []
            for i in range(8):
                byte = data[ioff+i]
                alpha.append(min(255, ((byte & 0xF) * 255 // 15) * 255 // 128))
                alpha.append(min(255, ((byte >> 4)  * 255 // 15) * 255 // 128))
            c0 = data[ioff+8] | (data[ioff+9] << 8)
            c1 = data[ioff+10] | (data[ioff+11] << 8)
            c0r, c0g, c0b = _e5(c0>>11), _e6((c0>>5)&63), _e5(c0&31)
            c1r, c1g, c1b = _e5(c1>>11), _e6((c1>>5)&63), _e5(c1&31)
            cols = [(c0r,c0g,c0b),(c1r,c1g,c1b),
                    ((2*c0r+c1r)//3,(2*c0g+c1g)//3,(2*c0b+c1b)//3),
                    ((c0r+2*c1r)//3,(c0g+2*c1g)//3,(c0b+2*c1b)//3)]
            for row in range(4):
                rb = data[ioff+12+row]
                boff = off + row * pitch
                for col in range(4):
                    r,g,b = cols[(rb >> (col*2)) & 3]
                    a = alpha[row*4+col]
                    out[boff]=r; out[boff+1]=g; out[boff+2]=b; out[boff+3]=a
                    boff += 4
            ioff += 16; off += 16
        off += pitch * 3


def decode_bmp2(data: bytes) -> Optional[tuple]:
    """Decode a raw BMP2 blob → (width, height, rgba_bytes), or None on failure."""
    if len(data) < 57:
        return None
    vf   = data[0]
    isc  = bool(vf >> 7)
    ver  = (vf >> 4) & 7
    w    = struct.unpack_from('<I', data, 21)[0]
    h    = struct.unpack_from('<I', data, 25)[0]
    bpp  = data[31]
    pbpp = data[53]
    if not w or not h or w > 512 or h > 512:
        return None

    ofs = 61 if ver == 3 else 57
    palette = texture = compressed = None
    fourcc = 0

    if ver != 2:
        if bpp == 4:
            ps = 16 * pbpp // 8; palette = data[ofs:ofs+ps]; ofs += ps
        elif bpp == 8:
            ps = 256 * pbpp // 8; palette = data[ofs:ofs+ps]; ofs += ps
        ts = bpp * w * h // 8; texture = data[ofs:ofs+ts]; ofs += ts

    if isc and ofs + 12 <= len(data):
        fc = struct.unpack_from('<I', data, ofs)[0]
        if 0x44585431 <= fc <= 0x44585435:
            ofs += 12
            cs = (8 if fc == 0x44585431 else 16) * w * h // 16
            fourcc = fc; compressed = data[ofs:ofs+cs]

    rgba = bytearray(w * h * 4)

    if compressed and not palette:
        if fourcc == 0x44585431:
            _dxt1_decode(compressed, w, h, rgba)
        elif fourcc == 0x44585433:
            _dxt3_decode(compressed, w, h, rgba)
        else:
            return None
    elif palette and texture and bpp == 8 and pbpp == 32:
        for y in range(h):
            fy = h - 1 - y
            for x in range(w):
                p = texture[fy*w + x]; pi = p*4; dst = (y*w + x)*4
                rgba[dst]   = palette[pi+2]
                rgba[dst+1] = palette[pi+1]
                rgba[dst+2] = palette[pi]
                rgba[dst+3] = min(255, palette[pi+3] * 255 // 128)
    elif texture and not palette and bpp == 32 and pbpp == 32:
        for y in range(h):
            fy = h - 1 - y
            for x in range(w):
                src = (fy*w + x)*4; dst = (y*w + x)*4
                rgba[dst]   = texture[src+2]; rgba[dst+1] = texture[src+1]
                rgba[dst+2] = texture[src];   rgba[dst+3] = min(255, texture[src+3] * 255 // 128)
    else:
        return None

    return w, h, bytes(rgba)


# ── Paths ─────────────────────────────────────────────────────────────────────

HERE     = os.path.dirname(os.path.abspath(__file__))
SF_DIR   = os.environ.get('SHINING_FANTASIA_PATH', r'G:\Games\FFXI\ShiningFantasia')
OUT_DIR  = os.path.join(HERE, 'site', 'icons')

BULK_FILES_DEFAULT = ['armor2']
BULK_FILES_ALL     = ['mydata', 'myarmor', 'armor2']


# ── Core logic ────────────────────────────────────────────────────────────────

def load_sf_json(name: str) -> list:
    path = os.path.join(SF_DIR, f'{name}.json')
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def icon_differs_from_sf(item_id: int, png_bytes: bytes) -> bool:
    """Return True if png_bytes differs from the SF/icons/ file for this item."""
    sf_path = os.path.join(SF_DIR, 'icons', f'{item_id}.png')
    if not os.path.isfile(sf_path):
        return True
    with open(sf_path, 'rb') as f:
        return f.read() != png_bytes


def process_items(items: list, dry_run: bool, force: bool) -> tuple:
    try:
        from PIL import Image
        import io
    except ImportError:
        print('ERROR: Pillow is required. Install with: pip install Pillow')
        sys.exit(1)

    written = skipped = errors = unchanged = 0

    for item in items:
        item_id  = item.get('id')
        b64      = item.get('iconTextureBase64', '')
        name     = (item.get('englishText') or [''])[0] or f'#{item_id}'

        if not item_id or not b64:
            skipped += 1
            continue

        out_path = os.path.join(OUT_DIR, f'{item_id}.png')
        if not force and os.path.isfile(out_path):
            skipped += 1
            continue

        try:
            raw    = base64.b64decode(b64)
            result = decode_bmp2(raw)
        except Exception as exc:
            print(f'  DECODE ERROR {item_id} ({name}): {exc}')
            errors += 1
            continue

        if result is None:
            print(f'  SKIP {item_id} ({name}): BMP2 decode returned None')
            skipped += 1
            continue

        w, h, rgba = result
        img = Image.frombytes('RGBA', (w, h), rgba)

        buf = io.BytesIO()
        img.save(buf, format='PNG', optimize=False)
        png_bytes = buf.getvalue()

        if not force and not icon_differs_from_sf(item_id, png_bytes):
            unchanged += 1
            continue

        if dry_run:
            print(f'  [DRY] would write {item_id}.png ({w}x{h}, {len(png_bytes)} bytes) — {name}')
            written += 1
        else:
            os.makedirs(OUT_DIR, exist_ok=True)
            with open(out_path, 'wb') as f:
                f.write(png_bytes)
            print(f'  WROTE {item_id}.png ({w}x{h}, {len(png_bytes)} bytes) — {name}')
            written += 1

    return written, skipped, errors, unchanged


def main():
    dry_run = '--dry-run' in sys.argv
    force   = '--force'   in sys.argv
    use_all = '--all'     in sys.argv

    file_list = BULK_FILES_ALL if use_all else BULK_FILES_DEFAULT

    print(f'ShiningFantasia path : {SF_DIR}')
    print(f'Output directory     : {OUT_DIR}')
    print(f'Files                : {file_list}')
    if dry_run:
        print('[DRY RUN — no files will be written]')
    print()

    total_written = total_skipped = total_errors = total_unchanged = 0

    for fname in file_list:
        print(f'--- {fname}.json ---')
        try:
            items = load_sf_json(fname)
        except FileNotFoundError:
            print(f'  NOT FOUND: {os.path.join(SF_DIR, fname + ".json")}')
            continue
        except Exception as exc:
            print(f'  ERROR loading {fname}: {exc}')
            continue

        w, s, e, u = process_items(items, dry_run=dry_run, force=force)
        total_written   += w
        total_skipped   += s
        total_errors    += e
        total_unchanged += u
        print(f'  {len(items)} items: {w} written, {u} unchanged (skipped), {s} skipped (no data/already exists), {e} errors')
        print()

    print('Done.')
    print(f'  Total written   : {total_written}')
    print(f'  Total unchanged : {total_unchanged}')
    print(f'  Total skipped   : {total_skipped}')
    print(f'  Total errors    : {total_errors}')


if __name__ == '__main__':
    main()
