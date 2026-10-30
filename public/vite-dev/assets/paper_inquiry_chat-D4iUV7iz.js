var e=e=>e==null?``:String(e).replace(/&/g,`&amp;`).replace(/</g,`&lt;`).replace(/>/g,`&gt;`).replace(/"/g,`&quot;`).replace(/'/g,`&#39;`),t=(t,n=null)=>{if(t==null||t===``)return`-`;let r=Number(t);return Number.isFinite(r)?n===null?r.toLocaleString(`ja-JP`):r.toLocaleString(`ja-JP`,{minimumFractionDigits:n,maximumFractionDigits:n}):e(t)},n=t=>e(t).replace(/\*\*(.+?)\*\*/g,`<strong>$1</strong>`).replace(/\n/g,`<br>`),r=r=>{let i=r.summary_rows||[],a=r.totals||{},o=r.notes||[],s=r.job_summary||{},c=i.map(n=>{let r=n.mtanka&&Number(n.mtanka)>0?`<span class="badge bg-warning text-dark">枚単価 ${t(n.mtanka,2)}円</span>`:`k単価 <strong>${t(n.ktanka,2)}円</strong>`,i=n.is_board?`<span class="badge bg-info text-dark ms-1">板紙(100枚単位)</span>`:``,a=n.ledger_shared?`<span class="text-muted small">（上段ロットと共有: ${t(n.ledger_qty)}枚 / ${t(n.ledger_amount)}円）</span>`:n.ledger_qty?`<strong>${t(n.ledger_qty)}枚</strong><br><span class="text-primary fw-bold">${t(n.ledger_amount)}円</span><br><span class="text-muted" style="font-size:11px;">(${e(n.ledger_date||``)} ${e(n.ledger_note||``)})</span>`:`<span class="badge bg-light text-secondary border">常備在庫（発注なし）</span>`;return`
      <tr>
        <td class="fw-bold">${e(n.part_name)}</td>
        <td>
          <div><strong>${e(n.paper_name)}</strong> (${e(n.size_type)}判 <strong>${t(n.ren,1)}kg</strong>)${i}</div>
          <div class="small text-secondary">${r} / 区分: ${e(n.paper_route)}</div>
        </td>
        <td class="text-end fw-bold">${t(n.jisu)} 枚</td>
        <td class="text-end">
          <div class="fw-bold text-danger">+${t(n.yobi)} 枚</div>
          <div class="text-muted" style="font-size:11px;">${e(n.yobi_detail)}</div>
        </td>
        <td class="text-end" style="background-color:#f8fff9;">
          <div><strong>${t(n.press_num)} 枚</strong> <span class="text-secondary small">(${t(n.weight,2)} kg)</span></div>
          <div class="fs-6 fw-bold text-success">${t(n.paper_price)} 円</div>
        </td>
        <td class="text-end" style="background-color:#f8faff;">
          ${a}
        </td>
      </tr>
    `}).join(``),l=i.map(n=>`
    <tr>
      <td><code>${e(n.post_press)}</code></td>
      <td><code>${e(n.paper_name)}</code></td>
      <td class="text-center"><code>${e(n.paper_route)}</code></td>
      <td class="text-end"><code>${t(n.ren,1)}</code></td>
      <td class="text-center">${n.is_board?`☑ (ON)`:`☐ (OFF)`}</td>
      <td class="text-end fw-bold"><code>${t(n.jisu)}</code></td>
      <td class="text-end"><code>${t(n.sasi||0)}</code></td>
      <td class="text-end fw-bold"><code>${t(n.yobi)}</code></td>
      <td class="text-end"><code>${n.ktanka?t(n.ktanka,2):``}</code></td>
      <td class="text-end"><code>${n.mtanka?t(n.mtanka,2):``}</code></td>
      <td class="text-end fw-bold text-primary"><code>${t(n.press_num)}</code></td>
      <td class="text-end"><code>${t(n.weight,2)}</code></td>
      <td class="text-end fw-bold text-success"><code>${t(n.paper_price)}</code></td>
    </tr>
  `).join(``),u=o.map(t=>`<li class="mb-1">${e(t)}</li>`).join(``);return`
    <div class="paper-inquiry-result-card border rounded p-3 mb-2 bg-white shadow-sm">
      <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
        <div>
          <span class="badge bg-primary me-2">${e(s.den_id)}</span>
          <strong>${e(s.client_name)}</strong> — ${e(s.title)}
          <span class="ms-2 text-muted small">
            [${e(s.print_method)} / 仕上:${e(s.size_spec)} / 数量:${e(s.quantity_label||t(s.quantity))} / ${e(s.colors)} / ${e(s.pages)}]
          </span>
        </div>
        <span class="badge bg-light text-secondary border">算出速度: ${e(r.elapsed_ms)} ms</span>
      </div>

      <div class="mb-2 small text-dark" style="line-height:1.5;">
        ${n(r.bot_reply||``)}
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
            ${c}
          </tbody>
          <tfoot class="table-secondary fw-bold">
            <tr>
              <td colspan="2">合計（全判枚数・金額 合計）</td>
              <td class="text-end">${t(a.jisu)} 枚</td>
              <td class="text-end text-danger">+${t(a.yobi)} 枚</td>
              <td class="text-end text-success">
                ${t(a.press_num)} 枚 (${t(a.weight,2)} kg)<br>
                <span class="fs-6">${t(a.paper_price)} 円</span>
              </td>
              <td class="text-end text-primary">
                ${a.ledger_qty?`${t(a.ledger_qty)} 枚<br><span class="fs-6">${t(a.ledger_amount)} 円</span>`:`-`}
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
              ${l}
            </tbody>
          </table>
        </div>
      </div>

      <details class="small text-secondary mt-1" open>
        <summary class="fw-bold" style="cursor:pointer;">🔍 判定・計算根拠の詳細（作業伝票・CTP依頼書・印刷日報・損紙率一覧・用紙単価台帳）</summary>
        <ul class="mt-1 mb-0 ps-3" style="font-size:0.78rem;">
          ${u}
        </ul>
      </details>
    </div>
  `},i=e=>{let t=e.querySelector(`#paperInquiryModalPanel`);if(t)return t;let n=e.querySelector(`.modal-body`);return n?(t=document.createElement(`div`),t.id=`paperInquiryModalPanel`,t.className=`mt-3 border border-primary rounded bg-light p-3`,t.style.display=`none`,n.appendChild(t),t):null},a=()=>{let e=document.getElementById(`paperInquiryDockPanel`);return e||(e=document.createElement(`div`),e.id=`paperInquiryDockPanel`,Object.assign(e.style,{position:`fixed`,left:`16px`,right:`16px`,bottom:`12px`,maxHeight:`58vh`,overflowY:`auto`,zIndex:`1055`,backgroundColor:`#f4f7fb`,border:`2px solid #0d6efd`,borderRadius:`8px`,boxShadow:`0 -4px 20px rgba(0,0,0,0.2)`,padding:`12px 16px`,display:`none`}),document.body.appendChild(e),e)},o=(t,n)=>`
  <div class="d-flex justify-content-between align-items-center mb-2">
    <div class="fw-bold text-primary" style="font-size:0.95rem;">
      🤖 用紙選定・金額計算アシスタント（チャット問い合わせ＆総括比較表）
      <span class="badge bg-secondary ms-2">受注No: ${e(n||``)}</span>
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

  <form class="js-inquiry-form d-flex gap-2" data-job-id="${e(t||``)}" data-den-id="${e(n||``)}">
    <input type="text" class="form-control form-control-sm js-inquiry-input"
           placeholder="質問や条件を入力（例: 菊判で計算して / 予備200枚 / k単価187 / 260729-005 を調べて）" />
    <button type="submit" class="btn btn-sm btn-primary text-nowrap px-3">問い合わせ送信</button>
  </form>
`,s=async(t,{jobId:n,denId:i,question:a=``})=>{let o=document.querySelector(`meta[name="csrf-token"]`),s=o?o.content:``,c=t.querySelector(`.js-inquiry-messages`);if(!c)return;if(a){let t=document.createElement(`div`);t.className=`text-end mb-2`,t.innerHTML=`<span class="badge bg-primary text-wrap text-start p-2" style="font-size:0.82rem;">💬 ${e(a)}</span>`,c.appendChild(t)}let l=document.createElement(`div`);l.className=`text-muted small py-1`,l.textContent=`🔄 計算中...`,c.appendChild(l),c.scrollTop=c.scrollHeight;try{let e=await fetch(`/add_values/paper_inquiry`,{method:`POST`,headers:{"Content-Type":`application/json`,"X-CSRF-Token":s,Accept:`application/json`},body:JSON.stringify({job_id:n,den_id:i,question:a})}),t=await e.json();if(l.remove(),!e.ok||!t.ok){let e=document.createElement(`div`);e.className=`alert alert-danger py-2 small mb-2`,e.textContent=t.error||`問い合わせ処理中にエラーが発生しました。`,c.appendChild(e);return}a||(c.innerHTML=``);let o=document.createElement(`div`);o.innerHTML=r(t),c.appendChild(o),c.scrollTop=c.scrollHeight}catch(e){console.error(e),l.remove();let t=document.createElement(`div`);t.className=`alert alert-danger py-2 small mb-2`,t.textContent=`通信エラーが発生しました。`,c.appendChild(t)}};function c(){document.body.dataset.paperInquiryBound!==`1`&&(document.body.dataset.paperInquiryBound=`1`,document.addEventListener(`click`,e=>{let t=e.target.closest(`.js-paper-inquiry-btn`);if(!t)return;e.preventDefault();let n=t.dataset.jobId||``,r=t.dataset.denId||``,c=t.closest(`#addValueModal`),l=null;l=c?i(c):a(),l&&(l.style.display=`block`,l.innerHTML=o(n,r),s(l,{jobId:n,denId:r,question:``}))}),document.addEventListener(`click`,e=>{let t=e.target.closest(`.js-close-paper-inquiry`);if(!t)return;e.preventDefault();let n=t.closest(`#paperInquiryModalPanel, #paperInquiryDockPanel`);n&&(n.style.display=`none`)}),document.addEventListener(`click`,e=>{let t=e.target.closest(`.js-inquiry-chip`);if(!t)return;e.preventDefault();let n=t.closest(`#paperInquiryModalPanel, #paperInquiryDockPanel`);if(!n)return;let r=n.querySelector(`.js-inquiry-form`);if(!r)return;let i=r.dataset.jobId,a=r.dataset.denId;s(n,{jobId:i,denId:a,question:t.dataset.q||``})}),document.addEventListener(`submit`,e=>{let t=e.target.closest(`.js-inquiry-form`);if(!t)return;e.preventDefault();let n=t.closest(`#paperInquiryModalPanel, #paperInquiryDockPanel`);if(!n)return;let r=t.querySelector(`.js-inquiry-input`),i=r?r.value.trim():``;if(!i)return;r&&(r.value=``);let a=i.match(/(\d{6}-\d{3})/),o=a?a[1]:t.dataset.denId;s(n,{jobId:a?``:t.dataset.jobId,denId:o,question:i})}))}export{c as t};