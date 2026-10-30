import { replaceJobRowsFromHtml } from './add_values_dom';
import { recalcRow as sharedRecalcRow, formatInitialRow as sharedFormatInitialRow } from './add_values_calc';
import { initPaperInquiryChat } from './paper_inquiry_chat';

// モーダル内の #add_papers テーブルにイベント群をセットする初期化関数
export function setupAddPapersTable(table) {
  initPaperInquiryChat();
  if (!table) return;
  // 二重バインド防止
  if (table.dataset.initBound === '1') return;
  table.dataset.initBound = '1';

  const csrfMeta = document.querySelector('meta[name="csrf-token"]');
  const csrf = csrfMeta ? csrfMeta.content : '';

  // Enterで確定（次のフィールドへフォーカス移動）
  table.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      const td = e.target.closest('td.editable[contenteditable="true"]');
      if (!td) return;
      e.preventDefault();

      const cells = Array.from(table.querySelectorAll('td.editable[contenteditable="true"]'));
      const curIndex = cells.indexOf(td);
      const nextIndex = (curIndex >= 0 && curIndex + 1 < cells.length) ? curIndex + 1 : curIndex;

      e.target.blur();

      setTimeout(() => {
        const freshCells = Array.from(table.querySelectorAll('td.editable[contenteditable="true"]'));
        const nextTd = freshCells[nextIndex] || freshCells[freshCells.length - 1];
        if (nextTd) {
          nextTd.focus();
          try {
            const sel = window.getSelection();
            if (sel) {
              const range = document.createRange();
              range.selectNodeContents(nextTd);
              sel.removeAllRanges();
              sel.addRange(range);
            }
          } catch (_) {}
        }
      }, 30);
    }
  });

  // contenteditableセルにフォーカスしたら全選択
  table.addEventListener('focusin', (e) => {
    const td = e.target.closest('td.editable[contenteditable="true"]');
    if (!td) return;
    setTimeout(() => {
      try {
        const sel = window.getSelection();
        if (!sel) return;
        const range = document.createRange();
        range.selectNodeContents(td);
        sel.removeAllRanges();
        sel.addRange(range);
      } catch (_) {}
    }, 0);
  });

  // 共通保存関数
  const fetchPatch = async (id, payload) => {
    const res = await fetch(`/add_values/${encodeURIComponent(id)}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ add_value: payload })
    });
    if (!res.ok) throw new Error(`Save failed: ${res.status}`);
    return res;
  };

  // 追加: 新規作成（create）
  const fetchPost = async (payload) => {
    const res = await fetch('/add_values', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
        'Accept': 'application/json'
      },
      body: JSON.stringify(payload) // createはトップレベル den_code を参照
    });
    if (!res.ok) throw new Error(`Create failed: ${res.status}`);
    return res.json();
  };

  const saveField = async (id, field, value, td) => {
    await fetchPatch(id, { [field]: value });
    if (td) {
      td.classList.remove('error');
      td.classList.add('saved');
      setTimeout(() => td.classList.remove('saved'), 600);
    }
  };

  // ヘルパ
  const getCell = (row, field) => row.querySelector(`td.editable[data-field="${field}"]`);
  const getCellText = (row, field) => {
    const td = getCell(row, field);
    return td ? td.innerText.trim() : '';
  };
  const setCellText = (row, field, text) => {
    const td = getCell(row, field);
    if (td) td.innerText = text;
    return td;
  };

  const getRowRecordId = (row) => {
    const any = row.querySelector('td.editable');
    if (!any) return null;
    const rid = any.dataset.recordId;
    return rid && rid !== '' ? rid : null;
  };

  const updateRowRecordId = (row, id) => {
    row.querySelectorAll('td.editable').forEach((td) => {
      td.dataset.recordId = String(id);
    });
  };

  const parseNum = (v) => {
    if (v === null || v === undefined) return NaN;
    const s = String(v).trim().replace(/,/g, '');
    if (s === '') return NaN;
    const n = Number(s);
    return Number.isFinite(n) ? n : NaN;
  };

  const groupInt = (intStr) => intStr.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  const formatGrouped = (value, mode = 'keep') => {
    if (value === '' || value === null || value === undefined) return '';
    const num = Number(value);
    if (!Number.isFinite(num)) return String(value);
    if (mode === 'int') {
      const i = Math.trunc(num);
      return groupInt(String(i));
    }
    if (mode === 'fixed2') {
      const s = num.toFixed(2);
      const [i, d] = s.split('.');
      return `${groupInt(i)}.${d}`;
    }
    const s = String(num);
    const [i, d] = s.split('.');
    return d ? `${groupInt(i)}.${d}` : groupInt(i);
  };

  const formatRenDisplay = (value) => {
    if (value === '' || value === null || value === undefined) return '';
    const num = Number(value);
    if (!Number.isFinite(num)) return String(value);
    const fixed = num.toFixed(1);
    const [i, d] = fixed.split('.');
    return `${i}.${d}`;
  };

  // ensureRecordId（新規作成してIDを得る）
  const ensureRecordId = async (row) => {
    let id = getRowRecordId(row);
    if (id) return { id: String(id), row };
    const denCode = row.getAttribute('data-den-code');
    if (!denCode) throw new Error('den_code not found for row');

    const json = await fetchPost({ den_code: denCode });
    const newId = json?.id ?? json?.add_value?.id;
    if (!newId) throw new Error('Failed to obtain new record id from create response');

    let newRow = row;
    if (json?.html) {
      const wrapper = document.createElement('tbody');
      wrapper.innerHTML = json.html.trim();
      const tr = wrapper.querySelector('tr');
      if (tr) {
        row.replaceWith(tr);
        newRow = tr;
        sharedFormatInitialRow(newRow);
      }
    } else {
      updateRowRecordId(newRow, newId);
    }
    return { id: String(newId), row: newRow };
  };

  // 初期表示のフォーマット適用
  const formatInitialRow = (row) => {
    const fixed2Fields = ['ktanka', 'mtanka'];
    fixed2Fields.forEach((f) => {
      const td = getCell(row, f);
      if (!td) return;
      const raw = td.innerText.trim();
      if (raw === '') return;
      const num = parseNum(raw);
      if (Number.isFinite(num)) td.innerText = formatGrouped(num, 'fixed2');
    });

    // ren
    {
      const td = getCell(row, 'ren');
      if (td) {
        const raw = td.innerText.trim();
        if (raw !== '') {
          const num = parseNum(raw);
          if (Number.isFinite(num)) td.innerText = formatRenDisplay(num);
        }
      }
    }

    const keepFields = ['jisu', 'yobi', 'weight'];
    keepFields.forEach((f) => {
      const td = getCell(row, f);
      if (!td) return;
      const raw = td.innerText.trim();
      if (raw === '') return;
      const num = parseNum(raw);
      if (Number.isFinite(num)) td.innerText = formatGrouped(num, 'keep');
    });

    const intFields = ['press_num'];
    intFields.forEach((f) => {
      const td = getCell(row, f);
      if (!td) return;
      const raw = td.innerText.trim();
      if (raw === '') return;
      const num = parseNum(raw);
      if (Number.isFinite(num)) td.innerText = formatGrouped(Math.trunc(num), 'int');
    });

    const tdPrice = getCell(row, 'paper_price');
    if (tdPrice) {
      const raw = tdPrice.innerText.trim();
      if (raw !== '') {
        const num = parseNum(raw);
        if (Number.isFinite(num)) tdPrice.innerText = formatGrouped(Math.trunc(num), 'int');
      }
    }
  };

  // Job単位で交互の背景色を適用する
  const recolorGroups = () => {
    const tbody = table.querySelector('tbody');
    if (!tbody) return;
    const groupMap = new Map();
    let toggle = 0;
    tbody.querySelectorAll('tr').forEach((tr) => {
      const jobId = tr.getAttribute('data-job-id') || '';
      if (!jobId) return;
      let cls = groupMap.get(jobId);
      if (!cls) {
        cls = (toggle % 2 === 0) ? 'group-even' : 'group-odd';
        groupMap.set(jobId, cls);
        toggle += 1;
      }
      tr.classList.remove('group-even', 'group-odd');
      tr.classList.add(cls);
    });
  };

  // 初期適用
  table.querySelectorAll('tbody tr').forEach((tr) => sharedFormatInitialRow(tr));
  recolorGroups();

  // contenteditable保存 + 再計算
  table.addEventListener('focusout', async (e) => {
    let td = e.target.closest('td.editable[contenteditable="true"]');
    if (!td) return;

    const field = td.dataset.field;
    if (!field) return;

    let newValue = td.innerText.trim();
    if (newValue === '') return;

    let id = td.dataset.recordId;

    try {
      let row = td.closest('tr');
      if (!id) {
        const created = await ensureRecordId(row);
        id = created.id;
        row = created.row;
        const tdNew = row.querySelector(`td.editable[data-field="${field}"]`);
        if (tdNew) {
          td = tdNew;
          td.innerText = newValue;
        }
        recolorGroups();
      }
      await saveField(id, field, newValue, td);

      if (field === 'sasi' || field === 'jisu') {
        const rowEl = td.closest('tr');
        const pressMethodEl = rowEl ? rowEl.querySelector('#press_method') : null;
        const pressMethod = pressMethodEl ? pressMethodEl.textContent.trim() : '';
        if (pressMethod === 'オフ輪') {
          const sasiNum = parseNum(getCellText(rowEl, 'sasi')) || 0;
          const jisuNum = parseNum(getCellText(rowEl, 'jisu')) || 0;
          let yobiRate = 0;
          if (jisuNum > 0) {
            if (jisuNum < 9999) {
              yobiRate = 6000.0 / jisuNum;
            } else if (jisuNum > 130000) {
              yobiRate = (0.069 - 0.03) * Math.exp(-0.00001 * (jisuNum - 150000)) + 0.03;
            } else {
              yobiRate = (0.6 - 0.07) * Math.exp(-0.00004 * (jisuNum - 10000)) + 0.07;
            }
          }
          const yobiVal = Math.trunc((yobiRate * jisuNum) + (sasiNum * 1500));
          const tdYobi = getCell(rowEl, 'yobi');
          if (tdYobi) {
            const yobiText = formatGrouped(yobiVal, 'int');
            if (tdYobi.innerText.trim() !== yobiText) {
              tdYobi.innerText = yobiText;
              await saveField(id, 'yobi', yobiVal, tdYobi);
            }
          }
        }
      }

      await sharedRecalcRow(row, saveField);

      if (['ktanka', 'mtanka'].includes(field)) {
        const num = parseNum(td.innerText.trim());
        if (Number.isFinite(num)) td.innerText = formatGrouped(num, 'fixed2');
      } else if (field === 'ren') {
        const num = parseNum(td.innerText.trim());
        if (Number.isFinite(num)) td.innerText = formatRenDisplay(num);
      } else if (field === 'jisu' || field === 'yobi') {
        const num = parseNum(td.innerText.trim());
        if (Number.isFinite(num)) td.innerText = formatGrouped(Math.trunc(num), 'int');
      }
    } catch (err) {
      td.classList.add('error');
      // eslint-disable-next-line no-console
      console.error(err);
    }
  });

  // 板紙チェックボックスの変更で保存 + 再計算
  table.addEventListener('change', async (e) => {
    const checkbox = e.target.closest('input.edit-toggle[type="checkbox"]');
    if (!checkbox) return;

    let td = checkbox.closest('td.editable[data-field="ita"]');
    if (!td) return;

    let id = td.dataset.recordId;
    const field = td.dataset.field;
    const newValue = checkbox.checked ? 1 : 0;

    try {
      let row = td.closest('tr');

      if (!id) {
        checkbox.checked = !checkbox.checked;
        td.classList.add('error');
        setTimeout(() => td.classList.remove('error'), 600);
        alert('先にセルへ値を入力して確定してください（チェックだけでは新規作成しません）。');
        return;
      }

      await saveField(id, field, newValue, td);
      await sharedRecalcRow(row, saveField);
    } catch (err) {
      td.classList.add('error');
      checkbox.checked = !checkbox.checked;
      // eslint-disable-next-line no-console
      console.error(err);
    }
  });

  // 削除（remote: true, format: json）成功時の置換はテーブル内で受ける
  table.addEventListener('ajax:success', (e) => {
    const target = e.target;
    if (!(target instanceof Element)) return;
    if (!target.matches('a.delete-add-value')) return;

    const data = e.detail && e.detail[0];
    if (!data || !data.html) return;

    const tr = target.closest('tr');
    if (!tr) return;

    const tbody = tr.parentElement;
    if (!tbody) return;

    const jobId = tr.getAttribute('data-job-id');
    if (!jobId) return;

    replaceJobRowsFromHtml(tbody, jobId, data.html, {
      formatRow: sharedFormatInitialRow,
      afterReplace: () => {
        // 再配色
        const tbody2 = table.querySelector('tbody');
        if (!tbody2) return;
        const groupMap = new Map();
        let toggle = 0;
        tbody2.querySelectorAll('tr').forEach((tr2) => {
          const jId = tr2.getAttribute('data-job-id') || '';
          if (!jId) return;
          let cls = groupMap.get(jId);
          if (!cls) {
            cls = (toggle % 2 === 0) ? 'group-even' : 'group-odd';
            groupMap.set(jId, cls);
            toggle += 1;
          }
          tr2.classList.remove('group-even', 'group-odd');
          tr2.classList.add(cls);
        });
      }
    });
  });

  table.addEventListener('ajax:error', (e) => {
    const target = e.target;
    if (!(target instanceof Element)) return;
    if (!target.matches('a.delete-add-value')) return;

    let message = '削除に失敗しました。';
    try {
      const payload = e.detail && e.detail[0];
      if (payload && payload.errors) {
        message = payload.errors.join(', ');
      }
    } catch (_) {}
    alert(message);
  });

  // 追加リンク
  table.addEventListener('click', async (e) => {
    const a = e.target.closest('a.add-add-value');
    if (!a) return;
    e.preventDefault();
    if (a.dataset.loading === '1') return;

    const tr = a.closest('tr');
    if (!tr) return;

    const denCode = tr.getAttribute('data-den-code');
    if (!denCode) {
      alert('den_codeが取得できませんでした。');
      return;
    }

    try {
      a.dataset.loading = '1';
      const res = await fetch('/add_values', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrf,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ den_code: denCode, all_rows: true })
      });
      if (!res.ok) throw new Error(`Create failed: ${res.status}`);
      const json = await res.json();
      if (!json || !json.html) {
        alert('行の生成に失敗しました。');
        return;
      }

      const tbody = tr.parentElement;
      if (!tbody) return;

      const jobId = tr.getAttribute('data-job-id');
      if (!jobId) return;

      const inserted = replaceJobRowsFromHtml(tbody, jobId, json.html, {
        formatRow: formatInitialRow,
        afterReplace: () => {
          // 再配色
          const tbody2 = table.querySelector('tbody');
          if (!tbody2) return;
          const groupMap = new Map();
          let toggle = 0;
          tbody2.querySelectorAll('tr').forEach((tr2) => {
            const jId = tr2.getAttribute('data-job-id') || '';
            if (!jId) return;
            let cls = groupMap.get(jId);
            if (!cls) {
              cls = (toggle % 2 === 0) ? 'group-even' : 'group-odd';
              groupMap.set(jId, cls);
              toggle += 1;
            }
            tr2.classList.remove('group-even', 'group-odd');
            tr2.classList.add(cls);
          });
        }
      });

      const lastInserted = inserted && inserted[inserted.length - 1];
      if (lastInserted) {
        lastInserted.classList.add('table-success');
        setTimeout(() => lastInserted.classList.remove('table-success'), 1000);
      }
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error(err);
      alert('追加に失敗しました。');
    } finally {
      delete a.dataset.loading;
    }
  });

  // -------------------------------
  // paper_route ポップアップメニュー
  // -------------------------------
  const PAPER_ROUTE_OPTIONS = ['シートカッター', '在庫'];

  let routeMenuEl = null;
  const closeRouteMenu = () => {
    if (routeMenuEl && routeMenuEl.parentNode) {
      routeMenuEl.parentNode.removeChild(routeMenuEl);
    }
    routeMenuEl = null;
    document.removeEventListener('click', handleDocClickForMenu, true);
    document.removeEventListener('keydown', handleEscForMenu, true);
    window.removeEventListener('scroll', closeRouteMenu, true);
    window.removeEventListener('resize', closeRouteMenu, true);
  };
  const handleDocClickForMenu = (e) => {
    if (!routeMenuEl) return;
    if (!routeMenuEl.contains(e.target)) closeRouteMenu();
  };
  const handleEscForMenu = (e) => {
    if (e.key === 'Escape') closeRouteMenu();
  };

  const openRouteMenu = (td, x, y) => {
    closeRouteMenu();
    const menu = document.createElement('div');
    menu.className = 'paper-route-menu';
    Object.assign(menu.style, {
      position: 'fixed',
      left: `${x}px`,
      top: `${y}px`,
      zIndex: 10000,
      background: '#fff',
      border: '1px solid #ccc',
      boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
      borderRadius: '4px',
      padding: '4px 0',
      minWidth: '140px'
    });

    PAPER_ROUTE_OPTIONS.forEach((label) => {
      const item = document.createElement('div');
      item.textContent = label;
      Object.assign(item.style, {
        padding: '6px 10px',
        cursor: 'pointer',
        userSelect: 'none',
        whiteSpace: 'nowrap'
      });
      item.addEventListener('mouseenter', () => item.style.background = '#f0f0f0');
      item.addEventListener('mouseleave', () => item.style.background = 'transparent');
      item.addEventListener('click', async () => {
        const row = td.closest('tr');
        if (!row) return;
        td.innerText = label;
        try {
          let id = td.dataset.recordId;
          if (!id) {
            const created = await ensureRecordId(row);
            id = created.id;
          }
          await saveField(id, 'paper_route', label, td);
          await sharedRecalcRow(row, saveField);
        } catch (err) {
          td.classList.add('error');
          // eslint-disable-next-line no-console
          console.error(err);
        } finally {
          closeRouteMenu();
        }
      });
      menu.appendChild(item);
    });

    document.body.appendChild(menu);
    routeMenuEl = menu;

    document.addEventListener('click', handleDocClickForMenu, true);
    document.addEventListener('keydown', handleEscForMenu, true);
    window.addEventListener('scroll', closeRouteMenu, true);
    window.addEventListener('resize', closeRouteMenu, true);
  };

  // 右クリックでメニューを開く（paper_routeセルのみ）
  table.addEventListener('contextmenu', (e) => {
    const td = e.target.closest('td.editable[data-field="paper_route"]');
    if (!td) return;
    e.preventDefault();
    const rect = td.getBoundingClientRect();
    const posX = Math.min(e.clientX || rect.left + 10, window.innerWidth - 10);
    const posY = Math.min(e.clientY || rect.bottom + 2, window.innerHeight - 10);
    openRouteMenu(td, posX, posY);
  });

  // Alt+↓でもメニュー表示
  table.addEventListener('keydown', (e) => {
    if (e.altKey && e.key === 'ArrowDown') {
      const td = e.target.closest('td.editable[data-field="paper_route"]');
      if (!td) return;
      e.preventDefault();
      const rect = td.getBoundingClientRect();
      openRouteMenu(td, rect.left + 8, rect.bottom + 2);
    }
  });
}
