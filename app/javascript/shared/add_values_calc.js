// Shared calculation and formatting helpers for AddValue rows
// This module centralizes inline recalculation and display-formatting so both
// jobs/index.js and calendar/index.js can reuse the same logic.

// ---------- Small helpers ----------
const getCell = (row, field) => row.querySelector(`td.editable[data-field="${field}"]`);
const getCellText = (row, field) => {
  const td = getCell(row, field);
  return td ? td.innerText.trim() : '';
};

const parseNum = (v) => {
  if (v === null || v === undefined) return NaN;
  const s = String(v).trim().replace(/,/g, '');
  if (s === '') return NaN;
  const n = Number(s);
  return Number.isFinite(n) ? n : NaN;
};

const roundTo = (n, dp = 0) => {
  const p = Math.pow(10, dp);
  return Math.round(n * p) / p;
};

const groupInt = (intStr) => intStr.replace(/\B(?=(\d{3})+(?!\d))/g, ',');

// mode: 'keep' | 'fixed2' | 'int'
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
  // keep（小数桁そのまま）
  const s = String(num);
  const [i, d] = s.split('.');
  return d ? `${groupInt(i)}.${d}` : groupInt(i);
};

// 連量(ren)の表示は「00.0」形式（整数部は最低2桁、少数1桁、カンマ無し）
const formatRenDisplay = (value) => {
  if (value === '' || value === null || value === undefined) return '';
  const num = Number(value);
  if (!Number.isFinite(num)) return String(value);
  const fixed = num.toFixed(1); // 1桁小数
  const [i, d] = fixed.split('.');
  return `${i}.${d}`;
};

const getRowRecordId = (row) => {
  const any = row.querySelector('td.editable');
  if (!any) return null;
  const rid = any.dataset.recordId;
  return rid && rid !== '' ? rid : null;
};

// ---------- Core: inline recalculation ----------
// saveField: (id, field, value, td?) => Promise<void>
export const recalcRow = async (row, saveField) => {
  if (!row || typeof saveField !== 'function') return;
  const id = getRowRecordId(row);
  if (!id) return;

  // 入力値
  const itaChecked = !!row.querySelector('td[data-field="ita"] input.edit-toggle[type="checkbox"]:checked');
  const ita = itaChecked ? 1 : 0;

  const ren = parseNum(getCellText(row, 'ren')) || 0;    // 連量
  const jisu = parseNum(getCellText(row, 'jisu')) || 0;  // 通し枚数
  const yobi = parseNum(getCellText(row, 'yobi')) || 0;  // 予備

  const ktankaStr = getCellText(row, 'ktanka');
  const mtankaStr = getCellText(row, 'mtanka');
  const ktanka = parseNum(ktankaStr);
  const mtanka = parseNum(mtankaStr);

  const saves = [];

  // [1] 総枚数 = 通し枚数 + 予備
  const pressNum = (jisu || 0) + (yobi || 0);
  const tdPress = getCell(row, 'press_num');
  const prevPressStr = tdPress ? tdPress.innerText.trim() : '';
  const pressStr = formatGrouped(pressNum, 'int');

  if (tdPress && prevPressStr !== pressStr) {
    tdPress.innerText = pressStr;
    saves.push(saveField(id, 'press_num', pressNum, tdPress));
  }

  // [2] 重量
  // IF(ktanka=="" => "", else base=(ita==1 ? (ren/100) : (ren/1000)) * pressNum; 小数は板紙時もそのまま)
  let weightVal = null;
  let weightText = '';
  const tdWeight = getCell(row, 'weight');

  if (ktankaStr !== '' && Number.isFinite(ktanka)) {
    // 印刷方式（行内の td#press_method）と Webスプリット値（hidden[name="web_sprit"]）を参照
    const pressMethodEl = row.querySelector('#press_method');
    const pressMethod = pressMethodEl ? pressMethodEl.textContent.trim() : '';
    const webSpritEl = row.querySelector('input[type="hidden"][name="web_sprit"]');
    const webSprit = webSpritEl ? parseInt(webSpritEl.value, 10) : NaN;

    let base;
    if (pressMethod === 'オフ輪' && Number.isFinite(webSprit) && webSprit > 0) {
      // 総重量 = (総枚数 / (2000 * web_sprit)) * 連量
      base = (pressNum / (2000)) * ren;
    } else {
      // 従来ロジック
      base = (ita === 1 ? (ren / 100) : (ren / 1000)) * pressNum;
    }

    weightVal = base; // 保存値は数値（カンマなし）
    weightText = formatGrouped(roundTo(base, 2), 'keep'); // 表示は2桁丸め後に位取り
  } else {
    weightText = '';
  }

  if (tdWeight && tdWeight.innerText.trim() !== weightText) {
    tdWeight.innerText = weightText;
    saves.push(saveField(id, 'weight', weightText === '' ? '' : weightVal, tdWeight));
  }

  // [3] 用紙価格
  // IF(ita===1, INT( IF(ktanka<1, pressNum*mtanka, weight*ktanka)/10 )*10,
  //               IF(ktanka<1, pressNum*mtanka, weight*ktanka))
  let priceVal = null;
  let priceText = '';
  const tdPrice = getCell(row, 'paper_price');

  if (Number.isFinite(ktanka) && ktanka >= 1) {
    // 重量ルート（重量未算出でもitaに応じてbaseから算出。板紙=1も小数そのまま）
    const weightBase = (weightVal !== null)
      ? weightVal
      : (ita === 1 ? (ren / 100) * pressNum : (ren / 1000) * pressNum);
    const priceBase = weightBase * ktanka;
    priceVal = (ita === 1)
      ? Math.floor(priceBase / 10) * 10
      : Math.round(priceBase);
    priceText = formatGrouped(priceVal, 'int');
  } else if (Number.isFinite(mtanka)) {
    // 枚単価ルート
    const priceBase = pressNum * mtanka;
    priceVal = (ita === 1)
      ? Math.floor(priceBase / 10) * 10
      : Math.round(priceBase);
    priceText = formatGrouped(priceVal, 'int');
  } else {
    priceText = '';
  }

  if (tdPrice && tdPrice.innerText.trim() !== priceText) {
    tdPrice.innerText = priceText;
    saves.push(saveField(id, 'paper_price', priceText === '' ? '' : priceVal, tdPrice));
  }

  // まとめて待機
  if (saves.length > 0) {
    try {
      await Promise.all(saves);
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e);
    }
  }
};

