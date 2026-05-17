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

function renderEquipment() {
  const slots = [
    ['🪖','Head'], ['🥋','Body'], ['🧤','Hands'],
    ['👖','Legs'], ['👢','Feet'], ['💍','Ring 1'],
    ['💍','Ring 2'], ['📿','Neck'], ['⌚','Waist'],
    ['🏹','Ranged'], ['⚔️','Main'], ['🛡️','Sub'],
    ['🎯','Ammo'], ['🏷️','Back'],
  ];
  qs('#equip-slots').innerHTML = slots.map(([icon, label]) => `
    <div class="equip-slot">
      <span class="equip-slot-icon">${icon}</span>
      <span class="equip-slot-label">${label}</span>
    </div>`).join('');
}

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

  // ── Tabs
  renderOverview(data);
  renderJobs(data);
  renderFame(data);
  renderEquipment();

  // ── Swap loading → profile
  hide(qs('#state-loading'));
  show(qs('#profile'));
}

main();
