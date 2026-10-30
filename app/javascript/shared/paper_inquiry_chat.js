// app/javascript/shared/paper_inquiry_chat.js

const escapeHtml = (str) => {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
};

const fmtNum = (val, decimals = null) => {
  if (val === null || val === undefined || val === '') return '-';
  const n = Number(val);
  if (!Number.isFinite(n)) return escapeHtml(val);
  if (decimals !== null) {
    return n.toLocaleString('ja-JP', {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals
    });
  }
  return n.toLocaleString('ja-JP');
};

const formatBoldMarkdown = (text) => {
  return escapeHtml(text)
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\n/g, '<br>');
};

const renderComparisonTableHtml = (data) => {
  const rows = data.summary_rows || [];
  const totals = data.totals || {};
  const notes = data.notes || [];
  const job = data.job_summary || {};

  const rowsHtml = rows.map((r) => {
    const unitPriceStr = r.mtanka && Number(r.mtanka) > 0
      ? `<span class="badge bg-warning text-dark">枚単価 ${fmtNum(r.mtanka, 2)}円</span>`
      : `k単価 <strong>${fmtNum(r.ktanka, 2)}円</strong>`;
    const boardBadge = r.is_board
      ? '<span class="badge bg-info text-dark ms-1">板紙(100枚単位)</span>'
      : '';
    const ledgerCell = r.ledger_shared
      ? `<span class="text-muted small">（上段ロットと共有: ${fmtNum(r.ledger_qty)}枚 / ${fmtNum(r.ledger_amount)}円）</span>`
      : (r.ledger_qty
          ? `<strong>${fmtNum(r.ledger_qty)}枚</strong><br><span class="text-primary fw-bold">${fmtNum(r.ledger_amount)}円</span><br><span class="text-muted" style="font-size:11px;">(${escapeHtml(r.ledger_date || '')} ${escapeHtml(r.ledger_note || '')})</span>`
          : '<span class="badge bg-light text-secondary border">常備在庫（発注なし）</span>');

    return `
      <tr>
        <td class="fw-bold">${escapeHtml(r.part_name)}</td>
        <td>
          <div><strong>${escapeHtml(r.paper_name)}</strong> (${escapeHtml(r.size_type)}判 <strong>${fmtNum(r.ren, 1)}kg</strong>)${boardBadge}</div>
          <div class="small text-secondary">${unitPriceStr} / 区分: ${escapeHtml(r.paper_route)}</div>
        </td>
        <td class="text-end fw-bold">${fmtNum(r.jisu)} 枚</td>
        <td class="text-end">
          <div class="fw-bold text-danger">+${fmtNum(r.yobi)} 枚</div>
          <div class="text-muted" style="font-size:11px;">${escapeHtml(r.yobi_detail)}</div>
        </td>
        <td class="text-end" style="background-color:#f8fff9;">
          <div><strong>${fmtNum(r.press_num)} 枚</strong> <span class="text-secondary small">(${fmtNum(r.weight, 2)} kg)</span></div>
          <div class="fs-6 fw-bold text-success">${fmtNum(r.paper_price)} 円</div>
        </td>
        <td class="text-end" style="background-color:#f8faff;">
          ${ledgerCell}
        </td>
      </tr>
    `;
  }).join('');

  // 手動転記用の列ガイド（AddValueテーブルのカラム順と完全一致）
  const guideRowsHtml = rows.map((r) => `
    <tr>
      <td><code>${escapeHtml(r.post_press)}</code></td>
      <td><code>${escapeHtml(r.paper_name)}</code></td>
      <td class="text-center"><code>${escapeHtml(r.paper_route)}</code></td>
      <td class="text-end"><code>${fmtNum(r.ren, 1)}</code></td>
      <td class="text-center">${r.is_board ? '☑ (ON)' : '☐ (OFF)'}</td>
      <td class="text-end fw-bold"><code>${fmtNum(r.jisu)}</code></td>
      <td class="text-end"><code>${fmtNum(r.sasi || 0)}</code></td>
      <td class="text-end fw-bold"><code>${fmtNum(r.yobi)}</code></td>
      <td class="text-end"><code>${r.ktanka ? fmtNum(r.ktanka, 2) : ''}</code></td>
      <td class="text-end"><code>${r.mtanka ? fmtNum(r.mtanka, 2) : ''}</code></td>
      <td class="text-end fw-bold text-primary"><code>${fmtNum(r.press_num)}</code></td>
      <td class="text-end"><code>${fmtNum(r.weight, 2)}</code></td>
      <td class="text-end fw-bold text-success"><code>${fmtNum(r.paper_price)}</code></td>
    </tr>
  `).join('');

  const notesHtml = notes.map((n) => `<li class="mb-1">${escapeHtml(n)}</li>`).join('');

  return `
    <div class="paper-inquiry-result-card border rounded p-3 mb-2 bg-white shadow-sm">
      <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
        <div>
          <span class="badge bg-primary me-2">${escapeHtml(job.den_id)}</span>
          <strong>${escapeHtml(job.client_name)}</strong> — ${escapeHtml(job.title)}
          <span class="ms-2 text-muted small">
            [${escapeHtml(job.print_method)} / 仕上:${escapeHtml(job.size_spec)} / 数量:${escapeHtml(job.quantity_label || fmtNum(job.quantity))} / ${escapeHtml(job.colors)} / ${escapeHtml(job.pages)}]
          </span>
        </div>
        <span class="badge bg-light text-secondary border">算出速度: ${escapeHtml(data.elapsed_ms)} ms</span>
      </div>

      <div class="mb-2 small text-dark" style="line-height:1.5;">
        ${formatBoldMarkdown(data.bot_reply || '')}
      </div>

      <h6 class="fw-bold mt-2 mb-1 text-primary" style="font-size:0.9rem;">
        📊 3. 計算結果の総括比較
      </h6>
      <div class="table-responsive mb-2">
        <table class="table table-sm table-bordered align-middle mb-0" style="font-size:0.82rem;">
          <thead class="table-light">
            <tr>
              <th style="min-width:150px;">パート / 台構成</th>
              <th style="min-width:200px;">使用用紙・判型・連量・単価</th>
              <th class="text-end" style="min-width:85px;">正味実数<br>(全判)</th>
              <th class="text-end" style="min-width:160px;">損紙・予備<br>(色校＋本生産)</th>
              <th class="text-end" style="min-width:140px; background-color:#eaf7ed;">理論必要総数・重量<br><strong>理論用紙金額</strong></th>
              <th class="text-end" style="min-width:150px; background-color:#eef4ff;">用紙台帳 手配実績<br>(手配枚数・購入金額)</th>
            </tr>
          </thead>
          <tbody>
            ${rowsHtml}
          </tbody>
          <tfoot class="table-secondary fw-bold">
            <tr>
              <td colspan="2">合計（全判枚数・金額 合計）</td>
              <td class="text-end">${fmtNum(totals.jisu)} 枚</td>
              <td class="text-end text-danger">+${fmtNum(totals.yobi)} 枚</td>
              <td class="text-end text-success">
                ${fmtNum(totals.press_num)} 枚 (${fmtNum(totals.weight, 2)} kg)<br>
                <span class="fs-6">${fmtNum(totals.paper_price)} 円</span>
              </td>
              <td class="text-end text-primary">
                ${totals.ledger_qty ? `${fmtNum(totals.ledger_qty)} 枚<br><span class="fs-6">${fmtNum(totals.ledger_amount)} 円</span>` : '-'}
              </td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div class="mb-2">
        <div class="fw-bold small text-secondary mb-1">
          📋 手動入力用 転記ガイド（上の「追加」ボタンを押して各セルへ入力してください）
        </div>
        <div class="table-responsive">
          <table class="table table-sm table-bordered mb-0" style="font-size:0.78rem; background:#fcfcfc;">
            <thead class="table-light text-center">
              <tr>
                <th>備考</th>
                <th>紙質</th>
                <th>注文</th>
                <th>連量</th>
                <th>板紙</th>
                <th>通し枚数(実数)</th>
                <th>差替</th>
                <th>予備</th>
                <th>k単価</th>
                <th>枚単価</th>
                <th>総枚数</th>
                <th>重量</th>
                <th>用紙価格</th>
              </tr>
            </thead>
            <tbody>
              ${guideRowsHtml}
            </tbody>
          </table>
        </div>
      </div>

      <details class="small text-secondary mt-1" open>
        <summary class="fw-bold" style="cursor:pointer;">🔍 判定・計算根拠の詳細（作業伝票・CTP依頼書・印刷日報・損紙率一覧・用紙単価台帳）</summary>
        <ul class="mt-1 mb-0 ps-3" style="font-size:0.78rem;">
          ${notesHtml}
        </ul>
      </details>
    </div>
  `;
};