// 初期表示のフォーマット適用（数値セルの位取り、用紙価格は小数切り捨て）
export const formatInitialRow = (row) => {
  // 小数2桁固定で位取り表示するフィールド（renは除外）
  const fixed2Fields = ['ktanka', 'mtanka'];
  fixed2Fields.forEach((f) => {
    const td = getCell(row, f);
    if (!td) return;
    const raw = td.innerText.trim();
    if (raw === '') return;
    const num = parseNum(raw);
    if (Number.isFinite(num)) {
      td.innerText = formatGrouped(num, 'fixed2');
    }
  });

  // ren は「00.0」形式
  {
    const td = getCell(row, 'ren');
    if (td) {
      const raw = td.innerText.trim();
      if (raw !== '') {
        const num = parseNum(raw);
        if (Number.isFinite(num)) {
          td.innerText = formatRenDisplay(num);
        }
      }
    }
  }

  // 小数保持のまま位取り表示するフィールド（weightのみ）
  const keepFields = ['weight'];
  keepFields.forEach((f) => {
    const td = getCell(row, f);
    if (!td) return;
    const raw = td.innerText.trim();
    if (raw === '') return;
    const num = parseNum(raw);
    if (Number.isFinite(num)) {
      td.innerText = formatGrouped(num, 'keep');
    }
  });

  // 整数表示（位取り）するフィールド（press_num, jisu, yobi）
  const intFields = ['press_num', 'jisu', 'yobi'];
  intFields.forEach((f) => {
    const td = getCell(row, f);
    if (!td) return;
    const raw = td.innerText.trim();
    if (raw === '') return;
    const num = parseNum(raw);
    if (Number.isFinite(num)) {
      td.innerText = formatGrouped(Math.trunc(num), 'int');
    }
  });

  // 用紙価格は小数点以下切り捨て（整数）で位取り
  const tdPrice = getCell(row, 'paper_price');
  if (tdPrice) {
    const raw = tdPrice.innerText.trim();
    if (raw !== '') {
      const num = parseNum(raw);
      if (Number.isFinite(num)) {
        tdPrice.innerText = formatGrouped(Math.trunc(num), 'int');
      }
    }
  }
};

// Optionally export some helpers if needed elsewhere
export const addValuesHelpers = {
  getCell,
  getCellText,
  parseNum,
  formatGrouped,
  formatRenDisplay,
};
