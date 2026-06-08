// Shared auth helper for MimicXI account pages.
//
// Configure where the Flask backend lives via window.MIMIC_API_BASE *before* this
// script loads, or it will assume same-origin. Examples:
//   <script>window.MIMIC_API_BASE = "http://127.0.0.1:5000";</script>
//   <script src="auth.js"></script>
//
// All requests use credentials:'include' so Flask's session cookie comes along.

(function () {
  const API_BASE = (window.MIMIC_API_BASE || "").replace(/\/$/, "");

  async function api(path, opts) {
    opts = opts || {};
    const init = {
      method: opts.method || "GET",
      credentials: "include",
      headers: { Accept: "application/json", ...(opts.headers || {}) },
    };
    if (opts.body !== undefined) {
      init.headers["Content-Type"] = "application/json";
      init.body = JSON.stringify(opts.body);
    }
    const res = await fetch(API_BASE + path, init);
    let data = null;
    try { data = await res.json(); } catch (e) { /* not JSON */ }
    return { ok: res.ok, status: res.status, data };
  }

  // Form-encoded variant (the existing /login endpoint expects form posts)
  async function apiForm(path, formData) {
    const body = new URLSearchParams();
    Object.entries(formData).forEach(([k, v]) => body.append(k, v));
    const res = await fetch(API_BASE + path, {
      method: "POST",
      credentials: "include",
      body,
    });
    return { ok: res.ok, status: res.status, redirected: res.redirected, url: res.url };
  }

  async function logout() {
    // /logout is a form POST that redirects
    const body = new URLSearchParams();
    await fetch(API_BASE + "/logout", {
      method: "POST",
      credentials: "include",
      body,
    });
    localStorage.removeItem("mimic_username");
    location.href = "signin.html";
  }

  function setSession(username) {
    if (username) localStorage.setItem("mimic_username", username);
    else localStorage.removeItem("mimic_username");
  }

  function getSession() {
    return localStorage.getItem("mimic_username");
  }

  // Guard helper: redirect to signin if /api/characters returns 401.
  async function requireAuth() {
    const r = await api("/api/characters");
    if (r.status === 401) {
      location.href = "signin.html?next=" + encodeURIComponent(location.pathname.split("/").pop());
      return null;
    }
    return r;
  }

  window.MimicAuth = { api, apiForm, logout, setSession, getSession, requireAuth, API_BASE };
})();
