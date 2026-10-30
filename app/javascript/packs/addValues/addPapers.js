import { initPaperInquiryChat } from '../../shared/paper_inquiry_chat';

document.addEventListener('DOMContentLoaded', () => {
    initPaperInquiryChat();
    const table = document.getElementById('add_papers');
    if (!table) return;

    const csrfMeta = document.querySelector('meta[name="csrf-token"]');
    const csrf = csrfMeta ? csrfMeta.content : '';

    // Enterで確定
    table.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            const td = e.target.closest('td.editable[contenteditable="true"]');
            if (!td) return;
            e.preventDefault();

            // テーブル内のcontenteditableセルの並びから次のセルを決める
            const cells = Array.from(table.querySelectorAll('td.editable[contenteditable="true"]'));
            const curIndex = cells.indexOf(td);
            const nextIndex = (curIndex >= 0 && curIndex + 1 < cells.length) ? curIndex + 1 : curIndex; // 末尾は据え置き

            // いったん確定（blurで保存と再計算が走る）
            e.target.blur();

            // DOM更新（行置換など）後に再取得して次セルへフォーカス
            setTimeout(() => {
                const freshCells = Array.from(table.querySelectorAll('td.editable[contenteditable="true"]'));
                const nextTd = freshCells[nextIndex] || freshCells[freshCells.length - 1];
                if (nextTd) {
                    nextTd.focus();
                    // 全選択はfocusinの選択ロジックが動くが、念のため
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
        // 選択を遅延してマウスアップ後にも維持しやすくする
        setTimeout(() => {
            try {
                const sel = window.getSelection();
                if (!sel) return;
                const range = document.createRange();
                range.selectNodeContents(td);
                sel.removeAllRanges();
                sel.addRange(range);
            } catch (_) {
                // ignore
            }
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

    const saveField = async (id, field, value, td) => {
        await fetchPatch(id, { [field]: value });
        if (td) {
            td.classList.remove('error');
            td.classList.add('saved');
            setTimeout(() => td.classList.remove('saved'), 600);
        }
    };

    // ヘルパ
    const getCell = (row, field) =>
        row.querySelector(`td.editable[data-field="${field}"]`);

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
        return any ? any.dataset.recordId : null;
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

    // 3桁区切り（小数は保持 or 固定小数）
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

    // tbody 内の行Noを振り直す（ページ内先頭行の表示番号から算出）
    const renumberRows = (tbody) => {
        const rows = Array.from(tbody.querySelectorAll('tr'));
        if (rows.length === 0) return;
        const firstNumCell = rows[0].querySelector('td');
        const firstNumRaw = firstNumCell ? firstNumCell.innerText.trim() : '1';
        const firstNum = parseInt(firstNumRaw.replace(/[^0-9\-]/g, ''), 10);
        const offset = Number.isFinite(firstNum) ? firstNum - 1 : 0;
        rows.forEach((r, i) => {
            const numCell = r.querySelector('td');
            if (numCell) numCell.textContent = String(offset + i + 1);
        });
    };

    // 行内再計算
    const recalcRow = async (row) => {
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

        //if (ktankaStr !== '' && Number.isFinite(ktanka)) {
            // 印刷方式（行内の td#press_method）と Webスプリット値（hidden[name="web_sprit"]）を参照
            const pressMethodEl = row.querySelector('#press_method');
            const pressMethod = pressMethodEl ? pressMethodEl.textContent.trim() : '';
            const webSpritEl = row.querySelector('input[type="hidden"][name="web_sprit"]');
            const webSprit = webSpritEl ? parseInt(webSpritEl.value, 10) : NaN;
            console.log('pressMethod:', pressMethod, 'webSprit:', webSprit);
            let base;
            if (pressMethod === 'オフ輪' && Number.isFinite(webSprit) && webSprit > 0) {
                // 総重量 = (総枚数 / (2000 * web_sprit)) * 連量
                base = (pressNum / (2000 * web_sprit)) * ren;
            } else {
                // 従来ロジック
                base = (ita === 1 ? (ren / 100) : (ren / 1000)) * pressNum;
            }

            weightVal = base; // 保存値は数値（カンマなし）
            weightText = formatGrouped(roundTo(base, 2), 'keep'); // 表示は2桁丸め後に位取り
        //} else {
        //    weightText = '';
        //}


        if (tdWeight && tdWeight.innerText.trim() !== weightText) {
            tdWeight.innerText = weightText;
            saves.push(saveField(id, 'weight', weightText === '' ? '' : weightVal, tdWeight));
        }

        // [2] 用紙価格
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
                console.error(e);
            }
        }
    };

    // 初期表示のフォーマット適用（数値セルの位取り、用紙価格は小数切り捨て）
    const formatInitialRow = (row) => {
        // 小数2桁固定で位取り表示するフィールド
        const fixed2Fields = ['ren', 'ktanka', 'mtanka'];
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

        // 小数保持のまま位取り表示するフィールド
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

        // 整数表示（位取り）するフィールド
        const intFields = ['press_num','jisu','yobi'];
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

    // 全行に初期フォーマットを適用
    table.querySelectorAll('tbody tr').forEach((tr) => formatInitialRow(tr));

    // contenteditableなセルの保存 + 再計算
    table.addEventListener('focusout', async (e) => {
        const td = e.target.closest('td.editable[contenteditable="true"]');
        if (!td) return;

        const newValue = td.innerText.trim();
        const id = td.dataset.recordId;
        const field = td.dataset.field;

        if (!id || !field) return;

        try {
            await saveField(id, field, newValue, td);
            await recalcRow(td.closest('tr'));

            // 表示整形：ren/ktanka/mtanka は小数2桁で位取り
            if (['ren', 'ktanka', 'mtanka'].includes(field)) {
                const num = parseNum(td.innerText.trim());
                if (Number.isFinite(num)) {
                    td.innerText = formatGrouped(num, 'fixed2');
                }
            }
        } catch (err) {
            td.classList.add('error');
            console.error(err);
        }
    });

    // 板紙チェックボックスの変更で保存 + 再計算
    table.addEventListener('change', async (e) => {
        const checkbox = e.target.closest('input.edit-toggle[type="checkbox"]');
        if (!checkbox) return;

        const td = checkbox.closest('td.editable[data-field="ita"]');
        if (!td) return;

        const id = td.dataset.recordId;
        const field = td.dataset.field;
        const newValue = checkbox.checked ? 1 : 0;

        try {
            await saveField(id, field, newValue, td);
            await recalcRow(td.closest('tr'));
        } catch (err) {
            td.classList.add('error');
            // 失敗時は元に戻す
            checkbox.checked = !checkbox.checked;
            console.error(err);
        }
    });

    // 削除リンク（remote: true, format: json）の成功時：行を削除し行Noを振り直す
    document.addEventListener('ajax:success', (e) => {
        const target = e.target;
        if (!(target instanceof Element)) return;
        if (!target.matches('a.delete-add-value')) return;

        const tr = target.closest('tr');
        if (!tr) return;

        const tbody = tr.parentElement;
        if (!tbody) return;

        // 削除
        tr.remove();

        // 行Noを振り直し
        renumberRows(tbody);
    });

    // 削除失敗時の通知
    document.addEventListener('ajax:error', (e) => {
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
});
