'use strict';

// ── Helpers ───────────────────────────────────────────────────────────────────

function qs(sel) { return document.querySelector(sel); }
function show(el) { el.style.display = ''; }
function hide(el) { el.style.display = 'none'; }

function fmt(n) { return Number(n).toLocaleString(); }

function starRating(tier) {
  return '★'.repeat(tier) + '☆'.repeat(8 - tier);
}

function charIdFromUrl() {
  return new URLSearchParams(window.location.search).get('id');
}

function escHtml(str) {
  return String(str ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ── Nav session check ─────────────────────────────────────────────────────────
async function initNav() {
  try {
    const r = await fetch('/api/session');
    const d = await r.json();
    if (d.authenticated) {
      const el = qs('#nav-user');
      if (el) el.textContent = d.username;
      const btn = qs('#nav-logout');
      if (btn) show(btn);
    }
  } catch { /* non-fatal */ }
}

// ── Tab switching ─────────────────────────────────────────────────────────────
function initTabs() {
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      const panel = qs(`#tab-${btn.dataset.tab}`);
      if (panel) panel.classList.add('active');
    });
  });
}

// ── Render helpers ────────────────────────────────────────────────────────────

function renderOverview(d) {
  const charDl = qs('#detail-character');
  const rows = [
    ['Race',   d.race_name],
    ['Nation', d.nation_name],
    ['Size',   d.size],
    ['Face',   d.face_label],
  ];
  charDl.innerHTML = rows.map(([k,v]) => `<dt>${k}</dt><dd>${v}</dd>`).join('');

  const rankDl = qs('#detail-ranks');
  const nations = [
    ["San d'Oria", d.ranks.sandoria],
    ['Bastok',     d.ranks.bastok],
    ['Windurst',   d.ranks.windurst],
  ];
  rankDl.innerHTML = nations.map(([n,r]) =>
    `<dt>${n}</dt><dd><span class="rank-badge">Rank ${r ?? '—'}</span></dd>`
  ).join('');
}

function renderJobs(d) {
  const grid    = qs('#jobs-grid');
  const maxLv   = 75;
  const mainAbbr = d.main_job;

  grid.innerHTML = d.jobs.map(j => {
    const pct      = Math.min(100, (j.level / maxLv) * 100).toFixed(1);
    const isMain   = j.abbr === mainAbbr;
    const hasLevel = j.level > 0;
    const cls = ['job-row', isMain ? 'job-main' : '', !hasLevel ? 'job-inactive' : ''].join(' ').trim();

    return `
      <div class="${cls}" title="${j.name}">
        <span class="job-abbr">${j.abbr}</span>
        <div class="job-bar-wrap"><div class="job-bar-fill" style="width:${pct}%"></div></div>
        <span class="job-level">${j.level || '—'}</span>
      </div>`;
  }).join('');
}

function renderFame(d) {
  const list = qs('#fame-list');
  list.innerHTML = Object.values(d.fame).map(f => {
    const pct = Math.min(100, (f.value / 1500) * 100).toFixed(1);
    return `
      <div class="fame-row">
        <span class="fame-label">${f.label}</span>
        <div class="fame-bar-wrap"><div class="fame-bar-fill" style="width:${pct}%"></div></div>
        <span class="fame-value">${fmt(f.value)}</span>
        <span class="fame-tier" title="Fame tier ${f.tier}">
          <span class="fame-stars">${starRating(f.tier)}</span>
        </span>
      </div>`;
  }).join('');
}

// ── Item tooltip ──────────────────────────────────────────────────────────────

const _itemCache = Object.create(null);
let   _ttEl      = null;

function getTooltipEl() {
  if (!_ttEl) {
    _ttEl = document.createElement('div');
    _ttEl.className = 'item-tooltip';
    document.body.appendChild(_ttEl);
  }
  return _ttEl;
}

async function fetchItemData(itemId) {
  if (_itemCache[itemId] !== undefined) return _itemCache[itemId];
  try {
    const res = await fetch(`/item-data/${itemId}`);
    _itemCache[itemId] = res.ok ? await res.json() : null;
  } catch {
    _itemCache[itemId] = null;
  }
  return _itemCache[itemId];
}