const ensureInquiryPanelInModal = (modalEl) => {
  let panel = modalEl.querySelector('#paperInquiryModalPanel');
  if (panel) return panel;

  const body = modalEl.querySelector('.modal-body');
  if (!body) return null;

  panel = document.createElement('div');
  panel.id = 'paperInquiryModalPanel';
  panel.className = 'mt-3 border border-primary rounded bg-light p-3';
  panel.style.display = 'none';
  body.appendChild(panel);
  return panel;
};

const ensureInquiryDockOnPage = () => {
  let dock = document.getElementById('paperInquiryDockPanel');
  if (dock) return dock;

  dock = document.createElement('div');
  dock.id = 'paperInquiryDockPanel';
  Object.assign(dock.style, {
    position: 'fixed',
    left: '16px',
    right: '16px',
    bottom: '12px',
    maxHeight: '58vh',
    overflowY: 'auto',
    zIndex: '1055',
    backgroundColor: '#f4f7fb',
    border: '2px solid #0d6efd',
    borderRadius: '8px',
    boxShadow: '0 -4px 20px rgba(0,0,0,0.2)',
    padding: '12px 16px',
    display: 'none'
  });
  document.body.appendChild(dock);
  return dock;
};

const renderChatContainerHtml = (jobId, denId) => `
  <div class="d-flex justify-content-between align-items-center mb-2">
    <div class="fw-bold text-primary" style="font-size:0.95rem;">
      🤖 用紙選定・金額計算アシスタント（チャット問い合わせ＆総括比較表）
      <span class="badge bg-secondary ms-2">受注No: ${escapeHtml(denId || '')}</span>
    </div>
    <button type="button" class="btn btn-sm btn-outline-secondary js-close-paper-inquiry">× 閉じる</button>
  </div>

  <div class="js-inquiry-messages mb-2" style="max-height:38vh; overflow-y:auto;">
    <div class="text-muted small py-2">🔄 作業伝票・CTP面付け・印刷日報・用紙単価台帳を照合して計算中です...</div>
  </div>

  <div class="d-flex flex-wrap gap-1 mb-2">
    <span class="small text-muted align-self-center me-1">条件変更で再計算:</span>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="A判で計算して">A判で計算</button>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="四六判で計算して">四六判で計算</button>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="菊判で計算して">菊判で計算</button>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="色校1回で計算して">色校1回</button>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="色校2回で計算して">色校2回</button>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="色校なしで計算して">色校なし</button>
    <button type="button" class="btn btn-xs btn-outline-primary py-0 px-2 small js-inquiry-chip" data-q="予備300枚で計算して">予備300枚</button>
    <button type="button" class="btn btn-xs btn-outline-success py-0 px-2 small js-inquiry-chip" data-q="台帳手配枚数で計算して">台帳手配枚数を適用</button>
  </div>

  <form class="js-inquiry-form d-flex gap-2" data-job-id="${escapeHtml(jobId || '')}" data-den-id="${escapeHtml(denId || '')}">
    <input type="text" class="form-control form-control-sm js-inquiry-input"
           placeholder="質問や条件を入力（例: 菊判で計算して / 予備200枚 / k単価187 / 260729-005 を調べて）" />
    <button type="submit" class="btn btn-sm btn-primary text-nowrap px-3">問い合わせ送信</button>
  </form>
`;

