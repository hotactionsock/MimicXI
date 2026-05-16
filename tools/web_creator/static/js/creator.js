'use strict';

// Face value → display label
function faceLabel(value) {
  if (value >= 0 && value <= 15) {
    return 'Face ' + (Math.floor(value / 2) + 1) + (value % 2 === 0 ? 'A' : 'B');
  }
  if (value >= 16 && value <= 23) {
    return 'Face ' + (value - 15) + 'C';
  }
  return 'Face ' + value;
}

// ── Face picker ──────────────────────────────────────────────────────────────
(function () {
  const tiles      = document.querySelectorAll('.face-tile');
  const input      = document.getElementById('face-value');
  const labelEl    = document.getElementById('face-selected-label');

  if (!tiles.length || !input) return;

  function select(tile) {
    tiles.forEach(t => t.classList.remove('face-selected'));
    tile.classList.add('face-selected');
    const val = parseInt(tile.dataset.value, 10);
    input.value = val;
    if (labelEl) labelEl.textContent = faceLabel(val);
  }

  tiles.forEach(tile => {
    tile.addEventListener('click', () => select(tile));
    tile.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); select(tile); }
    });
    tile.setAttribute('tabindex', '0');
    tile.setAttribute('role', 'radio');
    tile.setAttribute('aria-checked', tile.classList.contains('face-selected') ? 'true' : 'false');
  });
})();

// ── Race picker ──────────────────────────────────────────────────────────────
(function () {
  const tiles = document.querySelectorAll('.race-tile');

  tiles.forEach(tile => {
    const radio = tile.querySelector('input[type="radio"]');
    if (!radio) return;

    tile.addEventListener('click', () => {
      tiles.forEach(t => t.classList.remove('selected'));
      tile.classList.add('selected');
      radio.checked = true;
    });
  });
})();

// ── Size / Nation picker ─────────────────────────────────────────────────────
(function () {
  document.querySelectorAll('.size-group').forEach(group => {
    const tiles = group.querySelectorAll('.size-tile');
    tiles.forEach(tile => {
      const radio = tile.querySelector('input[type="radio"]');
      if (!radio) return;
      tile.addEventListener('click', () => {
        tiles.forEach(t => t.classList.remove('selected'));
        tile.classList.add('selected');
        radio.checked = true;
      });
    });
  });
})();

// ── Form validation feedback ─────────────────────────────────────────────────
(function () {
  const form = document.getElementById('create-form');
  if (!form) return;

  form.addEventListener('submit', e => {
    const name = form.querySelector('#name');
    if (name && (name.value.trim().length < 3 || !/^[a-zA-Z]+$/.test(name.value.trim()))) {
      e.preventDefault();
      name.focus();
      name.style.borderColor = 'var(--error)';
      return;
    }
    const face = document.getElementById('face-value');
    if (face && (face.value === '' || face.value === null)) {
      e.preventDefault();
      document.querySelector('.face-grid')?.scrollIntoView({ behavior: 'smooth' });
    }
  });
})();
