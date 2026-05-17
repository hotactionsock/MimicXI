'use strict';

// ── Helpers ───────────────────────────────────────────────────────────────────

function qs(sel) { return document.querySelector(sel); }
function show(el) { el.style.display = ''; }
function hide(el) { el.style.display = 'none'; }

function fmt(n) { return Number(n).toLocaleString(); }

function starRating(tier) {
  return '★'.repeat(tier) + '☆'.repeat(8 - tier);
}

// Read ?id= from URL
function charIdFromUrl() {
  return new URLSearchParams(window.location.search).get('id');
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
  // Character detail card
  const charDl = qs('#detail-character');
  const rows = [
    ['Race',    d.race_name],
    ['Nation',  d.nation_name],
    ['Size',    d.size],
    ['Face',    d.face_label],
  ];
  charDl.innerHTML = rows.map(([k,v]) =>
    `<dt>${k}</dt><dd>${v}</dd>`
  ).join('');

  // Rank card
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
  const grid  = qs('#jobs-grid');
  const maxLv = 75;
  const mainAbbr = d.main_job;

  grid.innerHTML = d.jobs.map(j => {
    const pct     = Math.min(100, (j.level / maxLv) * 100).toFixed(1);
    const isMain  = j.abbr === mainAbbr;
    const hasLevel = j.level > 0;
    const cls = [
      'job-row',
      isMain  ? 'job-main'     : '',
      !hasLevel ? 'job-inactive' : '',
    ].join(' ').trim();

    return `
      <div class="${cls}" title="${j.name}">
        <span class="job-abbr">${j.abbr}</span>
        <div class="job-bar-wrap">
          <div class="job-bar-fill" style="width:${pct}%"></div>
        </div>
        <span class="job-level">${j.level || '—'}</span>
      </div>`;
  }).join('');
}

function renderFame(d) {
  const list = qs('#fame-list');
  list.innerHTML = Object.values(d.fame).map(f => {
    const pct  = Math.min(100, (f.value / 1500) * 100).toFixed(1);
    return `
      <div class="fame-row">
        <span class="fame-label">${f.label}</span>
        <div class="fame-bar-wrap">
          <div class="fame-bar-fill" style="width:${pct}%"></div>
        </div>
        <span class="fame-value">${fmt(f.value)}</span>
        <span class="fame-tier" title="Fame tier ${f.tier}">
          <span class="fame-stars">${starRating(f.tier)}</span>
        </span>
      </div>`;
  }).join('');
}

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
    const nameAttr = filled ? `data-item-name="${escHtml(slot.name)}"` : '';
    const iconSrc  = filled ? `/item-icon/${slot.item_id}` : '';

    const imgTag = filled
      ? `<img class="equip-slot-img" src="${iconSrc}"
             alt="${escHtml(slot.name)}"
             onerror="this.src='/item-icon/0'">`
      : '';

    return `
      <div class="${cls}" ${nameAttr}
           data-slot-id="${slot.slot_id}"
           data-item-id="${slot.item_id ?? ''}"
           data-slot-name="${escHtml(slot.slot_name)}">
        ${imgTag}
        <span class="equip-slot-label">${escHtml(slot.slot_name)}</span>
      </div>`;
  }).join('');

  // Click → detail panel
  grid.querySelectorAll('.equip-slot.slot-filled').forEach(tile => {
    tile.addEventListener('click', () => showItemDetail(tile, slots));
  });

  if (loading) hide(loading);
  show(wrap);
}

function escHtml(str) {
  return String(str ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function showItemDetail(tile, slots) {
  const slotId = parseInt(tile.dataset.slotId, 10);
  const slot   = slots.find(s => s.slot_id === slotId);
  if (!slot || !slot.item_id) return;

  // Highlight active slot
  document.querySelectorAll('.equip-slot').forEach(t => t.classList.remove('slot-active'));
  tile.classList.add('slot-active');

  const panel = qs('#equip-detail');
  qs('#equip-detail-icon').src = `/item-icon/${slot.item_id}`;
  qs('#equip-detail-name').textContent = slot.name ?? `Item #${slot.item_id}`;

  const stats = [];
  if (slot.req_level) stats.push(['Lv. Req', slot.req_level]);
  if (slot.ilevel)    stats.push(['iLevel', slot.ilevel]);
  stats.push(['Slot', slot.slot_name]);
  stats.push(['Item ID', slot.item_id]);

  qs('#equip-detail-stats').innerHTML = stats
    .map(([k,v]) => `<dt>${k}</dt><dd>${v}</dd>`)
    .join('');

  show(panel);
}

// Close detail panel
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

  // ── Header
  qs('#char-avatar').textContent = data.name[0].toUpperCase();
  qs('#char-name').textContent   = data.name;
  qs('#char-sub').textContent    = `${data.race_name} · ${data.nation_name}`;

  const subLine = data.sub_job
    ? `${data.main_job}${data.main_job_level} / ${data.sub_job}${data.sub_job_level}`
    : `${data.main_job}${data.main_job_level}`;
  qs('#char-job-line').textContent  = subLine;
  qs('#char-playtime').textContent  = `Playtime: ${data.playtime_hours}h ${data.playtime_mins}m`;

  document.title = `${data.name} — MimicXI`;

  // ── Private section
  if (data.is_owner && data.private) {
    const p = data.private;
    qs('#stat-gil').textContent   = fmt(p.gil) + ' gil';
    qs('#stat-cp-s').textContent  = fmt(p.conquest_points.sandoria);
    qs('#stat-cp-b').textContent  = fmt(p.conquest_points.bastok);
    qs('#stat-cp-w').textContent  = fmt(p.conquest_points.windurst);
    show(qs('#private-banner'));
  }

  // ── Tabs: render static tabs immediately
  renderOverview(data);
  renderJobs(data);
  renderFame(data);

  // Equipment loads lazily when the tab is first clicked
  let equipLoaded = false;
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      if (btn.dataset.tab === 'equipment' && !equipLoaded) {
        equipLoaded = true;
        loadEquipment(charid);
      }
    });
  });

  // ── Swap loading → profile
  hide(qs('#state-loading'));
  show(qs('#profile'));
}

main();
