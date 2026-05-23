/* ============================================================
   ESTADO
============================================================ */
const roleMap = {
  admin: 'Administrador',
  doctor: 'Doctor',
  paciente: 'Paciente',
  personal: 'Personal',
  practicante: 'Practicante'
};

let currentRole = '';

const state = {
  // Cada objeto guarda { id, ...datos } donde id viene del servidor (BD)
  pacientes:      [],   // { id, nombre, dni, contacto }
  especialidades: [],   // { id, nombre }
  consultorios:   [],   // { id, numero, especialidad, idEspecialidad }
  citas:          [],   // { id, paciente, consultorio, doctor, fecha, hora }
  historias:      [],   // { id, paciente, sintomas, tratamiento }
  practicantes:   []    // { id, nombre, dni, supervisor, especialidad }
};

/* ============================================================
   UTILIDAD: llamada al servlet con fetch
   Devuelve { ok: true, id: N } o { ok: false, msg: '...' }
============================================================ */
async function postServlet(endpoint, params) {
  const body = new URLSearchParams(params);
  try {
    const res = await fetch(endpoint, { method: 'POST', body });
    const text = await res.text();
    if (!res.ok) return { ok: false, msg: text || 'Error del servidor' };
    // Los servlets devuelven "ID:N" cuando tienen éxito
    if (text.startsWith('ID:')) return { ok: true, id: parseInt(text.slice(3), 10) };
    return { ok: true, id: -1 };
  } catch (err) {
    return { ok: false, msg: 'No se pudo conectar con el servidor: ' + err.message };
  }
}

/* ============================================================
   AUTH
============================================================ */
function autofill(r) {
  document.getElementById('username').value = r;
  document.getElementById('password').value = r;
}

function login() {
  const u = document.getElementById('username').value.trim().toLowerCase();
  const p = document.getElementById('password').value.trim().toLowerCase();
  const err = document.getElementById('login-error');

  if (u === p && roleMap[u]) {
    currentRole = roleMap[u];
    err.style.display = 'none';
    document.getElementById('login-section').style.display = 'none';
    document.getElementById('main-app').classList.add('visible');
    document.getElementById('role-badge').textContent = currentRole;
    renderDashboard();
  } else {
    err.textContent = 'Credenciales inválidas. Use el mismo valor para usuario y contraseña.';
    err.style.display = 'block';
  }
}

document.addEventListener('keydown', e => {
  if (e.key === 'Enter' && document.getElementById('login-section').style.display !== 'none') {
    login();
  }
});

function logout() {
  currentRole = '';
  document.getElementById('login-section').style.display = '';
  document.getElementById('main-app').classList.remove('visible');
  document.getElementById('username').value = '';
  document.getElementById('password').value = '';
}

/* ============================================================
   DASHBOARD
============================================================ */
const MOD_CFG = {
  pacientes:      { cls: 'mod-blue',   title: 'Pacientes',        desc: 'Registra y consulta información de pacientes',        icon: svgUsers() },
  especialidades: { cls: 'mod-violet', title: 'Especialidades',   desc: 'Gestiona las especialidades médicas disponibles',     icon: svgStethoscope() },
  consultorios:   { cls: 'mod-green',  title: 'Consultorios',     desc: 'Administra los consultorios y sus asignaciones',      icon: svgBuilding() },
  citas:          { cls: 'mod-orange', title: 'Citas',            desc: 'Programa y visualiza citas médicas',                  icon: svgCalendar() },
  historia:       { cls: 'mod-teal',   title: 'Historia Clínica', desc: 'Registra síntomas y tratamientos de pacientes',       icon: svgClipboard() },
  practicantes:   { cls: 'mod-indigo', title: 'Practicantes',     desc: 'Administra el registro de practicantes',              icon: svgGradCap() },
};

const ROLE_MODS = {
  Administrador: ['pacientes', 'especialidades', 'consultorios', 'citas', 'historia', 'practicantes'],
  Doctor:        ['historia'],
  Personal:      ['pacientes', 'citas'],
  Paciente:      [],
  Practicante:   []
};

