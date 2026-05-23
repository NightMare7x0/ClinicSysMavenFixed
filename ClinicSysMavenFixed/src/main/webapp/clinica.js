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
  pacientes:      [],   // { id, nombre, dni, contacto }
  especialidades: [],   // { id, nombre }
  doctores:       [],   // { id, nombre, dni, telefono, id_especialidad, especialidad_nombre }
  consultorios:   [],   // { id, numero, especialidad, idEspecialidad }
  citas:          [],   // { id, paciente, consultorio, doctor, fecha, hora }
  historias:      [],   // { id, paciente, sintomas, tratamiento }
  practicantes:   []    // { id, nombre, dni, supervisor, especialidad }
};

/* ============================================================
   UTILIDAD: llamada al servlet con fetch
============================================================ */
async function postServlet(endpoint, params) {
  const body = new URLSearchParams(params);
  try {
    const res = await fetch(endpoint, { method: 'POST', body });
    const text = await res.text();
    if (!res.ok) return { ok: false, msg: text || 'Error del servidor', status: res.status };
    if (text.startsWith('ID:')) return { ok: true, id: parseInt(text.slice(3), 10) };
    return { ok: true, id: -1, text };
  } catch (err) {
    return { ok: false, msg: 'No se pudo conectar con el servidor: ' + err.message };
  }
}

async function getServlet(endpoint, params = {}) {
  const url = new URL(endpoint, window.location.origin);
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));
  try {
    const res = await fetch(url, { method: 'GET' });
    if (!res.ok) return { ok: false, msg: 'Error del servidor' };
    const json = await res.json();
    return { ok: true, data: json };
  } catch (err) {
    return { ok: false, msg: 'No se pudo conectar: ' + err.message };
  }
}

async function putServlet(endpoint, params) {
  const body = new URLSearchParams(params);
  try {
    const res = await fetch(endpoint, { method: 'PUT', body });
    const text = await res.text();
    if (!res.ok) return { ok: false, msg: text || 'Error del servidor', status: res.status };
    return { ok: true, text };
  } catch (err) {
    return { ok: false, msg: 'No se pudo conectar: ' + err.message };
  }
}

