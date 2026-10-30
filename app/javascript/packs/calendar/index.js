import * as bootstrap from "bootstrap"

console.log("calendar.js")

// HTML文字列を安全にレンダリングするためのヘルパー関数（XSS対策）
const escapeHtml = (unsafe) => {
    if (unsafe === null || unsafe === undefined) return '';
    return String(unsafe)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function initCalendarModal() {
    const jobModalElement = document.getElementById('jobModal');

    if (jobModalElement && !jobModalElement.dataset.boundModal) {
        jobModalElement.dataset.boundModal = "true";
        jobModalElement.addEventListener('show.bs.modal', async (event) => {
            const button = event.relatedTarget;
            const jobId = button.dataset.jobId;
            const modalTitle = jobModalElement.querySelector('.modal-title');
            const modalBody = jobModalElement.querySelector('.modal-body');

            modalTitle.textContent = '読み込み中...';
            modalBody.innerHTML = '<p>詳細データを取得しています...</p>';

            try {
                const response = await fetch(`/jobs/${jobId}`);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                const html = await response.text();
                modalTitle.textContent = "";
                modalBody.innerHTML = html;
            } catch (error) {
                console.error("Job詳細の取得に失敗しました:", error);
                modalTitle.textContent = 'エラー';
                modalBody.innerHTML = '<p>データの読み込みに失敗しました。時間をおいて再度お試しください。</p>';
            }
        });
    }
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initCalendarModal);
} else {
    initCalendarModal();
}
document.addEventListener("turbolinks:load", initCalendarModal);