function renderDashboard() {
  const mods = ROLE_MODS[currentRole] || [];
  document.getElementById('welcome-title').textContent = `Bienvenido, ${currentRole}`;
  document.getElementById('welcome-sub').textContent = mods.length > 0
    ? 'Selecciona un módulo para comenzar a gestionar.'
    : 'Actualmente no tienes módulos asignados para este rol.';

  const stats = document.getElementById('stats-section');
  stats.style.display = currentRole === 'Administrador' ? 'grid' : 'none';
  updateStats();

  const cont = document.getElementById('modules-container');
  if (!mods.length) {
    cont.innerHTML = `
      <div class="no-access">
        <div class="no-access-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#60a5fa" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </div>
        <p class="no-access-title">Sin acceso a módulos</p>
        <p class="no-access-desc">El rol <strong>${currentRole}</strong> no tiene permisos para gestionar módulos.</p>
      </div>`;
    return;
  }

  cont.innerHTML = `<div class="modules-grid">${mods.map(id => {
    const c = MOD_CFG[id];
    return `
      <div class="card card-hover module-card ${c.cls}" onclick="openModal('${id}')">
        <div class="module-icon">${c.icon}</div>
        <h3>${c.title}</h3>
        <p class="module-desc">${c.desc}</p>
        <button class="module-link" onclick="event.stopPropagation();openModal('${id}')">
          Abrir módulo
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="9 18 15 12 9 6"/>
          </svg>
        </button>
      </div>`;
  }).join('')}</div>`;
}

function updateStats() {
  document.getElementById('stat-pacientes').textContent    = state.pacientes.length;
  document.getElementById('stat-citas').textContent        = state.citas.length;
  document.getElementById('stat-consultorios').textContent = state.consultorios.length;
  document.getElementById('stat-especialidades').textContent = state.especialidades.length;
}

/* ============================================================
   MODALS
============================================================ */
function openModal(id) {
  refreshSelects();
  const ov = document.getElementById(`modal-${id}`);
  ov.querySelectorAll('.tab-btn').forEach((b, i) => b.classList.toggle('active', i === 0));
  ov.querySelectorAll('.tab-panel').forEach((p, i) => p.classList.toggle('active', i === 0));
  ov.classList.add('open');
}

function closeModal(id) {
  document.getElementById(`modal-${id}`).classList.remove('open');
}

document.querySelectorAll('.modal-overlay').forEach(o => {
  o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); });
});

function switchTab(modalId, tabId, btn) {
  const ov = document.getElementById(`modal-${modalId}`);
  ov.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  ov.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById(`${modalId}-${tabId}`).classList.add('active');
}

function refreshSelects() {
  // Especialidades — value = id (BD), texto = nombre
  ['cons-esp', 'cita-esp', 'prac-esp'].forEach(id => {
    const s = document.getElementById(id);
    if (!s) return;
    s.innerHTML = state.especialidades.length === 0
      ? '<option value="">Registra una especialidad primero</option>'
      : '<option value="">Elegir...</option>' + state.especialidades.map(e => `<option value="${e.id}">${e.nombre}</option>`).join('');
    s.disabled = state.especialidades.length === 0;
  });

  // Pacientes — value = id (BD), texto = nombre
  ['cita-pac', 'hist-pac'].forEach(id => {
    const s = document.getElementById(id);
    if (!s) return;
    s.innerHTML = state.pacientes.length === 0
      ? '<option value="">Registra un paciente primero</option>'
      : '<option value="">Elegir...</option>' + state.pacientes.map(p => `<option value="${p.id}">${p.nombre}</option>`).join('');
  });

  // Consultorios — value = id (BD), texto = numero + especialidad
  const cs = document.getElementById('cita-cons');
  if (cs) {
    cs.innerHTML = state.consultorios.length === 0
      ? '<option value="">Registra un consultorio primero</option>'
      : '<option value="">Elegir...</option>' + state.consultorios.map(c => `<option value="${c.id}">N° ${c.numero} — ${c.especialidad}</option>`).join('');
  }
}

/* ============================================================
   FORM SUBMISSIONS
============================================================ */
// ——— PACIENTE ———
async function submitPaciente(e) {
  e.preventDefault();
  const nombre = v('pac-nombre'), dni = v('pac-dni'), contacto = v('pac-contacto');
  if (!nombre || !dni) { toast('Nombre y DNI son obligatorios.', 'error'); return; }

  const res = await postServlet('paciente', { nombre, dni, contacto });
  if (!res.ok) { toast('Error al guardar paciente: ' + res.msg, 'error'); return; }

  state.pacientes.push({ id: res.id, nombre, dni, contacto });
  e.target.reset();
  renderPacientes();
  refreshSelects();
  updateStats();
  toast('Paciente registrado correctamente (ID: ' + res.id + ')', 'success');
}

