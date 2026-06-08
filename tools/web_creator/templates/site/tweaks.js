// MimicXI — Tweaks panel (vanilla)
(function () {
  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "palette": "blue",
    "fantasy": "subtle",
    "headingFont": "cormorant",
    "showMascot": true
  }/*EDITMODE-END*/;

  // --- read persisted on first load ---
  const state = { ...TWEAK_DEFAULTS };

  // --- apply state to DOM ---
  function applyPalette(name) {
    const root = document.documentElement;
    const palettes = {
      blue: { blue: "#7fb6d9", blueDeep: "#4d8fb8", lilac: "#c9a8d6", amber: "#e8c785", amberDeep: "#c79a4a" },
      sage: { blue: "#8fb59e", blueDeep: "#5a8a6f", lilac: "#d3c39a", amber: "#e6cf91", amberDeep: "#b48a48" },
      rose: { blue: "#d9a8b3", blueDeep: "#a86b78", lilac: "#c9a8d6", amber: "#e8c785", amberDeep: "#c79a4a" },
    };
    const p = palettes[name] || palettes.blue;
    root.style.setProperty("--crystal-blue", p.blue);
    root.style.setProperty("--crystal-blue-deep", p.blueDeep);
    root.style.setProperty("--crystal-lilac", p.lilac);
    root.style.setProperty("--crystal-amber", p.amber);
    root.style.setProperty("--crystal-amber-deep", p.amberDeep);
    root.style.setProperty("--accent", p.blueDeep);
  }

  function applyFont(name) {
    const root = document.documentElement;
    const fonts = {
      cormorant: '"Cormorant Garamond", Georgia, serif',
      fraunces: '"Fraunces", Georgia, serif',
      sansOnly: '"Inter", -apple-system, sans-serif',
    };
    root.style.setProperty("--serif", fonts[name] || fonts.cormorant);
    if (name === "fraunces" && !document.getElementById("fnt-fraunces")) {
      const l = document.createElement("link");
      l.id = "fnt-fraunces";
      l.rel = "stylesheet";
      l.href = "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&display=swap";
      document.head.appendChild(l);
    }
  }

  function applyFantasy(level) {
    document.body.classList.remove("fantasy-clean", "fantasy-subtle", "fantasy-ornate");
    document.body.classList.add(`fantasy-${level}`);
  }

  function applyAll() {
    applyPalette(state.palette);
    applyFont(state.headingFont);
    applyFantasy(state.fantasy);
  }

  // --- panel UI ---
  let panel;

  function buildPanel() {
    panel = document.createElement("div");
    panel.id = "mxi-tweaks";
    panel.innerHTML = `
      <div class="mxi-tw-head">
        <strong>Tweaks</strong>
        <button class="mxi-tw-close" aria-label="Close">×</button>
      </div>
      <div class="mxi-tw-body">

        <div class="mxi-tw-section">
          <label>Crystal palette</label>
          <div class="mxi-tw-swatches" data-key="palette">
            <button data-val="blue" title="Blue / lilac / amber"><span style="background:#7fb6d9"></span><span style="background:#c9a8d6"></span><span style="background:#e8c785"></span></button>
            <button data-val="sage" title="Sage / amber"><span style="background:#8fb59e"></span><span style="background:#d3c39a"></span><span style="background:#e6cf91"></span></button>
            <button data-val="rose" title="Rose quartz"><span style="background:#d9a8b3"></span><span style="background:#c9a8d6"></span><span style="background:#e8c785"></span></button>
          </div>
        </div>

        <div class="mxi-tw-section">
          <label>Heading type</label>
          <div class="mxi-tw-radio" data-key="headingFont">
            <button data-val="cormorant">Cormorant</button>
            <button data-val="fraunces">Fraunces</button>
            <button data-val="sansOnly">Sans only</button>
          </div>
        </div>

        <div class="mxi-tw-section">
          <label>Fantasy intensity</label>
          <div class="mxi-tw-radio" data-key="fantasy">
            <button data-val="clean">Clean</button>
            <button data-val="subtle">Subtle</button>
            <button data-val="ornate">Ornate</button>
          </div>
        </div>

      </div>
    `;
    document.body.appendChild(panel);

    panel.querySelector(".mxi-tw-close").addEventListener("click", hide);

    panel.querySelectorAll(".mxi-tw-swatches").forEach(g => {
      g.addEventListener("click", e => {
        const b = e.target.closest("button[data-val]");
        if (!b) return;
        setKey(g.dataset.key, b.dataset.val);
      });
    });
    panel.querySelectorAll(".mxi-tw-radio").forEach(g => {
      g.addEventListener("click", e => {
        const b = e.target.closest("button[data-val]");
        if (!b) return;
        setKey(g.dataset.key, b.dataset.val);
      });
    });

    syncSelected();
  }

  function syncSelected() {
    if (!panel) return;
    panel.querySelectorAll("[data-key]").forEach(g => {
      const k = g.dataset.key;
      g.querySelectorAll("button[data-val]").forEach(b => {
        b.classList.toggle("active", String(state[k]) === b.dataset.val);
      });
    });
  }

  function setKey(key, val) {
    state[key] = val;
    applyAll();
    syncSelected();
    try {
      window.parent.postMessage({ type: "__edit_mode_set_keys", edits: { [key]: val } }, "*");
    } catch (e) {}
  }

  function show() {
    if (!panel) buildPanel();
    panel.classList.add("open");
  }
  function hide() {
    if (panel) panel.classList.remove("open");
    try { window.parent.postMessage({ type: "__edit_mode_dismissed" }, "*"); } catch (e) {}
  }

  // --- styles ---
  const css = `
    #mxi-tweaks {
      position: fixed; bottom: 24px; right: 24px;
      width: 280px; z-index: 1000;
      background: #fff; color: #2a2620;
      border: 1px solid #e6dfd0; border-radius: 10px;
      box-shadow: 0 14px 40px rgba(40,32,20,0.16), 0 2px 8px rgba(40,32,20,0.06);
      font-family: var(--sans, "Inter", sans-serif);
      transform: translateY(12px); opacity: 0; pointer-events: none;
      transition: opacity .18s ease, transform .18s ease;
    }
    #mxi-tweaks.open { transform: translateY(0); opacity: 1; pointer-events: auto; }
    #mxi-tweaks .mxi-tw-head {
      display: flex; align-items: center; justify-content: space-between;
      padding: 14px 16px; border-bottom: 1px solid #efe9da;
      font-family: var(--serif, "Cormorant Garamond", serif); font-size: 1.1rem;
    }
    #mxi-tweaks .mxi-tw-close {
      background: transparent; border: 0; font-size: 1.4rem; line-height: 1;
      color: #8a8276; cursor: pointer; padding: 0 4px;
    }
    #mxi-tweaks .mxi-tw-close:hover { color: #2a2620; }
    #mxi-tweaks .mxi-tw-body { padding: 14px 16px 18px; }
    #mxi-tweaks .mxi-tw-section { margin-bottom: 14px; }
    #mxi-tweaks .mxi-tw-section:last-child { margin-bottom: 0; }
    #mxi-tweaks label {
      display: block; font-size: 0.7rem; letter-spacing: 0.14em;
      text-transform: uppercase; color: #8a8276; margin-bottom: 8px;
      font-family: var(--mono, ui-monospace, monospace);
    }
    #mxi-tweaks .mxi-tw-swatches { display: flex; gap: 8px; }
    #mxi-tweaks .mxi-tw-swatches button {
      flex: 1; display: flex; padding: 6px; gap: 3px;
      background: #fbf9f3; border: 1px solid #e6dfd0; border-radius: 6px;
      cursor: pointer; transition: border-color .15s;
    }
    #mxi-tweaks .mxi-tw-swatches button:hover { border-color: #2a2620; }
    #mxi-tweaks .mxi-tw-swatches button.active { border-color: #2a2620; box-shadow: 0 0 0 2px rgba(127,182,217,0.25); }
    #mxi-tweaks .mxi-tw-swatches button span {
      flex: 1; aspect-ratio: 1; border-radius: 50%;
    }
    #mxi-tweaks .mxi-tw-radio {
      display: flex; gap: 0; border: 1px solid #e6dfd0; border-radius: 6px; overflow: hidden;
    }
    #mxi-tweaks .mxi-tw-radio button {
      flex: 1; padding: 7px 8px; background: #fff;
      border: 0; border-left: 1px solid #efe9da;
      font: inherit; font-size: 0.82rem; color: #5b544a; cursor: pointer;
    }
    #mxi-tweaks .mxi-tw-radio button:first-child { border-left: 0; }
    #mxi-tweaks .mxi-tw-radio button:hover { background: #fbf9f3; }
    #mxi-tweaks .mxi-tw-radio button.active { background: #2a2620; color: #fbf9f3; }

    /* Fantasy intensity flavor */
    body.fantasy-clean h1 em, body.fantasy-clean h1 i { font-style: normal; }
    body.fantasy-ornate h1, body.fantasy-ornate h2 { letter-spacing: -0.015em; }
    body.fantasy-ornate h1::first-letter, body.fantasy-ornate .page-hero h1::first-letter {
      font-size: 1.35em; color: var(--crystal-amber-deep);
    }
    body.fantasy-clean .crystal-mark { display: none; }
  `;
  const styleEl = document.createElement("style");
  styleEl.textContent = css;
  document.head.appendChild(styleEl);

  // --- host protocol ---
  window.addEventListener("message", e => {
    const d = e.data || {};
    if (d.type === "__activate_edit_mode") show();
    else if (d.type === "__deactivate_edit_mode") hide();
  });

  function init() {
    applyAll();
    try { window.parent.postMessage({ type: "__edit_mode_available" }, "*"); } catch (e) {}
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
