// Shared header/footer + small utilities for MimicXI site
(function () {
  const PAGES = [
    { href: "index.html", label: "Home" },
    { href: "changes.html", label: "Changes" },
    { href: "jobs.html", label: "Jobs" },
    { href: "rules.html", label: "Rules" },
    { href: "join.html", label: "Join" },
  ];

  const here = (location.pathname.split("/").pop() || "index.html").toLowerCase();

  function crystalMark(size) {
    const s = size || 22;
    return `
      <svg class="crystal-mark" width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <defs>
          <linearGradient id="cm-grad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#bfe0f5"/>
            <stop offset="1" stop-color="#5fa3cf"/>
          </linearGradient>
        </defs>
        <path d="M12 2 L20 9 L12 22 L4 9 Z" fill="url(#cm-grad)" stroke="#8cc5e8" stroke-width="0.8" stroke-linejoin="round"/>
        <path d="M12 2 L8 9 L12 22 L16 9 Z" fill="#a8d4ee" opacity="0.7"/>
        <path d="M4 9 L20 9" stroke="#8cc5e8" stroke-width="0.6"/>
        <path d="M12 2 L12 22" stroke="#ffffff" stroke-width="0.4" opacity="0.5"/>
      </svg>`;
  }

  function getUser() {
    try { return localStorage.getItem("mimic_username"); } catch (e) { return null; }
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, c => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
    }[c]));
  }

  function renderHeader() {
    const navLinks = PAGES.map(p => {
      const cls = p.href.toLowerCase() === here ? "active" : "";
      return `<a href="${p.href}" class="nav-link ${cls}">${p.label}</a>`;
    }).join("");

    const user = getUser();
    document.body.insertAdjacentHTML("afterbegin", buildHeaderHtml(navLinks, user));

    wireMobileNav();
    verifyAuthAndUpdate(navLinks);
  }

  function buildHeaderHtml(navLinks, user) {
    const accountActive = here === "account.html" || here === "create-character.html";
    const accountHtml = user
      ? `<a href="account.html" class="nav-account ${accountActive ? "is-active" : ""}" title="Signed in as ${escapeHtml(user)}">
           <svg class="nav-account-glyph" viewBox="0 0 24 24" aria-hidden="true">
             <path d="M12 2 L20 9 L12 22 L4 9 Z" fill="currentColor" opacity="0.9"/>
             <path d="M12 2 L8 9 L12 22 L16 9 Z" fill="#0f1424" opacity="0.25"/>
           </svg>
           <span class="acc-label">
             <span class="acc-hint">Signed in</span>
             <span class="acc-name">${escapeHtml(user)}</span>
           </span>
         </a>`
      : `<a href="signin.html" class="nav-account nav-account--signin ${here === "signin.html" ? "is-active" : ""}">
           <svg class="nav-account-glyph" viewBox="0 0 24 24" aria-hidden="true">
             <path d="M12 2 L20 9 L12 22 L4 9 Z" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>
           </svg>
           <span class="acc-label">
             <span class="acc-hint">Account</span>
             <span class="acc-name">Sign in</span>
           </span>
         </a>`;

    const worldActive = here === "world.html";
    const onlineBadge = `
      <a href="world.html" class="online-badge${worldActive ? " is-active" : ""}" id="online-badge" title="Who's online">
        <span class="online-dot" id="online-dot"></span>
        <span id="online-count-text">···</span>
      </a>
      <button type="button" class="maint-toggle" id="maint-toggle" style="display:none" title="Toggle maintenance mode">
        <svg viewBox="0 0 18 18" fill="none" aria-hidden="true" width="14" height="14">
          <path d="M9 2 C5.13 2 2 5.13 2 9s3.13 7 7 7 7-3.13 7-7-3.13-7-7-7zm0 12.6A5.6 5.6 0 1 1 9 3.4a5.6 5.6 0 0 1 0 11.2z" fill="currentColor" opacity="0.7"/>
          <path d="M9 6v4l2.5 1.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </button>`;

    return `
      <header class="site-header">
        <div class="inner">
          <a href="index.html" class="brand">
            ${crystalMark(22)}
            <span>Mimic<span class="brand-x">XI</span></span>
          </a>
          <nav class="nav nav-desktop" aria-label="Primary">
            <div class="nav-links">${navLinks}</div>
            ${onlineBadge}
            ${accountHtml}
          </nav>
          <button type="button" class="nav-burger" aria-label="Open menu" aria-expanded="false" aria-controls="nav-drawer">
            <span></span><span></span><span></span>
          </button>
        </div>
      </header>
      <div class="nav-scrim" aria-hidden="true"></div>
      <nav class="nav-drawer" id="nav-drawer" aria-hidden="true" aria-label="Mobile menu">
        <div class="nav-drawer-inner">
          <div class="nav-links">${navLinks}</div>
          ${onlineBadge}
          ${accountHtml}
        </div>
      </nav>`;
  }

  // Source of truth: ask Flask whether the session cookie is valid.
  // If so, sync localStorage and (if needed) re-render the header.
  async function verifyAuthAndUpdate(navLinks) {
    const base = (window.MIMIC_API_BASE || "").replace(/\/$/, "");
    let serverUser = null;
    let isAdmin = false;
    try {
      // Try /api/session first (cheap). If that's not present, fall back to /api/characters.
      let r = await fetch(base + "/api/session", { credentials: "include", headers: { Accept: "application/json" } });
      if (r.ok) {
        const d = await r.json();
        if (d && d.authenticated) {
          serverUser = d.username || "Player";
          isAdmin = !!d.is_admin;
        }
      } else if (r.status === 404) {
        r = await fetch(base + "/api/characters", { credentials: "include", headers: { Accept: "application/json" } });
        if (r.ok) serverUser = getUser() || "Player";
      }
    } catch (e) {
      // Network failure / file:// — leave UI as-is.
      return;
    }

    const localUser = getUser();
    if (serverUser && serverUser !== localUser) {
      try { localStorage.setItem("mimic_username", serverUser); } catch (e) {}
    } else if (!serverUser && localUser) {
      try { localStorage.removeItem("mimic_username"); } catch (e) {}
    }
    const finalUser = serverUser || (serverUser === null ? null : localUser);

    // Only rebuild if the visible state would actually change.
    const wasShowingUser = !!localUser;
    const shouldShowUser = !!finalUser;
    if (wasShowingUser !== shouldShowUser || (shouldShowUser && finalUser !== localUser)) {
      const oldHeader = document.querySelector(".site-header");
      const oldScrim = document.querySelector(".nav-scrim");
      const oldDrawer = document.querySelector(".nav-drawer");
      if (oldHeader) oldHeader.remove();
      if (oldScrim) oldScrim.remove();
      if (oldDrawer) oldDrawer.remove();
      document.body.insertAdjacentHTML("afterbegin", buildHeaderHtml(navLinks, finalUser));
      wireMobileNav();
    }

    if (isAdmin) wireMaintenanceToggle(base);
  }

  function wireMobileNav() {
    const burger = document.querySelector(".nav-burger");
    const drawer = document.getElementById("nav-drawer");
    const scrim = document.querySelector(".nav-scrim");
    if (!burger || !drawer) return;

    function open() {
      document.body.classList.add("nav-open");
      burger.setAttribute("aria-expanded", "true");
      drawer.setAttribute("aria-hidden", "false");
    }
    function close() {
      document.body.classList.remove("nav-open");
      burger.setAttribute("aria-expanded", "false");
      drawer.setAttribute("aria-hidden", "true");
    }
    function toggle() {
      if (document.body.classList.contains("nav-open")) close(); else open();
    }
    burger.addEventListener("click", toggle);
    scrim && scrim.addEventListener("click", close);
    drawer.addEventListener("click", e => {
      if (e.target.closest("a")) close();
    });
    // Close on Escape for keyboard users
    document.addEventListener("keydown", e => {
      if (e.key === "Escape") close();
    });
    // Reset on resize back to desktop so the drawer doesn't trap layout
    window.addEventListener("resize", () => {
      if (window.innerWidth > 860) close();
    });
  }

  function renderFooter() {
    const html = `
      <footer class="site-footer">
        <div class="inner">
          <div class="disclaimer">
            <strong style="color: var(--ink);">MimicXI</strong> is a private, non-commercial project run by fans of Final Fantasy XI.
            Not affiliated with or endorsed by Square Enix. All trademarks belong to their respective owners.
          </div>
          <div class="footer-meta">Alpha · Wings of the Goddess era · 75 cap</div>
        </div>
      </footer>`;
    document.body.insertAdjacentHTML("beforeend", html);
  }

  function applyServerStatus(d) {
    const ct  = document.getElementById("online-count-text");
    const dot = document.getElementById("online-dot");
    if (!ct || !dot) return;
    dot.className = "online-dot";
    if (d.mode === "maintenance") {
      ct.textContent = "Maintenance";
      dot.classList.add("is-maintenance");
    } else if (d.mode === "offline") {
      ct.textContent = "Offline";
      dot.classList.add("is-offline");
    } else {
      const n = d.count || 0;
      ct.textContent = n === 1 ? "1 online" : `${n} online`;
      if (n === 0) dot.classList.add("is-empty");
    }
    if (typeof window._onlineData !== "undefined") window._onlineData(d);
  }

  async function fetchOnline() {
    const base = (window.MIMIC_API_BASE || "").replace(/\/$/, "");
    try {
      const r = await fetch(base + "/api/server-status", { headers: { Accept: "application/json" } });
      if (!r.ok) { applyServerStatus({ mode: "offline", count: 0 }); return; }
      applyServerStatus(await r.json());
    } catch (e) {
      applyServerStatus({ mode: "offline", count: 0 });
    }
  }

  function wireMaintenanceToggle(base) {
    document.querySelectorAll("#maint-toggle").forEach(btn => {
      btn.style.display = "";
      btn.onclick = async () => {
        const dot = document.getElementById("online-dot");
        const currentlyMaint = dot && dot.classList.contains("is-maintenance");
        const action = currentlyMaint ? "disable maintenance mode" : "enable maintenance mode";
        if (!confirm(`Are you sure you want to ${action}?`)) return;
        try {
          const r = await fetch(base + "/api/server-status/maintenance", {
            method: "POST",
            credentials: "include",
            headers: { "Content-Type": "application/json", Accept: "application/json" },
            body: JSON.stringify({ enabled: !currentlyMaint }),
          });
          if (r.ok) fetchOnline();
        } catch (e) {}
      };
    });
  }

  document.addEventListener("DOMContentLoaded", () => {
    renderHeader();
    renderFooter();
    fetchOnline();
    setInterval(fetchOnline, 30000);
  });
})();