// ——— ESPECIALIDAD ———
async function submitEspecialidad(e) {
  e.preventDefault();
  const nombre = document.getElementById('esp-select').value;
  if (!nombre) return;
  if (state.especialidades.some(x => x.nombre === nombre)) {
    toast('Especialidad ya registrada', 'error'); return;
  }

  const res = await postServlet('especialidad', { especialidad: nombre });
  if (!res.ok) { toast('Error al guardar especialidad: ' + res.msg, 'error'); return; }

  state.especialidades.push({ id: res.id, nombre });
  e.target.reset();
  renderEspecialidades();
  refreshSelects();
  updateStats();
  toast('Especialidad registrada (ID: ' + res.id + ')', 'success');
}

// ——— CONSULTORIO ———
async function submitConsultorio(e) {
  e.preventDefault();
  const idEsp = document.getElementById('cons-esp').value;
  const numeroSel = document.getElementById('cons-numero') ? v('cons-numero') : String(state.consultorios.length + 1);
  if (!idEsp) { toast('Selecciona una especialidad.', 'error'); return; }

  const numero = state.consultorios.length + 1;   // numero autoincremental local
  const espObj = state.especialidades.find(x => String(x.id) === String(idEsp));

  const res = await postServlet('consultorio', { numero, especialidad: idEsp });
  if (!res.ok) { toast('Error al guardar consultorio: ' + res.msg, 'error'); return; }

  state.consultorios.push({ id: res.id, numero, especialidad: espObj ? espObj.nombre : idEsp, idEspecialidad: idEsp });
  e.target.reset();
  renderConsultorios();
  refreshSelects();
  updateStats();
  toast('Consultorio registrado (ID: ' + res.id + ')', 'success');
}

// ——— CITA ———
async function submitCita(e) {
  e.preventDefault();
  const idPac  = v('cita-pac');
  const idCons = v('cita-cons');
  const doctor = v('cita-doc');
  const fecha  = v('cita-fecha');
  const hora   = v('cita-hora');
  if (!idPac || !fecha || !hora) { toast('Paciente, fecha y hora son obligatorios.', 'error'); return; }

  const pacObj  = state.pacientes.find(x => String(x.id) === String(idPac));
  const consObj = state.consultorios.find(x => String(x.id) === String(idCons));

  const res = await postServlet('cita', { paciente: idPac, consultorio: idCons || 0, doctor, fecha, hora });
  if (!res.ok) { toast('Error al guardar cita: ' + res.msg, 'error'); return; }

  state.citas.push({
    id: res.id,
    paciente:    pacObj  ? pacObj.nombre  : idPac,
    consultorio: consObj ? consObj.numero : (idCons || 'N/A'),
    doctor, fecha, hora
  });
  e.target.reset();
  renderCitas();
  updateStats();
  toast('Cita registrada (ID: ' + res.id + ')', 'success');
}

// ——— HISTORIA ———
async function submitHistoria(e) {
  e.preventDefault();
  const idPac     = v('hist-pac');
  const sintomas  = v('hist-sint');
  const tratamiento = v('hist-trat');
  if (!idPac) { toast('Selecciona un paciente.', 'error'); return; }

  const pacObj = state.pacientes.find(x => String(x.id) === String(idPac));

  const res = await postServlet('historia', { paciente: idPac, sintomas, tratamiento });
  if (!res.ok) { toast('Error al guardar historia: ' + res.msg, 'error'); return; }

  state.historias.push({ id: res.id, paciente: pacObj ? pacObj.nombre : idPac, sintomas, tratamiento });
  e.target.reset();
  renderHistorias();
  toast('Historia clínica registrada (ID: ' + res.id + ')', 'success');
}

