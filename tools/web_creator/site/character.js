/**
 * MimicXI — character profile page logic.
 *
 * Fetches one character's data, renders the tabbed profile, lazy-loads
 * equipment on demand.
 *
 * Expected backend endpoints (build these in Flask):
 *
 *   GET /api/character/<charid>
 *     200 → {
 *       charid, name, race, face, size, nation,
 *       mjob, mjob_level, sjob, sjob_level,
 *       playtime_seconds,            // optional
 *       is_owner: true|false,        // true if session.accid == chars.accid
 *       jobs: [                      // 22 entries — one per job
 *         { id, name, abbr, level, exp, unlocked }
 *       ],
 *       ranks: {
 *         nation_name, rank, rank_points
 *       },
 *       fame: [                      // optional
 *         { area, level, points }
 *       ],
 *       private: {                   // only present if is_owner
 *         gil, cp_sandoria, cp_bastok, cp_windurst
 *       }
 *     }
 *     404 → { error: "..." }
 *
 *   GET /api/character/<charid>/equipment
 *     200 → {
 *       slots: {
 *         main:   { item_id, name, icon_url, stats: {DMG:41, Delay:224, ...}, description },
 *         sub:    null,
 *         ranged: { ... },
 *         ...
 *         feet:   null
 *       }
 *     }
 *
 * Until those exist, the page falls back to /api/characters and renders
 * the basics (race, nation, face) so you can see the layout.
 */

