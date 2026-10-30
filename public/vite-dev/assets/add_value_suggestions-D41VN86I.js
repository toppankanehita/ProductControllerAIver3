(function(){if(typeof $>`u`)return;function e(){$(`#archiveSuggestModal`).length||$(`body`).append(`
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
</div>`)}function t(e){let t=e.closest(`tr`);return t.length===0&&(t=e.closest(`.add-value-row`)),t.length?t:e.closest(`form`)}function n(e){let t=e.find(`input[name$="[id]"], input[name="add_value[id]"]`).first();return t.length&&t.val()?t.val():e.data(`addValueId`)||e.data(`id`)||null}function r(e,t,n){let r=new Set([`den_id`,`textInfo02`,`textInfo05`,`textInfo07`,`numInfo01`,`post_press`,`paper_route`,`paper_name`,`paper_jisu`,`paper_yobi`,`paper_ren`,`ktanka`,`mtanaka`,`paper_weight`,`cost_paper`]);e.empty(),!t||t.length===0?e.append(`<div class="list-group-item text-muted">候補は見つかりませんでした</div>`):t.forEach(function(t,a){let o=Object.entries(t.attributes||{}).filter(([e,t])=>r.has(e)).map(([e,t])=>`<span class="badge bg-light text-dark me-1">${e}: ${String(t).substring(0,20)}</span>`).join(` `),s=$(`
<div class="list-group-item">
  <div class="d-flex justify-content-between">
    <div>
      <div><strong>#${t.id}</strong> <span class="text-muted">score: ${t.score.toFixed(3)}</span></div>
      <div class="mt-1">${o}</div>
    </div>
    <div class="ms-3">
      <button class="btn btn-sm btn-primary js-apply-suggest">適用</button>
    </div>
  </div>
</div>`);s.find(`.js-apply-suggest`).on(`click`,function(){let e=t.attributes||{},r={paper_name:e.paper_name,paper_route:e.paper_route,ita:e.ita,jisu:e.paper_jisu,yobi:e.paper_yobi,ren:e.paper_ren,ktanka:e.paper_ktanka,mtanka:e.paper_mtanka};Object.keys(r).forEach(function(e){r[e]??delete r[e]}),i(n,r),n.addClass(`table-success`),setTimeout(function(){n.removeClass(`table-success`)},1200)}),e.append(s)})}function i(e,t){let n=!1;if(e.find(`input[name^="add_value["], select[name^="add_value["], textarea[name^="add_value["]`).each(function(){let e=$(this),r=e.attr(`name`),i=r&&r.match(/^add_value\[(.+)]$/);if(!i)return;let a=i[1];if(!Object.prototype.hasOwnProperty.call(t,a))return;let o=t[a];e.is(`:checkbox`)?e.prop(`checked`,!!o).trigger(`change`):(e.val(o),e.trigger(`input`).trigger(`change`).trigger(`blur`)),n=!0}),Object.keys(t||{}).forEach(function(r){let i=e.find(`td.editable[data-field="`+r+`"]`);if(i.length===0)return;let a=t[r],o=i.find(`input[type="checkbox"]`);if(o.length){o.prop(`checked`,!!a).trigger(`change`),n=!0;return}let s=(i.data(`type`)||``).toString(),c=a==null?``:String(s===`number`?Number(a):a);i.text(c),i.trigger(`input`),i.trigger(`blur`),n=!0}),n){e.trigger(`add_value:suggestion:applied`,[t]);try{let n=new CustomEvent(`add_value:suggestion:applied`,{detail:{row:e.get(0),attrs:t}});window.dispatchEvent(n)}catch{}}}function a(t,n){e();let i=document.getElementById(`archiveSuggestModal`),a=window.bootstrap&&window.bootstrap.Modal?window.bootstrap.Modal:null;if(!a){console.warn(`Bootstrap Modal が利用できません。bootstrap の読み込みを確認してください。`);return}let o=new a(i),s=$(`#archiveSuggestList`),c=$(`#archiveSuggestQuery`);s.html(`<div class="text-muted">検索中...</div>`);function l(e){let i={};n.addValueId&&(i.add_value_id=n.addValueId),e&&(i.q=e),$.getJSON(`/suggestions/archives.json`,i).done(function(e){r(s,e,t)}).fail(function(){s.html(`<div class="text-danger">取得に失敗しました</div>`)})}c.off(`keydown`).on(`keydown`,function(e){e.key===`Enter`&&(e.preventDefault(),l(c.val().trim()))}),o.show(),l((c.val()||``).trim())}$(document).on(`click`,`.js-archive-suggest-btn`,function(e){e.preventDefault();let r=$(this),i=t(r);a(i,{addValueId:r.data(`addValueId`)||n(i)})})})();