// ——— PRACTICANTE ———
async function submitPracticante(e) {
  e.preventDefault();
  const nombre      = v('prac-nombre');
  const dni         = v('prac-dni');
  const supervisor  = v('prac-sup');
  const especialidad = v('prac-esp');
  if (!nombre || !dni) { toast('Nombre y DNI son obligatorios.', 'error'); return; }

  const res = await postServlet('practicante', { nombre, dni, supervisor, especialidad });
  if (!res.ok) { toast('Error al guardar practicante: ' + res.msg, 'error'); return; }

  state.practicantes.push({ id: res.id, nombre, dni, supervisor: supervisor || 'No asignado', especialidad: especialidad || 'General' });
  e.target.reset();
  renderPracticantes();
  toast('Practicante registrado (ID: ' + res.id + ')', 'success');
}

function v(id) {
  return document.getElementById(id).value.trim();
}

/* ============================================================
   RENDER DATA
============================================================ */
function renderPacientes() {
  const rows = state.pacientes.map(p => `<tr><td>${p.nombre}</td><td>${p.dni}</td><td>${p.contacto}</td></tr>`).join('');
  toggle('pac-tbody', rows, 'pac-empty', 'pac-table', state.pacientes.length);
}

function renderEspecialidades() {
  const sec = document.getElementById('esp-list-section');
  sec.style.display = state.especialidades.length ? 'block' : 'none';
  document.getElementById('esp-tags').innerHTML = state.especialidades.map(e => `<span class="specialty-tag">${e.nombre}</span>`).join('');
}

function renderConsultorios() {
  const rows = state.consultorios.map(c => `<tr><td>${c.numero}</td><td>${c.especialidad}</td></tr>`).join('');
  toggle('cons-tbody', rows, 'cons-empty', 'cons-table', state.consultorios.length);
}

function renderCitas() {
  const rows = state.citas.map(c => `<tr><td>${c.paciente}</td><td>N° ${c.consultorio}</td><td>${c.doctor}</td><td>${c.fecha}</td><td>${c.hora}</td></tr>`).join('');
  toggle('citas-tbody', rows, 'citas-empty', 'citas-table', state.citas.length);
}

function renderHistorias() {
  const rows = state.historias.map(h => `<tr><td>${h.paciente}</td><td>${h.sintomas}</td><td>${h.tratamiento}</td></tr>`).join('');
  toggle('hist-tbody', rows, 'hist-empty', 'hist-table', state.historias.length);
}

function renderPracticantes() {
  const rows = state.practicantes.map(p => `<tr><td>${p.nombre}</td><td>${p.dni}</td><td>${p.supervisor}</td><td>${p.especialidad}</td></tr>`).join('');
  toggle('prac-tbody', rows, 'prac-empty', 'prac-table', state.practicantes.length);
}

function toggle(tbodyId, rows, emptyId, tableId, len) {
  document.getElementById(tbodyId).innerHTML = rows;
  document.getElementById(emptyId).style.display = len ? 'none' : 'flex';
  document.getElementById(tableId).style.display = len ? 'block' : 'none';
}

/* ============================================================
   TOASTS
============================================================ */
function toast(msg, type = 'success') {
  const c = document.getElementById('toast-container');
  const el = document.createElement('div');
  el.className = `toast toast-${type}`;
  const ok = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>`;
  const er = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`;
  el.innerHTML = `${type === 'success' ? ok : er}<span class="toast-text">${msg}</span>`;
  c.appendChild(el);
  setTimeout(() => {
    el.style.animation = 'toastOut .2s ease forwards';
    setTimeout(() => el.remove(), 200);
  }, 3000);
}

/* ============================================================
   INLINE SVG ICONS
============================================================ */
function svgUsers() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`;
}
function svgStethoscope() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4.8 2.3A.3.3 0 1 0 5 2H4a2 2 0 0 0-2 2v5a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6V4a2 2 0 0 0-2-2h-1a.2.2 0 1 0 .3.3"/><path d="M8 15v1a6 6 0 0 0 6 6v0a6 6 0 0 0 6-6v-4"/><circle cx="20" cy="10" r="2"/></svg>`;
}
function svgBuilding() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 22V4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v18Z"/><path d="M6 12H4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2"/><path d="M18 9h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-2"/><path d="M10 6h4"/><path d="M10 10h4"/><path d="M10 14h4"/><path d="M10 18h4"/></svg>`;
}
function svgCalendar() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>`;
}
function svgClipboard() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1"/><path d="M9 14l2 2 4-4"/></svg>`;
}
function svgGradCap() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>`;
}
