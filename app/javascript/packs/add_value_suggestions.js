/* global $ */
(function () {
  // 依存: jQuery, Bootstrap5
  if (typeof $ === 'undefined') return;

  function ensureModal() {
    if ($('#archiveSuggestModal').length) return;

    const html = `
<div class="modal fade" id="archiveSuggestModal" tabindex="-1" aria-labelledby="archiveSuggestModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="archiveSuggestModalLabel">モデルアーカイブ候補</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="閉じる"></button>
      </div>
      <div class="modal-body">
        <div class="mb-2">
          <input type="text" class="form-control" id="archiveSuggestQuery" placeholder="キーワードで再検索（任意）">
        </div>
        <div id="archiveSuggestList" class="list-group"></div>
      </div>
      <div class="modal-footer">
        <span class="text-muted me-auto small">スコアは 0〜1（高いほど類似）</span>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">閉じる</button>
      </div>
    </div>
  </div>
</div>`;
    $('body').append(html);
  }

  function findRow($el) {
    // 行（tr か .add-value-row）を推定
    let $row = $el.closest('tr');
    if ($row.length === 0) {
      $row = $el.closest('.add-value-row');
    }
    return $row.length ? $row : $el.closest('form'); // 最後の砦
  }

  function findAddValueId($row) {
    // name="add_value[id]" などの hidden を優先
    const $hid = $row.find('input[name$="[id]"], input[name="add_value[id]"]').first();
    if ($hid.length && $hid.val()) return $hid.val();
    // data 属性のフォールバック
    const dataId = $row.data('addValueId') || $row.data('id');
    if (dataId) return dataId;
    return null;
  }

  function renderList($list, items, $row) {
      // 1. 予め、表示したいキーのリストを定義しておきます。(Setを使うと効率的です)
      const allowedKeys = new Set([
          "den_id", "textInfo02", "textInfo05", "textInfo07", "numInfo01",
          "post_press", "paper_route", "paper_name", "paper_jisu", "paper_yobi",
          "paper_ren", "ktanka", "mtanaka", "paper_weight", "cost_paper"
      ]);
    $list.empty();
    if (!items || items.length === 0) {
      $list.append('<div class="list-group-item text-muted">候補は見つかりませんでした</div>');
      return;
    }
  items.forEach(function (item, idx) {
      const attrsPreview = Object.entries(item.attributes || {})
          // 2.【ここを追加】allowedKeysに含まれるキー(k)を持つ要素だけをフィルタリング
          .filter(([k, v]) => allowedKeys.has(k))
          // 3. 絞り込まれた要素を元にHTMLタグを生成（この行は元のまま）
          .map(([k, v]) => `<span class="badge bg-light text-dark me-1">${k}: ${String(v).substring(0, 20)}</span>`)
          .join(' ');
      const $entry = $(`
<div class="list-group-item">
  <div class="d-flex justify-content-between">
    <div>
      <div><strong>#${item.id}</strong> <span class="text-muted">score: ${item.score.toFixed(3)}</span></div>
      <div class="mt-1">${attrsPreview}</div>
    </div>
    <div class="ms-3">
      <button class="btn btn-sm btn-primary js-apply-suggest">適用</button>
    </div>
  </div>
</div>`);
      $entry.find('.js-apply-suggest').on('click', function () {
        const attrs = item.attributes || {};
        // Archive -> AddValue の対応マッピング
        const mapped = {
          paper_name: attrs.paper_name,        // Archive.paper_name -> AddValue.paper_name
          paper_route: attrs.paper_route,      // Archive.paper_route -> AddValue.paper_route
          ita: attrs.ita,                      // Archive.ita -> AddValue.ita
          jisu: attrs.paper_jisu,              // Archive.paper_jisu -> AddValue.jisu
          yobi: attrs.paper_yobi,              // Archive.paper_yobi -> AddValue.yobi
          ren: attrs.paper_ren,                // Archive.paper_ren -> AddValue.ren
          ktanka: attrs.paper_ktanka,          // Archive.paper_ktanka -> AddValue.ktanka
          mtanka: attrs.paper_mtanka          // Archive.paper_mtanaka -> AddValue.mtanka
        };
        // null/undefined を除去
        Object.keys(mapped).forEach(function (k) { if (mapped[k] == null) delete mapped[k]; });

        applyToRow($row, mapped);
        // 強調表示
        $row.addClass('table-success');
        setTimeout(function () { $row.removeClass('table-success'); }, 1200);
      });

      $list.append($entry);
    });
  }

  function applyToRow($row, attrs) {
    let changed = false;

    // 1) 行内の add_value[...] 系 input/select/textarea にマッピング
    const inputs = $row.find('input[name^="add_value["], select[name^="add_value["], textarea[name^="add_value["]');
    inputs.each(function () {
      const $i = $(this);
      const name = $i.attr('name'); // 例: add_value[field_name]
      const match = name && name.match(/^add_value\[(.+)]$/);
      if (!match) return;
      const key = match[1];
      if (!Object.prototype.hasOwnProperty.call(attrs, key)) return;

      const val = attrs[key];
      if ($i.is(':checkbox')) {
        $i.prop('checked', !!val).trigger('change');
      } else {
        $i.val(val);
        // 変更通知（既存の保存ロジックを起動）
        $i.trigger('input').trigger('change').trigger('blur');
      }
      changed = true;
    });

    // 2) contenteditable な <td class="editable" data-field="..."> にマッピング
    Object.keys(attrs || {}).forEach(function (key) {
      const $td = $row.find('td.editable[data-field="' + key + '"]');
      if ($td.length === 0) return;

      const val = attrs[key];

      // チェックボックスを内包している場合（boolean）
      const $chk = $td.find('input[type="checkbox"]');
      if ($chk.length) {
        $chk.prop('checked', !!val).trigger('change');
        changed = true;
        return;
      }

      // テキスト/数値セルの内容を書き換え
      const type = ($td.data('type') || '').toString();
      const disp = (val == null) ? '' : (type === 'number' ? String(Number(val)) : String(val));
      // 既存の contenteditable 保存ロジックが input/blur を監視しているケースに対応
      $td.text(disp);
      $td.trigger('input'); // 独自実装が拾う可能性
      $td.trigger('blur');  // blur 保存型の実装にも対応
      changed = true;
    });

    // 3) 反映後の通知（既存側でハンドルできるように）
    if (changed) {
      $row.trigger('add_value:suggestion:applied', [attrs]);
      try {
        const ev = new CustomEvent('add_value:suggestion:applied', { detail: { row: $row.get(0), attrs: attrs } });
        window.dispatchEvent(ev);
      } catch (e) { /* no-op */ }
    }
  }

  function openModalAndLoad($row, opts) {
    ensureModal();
    const modalEl = document.getElementById('archiveSuggestModal');
    const ModalCtor = (window.bootstrap && window.bootstrap.Modal) ? window.bootstrap.Modal : null;
    if (!ModalCtor) {
      console.warn('Bootstrap Modal が利用できません。bootstrap の読み込みを確認してください。');
      return;
    }
    const modal = new ModalCtor(modalEl);
    const $list = $('#archiveSuggestList');
    const $q = $('#archiveSuggestQuery');

    $list.html('<div class="text-muted">検索中...</div>');

    function doFetch(q) {
      const params = {};
      if (opts.addValueId) params.add_value_id = opts.addValueId;
      if (q) params.q = q;
      $.getJSON('/suggestions/archives.json', params)
        .done(function (res) {
          renderList($list, res, $row);
        })
        .fail(function () {
          $list.html('<div class="text-danger">取得に失敗しました</div>');
        });
    }

    $q.off('keydown').on('keydown', function (e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        doFetch($q.val().trim());
      }
    });

    modal.show();
    doFetch(($q.val() || '').trim());
  }

  // ボタンをクリックしたら現在の行に対して候補を表示
  $(document).on('click', '.js-archive-suggest-btn', function (e) {
    e.preventDefault();
    const $btn = $(this);
    const $row = findRow($btn);
    const addValueId = $btn.data('addValueId') || findAddValueId($row);
    openModalAndLoad($row, { addValueId: addValueId });
  });

  // 自動でボタンを補完（行内に .js-archive-suggest-btn が無ければ追加）
  function tryInjectButtons() {
    $('.add-value-row').each(function () {
      const $row = $(this);
      if ($row.find('.js-archive-suggest-btn').length) return;
      // 行の末尾にボタンを追加（レイアウトに応じて調整してください）
      const $targetCell = $row.find('td').last().length ? $row.find('td').last() : $row;
      const $btn = $('<button type="button" class="btn btn-sm btn-outline-primary js-archive-suggest-btn ms-1">参照候補</button>');
      const avId = findAddValueId($row);
      if (avId) $btn.attr('data-add-value-id', avId);
      $targetCell.append($btn);
    });
  }
  //
  // $(document).on('turbolinks:load', function () {
  //   tryInjectButtons();
  // });
  // $(function () {
  //   tryInjectButtons();
  // });
})();
