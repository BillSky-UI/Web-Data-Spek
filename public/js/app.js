(function () {
  'use strict';

  const API = '/api/devices';
  let devices = [];
  const state = { view: 'dashboard', editId: null, toDelete: null };

  const $ = (id) => document.getElementById(id);

  const els = {
    list: $('list'), empty: $('empty'), loading: $('loading'),
    search: $('search'), filterPlan: $('filterPlan'), filterBagian: $('filterBagian'), filterStatus: $('filterStatus'),
    statTotal: $('statTotal'), statDone: $('statDone'), statPending: $('statPending'),
    dashboard: $('dashboard'), detail: $('detail'), detailContent: $('detailContent'),
    formModal: $('formModal'), formTitle: $('formTitle'),
    confirmModal: $('confirmModal'), confirmText: $('confirmText'),
    toast: $('toast'), countChip: $('count-chip')
  };

  // ---------- Helpers ----------
  function esc(s) {
    return String(s ?? '').replace(/[&<>"']/g, (c) => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
  }

  function toast(msg, isError) {
    els.toast.textContent = msg;
    els.toast.className = 'toast show' + (isError ? ' error' : '');
    clearTimeout(toast._t);
    toast._t = setTimeout(() => { els.toast.className = 'toast'; }, 2600);
  }

  async function apiFetch(url, opts) {
    const res = await fetch(url, opts);
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || 'Terjadi kesalahan');
    return data;
  }

  function showView(name) {
    state.view = name;
    els.dashboard.style.display = name === 'dashboard' ? '' : 'none';
    els.detail.style.display = name === 'detail' ? '' : 'none';
    window.scrollTo(0, 0);
  }

  // ---------- Data loading ----------
  async function loadDevices() {
    els.loading.style.display = '';
    els.list.style.display = 'none';
    els.empty.style.display = 'none';
    try {
      devices = await apiFetch(API);
      buildFilters();
      render();
    } catch (e) {
      els.loading.style.display = 'none';
      toast('Gagal memuat data: ' + e.message, true);
    }
  }

  // ---------- Filters ----------
  function buildFilters() {
    const plans = [...new Set(devices.map(d => d.plan).filter(Boolean))].sort();
    const bagian = [...new Set(devices.map(d => d.bagian).filter(Boolean))].sort();

    const pSel = $('filterPlan');
    const currentP = pSel.value;
    pSel.innerHTML = '<option value="">Semua PLAN</option>' + plans.map(p => `<option value="${esc(p)}">${esc(p)}</option>`).join('');
    pSel.value = currentP;

    const bSel = $('filterBagian');
    const currentB = bSel.value;
    bSel.innerHTML = '<option value="">Semua Bagian</option>' + bagian.map(b => `<option value="${esc(b)}">${esc(b)}</option>`).join('');
    bSel.value = currentB;
  }

  function getFiltered() {
    const q = els.search.value.toLowerCase().trim();
    const p = els.filterPlan.value;
    const b = els.filterBagian.value;
    const s = els.filterStatus.value;
    return devices.filter(d => {
      if (q) {
        const kode = String(d.kodeInventaris || '').toLowerCase();
        const name = String(d.deviceName || '').toLowerCase();
        if (!kode.includes(q) && !name.includes(q)) return false;
      }
      if (p && d.plan !== p) return false;
      if (b && d.bagian !== b) return false;
      if (s && String(d.statusUpgrade || '') !== s) return false;
      return true;
    });
  }

  // ---------- Render dashboard ----------
  function render() {
    els.loading.style.display = 'none';
    els.list.style.display = '';

    const total = devices.length;
    const done = devices.filter(d => String(d.statusUpgrade || '').toLowerCase() === 'complated').length;
    const pending = total - done;
    els.statTotal.textContent = total;
    els.statDone.textContent = done;
    els.statPending.textContent = pending;

    const filtered = getFiltered();
    els.countChip.style.display = total ? '' : 'none';
    els.countChip.textContent = `${filtered.length}/${total}`;

    if (!filtered.length) {
      els.empty.style.display = '';
      els.list.innerHTML = '';
      return;
    }
    els.empty.style.display = 'none';

    els.list.innerHTML = filtered.map(d => {
      const first = (d.deviceName || '?').trim()[0]?.toUpperCase() || '?';
      const sticker = String(d.statusStiker || '').trim();
      return `
        <div class="device-card" data-id="${esc(d.id)}">
          <div class="avatar">${esc(first)}</div>
          <div class="main">
            <div class="name">${esc(d.kodeInventaris || '—')} · ${esc(d.deviceName || 'Tanpa nama')}</div>
            <div class="sub">${esc(d.bagian || '—')}${d.plan ? ' · ' + esc(d.plan) : ''}</div>
          </div>
          <div class="meta">
            <span class="badge plan">${esc(d.plan || '-')}</span>
            ${sticker ? `<div><span class="badge sticker">${esc(sticker)}</span></div>` : ''}
          </div>
        </div>`;
    }).join('');
  }

  // ---------- Detail ----------
  function openDetail(id) {
    const d = devices.find(x => x.id === id);
    if (!d) return;
    showView('detail');
    buildDetail(d);
  }

  function buildDetail(d) {
    const sticker = String(d.statusStiker || '').trim();
    const rows = [
      ['Tanggal Evaluasi', d.tanggalEvaluasi],
      ['PLAN', d.plan],
      ['Bagian', d.bagian],
      ['Device Name', d.deviceName],
      ['Category', d.category],
      ['Spesifikasi Prosesor', d.prosesor],
      ['Motherboard', d.motherboard],
      ['RAM', d.ram],
      ['Storage', d.storage],
      ['OS Windows', d.osWindows],
      ['Goal', d.goal],
      ['Perlu Upgrade - Ganti', d.perluUpgradeGanti],
      ['Perlu Upgrade - Repair', d.perluUpgradeRepair],
      ['Status Upgrade', d.statusUpgrade],
      ['Keterangan', d.keterangan],
      ['Status Stiker', sticker]
    ];

    const infoHtml = rows.filter(r => String(r[1] ?? '').trim() !== '').map(r =>
      `<div class="info-row"><div class="k">${esc(r[0])}</div><div class="v">${esc(r[1])}</div></div>`
    ).join('');

    els.detailContent.innerHTML = `
      <div class="detail-hero">
        <div class="kode">${esc(d.kodeInventaris || 'Kode')}</div>
        <div class="title">${esc(d.deviceName || 'Tanpa nama')}</div>
        <div class="chips">
          <span class="badge plan">${esc(d.plan || '-')}</span>
          ${sticker ? `<span class="badge sticker">${esc(sticker)}</span>` : ''}
          ${d.category ? `<span class="badge">${esc(d.category)}</span>` : ''}
        </div>
      </div>
      <div class="info-card"><h3>Detail Spesifikasi</h3>${infoHtml || '<div class="info-row"><div class="v">— Tidak ada data spesifikasi —</div></div>'}</div>
      <div class="detail-actions">
        <button class="btn btn-edit" data-edit="${esc(d.id)}">✏️ Edit</button>
        <button class="btn btn-del" data-del="${esc(d.id)}">🗑️ Hapus</button>
      </div>`;
  }

  // ---------- Form (add / edit) ----------
  function openForm(device) {
    state.editId = device ? device.id : null;
    els.formTitle.textContent = device ? 'Edit Data' : 'Tambah Data';

    const clear = (el, v) => { $('f' + el).value = v ?? ''; };
    const f = (k) => (device ? (device[k] ?? '') : '');

    clear('Kode', f('kodeInventaris'));
    // convert dd/mm/yyyy to yyyy-mm-dd for date input
    const iso = (v) => {
      const m = String(v || '').match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
      return m ? `${m[3]}-${m[2]}-${m[1]}` : '';
    };
    $('fTanggal').value = iso(f('tanggalEvaluasi'));
    clear('Plan', f('plan'));
    clear('Bagian', f('bagian'));
    clear('DeviceName', f('deviceName'));
    clear('Category', f('category'));
    clear('Prosesor', f('prosesor'));
    clear('Motherboard', f('motherboard'));
    clear('Ram', f('ram'));
    clear('Storage', f('storage'));
    clear('Os', f('osWindows'));
    clear('Goal', f('goal'));
    clear('Ganti', f('perluUpgradeGanti'));
    clear('Repair', f('perluUpgradeRepair'));
    clear('Status', f('statusUpgrade'));
    clear('Keterangan', f('keterangan'));
    clear('Stiker', f('statusStiker'));

    els.formModal.classList.add('open');
  }

  function closeForm() { els.formModal.classList.remove('open'); }

  async function saveForm() {
    const dateVal = $('fTanggal').value; // yyyy-mm-dd or ''
    let tanggal = '';
    if (dateVal) {
      const [y, m, d] = dateVal.split('-');
      tanggal = `${d}/${m}/${y}`;
    }

    const payload = {
      kodeInventaris: $('fKode').value.trim(),
      tanggalEvaluasi: tanggal,
      plan: $('fPlan').value.trim(),
      bagian: $('fBagian').value.trim(),
      deviceName: $('fDeviceName').value.trim(),
      category: $('fCategory').value.trim(),
      prosesor: $('fProsesor').value.trim(),
      motherboard: $('fMotherboard').value.trim(),
      ram: $('fRam').value.trim(),
      storage: $('fStorage').value.trim(),
      osWindows: $('fOs').value.trim(),
      goal: $('fGoal').value.trim(),
      perluUpgradeGanti: $('fGanti').value.trim(),
      perluUpgradeRepair: $('fRepair').value.trim(),
      statusUpgrade: $('fStatus').value.trim(),
      keterangan: $('fKeterangan').value.trim(),
      statusStiker: $('fStiker').value.trim()
    };

    try {
      if (state.editId) {
        await apiFetch(`${API}/${state.editId}`, {
          method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload)
        });
        toast('Data berhasil diperbarui');
      } else {
        const created = await apiFetch(API, {
          method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload)
        });
        toast('Data berhasil ditambahkan');
        state.editId = created.id;
      }
      closeForm();
      await loadDevices();
    } catch (e) {
      toast(e.message, true);
    }
  }

  // ---------- Delete ----------
  function askDelete(id) {
    const d = devices.find(x => x.id === id);
    if (!d) return;
    state.toDelete = id;
    els.confirmText.textContent = `Hapus ${d.kodeInventaris || ''} — ${d.deviceName || ''}?`;
    els.confirmModal.classList.add('open');
  }
  function closeConfirm() { els.confirmModal.classList.remove('open'); state.toDelete = null; }

  async function doDelete() {
    try {
      await apiFetch(`${API}/${state.toDelete}`, { method: 'DELETE' });
      toast('Data dihapus');
      closeConfirm();
      // if we were in detail of the deleted item, go back
      if (state.view === 'detail') showView('dashboard');
      await loadDevices();
    } catch (e) {
      toast(e.message, true);
    }
  }

  // ---------- Import / Sync ----------
  async function importExcel() {
    $('btnImport').textContent = '…';
    try {
      const r = await apiFetch('/api/import', { method: 'POST' });
      toast(`Import berhasil: ${r.imported} data disinkronkan dari Excel. Total ${r.count}`);
      await loadDevices();
    } catch (e) {
      toast(e.message, true);
    } finally {
      $('btnImport').innerHTML = '<span class="plus">⇅</span>';
    }
  }

  // ---------- PWA install ----------
  let deferredPrompt = null;
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    $('installBanner').classList.add('show');
  });
  $('btnInstall').addEventListener('click', async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const res = await deferredPrompt.userChoice;
    deferredPrompt = null;
    $('installBanner').classList.remove('show');
  });
  window.addEventListener('appinstalled', () => {
    $('installBanner').classList.remove('show');
    toast('Aplikasi terinstal!');
  });

  // ---------- Events ----------
  els.search.addEventListener('input', render);
  els.filterPlan.addEventListener('change', render);
  els.filterBagian.addEventListener('change', render);
  els.filterStatus.addEventListener('change', render);

  els.list.addEventListener('click', (e) => {
    const card = e.target.closest('.device-card');
    if (card) openDetail(card.dataset.id);
  });

  els.detailContent.addEventListener('click', (e) => {
    const ed = e.target.closest('[data-edit]');
    const dl = e.target.closest('[data-del]');
    if (ed) openForm(devices.find(x => x.id === ed.dataset.edit));
    if (dl) askDelete(dl.dataset.del);
  });

  $('fabAdd').addEventListener('click', () => openForm(null));
  $('btnBack').addEventListener('click', () => showView('dashboard'));
  $('btnImport').addEventListener('click', importExcel);

  $('btnCloseForm').addEventListener('click', closeForm);
  $('btnFormCancel').addEventListener('click', closeForm);
  $('btnFormSave').addEventListener('click', saveForm);
  els.formModal.addEventListener('click', (e) => { if (e.target === els.formModal) closeForm(); });

  $('btnCloseConfirm').addEventListener('click', closeConfirm);
  $('btnConfirmNo').addEventListener('click', closeConfirm);
  $('btnConfirmYes').addEventListener('click', doDelete);
  els.confirmModal.addEventListener('click', (e) => { if (e.target === els.confirmModal) closeConfirm(); });

  // ---------- Service worker ----------
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('sw.js').catch(() => {});
  }

  // ---------- Init ----------
  loadDevices();
})();