// Parse one description line into colored HTML spans.
// Handles: "Quoted Ability"+N%, KEY:N, STAT+N%, STAT-N%, plain words.
function parseDescLine(line) {
  // Match in priority order:
  // 1. "Quoted ability"+N%?   e.g. "Store TP"+5  "Double Attack"+2%
  // 2. WORD:N                 e.g. DMG:120  Delay:492
  // 3. WORD+N%? / WORD-N%?   e.g. STR+8  Accuracy+12  HP-10
  // 4. anything else (plain)
  const re = /"([^"]+)"([+-][\d.]+%?)|(\w+):([\d.]+)|(\w+)([+-][\d.]+%?)|(\S+)/g;
  const parts = [];
  let m;
  while ((m = re.exec(line)) !== null) {
    if (m[1] != null) {
      const cls = m[2].startsWith('-') ? 'tt-neg' : 'tt-pos';
      parts.push(
        `<span class="tt-ability">“${escHtml(m[1])}”</span>` +
        `<span class="${cls}">${escHtml(m[2])}</span>`
      );
    } else if (m[3] != null) {
      parts.push(
        `<span class="tt-key">${escHtml(m[3])}:</span>` +
        `<span class="tt-keyval">${escHtml(m[4])}</span>`
      );
    } else if (m[5] != null) {
      const cls = m[6].startsWith('-') ? 'tt-neg' : 'tt-pos';
      parts.push(
        `<span class="tt-stat">${escHtml(m[5])}</span>` +
        `<span class="${cls}">${escHtml(m[6])}</span>`
      );
    } else {
      parts.push(`<span class="tt-plain">${escHtml(m[7])}</span>`);
    }
  }
  return parts.join(' ');
}

function buildTooltipHtml(data, slotName) {
  const itemId = data.item_id;
  const name   = data.name || `Item #${itemId}`;

  const header = `
    <div class="tt-header">
      <img class="tt-icon" src="/item-icon/${itemId}" alt=""
           onerror="this.style.visibility='hidden'">
      <div class="tt-title">
        <div class="tt-name">${escHtml(name)}</div>
        <div class="tt-slot-name">${escHtml(slotName)}</div>
      </div>
    </div>`;

  let body = '';
  if (data.description) {
    const lines = data.description.split('\\n').map(l => l.trim()).filter(Boolean);
    body = lines.map(l => `<div class="tt-line">${parseDescLine(l)}</div>`).join('');
  }

  const footerParts = [];
  if (data.level)  footerParts.push(`Lv. ${data.level}`);
  if (data.ilvl)   footerParts.push(`iLv. ${data.ilvl}`);
  if (data.jobs && data.jobs.length) footerParts.push(data.jobs.join(' '));
  const footer = footerParts.length
    ? `<div class="tt-level-line">${escHtml(footerParts.join('  '))}</div>`
    : '';

  return header + (body || footer
    ? `<div class="tt-body">${body}${footer}</div>`
    : '');
}

function positionTooltip(tt, anchor) {
  const rect = anchor.getBoundingClientRect();
  const gap  = 10;

  // Temporarily make it visible but transparent to measure size
  tt.style.visibility = 'hidden';
  tt.style.display    = 'block';
  const ttW = tt.offsetWidth;
  const ttH = tt.offsetHeight;
  tt.style.visibility = '';
  tt.style.display    = '';

  const vw = window.innerWidth;
  const vh = window.innerHeight;

  // Prefer above slot; fall back to below
  let top = rect.top - ttH - gap;
  if (top < 4) top = rect.bottom + gap;
  // Clamp bottom
  if (top + ttH > vh - 4) top = vh - ttH - 4;

  // Horizontally centred on slot, clamped to viewport
  let left = rect.left + rect.width / 2 - ttW / 2;
  left = Math.max(4, Math.min(left, vw - ttW - 4));

  tt.style.top  = `${top}px`;
  tt.style.left = `${left}px`;
}

async function onSlotEnter(tile, slots) {
  const slotId = parseInt(tile.dataset.slotId, 10);
  const slot   = slots.find(s => s.slot_id === slotId);
  if (!slot?.item_id) return;

  const tt = getTooltipEl();
  tt.innerHTML = '<div class="tt-loading">Loading…</div>';
  tt.classList.add('tt-visible');
  positionTooltip(tt, tile);

  const data = await fetchItemData(slot.item_id);
  if (!tt.classList.contains('tt-visible')) return; // mouse left during fetch

  if (!data) {
    tt.innerHTML = `<div class="tt-header"><div class="tt-title"><div class="tt-name">${escHtml(slot.name || `Item #${slot.item_id}`)}</div></div></div>`;
  } else {
    tt.innerHTML = buildTooltipHtml(data, slot.slot_name);
  }
  positionTooltip(tt, tile);
}

function onSlotLeave() {
  getTooltipEl().classList.remove('tt-visible');
}

// ── Equipment loader ──────────────────────────────────────────────────────────

async function loadEquipment(charid) {
  const loading = qs('#equip-loading');
  const wrap    = qs('#equip-wrap');

  let slots;
  try {
    const res = await fetch(`/api/character/${charid}/equipment`, { credentials: 'include' });
    slots = await res.json();
    if (!res.ok) throw new Error(slots.error || 'Failed to load equipment.');
  } catch (e) {
    if (loading) loading.textContent = `Could not load equipment: ${e.message}`;
    return;
  }

  const grid = qs('#equip-grid');
  grid.innerHTML = slots.map(slot => {
    const filled   = slot.item_id != null;
    const cls      = ['equip-slot', filled ? 'slot-filled' : 'slot-empty'].join(' ');
    const iconSrc  = filled ? `/item-icon/${slot.item_id}` : '';

    const imgTag = filled
      ? `<img class="equip-slot-img" src="${iconSrc}"
             alt="${escHtml(slot.name)}"
             onerror="this.src='/item-icon/0'">`
      : '';

    return `
      <div class="${cls}"
           data-slot-id="${slot.slot_id}"
           data-item-id="${slot.item_id ?? ''}"
           data-slot-name="${escHtml(slot.slot_name)}">
        ${imgTag}
        <span class="equip-slot-label">${escHtml(slot.slot_name)}</span>
      </div>`;
  }).join('');

  grid.querySelectorAll('.equip-slot.slot-filled').forEach(tile => {
    tile.addEventListener('click',      () => showItemDetail(tile, slots));
    tile.addEventListener('mouseenter', () => onSlotEnter(tile, slots));
    tile.addEventListener('mouseleave', onSlotLeave);
  });

  if (loading) hide(loading);
  show(wrap);
}