async function deleteServlet(endpoint, params) {
  const body = new URLSearchParams(params);
  try {
    const res = await fetch(endpoint, { method: 'DELETE', body });
    const text = await res.text();
    if (!res.ok) return { ok: false, msg: text || 'Error del servidor', status: res.status };
    return { ok: true, text };
  } catch (err) {
    return { ok: false, msg: 'No se pudo conectar: ' + err.message };
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
  doctores:       { cls: 'mod-cyan',   title: 'Doctores',         desc: 'Gestiona los doctores y sus especialidades',          icon: svgUserMd() },
  especialidades: { cls: 'mod-violet', title: 'Especialidades',   desc: 'Gestiona las especialidades médicas disponibles',     icon: svgStethoscope() },
  consultorios:   { cls: 'mod-green',  title: 'Consultorios',     desc: 'Administra los consultorios y sus asignaciones',      icon: svgBuilding() },
  citas:          { cls: 'mod-orange', title: 'Citas',            desc: 'Programa y visualiza citas médicas',                  icon: svgCalendar() },
  historia:       { cls: 'mod-teal',   title: 'Historia Clínica', desc: 'Registra síntomas y tratamientos de pacientes',       icon: svgClipboard() },
  practicantes:   { cls: 'mod-indigo', title: 'Practicantes',     desc: 'Administra el registro de practicantes',              icon: svgGradCap() },
};

const ROLE_MODS = {
  Administrador: ['pacientes', 'doctores', 'especialidades', 'consultorios', 'citas', 'historia', 'practicantes'],
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
    cont.innerHTML = `<div class="no-access"><div class="no-access-icon"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#60a5fa" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></div><p class="no-access-title">Sin acceso a módulos</p><p class="no-access-desc">El rol <strong>${currentRole}</strong> no tiene permisos para gestionar módulos.</p></div>`;
    return;
  }

  cont.innerHTML = `<div class="modules-grid">${mods.map(id => {
    const c = MOD_CFG[id];
    return `<div class="card card-hover module-card ${c.cls}" onclick="openModal('${id}')"><div class="module-icon">${c.icon}</div><h3>${c.title}</h3><p class="module-desc">${c.desc}</p><button class="module-link" onclick="event.stopPropagation();openModal('${id}')">Abrir módulo<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg></button></div>`;
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
  
  // Cargar datos al abrir la pestaña visualizar
  if (id === 'especialidades') loadEspecialidades();
  if (id === 'doctores') loadDoctores();
  if (id === 'pacientes') loadPacientes();
  if (id === 'consultorios') loadConsultorios();
  if (id === 'citas') loadCitas();
  if (id === 'historia') loadHistorias();
  if (id === 'practicantes') loadPracticantes();
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
  
  // Recargar datos al cambiar a visualizar
  if (tabId === 'vis') {
    if (modalId === 'especialidades') loadEspecialidades();
    if (modalId === 'doctores') loadDoctores();
    if (modalId === 'pacientes') loadPacientes();
    if (modalId === 'consultorios') loadConsultorios();
    if (modalId === 'citas') loadCitas();
    if (modalId === 'historia') loadHistorias();
    if (modalId === 'practicantes') loadPracticantes();
  }
}

function refreshSelects() {
  // Especialidades
  ['cons-esp', 'cita-esp', 'prac-esp', 'doc-esp'].forEach(id => {
    const s = document.getElementById(id);
    if (!s) return;
    s.innerHTML = state.especialidades.length === 0
      ? '<option value="">Registra una especialidad primero</option>'
      : '<option value="">Elegir...</option>' + state.especialidades.map(e => `<option value="${e.id}">${e.nombre}</option>`).join('');
  });

  // Pacientes
  ['cita-pac', 'hist-pac'].forEach(id => {
    const s = document.getElementById(id);
    if (!s) return;
    s.innerHTML = state.pacientes.length === 0
      ? '<option value="">Registra un paciente primero</option>'
      : '<option value="">Elegir...</option>' + state.pacientes.map(p => `<option value="${p.id}">${p.nombre}</option>`).join('');
  });

  // Doctores
  ['cita-doc-select', 'hist-doc-select', 'prac-sup-select'].forEach(id => {
    const s = document.getElementById(id);
    if (!s) return;
    s.innerHTML = state.doctores.length === 0
      ? '<option value="">Registra un doctor primero</option>'
      : '<option value="">Elegir...</option>' + state.doctores.map(d => `<option value="${d.id}">${d.nombre}</option>`).join('');
  });

  // Consultorios
  const cs = document.getElementById('cita-cons');
  if (cs) {
    cs.innerHTML = state.consultorios.length === 0
      ? '<option value="">Registra un consultorio primero</option>'
      : '<option value="">Elegir...</option>' + state.consultorios.map(c => `<option value="${c.id}">N° ${c.numero} — ${c.especialidad}</option>`).join('');
  }
}

/* ============================================================
   FORM SUBMISSIONS - ESPECIALIDADES
============================================================ */
async function submitEspecialidad(e) {
  e.preventDefault();
  const nombre = document.getElementById('esp-select').value;
  if (!nombre) return;
  
  // Verificar duplicados en el estado local
  if (state.especialidades.some(x => x.nombre.toLowerCase() === nombre.toLowerCase())) {
    toast('⚠️ Esta especialidad ya está registrada', 'error');
    return;
  }

  const res = await postServlet('especialidad', { especialidad: nombre });
  if (!res.ok) { 
    if (res.status === 409 || (res.text && res.text.includes('DUPLICADO'))) {
      toast('⚠️ Esta especialidad ya está registrada', 'error');
    } else {
      toast('Error al guardar especialidad: ' + res.msg, 'error'); 
    }
    return; 
  }

  state.especialidades.push({ id: res.id, nombre });
  e.target.reset();
  renderEspecialidades();
  refreshSelects();
  updateStats();
  toast('✅ Especialidad registrada correctamente', 'success');
}

async function loadEspecialidades() {
  const order = document.getElementById('esp-filter').value;
  const res = await getServlet('especialidad', { action: 'list', order });
  if (!res.ok) { toast('Error al cargar especialidades', 'error'); return; }
  
  state.especialidades = res.data.map(item => ({ id: item.id, nombre: item.nombre }));
  renderEspecialidades();
}

function renderEspecialidades() {
  const tbody = document.getElementById('esp-tbody');
  const empty = document.getElementById('esp-empty');
  const table = document.getElementById('esp-table');
  
  if (state.especialidades.length === 0) {
    empty.style.display = 'flex';
    table.style.display = 'none';
    return;
  }
  
  empty.style.display = 'none';
  table.style.display = 'block';
  
  tbody.innerHTML = state.especialidades.map(esp => `
    <tr>
      <td>${esp.nombre}</td>
      <td class="actions-cell">
        <button class="btn-icon btn-edit" onclick="editEspecialidad(${esp.id}, '${esp.nombre.replace(/'/g, "\\'")}')" title="Editar">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        </button>
        <button class="btn-icon btn-delete" onclick="deleteEspecialidad(${esp.id})" title="Eliminar">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
        </button>
      </td>
    </tr>
  `).join('');
}

async function editEspecialidad(id, nombreActual) {
  const nuevoNombre = prompt('Editar nombre de especialidad:', nombreActual);
  if (!nuevoNombre || nuevoNombre.trim() === '') return;
  
  const res = await putServlet('especialidad', { id, nombre: nuevoNombre.trim() });
  if (!res.ok) {
    if (res.status === 500 || (res.text && res.text.includes('DUPLICADO'))) {
      toast('⚠️ Ya existe una especialidad con ese nombre', 'error');
    } else {
      toast('Error al actualizar: ' + res.msg, 'error');
    }
    return;
  }
  
  const esp = state.especialidades.find(e => e.id === id);
  if (esp) esp.nombre = nuevoNombre.trim();
  renderEspecialidades();
  refreshSelects();
  toast('✅ Especialidad actualizada', 'success');
}

async function deleteEspecialidad(id) {
  if (!confirm('¿Está seguro de eliminar esta especialidad?')) return;
  
  const res = await deleteServlet('especialidad', { id });
  if (!res.ok) {
    if (res.text && res.text.includes('REFERENCIAS')) {
      toast('⚠️ No se puede eliminar: tiene registros relacionados', 'error');
    } else {
      toast('Error al eliminar: ' + res.msg, 'error');
    }
    return;
  }
  
  state.especialidades = state.especialidades.filter(e => e.id !== id);
  renderEspecialidades();
  refreshSelects();
  updateStats();
  toast('✅ Especialidad eliminada', 'success');
}

/* ============================================================
   FORM SUBMISSIONS - DOCTORES
============================================================ */
async function submitDoctor(e) {
  e.preventDefault();
  const nombre = v('doc-nombre');
  const dni = v('doc-dni');
  const telefono = v('doc-telefono') || '';
  const idEspecialidad = document.getElementById('doc-esp').value;
  
  if (!nombre || !dni || !idEspecialidad) { 
    toast('Nombre, DNI y especialidad son obligatorios', 'error'); 
    return; 
  }

  // Verificar duplicados locales
  if (state.doctores.some(d => d.dni === dni)) {
    toast('⚠️ Ya existe un doctor con ese DNI', 'error');
    return;
  }

  const res = await postServlet('doctor', { nombre, dni, telefono, id_especialidad: idEspecialidad });
  if (!res.ok) {
    if (res.status === 409 || (res.text && res.text.includes('DUPLICADO'))) {
      toast('⚠️ Ya existe un doctor con ese DNI', 'error');
    } else {
      toast('Error al guardar doctor: ' + res.msg, 'error');
    }
    return;
  }

  const espObj = state.especialidades.find(e => String(e.id) === String(idEspecialidad));
  state.doctores.push({ 
    id: res.id, nombre, dni, telefono, 
    id_especialidad: parseInt(idEspecialidad),
    especialidad_nombre: espObj ? espObj.nombre : ''
  });
  
  e.target.reset();
  renderDoctores();
  refreshSelects();
  toast('✅ Doctor registrado correctamente', 'success');
}

async function loadDoctores() {
  const order = document.getElementById('doc-filter').value;
  const res = await getServlet('doctor', { action: 'list', order });
  if (!res.ok) { toast('Error al cargar doctores', 'error'); return; }
  
  state.doctores = res.data.map(item => ({
    id: item.id,
    nombre: item.nombre,
    dni: item.dni,
    telefono: item.telefono || '',
    id_especialidad: item.id_especialidad,
    especialidad_nombre: item.especialidad_nombre || ''
  }));
  renderDoctores();
}

function renderDoctores() {
  const tbody = document.getElementById('doc-tbody');
  const empty = document.getElementById('doc-empty');
  const table = document.getElementById('doc-table');
  
  if (state.doctores.length === 0) {
    empty.style.display = 'flex';
    table.style.display = 'none';
    return;
  }
  
  empty.style.display = 'none';
  table.style.display = 'block';
  
  tbody.innerHTML = state.doctores.map(doc => `
    <tr>
      <td>${doc.nombre}</td>
      <td>${doc.dni}</td>
      <td>${doc.telefono || 'N/A'}</td>
      <td>${doc.especialidad_nombre || 'N/A'}</td>
      <td class="actions-cell">
        <button class="btn-icon btn-edit" onclick="editDoctor(${doc.id})" title="Editar">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        </button>
        <button class="btn-icon btn-delete" onclick="deleteDoctor(${doc.id})" title="Eliminar">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
        </button>
      </td>
    </tr>
  `).join('');
}

async function editDoctor(id) {
  const doc = state.doctores.find(d => d.id === id);
  if (!doc) return;
  
  const nuevoNombre = prompt('Editar nombre:', doc.nombre);
  if (!nuevoNombre) return;
  
  const nuevoDni = prompt('Editar DNI:', doc.dni);
  if (!nuevoDni) return;
  
  const nuevoTelefono = prompt('Editar teléfono:', doc.telefono);
  
  // Construir select de especialidades para edición
  const espOptions = state.especialidades.map(e => 
    `<option value="${e.id}" ${e.id === doc.id_especialidad ? 'selected' : ''}>${e.nombre}</option>`
  ).join('');
  
  const espHtml = `<div style="margin-top:10px"><label>Especialidad:</label><select id="edit-doc-esp" class="input" style="width:100%;margin-top:5px">${espOptions}</select></div>`;
  
  // Crear contenedor temporal para el prompt de especialidad
  const tempDiv = document.createElement('div');
  tempDiv.innerHTML = espHtml;
  
  // Usar un approach simplificado - editar solo campos básicos
  const res = await putServlet('doctor', { 
    id, 
    nombre: nuevoNombre, 
    dni: nuevoDni, 
    telefono: nuevoTelefono || '',
    id_especialidad: doc.id_especialidad
  });
  
  if (!res.ok) {
    if (res.status === 500 || (res.text && res.text.includes('DUPLICADO'))) {
      toast('⚠️ Ya existe un doctor con ese DNI', 'error');
    } else {
      toast('Error al actualizar: ' + res.msg, 'error');
    }
    return;
  }
  
  const espObj = state.especialidades.find(e => e.id === doc.id_especialidad);
  doc.nombre = nuevoNombre;
  doc.dni = nuevoDni;
  doc.telefono = nuevoTelefono || '';
  doc.especialidad_nombre = espObj ? espObj.nombre : '';
  
  renderDoctores();
  refreshSelects();
  toast('✅ Doctor actualizado', 'success');
}

async function deleteDoctor(id) {
  if (!confirm('¿Está seguro de eliminar este doctor?')) return;
  
  const res = await deleteServlet('doctor', { id });
  if (!res.ok) {
    if (res.text && res.text.includes('REFERENCIAS')) {
      toast('⚠️ No se puede eliminar: tiene citas, historias o practicantes asignados', 'error');
    } else {
      toast('Error al eliminar: ' + res.msg, 'error');
    }
    return;
  }
  
  state.doctores = state.doctores.filter(d => d.id !== id);
  renderDoctores();
  refreshSelects();
  toast('✅ Doctor eliminado', 'success');
}

/* ============================================================
   ICONS SVG
============================================================ */
function svgUserMd() {
  return `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`;
}
