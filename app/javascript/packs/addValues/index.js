import { Modal } from 'bootstrap';
import { setupAddPapersTable } from '../../shared/add_values_table';
import { initPaperInquiryChat } from '../../shared/paper_inquiry_chat';

initPaperInquiryChat();
/// Turbolinks による差し替えにも強いイベントデリゲーション
document.addEventListener('click', async (e) => {
    const link = e.target.closest('.js-open-addvalues');
    console.log('link');
    if (!link) return;

    e.preventDefault();

    const jobId = link.dataset.jobId;
    const denId = link.dataset.denId;

    try {
        const res = await fetch(`/add_values/rows?job_id=${encodeURIComponent(jobId)}`, {
            headers: { 'Accept': 'application/json' },
            credentials: 'same-origin',
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();

        const modalEl = document.getElementById('addValueModal');
        if (!modalEl) return;

        const titleEl = modalEl.querySelector('.modal-title');
        if (titleEl) titleEl.textContent = `受注伝票: ${denId} `;

        const body = modalEl.querySelector('.modal-body');

        if (body) {
            body.innerHTML = `
              
              <div class="table-responsive">
                <div calss="000"> ${data.job_html || ''}</div>
                <table class="index table table-sm table-bordered mb-0" id="add_papers">
                  <thead>
                    ${data.header_html || ''}
                  </thead>
                  <tbody>${data.html || ''}</tbody>
                </table>
              </div>
            `;
        }

        // モーダル内に挿入したテーブルへイベント群をセット
        const tableEl = modalEl.querySelector('#add_papers');
        if (tableEl && typeof setupAddPapersTable === 'function') {
            setupAddPapersTable(tableEl);
        }

        // 保存しておき、クローズ時に参照する
        modalEl.dataset.currentJobId = jobId;

        // モーダル閉じ時に対象ジョブの表示を更新（id=job_id の要素の中身を差し替え）
        if (modalEl.dataset.refreshBound !== '1') {
            modalEl.addEventListener('hidden.bs.modal', async () => {
                const targetJobId = modalEl.dataset.currentJobId;
                if (!targetJobId) return;
                try {
                    const res2 = await fetch(`/calendar/job_item?job_id=${encodeURIComponent(targetJobId)}`, {
                        headers: { 'Accept': 'application/json' },
                        credentials: 'same-origin',
                    });
                    if (res2.ok) {
                        const payload = await res2.json();
                        const html = payload && payload.html;
                        if (html) {
                            const li = document.getElementById(String(targetJobId));
                            if (li) {
                                li.innerHTML = html;
                            }
                        }
                    }
                } catch (e) {
                    // eslint-disable-next-line no-console
                    console.error('Failed to refresh calendar job item:', e);
                }
            });
            modalEl.dataset.refreshBound = '1';
        }

        const modal = new Modal(modalEl);
        modal.show();
    } catch (err) {
        console.error(err);
        alert('明細の取得に失敗しました。時間をおいて再度お試しください。');
    }
});

window.arrangeModal = function (id) {
    // console.log(planned_date);
    $.ajax({
        url:  "jobs/" + id +"/arrange",
        type: "GET",
        data: {job : id },
        dataType: "html",
        success: function(data) {
            let $modal = $('#modal')
            let $mask = $('#mask')
            let today = new Date()

            $modal.html(data);

            $modal.removeClass('hidden')
            $mask.removeClass('hidden')

            $mask.click(function() {
                $modal.addClass('hidden')
                $mask.addClass('hidden')
            });

            let $d = (today.getMonth() + 1) + "/" + today.getDate()
            $("#job" + id).html("<div>" + $d + "</div>")
        },
        error: function(data) {
            console.log("error")
        }
    });
}