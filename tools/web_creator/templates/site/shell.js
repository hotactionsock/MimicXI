// Shared header/footer + small utilities for MimicXI site
(function () {
  const PAGES = [
    { href: "index.html", label: "Home" },
    { href: "changes.html", label: "Changes" },
    { href: "jobs.html", label: "Jobs" },
    { href: "rules.html", label: "Rules" },
  ];

  const here = (location.pathname.split("/").pop() || "index.html").toLowerCase();

  function crystalMark() {
    return `
      <svg class="crystal-mark" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <path d="M12 2 L20 9 L12 22 L4 9 Z" fill="#7fb6d9" stroke="#4d8fb8" stroke-width="0.8" stroke-linejoin="round"/>
        <path d="M12 2 L8 9 L12 22 L16 9 Z" fill="#a3cce4" opacity="0.9"/>
        <path d="M4 9 L20 9" stroke="#4d8fb8" stroke-width="0.6"/>
        <path d="M12 2 L12 22" stroke="#ffffff" stroke-width="0.4" opacity="0.5"/>
      </svg>`;
  }

  function renderHeader() {
    const navLinks = PAGES.map(p => {
      const cls = p.href.toLowerCase() === here ? "active" : "";
      return `<a href="${p.href}" class="${cls}">${p.label}</a>`;
    }).join("");

    // Account / sign-in slot — flips based on localStorage 'mimic_username'
    const user = (() => { try { return localStorage.getItem("mimic_username"); } catch (e) { return null; } })();
    const accountLink = user
      ? `<a href="account.html" class="${here === "account.html" || here === "create-character.html" ? "active" : ""}" title="Signed in as ${user}">Account</a>`
      : `<a href="signin.html" class="${here === "signin.html" ? "active" : ""}">Sign in</a>`;

    const html = `
      <header class="site-header">
        <div class="inner">
          <a href="index.html" class="brand">
            ${crystalMark()}
            <span>Mimic<span class="brand-x">XI</span></span>
          </a>
          <nav class="nav">
            ${navLinks}
            ${accountLink}
            <a href="join.html" class="nav-join">Join the alpha</a>
          </nav>
        </div>
      </header>`;
    document.body.insertAdjacentHTML("afterbegin", html);
  }

  function renderFooter() {
    const html = `
      <footer class="site-footer">
        <div class="inner">
          <div class="disclaimer">
            <strong style="color: var(--ink);">MimicXI</strong> is a private, non-commercial project run by fans of Final Fantasy XI.
            Not affiliated with or endorsed by Square Enix. All trademarks belong to their respective owners.
          </div>
          <div style="font-family: var(--mono); font-size: 0.72rem; letter-spacing: 0.12em; text-transform: uppercase; color: var(--ink-faint);">
            Alpha · Wings of the Goddess era · 75 cap
          </div>
        </div>
      </footer>`;
    document.body.insertAdjacentHTML("beforeend", html);
  }

  document.addEventListener("DOMContentLoaded", () => {
    renderHeader();
    renderFooter();
  });
})();
