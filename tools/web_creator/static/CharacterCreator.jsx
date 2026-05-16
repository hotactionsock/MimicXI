/**
 * CharacterCreator — self-contained React component.
 *
 * Paste into Claude Design to preview / iterate on the UI.
 * Set API_BASE to your Flask server URL for real use.
 *
 * Face value encoding (matches server CharFace enum):
 *   A variant : (faceNum - 1) * 2
 *   B variant : (faceNum - 1) * 2 + 1
 *   C variant : faceNum + 15   (custom — requires matching client DATs)
 */

const API_BASE = '';   // e.g. 'http://127.0.0.1:5000' in production

// ── Game data ────────────────────────────────────────────────────────────────

const RACES = [
  { id: 1, name: 'Hume',     gender: 'Male',   initial: 'H' },
  { id: 2, name: 'Hume',     gender: 'Female', initial: 'H' },
  { id: 3, name: 'Elvaan',   gender: 'Male',   initial: 'E' },
  { id: 4, name: 'Elvaan',   gender: 'Female', initial: 'E' },
  { id: 5, name: 'Tarutaru', gender: 'Male',   initial: 'T' },
  { id: 6, name: 'Tarutaru', gender: 'Female', initial: 'T' },
  { id: 7, name: 'Mithra',   gender: '',       initial: 'M' },
  { id: 8, name: 'Galka',    gender: '',       initial: 'G' },
];

const JOBS = [
  { id: 1, name: 'Warrior',    abbr: 'WAR' },
  { id: 2, name: 'Monk',       abbr: 'MNK' },
  { id: 3, name: 'White Mage', abbr: 'WHM' },
  { id: 4, name: 'Black Mage', abbr: 'BLM' },
  { id: 5, name: 'Red Mage',   abbr: 'RDM' },
  { id: 6, name: 'Thief',      abbr: 'THF' },
];

const NATIONS = [
  { id: 0, name: "San d'Oria" },
  { id: 1, name: 'Bastok' },
  { id: 2, name: 'Windurst' },
];

const SIZES = [
  { id: 0, label: 'Small' },
  { id: 1, label: 'Medium' },
  { id: 2, label: 'Large' },
];

// Build the 8×3 face grid
const FACE_GRID = Array.from({ length: 8 }, (_, i) => {
  const num = i + 1;
  return [
    { num, variant: 'A', value: (num - 1) * 2,     custom: false },
    { num, variant: 'B', value: (num - 1) * 2 + 1, custom: false },
    { num, variant: 'C', value: num + 15,           custom: true  },
  ];
});

function faceLabel(value) {
  if (value >= 0 && value <= 15)  return `Face ${Math.floor(value / 2) + 1}${value % 2 === 0 ? 'A' : 'B'}`;
  if (value >= 16 && value <= 23) return `Face ${value - 15}C`;
  return `Face ${value}`;
}

// ── Styles (inline for portability in Claude Design) ─────────────────────────