const executePaperInquiry = async (container, { jobId, denId, question = '' }) => {
  const csrfMeta = document.querySelector('meta[name="csrf-token"]');
  const csrf = csrfMeta ? csrfMeta.content : '';
  const msgBox = container.querySelector('.js-inquiry-messages');
  if (!msgBox) return;

  if (question) {
    const userBubble = document.createElement('div');
    userBubble.className = 'text-end mb-2';
    userBubble.innerHTML = `<span class="badge bg-primary text-wrap text-start p-2" style="font-size:0.82rem;">💬 ${escapeHtml(question)}</span>`;
    msgBox.appendChild(userBubble);
  }

  const loadingEl = document.createElement('div');
  loadingEl.className = 'text-muted small py-1';
  loadingEl.textContent = '🔄 計算中...';
  msgBox.appendChild(loadingEl);
  msgBox.scrollTop = msgBox.scrollHeight;

  try {
    const res = await fetch('/add_values/paper_inquiry', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ job_id: jobId, den_id: denId, question: question })
    });
    const data = await res.json();
    loadingEl.remove();

    if (!res.ok || !data.ok) {
      const errDiv = document.createElement('div');
      errDiv.className = 'alert alert-danger py-2 small mb-2';
      errDiv.textContent = data.error || '問い合わせ処理中にエラーが発生しました。';
      msgBox.appendChild(errDiv);
      return;
    }

    // 初回表示時はプレースホルダーをクリア
    if (!question) {
      msgBox.innerHTML = '';
    }

    const resultWrapper = document.createElement('div');
    resultWrapper.innerHTML = renderComparisonTableHtml(data);
    msgBox.appendChild(resultWrapper);
    msgBox.scrollTop = msgBox.scrollHeight;
  } catch (err) {
    console.error(err);
    loadingEl.remove();
    const errDiv = document.createElement('div');
    errDiv.className = 'alert alert-danger py-2 small mb-2';
    errDiv.textContent = '通信エラーが発生しました。';
    msgBox.appendChild(errDiv);
  }
};