(function () {
  // ── constants
  const RACES = {
    1: "Hume (M)", 2: "Hume (F)",
    3: "Elvaan (M)", 4: "Elvaan (F)",
    5: "Tarutaru (M)", 6: "Tarutaru (F)",
    7: "Mithra", 8: "Galka",
  };
  const NATIONS = { 0: "San d'Oria", 1: "Bastok", 2: "Windurst" };
  const NATION_META = {
    0: { key: "sandoria", name: "San d'Oria", icon: "Sandorian_Iconv2.png" },
    1: { key: "bastok",   name: "Bastok",     icon: "Bastok_Iconv2.png"    },
    2: { key: "windurst", name: "Windurst",   icon: "Windurst_Iconv2.png"  },
  };
  const RACE_HUE = {
    1: "#8cc5e8", 2: "#8cc5e8",
    3: "#c9a8d6", 4: "#c9a8d6",
    5: "#e8c785", 6: "#e8c785",
    7: "#d9a8b3", 8: "#8fb59e",
  };
  const SIZES = { 0: "Small", 1: "Medium", 2: "Large" };

  // Standard FFXI job list — index aligns with mjob/sjob values.
  const JOBS_BY_ID = [
    null,
    { name: "Warrior",       abbr: "WAR" },
    { name: "Monk",          abbr: "MNK" },
    { name: "White Mage",    abbr: "WHM" },
    { name: "Black Mage",    abbr: "BLM" },
    { name: "Red Mage",      abbr: "RDM" },
    { name: "Thief",         abbr: "THF" },
    { name: "Paladin",       abbr: "PLD" },
    { name: "Dark Knight",   abbr: "DRK" },
    { name: "Beastmaster",   abbr: "BST" },
    { name: "Bard",          abbr: "BRD" },
    { name: "Ranger",        abbr: "RNG" },
    { name: "Samurai",       abbr: "SAM" },
    { name: "Ninja",         abbr: "NIN" },
    { name: "Dragoon",       abbr: "DRG" },
    { name: "Summoner",      abbr: "SMN" },
    { name: "Blue Mage",     abbr: "BLU" },
    { name: "Corsair",       abbr: "COR" },
    { name: "Puppetmaster",  abbr: "PUP" },
    { name: "Dancer",        abbr: "DNC" },
    { name: "Scholar",       abbr: "SCH" },
    { name: "Geomancer",     abbr: "GEO" },
    { name: "Rune Fencer",   abbr: "RUN" },
  ];

  // Equipment slots in display order (FFXI standard 4×4 grid).
  const SLOT_ORDER = [
    { key: "main",   label: "Main" },
    { key: "sub",    label: "Sub"  },
    { key: "ranged", label: "Ranged" },
    { key: "ammo",   label: "Ammo" },
    { key: "head",   label: "Head" },
    { key: "neck",   label: "Neck" },
    { key: "ear1",   label: "Earring 1" },
    { key: "ear2",   label: "Earring 2" },
    { key: "body",   label: "Body" },
    { key: "hands",  label: "Hands" },
    { key: "ring1",  label: "Ring 1"  },
    { key: "ring2",  label: "Ring 2"  },
    { key: "back",   label: "Back"  },
    { key: "waist",  label: "Waist" },
    { key: "legs",   label: "Legs"  },
    { key: "feet",   label: "Feet"  },
  ];

  // DB slot_id → SLOT_ORDER key (mirrors _SLOT_DEFS in app.py)
  const SLOT_ID_TO_KEY = {
    0:"main", 1:"sub", 2:"ranged", 3:"ammo",
    4:"head", 5:"body", 6:"hands", 7:"legs", 8:"feet",
    9:"neck", 10:"waist", 11:"ear1", 12:"ear2",
    13:"ring1", 14:"ring2", 15:"back",
  };

  // Equipment rarity → crystal hue + display label.
  // Pass on the item as `rarity: "rare"` (preferred) or `tier: 3`.
  const RARITY = {
    common:      { label: "Common",      hue: "#9b94a8" },
    uncommon:    { label: "Uncommon",    hue: "#7fbf94" },
    rare:        { label: "Rare",        hue: "#6dadd8" },
    exceptional: { label: "Exceptional", hue: "#b787c9" },
    relic:       { label: "Relic",       hue: "#e8c785" },
    mythic:      { label: "Mythic",      hue: "#f0a85b" },
    empyrean:    { label: "Empyrean",    hue: "#5fa3cf" },
    custom:      { label: "Custom",      hue: "#d97a5c" },
  };
  const TIER_TO_RARITY = ["common", "common", "uncommon", "rare", "exceptional", "relic"];
  function itemRarity(item) {
    if (!item) return RARITY.common;
    if (item.rarity && RARITY[item.rarity]) return Object.assign({ key: item.rarity }, RARITY[item.rarity]);
    if (typeof item.tier === "number") {
      const k = TIER_TO_RARITY[Math.max(0, Math.min(5, item.tier))];
      return Object.assign({ key: k }, RARITY[k]);
    }
    return Object.assign({ key: "common" }, RARITY.common);
  }

  // Currency catalogue — id → display name + hue for the crystal icon.
  // Backend can return any subset; unknown ids fall back to a generic slate.
  const CURRENCY_META = {
    sandoria_cp:       { name: "San d'Oria CP",        hue: "#b85060" },
    bastok_cp:         { name: "Bastok CP",            hue: "#4a7ec4" },
    windurst_cp:       { name: "Windurst CP",          hue: "#5a9e6e" },
    obsidian_fragment: { name: "Obsidian Fragments",   hue: "#3a3550" },
    allied_notes:      { name: "Allied Notes",         hue: "#e4d6a7" },
    bayld:             { name: "Bayld",                hue: "#9dc7e8" },
    cruor:             { name: "Cruor",                hue: "#c75c5c" },
    imperial_standing: { name: "Imperial Standing",    hue: "#c79a4a" },
    sparks:            { name: "Sparks of Eminence",   hue: "#f3d28a" },
    therion_ichor:     { name: "Therion Ichor",        hue: "#5f9d6e" },
    voidstone:         { name: "Voidstones",           hue: "#7a5fa3" },
    cinders:           { name: "Cinders",              hue: "#d4895c" },
    coalition_imprimaturs: { name: "Coalition Imprimaturs", hue: "#b5a05f" },
  };

  // Quest status enum.
  const QUEST_STATUSES = {
    not_started: { label: "Not started" },
    in_progress: { label: "In progress" },
    completed:   { label: "Completed" },
    available:   { label: "Available" },
  };

  // Canonical stat name → display label.
  // Anything not in this map gets shown as-is.
  const STAT_NAMES = {
    "str": "STR", "dex": "DEX", "vit": "VIT", "agi": "AGI",
    "int": "INT", "mnd": "MND", "chr": "CHR",
    "hp": "HP", "mp": "MP",
    "acc": "Accuracy", "accuracy": "Accuracy",
    "att": "Attack", "atk": "Attack", "attack": "Attack",
    "eva": "Evasion", "evasion": "Evasion",
    "magic acc": "Magic Accuracy", "magic accuracy": "Magic Accuracy", "macc": "Magic Accuracy",
    "magic atk": "Magic Attack", "magic attack": "Magic Attack", "matk": "Magic Attack",
    "rng. acc": "Ranged Accuracy", "ranged acc": "Ranged Accuracy", "ranged accuracy": "Ranged Accuracy",
    "rng. atk": "Ranged Attack", "ranged atk": "Ranged Attack", "ranged attack": "Ranged Attack",
    "haste": "Haste",
    "dual wield": "Dual Wield",
    "dbl. atk": "Double Attack", "double attack": "Double Attack",
    "crit rate": "Crit Rate", "critical hit rate": "Crit Rate",
    "movement": "Movement Speed", "movement speed": "Movement Speed",
  };

  // Display order for the totals panel.
  const STAT_ORDER = [
    "HP", "MP",
    "STR", "DEX", "VIT", "AGI", "INT", "MND", "CHR",
    "Accuracy", "Attack",
    "Magic Accuracy", "Magic Attack",
    "Ranged Accuracy", "Ranged Attack",
    "Evasion",
    "Haste", "Dual Wield", "Double Attack", "Crit Rate", "Movement Speed",
  ];

  // ── helpers
  function $(id) { return document.getElementById(id); }
  function show(id) { const e = $(id); if (e) e.style.display = ""; }
  function hide(id) { const e = $(id); if (e) e.style.display = "none"; }
  function escapeHtml(s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, c => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
    }[c]));
  }
  function fmt(n) {
    if (n == null || isNaN(n)) return "—";
    return Number(n).toLocaleString();
  }
  function faceLabel(v) {
    if (v == null) return "—";
    if (v <= 15) return `Face ${Math.floor(v/2)+1}${v%2===0?'A':'B'}`;
    if (v <= 23) return `Face ${v-15}C`;
    return `Face ${v}`;
  }
  function jobInfo(id) { return JOBS_BY_ID[id] || { name: "Unknown", abbr: "?" }; }

  function crystalSVG(color, size) {
    const s = size || 140;
    return `
      <svg viewBox="0 0 ${s} ${s}" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <defs>
          <radialGradient id="char-glow" cx="50%" cy="50%" r="55%">
            <stop offset="0" stop-color="${color}66"/>
            <stop offset="1" stop-color="${color}00"/>
          </radialGradient>
          <linearGradient id="char-fill" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="${color}"/>
            <stop offset="1" stop-color="${color}88"/>
          </linearGradient>
        </defs>
        <circle cx="${s/2}" cy="${s/2}" r="${s/2 - 4}" fill="url(#char-glow)"/>
        <g transform="translate(${s/2} ${s/2})">
          <path d="M0 -${s*0.36} L${s*0.22} -${s*0.05} L0 ${s*0.40} L-${s*0.22} -${s*0.05} Z"
                fill="url(#char-fill)" stroke="${color}" stroke-width="1.5" stroke-linejoin="round"/>
          <path d="M0 -${s*0.36} L-${s*0.10} -${s*0.05} L0 ${s*0.40} L${s*0.10} -${s*0.05} Z"
                fill="${color}" opacity="0.55"/>
          <path d="M-${s*0.22} -${s*0.05} L${s*0.22} -${s*0.05}" stroke="${color}" stroke-width="1" opacity="0.7"/>
          <path d="M0 -${s*0.36} L0 ${s*0.40}" stroke="#ffffff" stroke-width="0.7" opacity="0.45"/>
        </g>
      </svg>`;
  }

  // ── data fetching
  const charId = new URLSearchParams(location.search).get("id");

  async function loadCharacter() {
    if (!charId) return showError("No character id in URL.");

    // Character profiles are public — no auth gate.
    // The API sets is_owner:true only when the session matches the character's account,
    // which gates the private banner (Gil, CP) without blocking public viewing.
    const r = await MimicAuth.api("/api/character/" + encodeURIComponent(charId));
    if (r.ok) return renderProfile(r.data);

    if (r.status === 404) return showError("Character #" + charId + " not found.");
    return showError((r.data && r.data.error) || ("Couldn't load character (" + r.status + ")."));
  }

  function showError(msg) {
    hide("state-loading");
    $("error-text").textContent = msg;
    show("state-error");
  }

  // ── render
  function renderProfile(c) {
    hide("state-loading");
    show("profile");

    const hue = RACE_HUE[c.race] || "#8cc5e8";
    $("char-avatar").innerHTML = crystalSVG(hue) + `<span class="initial">${escapeHtml((c.name || "?")[0])}</span>`;

    $("char-name").textContent = c.name || "—";

    const subParts = [];
    if (c.race != null)   subParts.push(RACES[c.race] || ("Race " + c.race));
    if (c.nation != null) subParts.push(NATIONS[c.nation] || ("Nation " + c.nation));
    if (c.size != null)   subParts.push(SIZES[c.size] || ("Size " + c.size));
    $("char-sub").innerHTML = subParts.map(escapeHtml).join('<span class="sep">·</span>');

    const mj = c.mjob ? jobInfo(c.mjob) : null;
    const sj = c.sjob ? jobInfo(c.sjob) : null;
    const jobLine = $("char-job-line");
    if (mj) {
      let html = `<span class="mjob">${escapeHtml(mj.name)}</span>`;
      if (c.mjob_level) html += ` <span class="lvl">Lv ${c.mjob_level}</span>`;
      if (sj && c.sjob !== c.mjob) {
        html += ` <span style="color:var(--ink-faint);"> / </span> `;
        html += `<span class="sjob">${escapeHtml(sj.name)}</span>`;
        if (c.sjob_level) html += ` <span class="lvl">Lv ${c.sjob_level}</span>`;
      }
      jobLine.innerHTML = html;
    } else {
      jobLine.style.display = "none";
    }

    if (c.playtime_seconds != null) {
      const h = Math.floor(c.playtime_seconds / 3600);
      const d = Math.floor(h / 24);
      $("char-playtime").textContent = d > 0
        ? `${d} day${d===1?"":"s"} ${h % 24}h played`
        : `${h}h played`;
    } else {
      $("char-playtime").style.display = "none";
    }

    // Private banner (owner only)
    if (c.is_owner && c.private) {
      $("stat-gil").textContent  = fmt(c.private.gil);
      $("stat-cp-s").textContent = fmt(c.private.cp_sandoria);
      $("stat-cp-b").textContent = fmt(c.private.cp_bastok);
      $("stat-cp-w").textContent = fmt(c.private.cp_windurst);
      show("private-banner");
    }

    // Overview tab
    renderOverview(c);
    renderJobs(c.jobs || []);
    renderFame(c.fame || []);
    renderCurrency(c.currencies || []);
    renderSkills(c.skills || {});
    renderCraft(c.crafts || []);
    renderHistory(c.history || null);

    // Tab wiring
    document.querySelectorAll(".tab-btn").forEach(btn => {
      btn.addEventListener("click", () => activateTab(btn.dataset.tab));
    });

    // Lazy-load equipment when its tab is opened
    let equipLoaded = false;
    const equipTabBtn = document.querySelector('.tab-btn[data-tab="equipment"]');
    if (equipTabBtn) equipTabBtn.addEventListener("click", () => {
      if (!equipLoaded) { equipLoaded = true; loadEquipment(); }
    });

    // Lazy-load quests when their tab is opened
    let questsLoaded = false;
    const questTabBtn = document.querySelector('.tab-btn[data-tab="quests"]');
    if (questTabBtn) questTabBtn.addEventListener("click", () => {
      if (!questsLoaded) { questsLoaded = true; loadQuests(); }
    });
  }

  function renderOverview(c) {
    const ranks = c.ranks || {};

    // Apply nation theme to entire profile
    const nationMeta = NATION_META[c.nation];
    const profile = document.getElementById("profile");
    if (profile && nationMeta) profile.dataset.nation = nationMeta.key;

    const mjob = c.main_job ? `${c.main_job} ${c.main_job_level || '?'}` : '—';
    const sjob = c.sub_job  ? `${c.sub_job} ${c.sub_job_level || '?'}`  : null;

    const ph = c.playtime_hours || 0;
    const pm = c.playtime_mins  || 0;
    const playtime = ph ? `${ph}h ${pm}m` : '—';

    // Face portrait
    const portraitWrap = $("face-portrait-wrap");
    const portraitImg  = $("face-portrait");
    if (portraitImg && c.race && c.face != null) {
      portraitImg.src = `/face-icon/${c.race}/${c.face}`;
      portraitImg.alt = c.face_label || "";
      portraitImg.onload  = () => { if (portraitWrap) portraitWrap.style.display = ""; };
      portraitImg.onerror = () => { if (portraitWrap) portraitWrap.style.display = "none"; };
    }

    const charList = [
      ["Race",     c.race_name   || "—"],
      ["Nation",   c.nation_name || "—"],
      ["Size",     c.size        || "—"],
      ["Face",     c.face_label  || "—"],
      ["Main Job", mjob],
      sjob ? ["Sub Job", sjob] : null,
      ["Playtime", playtime],
    ].filter(Boolean);
    $("detail-character").innerHTML = charList.map(([k, v]) =>
      `<dt>${escapeHtml(k)}</dt><dd>${escapeHtml(v)}</dd>`).join("");

    // Nation hero card
    if (nationMeta) {
      const flagEl = $("nation-flag-lg");
      if (flagEl) { flagEl.src = `/nation-icon/${nationMeta.icon}`; flagEl.alt = nationMeta.name; }

      const nameEl = $("nation-home-name");
      if (nameEl) nameEl.textContent = nationMeta.name;

      const homeRank = ranks[nationMeta.key];
      const pillEl = $("nation-rank-pill");
      if (pillEl) pillEl.textContent = homeRank != null ? `Rank ${homeRank}` : "Rank —";

      const othersEl = $("nation-others");
      if (othersEl) {
        othersEl.innerHTML = Object.entries(NATION_META)
          .filter(([id]) => parseInt(id) !== c.nation)
          .map(([id, n]) => {
            const r = ranks[n.key];
            return `<div class="nation-other-row">
              <img class="nation-flag-sm" src="/nation-icon/${n.icon}" alt="${escapeHtml(n.name)}">
              <span class="nation-other-name">${escapeHtml(n.name)}</span>
              <span class="nation-other-rank">${r != null ? "Rank " + r : "—"}</span>
            </div>`;
          }).join("");
      }
    }
  }

  function renderJobs(jobs) {
    const list = $("jobs-list");
    if (!jobs.length) {
      list.innerHTML = `<p style="color:var(--ink-faint);">Job data unavailable.</p>`;
      return;
    }
    list.innerHTML = jobs.map(j => {
      const lvl    = j.level || 0;
      const isMax  = lvl >= 75;
      const locked = lvl === 0;
      const isMain = j.col === jobs._main_col;
      const cls    = ["job-row",
        locked ? "locked" : "",
        isMain  ? "is-main" : "",
        isMax   ? "is-max"  : "",
      ].filter(Boolean).join(" ");

      // EXP bar
      let pct = 0, tnlText = "—";
      if (isMax) {
        pct = 100; tnlText = "MAX";
      } else if (lvl > 0 && j.exp_to_next != null) {
        const needed = j.exp_to_next;
        // total EXP for this level span = exp_to_next + current exp held
        const total  = needed + (j.exp || 0);
        pct = total > 0 ? Math.round(((j.exp || 0) / total) * 100) : 0;
        tnlText = fmt(needed) + " TNL";
      }

      return `
        <div class="${cls}">
          <div class="job-abbr">${escapeHtml(j.abbr)}</div>
          <span class="job-name">${escapeHtml(j.name)}</span>
          <span class="job-lv">Lv <span class="num">${lvl || "—"}</span></span>
          <div class="job-exp-wrap"><div class="job-exp-fill" style="width:${pct}%"></div></div>
          <span class="job-tnl">${escapeHtml(tnlText)}</span>
        </div>`;
    }).join("");
  }

  function renderFame(fame) {
    const list = $("fame-list");
    if (!fame.length) {
      list.innerHTML = `<p style="color:var(--ink-faint);">Fame data unavailable.</p>`;
      return;
    }
    list.innerHTML = fame.map(f => {
      const pct = Math.min(100, ((f.points || 0) / 4000) * 100);
      return `
        <div class="fame-row">
          <span class="fame-area">${escapeHtml(f.area)}</span>
          <div class="fame-bar"><div class="fame-bar-fill" style="width:${pct}%"></div></div>
          <span class="fame-level">Fame ${f.level || 0}</span>
        </div>`;
    }).join("");
  }

  // ── currency
  function currencyIcon(hue) {
    return `
      <svg viewBox="0 0 36 36" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <defs>
          <linearGradient id="cg-${hue.replace(/[^a-f0-9]/gi,'')}" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="${hue}"/>
            <stop offset="1" stop-color="${hue}aa"/>
          </linearGradient>
        </defs>
        <path d="M18 4 L30 14 L18 32 L6 14 Z" fill="url(#cg-${hue.replace(/[^a-f0-9]/gi,'')})" stroke="${hue}" stroke-width="1.2" stroke-linejoin="round" filter="drop-shadow(0 0 6px ${hue}55)"/>
        <path d="M18 4 L11 14 L18 32 L25 14 Z" fill="${hue}" opacity="0.55"/>
        <path d="M6 14 L30 14" stroke="${hue}" stroke-width="0.7" opacity="0.8"/>
        <path d="M18 4 L18 32" stroke="#ffffff" stroke-width="0.5" opacity="0.4"/>
      </svg>`;
  }

  function renderCurrency(currencies) {
    const grid = $("currency-grid");
    if (!currencies.length) {
      grid.outerHTML = `<div class="currency-empty" id="currency-grid">No currency data available for this character.</div>`;
      return;
    }
    grid.innerHTML = currencies.map(c => {
      const meta = CURRENCY_META[c.id] || { name: c.name || c.id, hue: "#6c728a" };
      const name = c.name || meta.name;
      const zero = !c.amount;
      return `
        <div class="currency-card ${zero ? "zero" : ""}">
          <div class="currency-icon">${currencyIcon(meta.hue)}</div>
          <div class="currency-meta">
            <span class="currency-amount">${fmt(c.amount || 0)}</span>
            <span class="currency-name">${escapeHtml(name)}</span>
          </div>
        </div>`;
    }).join("");
  }

  // ── skills
  function renderSkills(skills) {
    const el = $("skills-content");
    const cats = Object.keys(skills);
    if (!cats.length) {
      el.innerHTML = `<p style="color:var(--ink-faint);">No skill data available.</p>`;
      return;
    }
    el.innerHTML = cats.map(cat => {
      const list = skills[cat];
      const cap  = list[0] ? list[0].cap : 276;
      return `
        <div class="skill-group">
          <h4 class="skill-group-title">${escapeHtml(cat)}</h4>
          ${list.map(s => {
            const pct = Math.min(100, Math.round((s.level / cap) * 100));
            return `
              <div class="skill-row">
                <span class="skill-name">${escapeHtml(s.name)}</span>
                <div class="skill-bar-wrap"><div class="skill-bar-fill" style="width:${pct}%"></div></div>
                <span class="skill-val">${s.level}</span>
              </div>`;
          }).join("")}
        </div>`;
    }).join("");
  }

  // ── craft skills
  function renderCraft(crafts) {
    const el = $("craft-content");
    if (!crafts.length) {
      el.innerHTML = `<p style="color:var(--ink-faint);">No craft data available.</p>`;
      return;
    }
    const CAP = 110;
    el.innerHTML = `
      <div class="skill-group">
        <h4 class="skill-group-title">Crafting Skills</h4>
        ${crafts.map(s => {
          const pct = Math.min(100, Math.round((s.level / CAP) * 100));
          const atCap = s.level >= CAP;
          return `
            <div class="skill-row">
              <span class="skill-name">${escapeHtml(s.name)}</span>
              <div class="skill-bar-wrap">
                <div class="skill-bar-fill craft-fill${atCap ? ' at-cap' : ''}" style="width:${pct}%"></div>
              </div>
              <span class="skill-val${atCap ? ' at-cap' : ''}">${s.level}</span>
            </div>`;
        }).join("")}
      </div>`;
  }

  // ── history
  function renderHistory(h) {
    const el = $("history-content");
    if (!h) {
      el.innerHTML = `<p style="color:var(--ink-faint);">No history data available.</p>`;
      return;
    }
    const ph = h.playtime_hours || 0;
    const days = Math.floor(ph / 24);
    const remH = ph % 24;
    const playtimeStr = days > 0 ? `${days}d ${remH}h` : `${ph}h`;

    function statCard(label, val) {
      if (val === null || val === undefined) return "";
      return `<div class="history-stat">
        <span class="history-val">${escapeHtml(String(val))}</span>
        <span class="history-label">${escapeHtml(label)}</span>
      </div>`;
    }
    function section(title, cards) {
      const inner = cards.join("");
      if (!inner) return "";
      return `<div class="history-section">
        <h4 class="history-section-title">${escapeHtml(title)}</h4>
        <div class="history-grid">${inner}</div>
      </div>`;
    }

    const yalms = h.distance_travelled;
    const distStr = yalms != null ? fmt(yalms) + " yalms" : null;

    el.innerHTML = [
      section("Progression", [
        statCard("Jobs Mastered (Lv75)", fmt(h.jobs_mastered)),
        statCard("Total Job Levels",     fmt(h.total_levels)),
        statCard("Skills at Cap",        fmt(h.skills_at_cap)),
        statCard("Conquest Points",      fmt(h.total_cp)),
        statCard("Time Played",          playtimeStr),
      ]),
      section("Combat", [
        statCard("Enemies Defeated",  h.enemies_defeated != null ? fmt(h.enemies_defeated) : null),
        statCard("Battles Fought",    h.battles_fought   != null ? fmt(h.battles_fought)   : null),
        statCard("Weapon Skills Used",h.ws_used          != null ? fmt(h.ws_used)           : null),
        statCard("Times KO'd",        h.times_knocked_out!= null ? fmt(h.times_knocked_out) : null),
        statCard("FATEs Completed",   h.fate_completions != null ? fmt(h.fate_completions)  : null),
      ]),
      section("Magic & Abilities", [
        statCard("Spells Cast",      h.spells_cast    != null ? fmt(h.spells_cast)    : null),
        statCard("Abilities Used",   h.abilities_used != null ? fmt(h.abilities_used) : null),
        statCard("Items Used",       h.items_used     != null ? fmt(h.items_used)     : null),
      ]),
      section("World", [
        statCard("Parties Joined",   h.joined_parties   != null ? fmt(h.joined_parties)   : null),
        statCard("Alliances Joined", h.joined_alliances != null ? fmt(h.joined_alliances) : null),
        statCard("NPC Interactions", h.npc_interactions != null ? fmt(h.npc_interactions) : null),
        statCard("Chats Sent",       h.chats_sent       != null ? fmt(h.chats_sent)       : null),
        statCard("Mog House Visits", h.mh_entrances     != null ? fmt(h.mh_entrances)     : null),
        statCard("Distance Travelled", distStr),
      ]),
    ].join("");
  }

  // ── quests
  function questIcon(status) {
    if (status === "completed") {
      return `<svg viewBox="0 0 16 16" fill="none"><path d="M3 8 L7 12 L13 4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>`;
    }
    if (status === "in_progress") {
      return `<svg viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="3" fill="currentColor"/></svg>`;
    }
    if (status === "available") {
      return `<svg viewBox="0 0 16 16" fill="none"><path d="M8 4 L8 9 M8 11.5 L8 12.5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>`;
    }
    return `<svg viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="2" fill="currentColor" opacity="0.6"/></svg>`;
  }

  let _allQuests = [];
  let _questFilter = "all";
  let _questSearch = "";

  function renderQuests(data) {
    const regular = (data && data.regular) ? data.regular : (Array.isArray(data) ? data : []);
    const dailies  = (data && data.dailies) ? data.dailies : [];
    _allQuests = regular;

    if (!regular.length && !dailies.length) {
      $("quest-list").innerHTML = `<p class="quest-empty">No quest data available for this character.</p>`;
      document.querySelectorAll(".qf-count").forEach(el => el.textContent = "0");
      return;
    }

    // Counts cover regular quests only (dailies live in their own section)
    const counts = { all: regular.length, not_started: 0, in_progress: 0, completed: 0 };
    regular.forEach(q => { counts[q.status] = (counts[q.status] || 0) + 1; });
    Object.entries(counts).forEach(([k, v]) => {
      const el = document.querySelector(`.qf-count[data-count="${k}"]`);
      if (el) el.textContent = v;
    });

    paintQuests();
    renderDailies(dailies);

    // Wire filter & search once
    if (!renderQuests._wired) {
      renderQuests._wired = true;
      document.getElementById("quest-filter").addEventListener("click", e => {
        const b = e.target.closest("button[data-status]"); if (!b) return;
        _questFilter = b.dataset.status;
        document.querySelectorAll("#quest-filter button").forEach(btn =>
          btn.classList.toggle("active", btn === b));
        paintQuests();
      });
      document.getElementById("quest-search").addEventListener("input", e => {
        _questSearch = e.target.value.trim().toLowerCase();
        paintQuests();
      });
    }
  }

  function paintQuests() {
    const list = $("quest-list");
    const filtered = _allQuests.filter(q => {
      if (_questFilter !== "all" && q.status !== _questFilter) return false;
      if (_questSearch && !(q.name || "").toLowerCase().includes(_questSearch) &&
          !(q.area || "").toLowerCase().includes(_questSearch)) return false;
      return true;
    });
    if (!filtered.length) {
      list.innerHTML = "";
      $("quest-empty").style.display = "";
      return;
    }
    $("quest-empty").style.display = "none";
    list.innerHTML = filtered.map(q => {
      const status = q.status || "not_started";
      const label  = (QUEST_STATUSES[status] || QUEST_STATUSES.not_started).label;
      const step   = (status === "in_progress" && q.finish > 1)
        ? `<span class="quest-step">(${q.value}/${q.finish})</span>` : "";
      return `
        <div class="quest-row">
          <div class="quest-icon ${status}">${questIcon(status)}</div>
          <div class="quest-info">
            <span class="quest-name">${escapeHtml(q.name || "Untitled quest")}${step}</span>
            ${q.area ? `<span class="quest-area">${escapeHtml(q.area)}</span>` : ""}
          </div>
          <span class="quest-status ${status}">${escapeHtml(label)}</span>
        </div>`;
    }).join("");
  }

  function renderDailies(dailies) {
    const section = document.getElementById("dailies-section");
    const list    = document.getElementById("dailies-list");
    if (!section || !list) return;
    if (!dailies.length) { section.style.display = "none"; return; }
    section.style.display = "";
    list.innerHTML = dailies.map(q => {
      const status = q.status || "available";
      const label  = (QUEST_STATUSES[status] || QUEST_STATUSES.available).label;
      return `
        <div class="quest-row">
          <div class="quest-icon ${status}">${questIcon(status)}</div>
          <div class="quest-info">
            <span class="quest-name">${escapeHtml(q.name || "Untitled")}</span>
          </div>
          <span class="quest-status ${status}">${escapeHtml(label)}</span>
        </div>`;
    }).join("");
  }

  function activateTab(name) {
    document.querySelectorAll(".tab-btn").forEach(b => {
      b.classList.toggle("active", b.dataset.tab === name);
    });
    document.querySelectorAll(".tab-panel").forEach(p => {
      p.classList.toggle("active", p.id === "tab-" + name);
    });
  }

  // ── quests
  async function loadQuests() {
    const loadingEl = document.getElementById("quest-loading");
    if (loadingEl) loadingEl.style.display = "";
    const r = await MimicAuth.api("/api/character/" + encodeURIComponent(charId) + "/quests");
    if (loadingEl) loadingEl.style.display = "none";
    if (!r.ok || !r.data) {
      $("quest-list").innerHTML = `<p class="quest-empty">Could not load quest data.</p>`;
      return;
    }
    renderQuests(r.data);
  }

  // ── equipment
  async function loadEquipment() {
    const r = await MimicAuth.api("/api/character/" + encodeURIComponent(charId) + "/equipment");
    hide("equip-loading");
    show("equip-wrap");
    document.getElementById("equip-wrap").style.display = "grid";

    renderRarityLegend();

    const haveAny = r.ok;
    const rawSlots = (r.ok && r.data && r.data.slots) || [];
    // API returns an array; convert to dict keyed by slot name for renderEquipGrid
    const slots = {};
    (Array.isArray(rawSlots) ? rawSlots : Object.values(rawSlots)).forEach(slot => {
      if (slot && slot.item_id != null) {
        const key = SLOT_ID_TO_KEY[slot.slot_id];
        if (key) slots[key] = slot;
      }
    });
    renderEquipGrid(slots, !haveAny);
    renderStatsSummary(slots);
  }

  function renderRarityLegend() {
    const list = document.getElementById("rarity-legend-list");
    if (!list || list.children.length) return;
    list.innerHTML = Object.entries(RARITY).map(([key, r]) => `
      <li class="rarity-legend-item" style="--rarity-color: ${r.hue};">
        <span class="rarity-legend-swatch" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none">
            <path d="M12 3 L20 10 L12 21 L4 10 Z" fill="${r.hue}" stroke="${r.hue}" stroke-width="0.8" stroke-linejoin="round"/>
            <path d="M12 3 L7 10 L12 21 L17 10 Z" fill="#ffffff" opacity="0.18"/>
          </svg>
        </span>
        <span class="rarity-legend-label">${r.label}</span>
      </li>
    `).join("");
  }

  // ── stats aggregation
  function normalizeStatKey(key) {
    const k = String(key).trim().toLowerCase();
    return STAT_NAMES[k] || key;
  }

  function parseStatValue(v) {
    if (v == null) return null;
    if (typeof v === "number") return { num: v, isPercent: false };
    const s = String(v);
    const isPercent = s.indexOf("%") !== -1;
    const m = s.match(/-?\+?(\d+(?:\.\d+)?)/);
    if (!m) return null;
    const sign = s.trim().startsWith("-") ? -1 : 1;
    return { num: parseFloat(m[1]) * sign, isPercent };
  }

  // Stats that are fixed weapon properties, not additive bonuses — exclude from totals.
  const STATS_EXCLUDE_FROM_TOTALS = new Set(["DMG", "Delay"]);

  function aggregateStats(slots) {
    const totals = {};   // displayName → { num, isPercent, count }
    const effects = [];  // text-only effects, deduplicated, insertion-ordered
    const effectSeen = new Set();

    function processStatDict(statsObj) {
      if (!statsObj) return;
      Object.entries(statsObj).forEach(([rawKey, rawVal]) => {
        if (STATS_EXCLUDE_FROM_TOTALS.has(rawKey)) return;
        const parsed = parseStatValue(rawVal);
        if (!parsed) {
          if (rawVal === '' && !effectSeen.has(rawKey)) {
            effectSeen.add(rawKey);
            effects.push(rawKey);
          }
          return;
        }
        const name = normalizeStatKey(rawKey);
        if (!totals[name]) totals[name] = { num: 0, isPercent: parsed.isPercent, count: 0 };
        totals[name].num += parsed.num;
        totals[name].count += 1;
        if (parsed.isPercent) totals[name].isPercent = true;
      });
    }

    Object.values(slots).forEach(item => {
      if (!item) return;
      processStatDict(item.stats);
      if (Array.isArray(item.augments)) {
        item.augments.forEach(augSlot => processStatDict(augSlot));
      }
    });
    return { totals, effects };
  }

  function renderStatsSummary(slots) {
    const list = document.getElementById("stats-summary-list");
    const wrap = document.getElementById("stats-summary");
    if (!list || !wrap) return;

    const { totals, effects } = aggregateStats(slots);
    const entries = Object.entries(totals).filter(([_, v]) => v.num !== 0);
    if (!entries.length && !effects.length) {
      wrap.style.display = "none";
      return;
    }
    wrap.style.display = "";

    // Sort by canonical order, then alphabetically for stragglers.
    entries.sort(([a], [b]) => {
      const ia = STAT_ORDER.indexOf(a);
      const ib = STAT_ORDER.indexOf(b);
      if (ia === -1 && ib === -1) return a.localeCompare(b);
      if (ia === -1) return 1;
      if (ib === -1) return -1;
      return ia - ib;
    });

    const numericHtml = entries.map(([name, v]) => {
      const sign = v.num > 0 ? "+" : "";
      const suffix = v.isPercent ? "%" : "";
      const cls = v.num > 0 ? "pos" : "neg";
      return `
        <li class="stat-row-summary">
          <span class="stat-key">${escapeHtml(name)}</span>
          <span class="stat-val ${cls}">${sign}${v.num}${suffix}</span>
        </li>`;
    }).join("");

    const effectsHtml = effects.map(e =>
      `<li class="stat-row-effect"><span class="stat-effect-text">${escapeHtml(e)}</span></li>`
    ).join("");

    list.innerHTML = numericHtml + effectsHtml;
  }

  function renderEquipGrid(slots, noData) {
    const grid = $("equip-grid");
    grid.innerHTML = SLOT_ORDER.map(s => {
      const item = slots[s.key];
      if (!item) {
        return `
          <div class="equip-slot empty" data-slot="${s.key}">
            <span class="equip-slot-label">${escapeHtml(s.label)}</span>
            <svg class="equip-empty-icon" viewBox="0 0 24 24" fill="none">
              <path d="M12 4 L20 11 L12 20 L4 11 Z" stroke="currentColor" stroke-width="1.2" stroke-linejoin="round"/>
            </svg>
            <span class="equip-slot-name">${noData ? "—" : "Empty"}</span>
          </div>`;
      }
      const r = itemRarity(item);
      const iconSrc = itemIconUrl(item);
      const icon = iconSrc
        ? `<img src="${escapeHtml(iconSrc)}" alt="${escapeHtml(item.name)}" onerror="this.replaceWith(document.createRange().createContextualFragment(this.dataset.fallback));" data-fallback="${escapeHtml(equipCrystalSVG(r.hue))}">`
        : equipCrystalSVG(r.hue);
      const sparkles = ["relic","mythic","empyrean","custom"].includes(r.key)
        ? '<span class="slot-sparkles" aria-hidden="true"></span>'
        : "";
      return `
        <button class="equip-slot rarity-${r.key}" data-slot="${s.key}" type="button"
                style="--rarity-color: ${r.hue};">
          ${sparkles}
          <span class="equip-slot-label">${escapeHtml(s.label)}</span>
          <div class="equip-slot-icon">${icon}</div>
          <span class="equip-slot-name">${escapeHtml(item.name)}</span>
        </button>`;
    }).join("");

    grid.addEventListener("click", e => {
      const slot = e.target.closest(".equip-slot:not(.empty)");
      if (!slot) return;
      grid.querySelectorAll(".equip-slot").forEach(s => s.classList.toggle("selected", s === slot));
      const slotKey = slot.dataset.slot;
      const slotMeta = SLOT_ORDER.find(s => s.key === slotKey);
      showItemDetail(slots[slotKey], slotMeta);
    }, { once: false });
  }

  // Resolve the icon source for an item:
  //   1) explicit icon_url — used as-is
  //   2) icon_id (or item_id) — derives "icons/<id>.png"
  //   3) nothing — falls back to the rarity-coloured crystal
  function itemIconUrl(item) {
    if (!item) return null;
    if (item.icon_url) return item.icon_url;
    const id = item.icon_id || item.item_id;
    if (id != null) return "icons/" + id + ".png";
    return null;
  }

  function equipCrystalSVG(color) {
    return `
      <svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <defs>
          <linearGradient id="eq-${color.replace(/[^a-f0-9]/gi,'')}" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="${color}"/>
            <stop offset="1" stop-color="${color}aa"/>
          </linearGradient>
        </defs>
        <path d="M24 6 L40 18 L24 42 L8 18 Z" fill="url(#eq-${color.replace(/[^a-f0-9]/gi,'')})" stroke="${color}" stroke-width="1.4" stroke-linejoin="round" filter="drop-shadow(0 0 6px ${color}aa)"/>
        <path d="M24 6 L15 18 L24 42 L33 18 Z" fill="${color}" opacity="0.55"/>
        <path d="M8 18 L40 18" stroke="${color}" stroke-width="0.8" opacity="0.7"/>
        <path d="M24 6 L24 42" stroke="#ffffff" stroke-width="0.5" opacity="0.45"/>
      </svg>`;
  }

  function showItemDetail(item, slotMeta) {
    if (!item) return;
    hide("equip-detail-empty");
    show("equip-detail");
    const r = itemRarity(item);
    const detail = $("equip-detail");
    detail.style.setProperty("--rarity-color", r.hue);
    detail.classList.remove("rarity-common","rarity-uncommon","rarity-rare","rarity-exceptional","rarity-relic","rarity-mythic","rarity-empyrean","rarity-custom");
    detail.classList.add("rarity-" + r.key);

    $("equip-detail-name").textContent = item.name || "—";
    $("equip-detail-slotname").innerHTML =
      `<span class="equip-detail-rarity" style="color:${r.hue};">${escapeHtml(r.label)}</span>` +
      `<span class="equip-detail-sep"> · </span>` +
      `<span>${slotMeta ? escapeHtml(slotMeta.label) : ""}</span>`;
    const img = $("equip-detail-img");
    const iconSrc = itemIconUrl(item);
    if (iconSrc) {
      img.src = iconSrc;
      img.alt = item.name || "";
      img.parentElement.style.display = "";
      img.onerror = function () {
        img.parentElement.style.display = "none";
      };
    } else {
      img.parentElement.style.display = "none";
    }

    const stats = item.stats || {};
    const statsEl = $("equip-detail-stats");
    const entries = Object.entries(stats);
    const meta = [];
    if (item.req_level) meta.push(["Lv. Req", item.req_level]);
    if (item.ilevel)    meta.push(["iLevel",  item.ilevel]);
    if (Array.isArray(item.jobs) && item.jobs.length) {
      const jobStr = item.jobs.length >= 22 ? "All Jobs" : item.jobs.join(" ");
      meta.push(["Jobs", jobStr]);
    }
    const metaHtml = meta.map(([k, v]) => `<dt>${escapeHtml(String(k))}</dt><dd>${escapeHtml(String(v))}</dd>`).join("");
    const statsHtml = entries.map(([k, v]) => v === ''
      ? `<dt class="stat-full">${escapeHtml(k)}</dt>`
      : `<dt>${escapeHtml(k)}</dt><dd>${escapeHtml(v)}</dd>`
    ).join("");

    const augments = Array.isArray(item.augments) ? item.augments : [];
    let augHtml = "";
    if (augments.length) {
      augHtml = `<dt class="aug-header">Augments</dt>`;
      augments.forEach(slot => {
        Object.entries(slot).forEach(([k, v]) => {
          augHtml += `<dt class="aug-stat">${escapeHtml(k)}</dt><dd class="aug-val">${escapeHtml(v)}</dd>`;
        });
      });
    }

    statsEl.innerHTML = (entries.length || meta.length || augments.length)
      ? metaHtml + statsHtml + augHtml
      : `<dt style="grid-column:1/-1; font-style:italic; text-transform:none; letter-spacing:0;">No stat data.</dt>`;

    const desc = $("equip-detail-desc");
    if (item.description) {
      desc.textContent = item.description;
      desc.style.display = "";
    } else {
      desc.style.display = "none";
    }
  }

  // ── go
  document.addEventListener("DOMContentLoaded", loadCharacter);
})();