const css = {
  page: {
    fontFamily: "'Georgia', serif",
    background: '#0a0e1a',
    color: '#e2d5b0',
    minHeight: '100vh',
    padding: '2rem 1.5rem 4rem',
  },
  container: { maxWidth: 860, margin: '0 auto' },

  heading: { fontSize: '1.5rem', color: '#d4af37', marginBottom: '0.5rem' },
  sectionWrap: { marginBottom: '2.5rem' },
  sectionTitle: {
    fontSize: '0.95rem', color: '#d4af37', letterSpacing: '0.06em',
    paddingBottom: '0.5rem', borderBottom: '1px solid #2d3748', marginBottom: '1rem',
  },

  // ── Race grid
  raceGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(96px, 1fr))',
    gap: '0.6rem',
  },
  raceTile: (selected) => ({
    display: 'flex', flexDirection: 'column', alignItems: 'center',
    gap: '0.3rem', padding: '0.8rem 0.4rem',
    background: '#1a2035',
    border: `2px solid ${selected ? '#d4af37' : '#2d3748'}`,
    borderRadius: 6, cursor: 'pointer', textAlign: 'center',
    background: selected ? 'rgba(212,175,55,0.08)' : '#1a2035',
    transition: 'border-color 0.15s',
  }),
  raceInitial: {
    width: '2rem', height: '2rem', borderRadius: '50%',
    background: '#2d3748', display: 'flex', alignItems: 'center',
    justifyContent: 'center', fontWeight: 'bold', color: '#d4af37', fontSize: '1rem',
  },
  raceName:   { fontSize: '0.78rem', fontWeight: 'bold' },
  raceGender: { fontSize: '0.7rem', color: '#8a7a5a' },

  // ── Face grid
  faceOuter: { overflowX: 'auto' },
  faceTable: { width: '100%', borderCollapse: 'separate', borderSpacing: '0.35rem' },
  faceHeaderCell: (custom) => ({
    textAlign: 'center', fontSize: '0.8rem', fontWeight: 'bold',
    color: custom ? '#9b59b6' : '#8a7a5a', paddingBottom: '0.4rem',
    letterSpacing: '0.08em',
  }),
  faceRowNum: {
    fontSize: '0.8rem', color: '#8a7a5a', textAlign: 'center',
    width: '2rem', paddingRight: '0.4rem',
  },
  faceTile: (selected, custom) => ({
    padding: '0.55rem 0.3rem',
    background: selected
      ? (custom ? 'rgba(155,89,182,0.14)' : 'rgba(212,175,55,0.1)')
      : '#1a2035',
    border: `2px solid ${
      selected ? (custom ? '#9b59b6' : '#d4af37') : (custom ? '#6c3483' : '#2d3748')
    }`,
    borderRadius: 5, cursor: 'pointer',
    display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.2rem',
    minWidth: '3.5rem',
    transition: 'border-color 0.12s',
  }),
  faceIcon:  { fontSize: '1.3rem' },
  faceSmall: { fontSize: '0.68rem', color: '#8a7a5a' },
  customBadge: {
    display: 'inline-block', fontSize: '0.55rem', background: '#6c3483',
    color: '#fff', borderRadius: 3, padding: '1px 4px', marginLeft: 4,
    verticalAlign: 'middle',
  },
  faceSelectedNote: { marginTop: '0.6rem', fontSize: '0.85rem', color: '#8a7a5a' },
  faceSelectedVal:  { color: '#d4af37', fontWeight: 'bold' },

  // ── Size / Nation row
  tileRow: { display: 'flex', gap: '0.65rem', flexWrap: 'wrap' },
  tile: (selected) => ({
    padding: '0.5rem 1.2rem',
    background: selected ? 'rgba(212,175,55,0.08)' : '#1a2035',
    border: `2px solid ${selected ? '#d4af37' : '#2d3748'}`,
    borderRadius: 5, cursor: 'pointer', fontSize: '0.9rem',
    transition: 'border-color 0.12s',
  }),

  // ── Name / Job
  input: {
    background: '#1a2035', border: '1px solid #2d3748', borderRadius: 5,
    color: '#e2d5b0', padding: '0.5rem 0.7rem', fontSize: '0.95rem',
    fontFamily: 'inherit', width: '100%', maxWidth: 300,
  },
  select: {
    background: '#1a2035', border: '1px solid #2d3748', borderRadius: 5,
    color: '#e2d5b0', padding: '0.5rem 0.7rem', fontSize: '0.9rem',
    fontFamily: 'inherit', width: '100%', maxWidth: 280,
    WebkitAppearance: 'none',
  },
  hint: { fontSize: '0.76rem', color: '#8a7a5a', marginTop: '0.3rem' },

  // ── Alerts
  alert: (type) => ({
    padding: '0.7rem 1rem', borderRadius: 5, marginBottom: '1rem',
    fontSize: '0.88rem', borderLeft: `4px solid ${type === 'error' ? '#e74c3c' : '#27ae60'}`,
    background: type === 'error' ? 'rgba(231,76,60,0.1)' : 'rgba(39,174,96,0.1)',
  }),

  // ── Buttons
  btnPrimary: {
    display: 'inline-flex', alignItems: 'center', gap: '0.4rem',
    padding: '0.6rem 1.4rem', borderRadius: 5, cursor: 'pointer',
    background: '#d4af37', color: '#0a0e1a', fontWeight: 'bold',
    border: '1px solid #d4af37', fontFamily: 'inherit', fontSize: '0.9rem',
  },
  btnOutline: {
    display: 'inline-flex', alignItems: 'center', gap: '0.4rem',
    padding: '0.6rem 1.2rem', borderRadius: 5, cursor: 'pointer',
    background: 'transparent', color: '#8a7a5a',
    border: '1px solid #2d3748', fontFamily: 'inherit', fontSize: '0.9rem',
  },
  actions: { display: 'flex', gap: '1rem', marginTop: '2.5rem' },
};

// ── Component ─────────────────────────────────────────────────────────────────