// ── Item detail panel (click) ─────────────────────────────────────────────────

function showItemDetail(tile, slots) {
  const slotId = parseInt(tile.dataset.slotId, 10);
  const slot   = slots.find(s => s.slot_id === slotId);
  if (!slot || !slot.item_id) return;

  document.querySelectorAll('.equip-slot').forEach(t => t.classList.remove('slot-active'));
  tile.classList.add('slot-active');

  const panel = qs('#equip-detail');
  qs('#equip-detail-icon').src           = `/item-icon/${slot.item_id}`;
  qs('#equip-detail-name').textContent   = slot.name ?? `Item #${slot.item_id}`;

  const stats = [];
  if (slot.req_level) stats.push(['Lv. Req',  slot.req_level]);
  if (slot.ilevel)    stats.push(['iLevel',   slot.ilevel]);
  stats.push(['Slot',    slot.slot_name]);
  stats.push(['Item ID', slot.item_id]);

  qs('#equip-detail-stats').innerHTML = stats
    .map(([k,v]) => `<dt>${k}</dt><dd>${v}</dd>`)
    .join('');

  // Populate parsed description
  const descEl = qs('#equip-detail-desc');
  if (descEl) {
    const cached = _itemCache[slot.item_id];
    if (cached?.description) {
      const lines = cached.description.split('\n').map(l => l.trim()).filter(Boolean);
      descEl.innerHTML = lines.map(l => `<div class="tt-line">${parseDescLine(l)}</div>`).join('');
      show(descEl);
    } else {
      hide(descEl);
      // Fetch and fill asynchronously
      fetchItemData(slot.item_id).then(data => {
        if (data?.description) {
          const lines = data.description.split('\\n').map(l => l.trim()).filter(Boolean);
          descEl.innerHTML = lines.map(l => `<div class="tt-line">${parseDescLine(l)}</div>`).join('');
          show(descEl);
        }
      });
    }
  }

  show(panel);
}

document.addEventListener('DOMContentLoaded', () => {
  const closeBtn = qs('#equip-detail-close');
  if (closeBtn) {
    closeBtn.addEventListener('click', () => {
      hide(qs('#equip-detail'));
      document.querySelectorAll('.equip-slot').forEach(t => t.classList.remove('slot-active'));
    });
  }
});

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  initNav();
  initTabs();

  const charid = charIdFromUrl();
  if (!charid) {
    qs('#state-loading') && hide(qs('#state-loading'));
    qs('#error-text').textContent = 'No character ID specified.';
    show(qs('#state-error'));
    return;
  }

  let data;
  try {
    const res = await fetch(`/api/character/${charid}`, { credentials: 'include' });
    data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Failed to load.');
  } catch (err) {
    hide(qs('#state-loading'));
    qs('#error-text').textContent = err.message;
    show(qs('#state-error'));
    return;
  }

  qs('#char-avatar').textContent = data.name[0].toUpperCase();
  qs('#char-name').textContent   = data.name;
  qs('#char-sub').textContent    = `${data.race_name} · ${data.nation_name}`;

  const subLine = data.sub_job
    ? `${data.main_job}${data.main_job_level} / ${data.sub_job}${data.sub_job_level}`
    : `${data.main_job}${data.main_job_level}`;
  qs('#char-job-line').textContent = subLine;
  qs('#char-playtime').textContent = `Playtime: ${data.playtime_hours}h ${data.playtime_mins}m`;

  document.title = `${data.name} — MimicXI`;

  if (data.is_owner && data.private) {
    const p = data.private;
    qs('#stat-gil').textContent  = fmt(p.gil) + ' gil';
    qs('#stat-cp-s').textContent = fmt(p.conquest_points.sandoria);
    qs('#stat-cp-b').textContent = fmt(p.conquest_points.bastok);
    qs('#stat-cp-w').textContent = fmt(p.conquest_points.windurst);
    show(qs('#private-banner'));
  }

  renderOverview(data);
  renderJobs(data);
  renderFame(data);

  let equipLoaded = false;
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      if (btn.dataset.tab === 'equipment' && !equipLoaded) {
        equipLoaded = true;
        loadEquipment(charid);
      }
    });
  });

  hide(qs('#state-loading'));
  show(qs('#profile'));
}

main();
