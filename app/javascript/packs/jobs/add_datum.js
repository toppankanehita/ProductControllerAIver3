import * as bootstrap from 'bootstrap';
import $ from 'jquery';

console.log('open add_datum.js');

// 親コードモーダルを遅延初期化で開く（ページロードイベントに依存しない）
$(document).on('click', '.js-open-parent-code-modal', function (e) {
  e.preventDefault();
  const jobId = $(this).data('job-id');

  const modalEl = document.getElementById('parentCodeModal');
  if (!modalEl) {
    console.warn('parentCodeModal element not found in DOM.');
    return;
  }

  // bootstrap.Modal インスタンスを都度（または再利用）作成
  const parentCodeModal = bootstrap.Modal.getOrCreateInstance(modalEl);
  const modalBody = modalEl.querySelector('.modal-body');
  if (!modalBody) {
    console.warn('parentCodeModal .modal-body not found.');
    return;
  }

  modalBody.innerHTML = '<div class="text-muted">読み込み中...</div>';
  parentCodeModal.show();

  $.ajax({
    url: `/add_data/edit_parent_code?job_id=${jobId}`,
    type: 'GET',
    success: function (data) {
      modalBody.innerHTML = data;
    },
    error: function () {
      modalBody.innerHTML = '<div class="alert alert-danger">フォームの読み込みに失敗しました。</div>';
    }
  });
});

// 動的に読み込まれるフォーム送信（保存）
$(document).on('submit', '#parent_code_form', function (e) {
  // 通常送信を完全に抑止（他ハンドラも止める）
  e.preventDefault();
  e.stopPropagation();
  e.stopImmediatePropagation();

  const form = $(this);
  const url = form.attr('action');
  const formData = form.serialize();

  console.log('[jQuery submit] #parent_code_form intercepted', {
    url,
    defaultPrevented: e.isDefaultPrevented()
  });

  const modalEl = document.getElementById('parentCodeModal');
  const parentCodeModal = modalEl ? bootstrap.Modal.getOrCreateInstance(modalEl) : null;
  console.log('親コードモーダル:', !!parentCodeModal);

  $.ajax({
    url: url,
    type: 'PATCH',
    headers: { 'Accept': 'application/json' },
    data: formData,
    dataType: 'json',
    beforeSend: function () {
      console.log('[AJAX beforeSend]', 'PATCH', url);
    },
    complete: function (xhr) {
      console.log('[AJAX complete]', xhr.status, xhr.getResponseHeader('Content-Type'));
    },
    success: function (data) {
      console.log('[AJAX success]', data);
      if (data.status === 'success') {
        if (parentCodeModal) parentCodeModal.hide();
        console.log('モーダルを閉じました。');

        // 0) add_values/index のジョブ一覧で親コードセルを更新
        const $addValuesTable = $('#add_values_index');
        if ($addValuesTable.length && data.parent_cell_html && data.job_id) {
          const selector = `.js-parent-code-cell[data-job-id="${data.job_id}"]`;
          const $cell = $addValuesTable.find(selector);
          if ($cell.length) {
            $cell.html(data.parent_cell_html);
          }
        }

        // 1) 既存のAddValueモーダル内のtbodyがあれば更新
        const $tbody = $('#addValueModal .modal-body tbody');
        if ($tbody.length) {
          $tbody.html(data.html);
        }

        // 2) ページ本体（jobs/index等）で add_values/_row.html.erb を埋め込んでいる
        const $mainTbody = $('#add_papers tbody');
        if ($mainTbody.length) {
          try {
            const $newRows = $(data.html); // rows_html 全体（複数行）
            const jobId = data.job_id;
            const $oldRows = $mainTbody.find(`tr[data-job-id="${jobId}"]`);
            if ($oldRows.length) {
              const $first = $oldRows.first();
              const $prev = $first.prev(); // 挿入位置基準
              $oldRows.remove();
              if ($prev && $prev.length) {
                $prev.after($newRows);
              } else {
                $mainTbody.prepend($newRows);
              }
            }
          } catch (e) {
            console.error('行の置換中にエラー:', e);
          }
        }

        console.log('親コードを保存し、行を更新しました。');
      } else {
        alert('エラー: ' + (data.errors ? data.errors.join(', ') : '不明なエラー'));
      }
    },
    error: function (xhr) {
      console.error('[AJAX error]', xhr.status, xhr.responseText);
      const errorMessage = xhr.responseJSON && xhr.responseJSON.errors ? xhr.responseJSON.errors.join(', ') : '保存に失敗しました。';
      alert(errorMessage);
    }
  });

  // 念のため通常遷移完全防止
  return false;
});

// ネイティブのキャプチャ段階でのログ（デバッグ用）
document.addEventListener('submit', function (evt) {
  const t = evt.target;
  if (t && t.id === 'parent_code_form') {
    console.log('[native capture] submit intercepted for #parent_code_form');
    // evt.preventDefault(); // 必要ならここでも抑止（通常はjQuery側で抑止済み）
  }
}, true);

// =======================
// Job 詳細ダイアログ（1650 x 800）
// =======================

function ensureJobDetailModal() {
  let modalEl = document.getElementById('jobDetailModal');
  if (modalEl) return modalEl;

  const html = `
<div class="modal fade" id="jobDetailModal" tabindex="-1" aria-labelledby="jobDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog" style="max-width: none; width: 1650px;">
    <div class="modal-content" style="height: 800px;">
      <div class="modal-header">
        <h5 class="modal-title" id="jobDetailModalLabel">受注詳細</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0" style="height: calc(100% - 56px);">
        <iframe src="about:blank" style="border:0;width:100%;height:100%;" title="受注詳細"></iframe>
      </div>
    </div>
  </div>
</div>`;
  document.body.insertAdjacentHTML('beforeend', html);
  modalEl = document.getElementById('jobDetailModal');

  // 閉じたら iframe をクリアしてリソース解放
  modalEl.addEventListener('hidden.bs.modal', () => {
    const iframe = modalEl.querySelector('iframe');
    if (iframe) iframe.src = 'about:blank';
  });

  return modalEl;
}

// add_values の No 列リンククリックでモーダル表示（ページ遷移なし）
$(document).on('click', '.js-open-job-dialog', function (e) {
  e.preventDefault();
  const url = $(this).data('url') || this.href;
  if (!url) return;

  const modalEl = ensureJobDetailModal();
  const iframe = modalEl.querySelector('iframe');
  if (iframe) iframe.src = url;

  const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
  modal.show();
});