export function initPaperInquiryChat() {
  if (document.body.dataset.paperInquiryBound === '1') return;
  document.body.dataset.paperInquiryBound = '1';

  // 「🤖 問い合わせ」ボタンのクリック
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('.js-paper-inquiry-btn');
    if (!btn) return;
    e.preventDefault();

    const jobId = btn.dataset.jobId || '';
    const denId = btn.dataset.denId || '';

    const modalEl = btn.closest('#addValueModal');
    let container = null;
    if (modalEl) {
      container = ensureInquiryPanelInModal(modalEl);
    } else {
      container = ensureInquiryDockOnPage();
    }
    if (!container) return;

    container.style.display = 'block';
    container.innerHTML = renderChatContainerHtml(jobId, denId);
    executePaperInquiry(container, { jobId, denId, question: '' });
  });

  // 閉じるボタン
  document.addEventListener('click', (e) => {
    const closeBtn = e.target.closest('.js-close-paper-inquiry');
    if (!closeBtn) return;
    e.preventDefault();
    const panel = closeBtn.closest('#paperInquiryModalPanel, #paperInquiryDockPanel');
    if (panel) panel.style.display = 'none';
  });

  // クイック質問チップボタン
  document.addEventListener('click', (e) => {
    const chip = e.target.closest('.js-inquiry-chip');
    if (!chip) return;
    e.preventDefault();
    const panel = chip.closest('#paperInquiryModalPanel, #paperInquiryDockPanel');
    if (!panel) return;
    const form = panel.querySelector('.js-inquiry-form');
    if (!form) return;
    const jobId = form.dataset.jobId;
    const denId = form.dataset.denId;
    const q = chip.dataset.q || '';
    executePaperInquiry(panel, { jobId, denId, question: q });
  });

  // チャットフォーム送信
  document.addEventListener('submit', (e) => {
    const form = e.target.closest('.js-inquiry-form');
    if (!form) return;
    e.preventDefault();
    const panel = form.closest('#paperInquiryModalPanel, #paperInquiryDockPanel');
    if (!panel) return;
    const input = form.querySelector('.js-inquiry-input');
    const q = input ? input.value.trim() : '';
    if (!q) return;
    if (input) input.value = '';

    // 入力文中に別の受注番号（26xxxx-xxx）が含まれている場合はその受注番号へ切り替え可能にする
    const m = q.match(/(\d{6}-\d{3})/);
    const denId = m ? m[1] : form.dataset.denId;
    const jobId = m ? '' : form.dataset.jobId;

    executePaperInquiry(panel, { jobId, denId, question: q });
  });
}