export default function CharacterCreator({ onSuccess }) {
  const [name,   setName]   = React.useState('');
  const [race,   setRace]   = React.useState(1);
  const [face,   setFace]   = React.useState(0);
  const [size,   setSize]   = React.useState(1);
  const [job,    setJob]    = React.useState(1);
  const [nation, setNation] = React.useState(0);
  const [msg,    setMsg]    = React.useState(null);   // { type, text }
  const [busy,   setBusy]   = React.useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setMsg(null);

    if (!name.trim() || name.trim().length < 3 || !/^[a-zA-Z]+$/.test(name.trim())) {
      setMsg({ type: 'error', text: 'Name must be 3–15 letters only.' });
      return;
    }

    setBusy(true);
    try {
      const res = await fetch(`${API_BASE}/api/create`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: name.trim(), race, face, size, job, nation }),
      });
      const data = await res.json();
      if (res.ok) {
        setMsg({ type: 'success', text: `Character '${name.trim()}' created!` });
        onSuccess?.();
      } else {
        setMsg({ type: 'error', text: data.error || 'Creation failed.' });
      }
    } catch {
      setMsg({ type: 'error', text: 'Could not reach server.' });
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={css.page}>
      <div style={css.container}>
        <h2 style={css.heading}>Create Character</h2>

        {msg && <div style={css.alert(msg.type)}>{msg.text}</div>}

        <form onSubmit={handleSubmit} noValidate>

          {/* ── Name */}
          <div style={css.sectionWrap}>
            <div style={css.sectionTitle}>Name</div>
            <input
              style={css.input}
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="3–15 letters"
              maxLength={15}
            />
            <p style={css.hint}>Letters only. First character will be capitalised in-game.</p>
          </div>

          {/* ── Race */}
          <div style={css.sectionWrap}>
            <div style={css.sectionTitle}>Race</div>
            <div style={css.raceGrid}>
              {RACES.map(r => (
                <div key={r.id} style={css.raceTile(race === r.id)} onClick={() => setRace(r.id)}>
                  <div style={css.raceInitial}>{r.initial}</div>
                  <span style={css.raceName}>{r.name}</span>
                  {r.gender && <span style={css.raceGender}>{r.gender}</span>}
                </div>
              ))}
            </div>
          </div>

          {/* ── Face */}
          <div style={css.sectionWrap}>
            <div style={css.sectionTitle}>
              Face
              <span style={{ fontSize: '0.76rem', color: '#8a7a5a', fontWeight: 'normal', marginLeft: 8 }}>
                — C variants require matching client data
              </span>
            </div>
            <div style={css.faceOuter}>
              <table style={css.faceTable}>
                <thead>
                  <tr>
                    <th style={{ width: '2rem' }} />
                    <th style={css.faceHeaderCell(false)}>A</th>
                    <th style={css.faceHeaderCell(false)}>B</th>
                    <th style={css.faceHeaderCell(true)}>
                      C <span style={css.customBadge}>Custom</span>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {FACE_GRID.map(row => (
                    <tr key={row[0].num}>
                      <td style={css.faceRowNum}>{row[0].num}</td>
                      {row.map(cell => (
                        <td key={cell.variant}>
                          <div
                            style={css.faceTile(face === cell.value, cell.custom)}
                            onClick={() => setFace(cell.value)}
                            title={`Face ${cell.num}${cell.variant} (value ${cell.value})`}
                          >
                            <span style={css.faceIcon}>{cell.custom ? '✦' : '◉'}</span>
                            <span style={css.faceSmall}>{cell.variant}</span>
                          </div>
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <p style={css.faceSelectedNote}>
              Selected: <span style={css.faceSelectedVal}>{faceLabel(face)}</span>
            </p>
          </div>

          {/* ── Size */}
          <div style={css.sectionWrap}>
            <div style={css.sectionTitle}>Size</div>
            <div style={css.tileRow}>
              {SIZES.map(s => (
                <div key={s.id} style={css.tile(size === s.id)} onClick={() => setSize(s.id)}>
                  {s.label}
                </div>
              ))}
            </div>
          </div>

          {/* ── Starting Job */}
          <div style={css.sectionWrap}>
            <div style={css.sectionTitle}>Starting Job</div>
            <select style={css.select} value={job} onChange={e => setJob(Number(e.target.value))}>
              {JOBS.map(j => (
                <option key={j.id} value={j.id}>{j.name} ({j.abbr})</option>
              ))}
            </select>
          </div>

          {/* ── Nation */}
          <div style={css.sectionWrap}>
            <div style={css.sectionTitle}>Starting Nation</div>
            <div style={css.tileRow}>
              {NATIONS.map(n => (
                <div key={n.id} style={css.tile(nation === n.id)} onClick={() => setNation(n.id)}>
                  {n.name}
                </div>
              ))}
            </div>
          </div>

          <div style={css.actions}>
            <button type="button" style={css.btnOutline} onClick={() => window.history.back()}>
              Cancel
            </button>
            <button type="submit" style={css.btnPrimary} disabled={busy}>
              {busy ? 'Creating…' : 'Create Character'}
            </button>
          </div>

        </form>
      </div>
    </div>
  );
}
