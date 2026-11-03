// Shared helpers for the world bot pages (bots.html, bot.html).
(function () {
  const CATEGORY_LABELS = {
    lifecycle: "Life",
    level:     "Level up",
    death:     "Defeat",
    combat:    "Combat",
    gear:      "Gear",
    magic:     "Magic",
    item:      "Items",
    job:       "Jobs",
    party:     "Party",
    travel:    "Travel",
    nm:        "Notorious",
    shop:      "Shopping",
    quest:     "Quests",
    mission:   "Missions",
    craft:     "Crafting",
  };

  function esc(s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, c => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
    }[c]));
  }

  function setText(id, text) {
    const el = document.getElementById(id);
    if (el) el.textContent = text;
  }

  async function getJson(path) {
    const base = (window.MIMIC_API_BASE || "").replace(/\/$/, "");
    const r = await fetch(base + path, { headers: { Accept: "application/json" } });
    if (!r.ok) throw new Error("HTTP " + r.status);
    return r.json();
  }

  // Unix seconds -> "just now", "5 minutes ago", "2 days ago".
  function ago(ts) {
    if (!ts) return "";
    const seconds = Math.max(0, Math.floor(Date.now() / 1000) - ts);
    const units = [["day", 86400], ["hour", 3600], ["minute", 60]];
    for (const [unit, size] of units) {
      if (seconds >= size) {
        const n = Math.floor(seconds / size);
        return `${n} ${unit}${n === 1 ? "" : "s"} ago`;
      }
    }
    return "just now";
  }

  function refreshTimes(root) {
    root.querySelectorAll("time[data-ts]").forEach(t => {
      t.textContent = ago(Number(t.dataset.ts));
    });
  }

  // Face portrait (the site's /face-icon route), falling back to the initial.
  function avatar(bot, cls) {
    const initial = esc((bot.name || "?").charAt(0));
    if (bot.race && bot.face != null) {
      return `<span class="${cls}"><img src="/face-icon/${bot.race}/${bot.face}" alt="" loading="lazy"
        onerror="this.replaceWith(Object.assign(document.createElement('span'), {className: 'avatar-initial', textContent: '${initial}'}))"></span>`;
    }
    return `<span class="${cls}"><span class="avatar-initial">${initial}</span></span>`;
  }

  function categoryLabel(category) {
    return CATEGORY_LABELS[category] || (category ? category.charAt(0).toUpperCase() + category.slice(1) : "");
  }

  // An event's sentence, with the bot's name (when it leads) linking to its page.
  function linkName(e) {
    const message = String(e.message || "");
    if (e.name && message.startsWith(e.name)) {
      return `<a class="feed-name" href="bot.html?id=${e.charid}">${esc(e.name)}</a>${esc(message.slice(e.name.length))}`;
    }
    return esc(message);
  }

  window.MimicBots = { esc, setText, getJson, ago, refreshTimes, avatar, categoryLabel, linkName, CATEGORY_LABELS };
})();
