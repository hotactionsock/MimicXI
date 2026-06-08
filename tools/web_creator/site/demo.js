/**
 * MimicXI — demo data for previewing account pages without the backend.
 *
 * Activates when `?demo=1` is in the URL on any account page, OR when
 * localStorage.mimic_demo === "1". MimicAuth.api routes intercepted by
 * the demo layer (when active) short-circuit with these fixtures.
 *
 * The toggle pill in the bottom-left is ALWAYS visible on the account/
 * sign-in pages — click to flip demo mode on or off.
 */
(function () {
  function onlyOnAccountPages() {
    const here = (location.pathname.split("/").pop() || "").toLowerCase();
    return /^(signin|account|character|create-character)\.html$/i.test(here);
  }

  function isOn() {
    try {
      if (new URLSearchParams(location.search).get("demo") === "1") return true;
      if (localStorage.getItem("mimic_demo") === "1") return true;
    } catch (e) {}
    return false;
  }

  // ── Sample data ─────────────────────────────────────────────
  const DEMO_USER = "Aevyn";

  const DEMO_CHARS = [
    { charid: 101, name: "Aevyn",   race: 7, face: 9,  nation: 0 },  // Mithra, San d'Oria
    { charid: 102, name: "Brizan",  race: 8, face: 4,  nation: 1 },  // Galka,  Bastok
    { charid: 103, name: "Niliana", race: 6, face: 16, nation: 2 },  // Taru,   Windurst, custom face
  ];

  const DEMO_CHARACTER = {
    101: {
      charid: 101, name: "Aevyn",
      race: 7, face: 9, size: 1, nation: 0,
      mjob: 6, mjob_level: 75,
      sjob: 1, sjob_level: 37,
      playtime_seconds: 412 * 3600,
      is_owner: true,
      ranks: { nation_name: "San d'Oria", rank: 8, rank_points: 3450 },
      jobs: [
        { id: 1,  name: "Warrior",     abbr: "WAR", level: 37 },
        { id: 2,  name: "Monk",        abbr: "MNK", level: 12 },
        { id: 3,  name: "White Mage",  abbr: "WHM", level: 25 },
        { id: 4,  name: "Black Mage",  abbr: "BLM", level: 18 },
        { id: 5,  name: "Red Mage",    abbr: "RDM", level: 22 },
        { id: 6,  name: "Thief",       abbr: "THF", level: 75 },
        { id: 7,  name: "Paladin",     abbr: "PLD", level: 0,  unlocked: false },
        { id: 8,  name: "Dark Knight", abbr: "DRK", level: 51 },
        { id: 9,  name: "Beastmaster", abbr: "BST", level: 0,  unlocked: false },
        { id: 10, name: "Bard",        abbr: "BRD", level: 0,  unlocked: false },
        { id: 11, name: "Ranger",      abbr: "RNG", level: 33 },
        { id: 12, name: "Samurai",     abbr: "SAM", level: 65 },
        { id: 13, name: "Ninja",       abbr: "NIN", level: 60 },
        { id: 14, name: "Dragoon",     abbr: "DRG", level: 0,  unlocked: false },
        { id: 15, name: "Summoner",    abbr: "SMN", level: 0,  unlocked: false },
        { id: 16, name: "Blue Mage",   abbr: "BLU", level: 0,  unlocked: false },
        { id: 17, name: "Corsair",     abbr: "COR", level: 0,  unlocked: false },
        { id: 18, name: "Puppetmaster",abbr: "PUP", level: 0,  unlocked: false },
        { id: 19, name: "Dancer",      abbr: "DNC", level: 0,  unlocked: false },
        { id: 20, name: "Scholar",     abbr: "SCH", level: 0,  unlocked: false },
        { id: 21, name: "Geomancer",   abbr: "GEO", level: 0,  unlocked: false },
        { id: 22, name: "Rune Fencer", abbr: "RUN", level: 0,  unlocked: false },
      ],
      fame: [
        { area: "San d'Oria", level: 9, points: 3900 },
        { area: "Bastok",     level: 6, points: 2400 },
        { area: "Windurst",   level: 7, points: 2800 },
        { area: "Jeuno",      level: 8, points: 3200 },
        { area: "Selbina",    level: 5, points: 2000 },
        { area: "Norg",       level: 3, points: 1200 },
        { area: "Kazham",     level: 4, points: 1600 },
        { area: "Rabao",      level: 2, points:  800 },
      ],
      private: {
        gil: 1843722,
        cp_sandoria: 12480,
        cp_bastok: 1200,
        cp_windurst: 0,
      },
      currencies: [
        { id: "obsidian_fragment", amount: 142 },
        { id: "bayld",             amount: 18450 },
        { id: "cruor",             amount: 240000 },
        { id: "imperial_standing", amount: 8200 },
        { id: "allied_notes",      amount: 14300 },
        { id: "sparks",            amount: 45000 },
        { id: "therion_ichor",     amount: 3700 },
        { id: "voidstone",         amount: 28 },
        { id: "cinders",           amount: 92 },
        { id: "coalition_imprimaturs", amount: 0 },
        { id: "mimic_token",       amount: 14 },
      ],
      quests: [
        { id: "lqs_intro_01",   name: "An Auspicious Welcome",      area: "MimicXI", status: "completed" },
        { id: "lqs_intro_02",   name: "First Steps in Vana'diel",   area: "MimicXI", status: "completed" },
        { id: "lqs_intro_03",   name: "The Crystal Awakens",        area: "MimicXI", status: "completed" },
        { id: "lqs_world_01",   name: "The Vana'diel I Knew",       area: "Chains", status: "in_progress" },
        { id: "lqs_world_02",   name: "Whispers from the Goddess",  area: "Wings",  status: "in_progress" },
        { id: "lqs_combat_01",  name: "A Bone to Pick",             area: "Tutorial", status: "completed" },
        { id: "lqs_combat_02",  name: "Damage in Layers",           area: "Tutorial", status: "completed" },
        { id: "lqs_combat_03",  name: "Elemental Theory",           area: "Tutorial", status: "in_progress" },
        { id: "lqs_combat_04",  name: "The Weapon Master",          area: "Tutorial", status: "not_started" },
        { id: "lqs_gear_01",    name: "Glimmering in the Dark",     area: "Itemisation", status: "completed" },
        { id: "lqs_gear_02",    name: "A Casket of Surprises",      area: "Itemisation", status: "in_progress" },
        { id: "lqs_gear_03",    name: "Augments & Auguries",        area: "Itemisation", status: "not_started" },
        { id: "lqs_th_01",      name: "Treasure for All",           area: "Story", status: "completed" },
        { id: "lqs_th_02",      name: "The Casket Hunter",          area: "Story", status: "not_started" },
        { id: "lqs_endgame_01", name: "First Steps Into Dynamis",   area: "Endgame", status: "not_started" },
        { id: "lqs_endgame_02", name: "Kings Among Men",            area: "Endgame", status: "not_started" },
        { id: "lqs_side_01",    name: "The Mithran Merchant's Cat", area: "Side", status: "completed" },
        { id: "lqs_side_02",    name: "Whispers in the Dunes",      area: "Side", status: "in_progress" },
      ],
    },
    102: {
      charid: 102, name: "Brizan",
      race: 8, face: 4, size: 2, nation: 1,
      mjob: 7, mjob_level: 71, sjob: 1, sjob_level: 35,
      playtime_seconds: 198 * 3600, is_owner: true,
      ranks: { nation_name: "Bastok", rank: 6, rank_points: 2100 },
      jobs: [
        { id: 1, name: "Warrior", abbr: "WAR", level: 35 },
        { id: 7, name: "Paladin", abbr: "PLD", level: 71 },
        { id: 8, name: "Dark Knight", abbr: "DRK", level: 22 },
        { id: 13, name: "Ninja",  abbr: "NIN", level: 48 },
      ],
      fame: [
        { area: "Bastok", level: 7, points: 2800 },
        { area: "San d'Oria", level: 3, points: 1200 },
      ],
      private: { gil: 421050, cp_sandoria: 0, cp_bastok: 8400, cp_windurst: 0 },
      currencies: [
        { id: "obsidian_fragment", amount: 22 },
        { id: "bayld",             amount: 2400 },
        { id: "imperial_standing", amount: 18800 },
        { id: "allied_notes",      amount: 6200 },
        { id: "sparks",            amount: 12000 },
        { id: "voidstone",         amount: 6 },
        { id: "mimic_token",       amount: 3 },
      ],
      quests: [
        { id: "lqs_intro_01", name: "An Auspicious Welcome", area: "MimicXI", status: "completed" },
        { id: "lqs_intro_02", name: "First Steps in Vana'diel", area: "MimicXI", status: "completed" },
        { id: "lqs_combat_01", name: "A Bone to Pick", area: "Tutorial", status: "in_progress" },
        { id: "lqs_endgame_01", name: "First Steps Into Dynamis", area: "Endgame", status: "not_started" },
      ],
    },
    103: {
      charid: 103, name: "Niliana",
      race: 6, face: 16, size: 0, nation: 2,
      mjob: 3, mjob_level: 58, sjob: 5, sjob_level: 29,
      playtime_seconds: 88 * 3600, is_owner: true,
      ranks: { nation_name: "Windurst", rank: 4, rank_points: 1450 },
      jobs: [
        { id: 3, name: "White Mage", abbr: "WHM", level: 58 },
        { id: 5, name: "Red Mage",   abbr: "RDM", level: 41 },
        { id: 4, name: "Black Mage", abbr: "BLM", level: 29 },
      ],
      fame: [
        { area: "Windurst", level: 6, points: 2400 },
      ],
      private: { gil: 92340, cp_sandoria: 0, cp_bastok: 0, cp_windurst: 3200 },
      currencies: [
        { id: "obsidian_fragment", amount: 4 },
        { id: "allied_notes",      amount: 1100 },
        { id: "sparks",            amount: 5400 },
      ],
      quests: [
        { id: "lqs_intro_01", name: "An Auspicious Welcome", area: "MimicXI", status: "completed" },
        { id: "lqs_combat_02", name: "Damage in Layers", area: "Tutorial", status: "in_progress" },
      ],
    },
  };

  // Sample equipment for the lead character. item_id maps to icons/<id>.png
  // (which auto-resolves via itemIconUrl). Rarity drives the border + glow.
  const DEMO_EQUIPMENT = {
    101: {
      slots: {
        main:  { item_id: 10440, name: "Mandau",            rarity: "relic",       stats: { DMG: 42, Delay: 224, "STR": 5, "DEX": 5, "AGI": 5, "Acc": 15, "Atk": 15, "Crit Rate": "+4%" }, description: "An exotic dagger said to be wielded by the legendary thief of legend." },
          sub: { item_id: 10489, name: "Joyeuse",           rarity: "exceptional", stats: { DMG: 33, Delay: 224, "STR": 4, "Acc": 7, "Latent": "Occ. attacks twice" } },
        ranged:null,
        ammo:  { item_id: 11472, name: "Bomb Core",         rarity: "common",      stats: { "STR": 4, "Magic Atk": 4 } },
        head:  { item_id: 15397, name: "Walahra Turban",    rarity: "rare",        stats: { "Haste": "+5%", "Acc": 8 } },
        neck:  { item_id: 15428, name: "Peacock Charm",     rarity: "exceptional", stats: { "DEX": 10, "Acc": 10, "Eva": 5 }, description: "Said to bring fortune to those who wear it." },
        ear1:  { item_id: 15455, name: "Suppanomimi",       rarity: "rare",        stats: { "Dual Wield": "+5%" } },
        ear2:  { item_id: 15452, name: "Brutal Earring",    rarity: "exceptional", stats: { "STR": 2, "Acc": 1, "Att": 5, "Dbl. Atk": "+1%" } },
        body:  { item_id: 14110, name: "Scorpion Harness",  rarity: "exceptional", stats: { "STR": 4, "DEX": 4, "AGI": 4, "Acc": 7, "Eva": 7 }, description: "An exquisitely-crafted set of leather armor said to grant strength." },
        hands: { item_id: 14336, name: "Dusk Gloves",       rarity: "rare",        stats: { "STR": 3, "VIT": 3, "Atk": 8 } },
        ring1: { item_id: 15777, name: "Rajas Ring",        rarity: "relic",       stats: { "STR": 5, "DEX": 5, "Acc": 5, "Att": 5 }, description: "A ring imbued with the essence of a fallen king." },
        ring2: { item_id: 15775, name: "Sniper's Ring",     rarity: "rare",        stats: { "Acc": 5, "Rng. Acc": 5 } },
        back:  { item_id: 15422, name: "Mimic's Mantle",    rarity: "custom",      stats: { "Acc": 8, "Att": 8, "Casket Find": "+10%" }, description: "A mantle stitched from the hide of a slain mimic. Glows faintly when treasure is near." },
        waist: { item_id: 15287, name: "Swift Belt",        rarity: "uncommon",    stats: { "Haste": "+4%", "Acc": 3 } },
        legs:  { item_id: 14266, name: "Byakko's Haidate",  rarity: "mythic",      stats: { "STR": 9, "DEX": 6, "Acc": 5, "Att": 12 }, description: "Legwear blessed by the celestial tiger of the west." },
        feet:  { item_id: 14108, name: "Rutter Sabatons",   rarity: "rare",        stats: { "Movement": "+12%", "AGI": 3 } },
      }
    }
  };

  // ── Fetch interceptor ───────────────────────────────────────
  function jsonResp(data, status) {
    return { ok: status >= 200 && status < 300, status, data };
  }

  function intercept(path, opts) {
    // Auth
    if (path === "/api/session")  return jsonResp({ authenticated: true, accid: 1, username: DEMO_USER }, 200);
    if (path === "/login")        return jsonResp(null, 302); // form post path; signin handles by checking /api/characters
    if (path === "/logout")       return jsonResp(null, 200);
    if (path === "/api/register") return jsonResp({ accid: 1, username: (opts && opts.body && opts.body.username) || DEMO_USER }, 201);

    if (path === "/api/characters") return jsonResp(DEMO_CHARS.slice(), 200);

    let m = path.match(/^\/api\/character\/(\d+)$/);
    if (m) {
      const c = DEMO_CHARACTER[+m[1]];
      return c ? jsonResp(c, 200) : jsonResp({ error: "Not found" }, 404);
    }
    m = path.match(/^\/api\/character\/(\d+)\/equipment$/);
    if (m) {
      const e = DEMO_EQUIPMENT[+m[1]];
      return e ? jsonResp(e, 200) : jsonResp({ slots: {} }, 200);
    }
    if (path === "/api/create") {
      const body = (opts && opts.body) || {};
      const id = 200 + Math.floor(Math.random() * 800);
      DEMO_CHARS.push({ charid: id, name: body.name, race: body.race, face: body.face, nation: body.nation });
      return jsonResp({ charid: id, name: body.name }, 201);
    }
    return null;
  }

  // ── Wire into MimicAuth ────────────────────────────────────
  function install() {
    if (!window.MimicAuth) return;
    const origApi = MimicAuth.api;
    const origForm = MimicAuth.apiForm;
    MimicAuth.api = async function (path, opts) {
      const r = intercept(path, opts);
      if (r) return r;
      return origApi.call(this, path, opts);
    };
    MimicAuth.apiForm = async function (path, formData) {
      // Treat the form-post sign-in as success in demo mode.
      if (path === "/login") {
        try { localStorage.setItem("mimic_username", formData.username || DEMO_USER); } catch (e) {}
        return { ok: true, status: 200, redirected: false, url: location.href };
      }
      return origForm.call(this, path, formData);
    };
    // Force the username so the header chip flips immediately.
    try {
      if (!localStorage.getItem("mimic_username")) {
        localStorage.setItem("mimic_username", DEMO_USER);
      }
    } catch (e) {}
  }

  // ── Demo pill in corner ────────────────────────────────────
  // Always present so users can flip demo mode on or off freely.

  function ensureStyles() {
    if (document.getElementById("demo-pill-styles")) return;
    const css = `
      .demo-pill {
        position: fixed; bottom: 20px; left: 20px; z-index: 200;
        display: inline-flex; align-items: center; gap: 8px;
        padding: 8px 14px; border-radius: 999px;
        font-family: var(--mono, ui-monospace, monospace);
        font-size: 0.7rem; font-weight: 600;
        letter-spacing: 0.12em; text-transform: uppercase;
        cursor: pointer; user-select: none;
        text-decoration: none !important;
        transition: transform .15s, box-shadow .2s, background .2s, color .2s;
      }
      .demo-pill.on {
        background: rgba(232, 199, 133, 0.94); color: #11162a !important;
        box-shadow: 0 8px 24px rgba(0,0,0,0.4), 0 0 18px rgba(232,199,133,0.45);
      }
      .demo-pill.off {
        background: rgba(27, 34, 64, 0.85);
        color: rgba(232, 199, 133, 0.85) !important;
        border: 1px solid rgba(232, 199, 133, 0.4);
        backdrop-filter: blur(6px);
        -webkit-backdrop-filter: blur(6px);
        box-shadow: 0 4px 14px rgba(0,0,0,0.35);
      }
      .demo-pill.off:hover {
        background: rgba(232, 199, 133, 0.18);
        color: #e8c785 !important;
      }
      .demo-pill .demo-dot { width: 6px; height: 6px; border-radius: 50%; }
      .demo-pill.on .demo-dot {
        background: #11162a;
        animation: demoPulse 2s ease-in-out infinite;
      }
      .demo-pill.off .demo-dot { background: currentColor; opacity: 0.7; }
      .demo-pill:hover { transform: translateY(-1px); }
      @keyframes demoPulse { 0%,100% { opacity:1; } 50% { opacity:0.35; } }
      @media (max-width: 600px) {
        .demo-pill { bottom: 14px; left: 14px; padding: 7px 12px; font-size: 0.65rem; }
      }
    `;
    const s = document.createElement("style");
    s.id = "demo-pill-styles";
    s.textContent = css;
    document.head.appendChild(s);
  }

  function renderPill() {
    if (!onlyOnAccountPages()) return;
    ensureStyles();
    const old = document.querySelector(".demo-pill");
    if (old) old.remove();
    const pill = document.createElement("a");
    const on = isOn();
    pill.className = "demo-pill " + (on ? "on" : "off");
    pill.href = "#";
    pill.title = on
      ? "Demo data active — click to use your real account"
      : "Click to preview with demo data";
    pill.innerHTML = `<span class="demo-dot"></span>${on ? "Demo mode" : "Try demo data"}`;
    pill.addEventListener("click", e => {
      e.preventDefault();
      try {
        if (isOn()) {
          localStorage.removeItem("mimic_demo");
          // Clear the cached username so the header doesn't keep showing
          // "Aevyn" after dropping back to the real (possibly-signed-out) state.
          if (localStorage.getItem("mimic_username") === DEMO_USER) {
            localStorage.removeItem("mimic_username");
          }
        } else {
          localStorage.setItem("mimic_demo", "1");
        }
      } catch (err) {}
      const u = new URL(location.href);
      u.searchParams.delete("demo");
      location.href = u.toString();
    });
    document.body.appendChild(pill);
  }

  // ── Boot ───────────────────────────────────────────────────
  if (isOn()) {
    try { localStorage.setItem("mimic_demo", "1"); } catch (e) {}
    // Pretend to already be signed in as the demo user.
    try { localStorage.setItem("mimic_username", DEMO_USER); } catch (e) {}

    // Skip the sign-in flow entirely when demo mode is on. If we're on the
    // signin page, fast-forward to the account hub (respecting any `next=`
    // param so we land where the user was originally headed).
    const here = (location.pathname.split("/").pop() || "").toLowerCase();
    if (here === "signin.html") {
      const next = new URLSearchParams(location.search).get("next");
      const safeNext = next && /^[a-z0-9_-]+\.html(\?.*)?$/i.test(next) ? next : "account.html";
      location.replace(safeNext);
      return;
    }

    if (window.MimicAuth) install();
    else {
      const iv = setInterval(() => {
        if (window.MimicAuth) { clearInterval(iv); install(); }
      }, 30);
    }
  }
  // The pill is always visible on account pages, on or off.
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", renderPill);
  } else {
    renderPill();
  }
})();
