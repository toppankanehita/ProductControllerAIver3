// Shared DOM helpers for AddValue rows (used by jobs/index.js and calendar/index.js)
// This module provides a single function to replace all rows that belong to a Job
// with new HTML returned from the server, while preserving non-editable info cells
// from the first row and applying per-row formatting and post-replacement hooks.

/**
 * Replace all rows for a given jobId within tbody with the given HTML fragment.
 * The HTML may contain multiple <tr> rows (e.g., when server returns all rows for a job).
 *
 * @param {HTMLElement} tbody - The tbody element that contains the rows.
 * @param {string} jobId - The job id string used in data-job-id attributes.
 * @param {string} html - The HTML string containing new <tr> elements.
 * @param {Object} [opts]
 * @param {(tr: HTMLTableRowElement) => void} [opts.formatRow] - Called for each inserted row.
 * @param {() => void} [opts.afterReplace] - Called after replacement completes (e.g., recolor).
 * @returns {HTMLTableRowElement[] | null} - The inserted rows, or null if nothing replaced.
 */
export function replaceJobRowsFromHtml(tbody, jobId, html, opts = {}) {
  if (!tbody || !jobId || !html) return null;

  const oldRows = Array.from(tbody.querySelectorAll(`tr[data-job-id="${jobId}"]`));
  if (oldRows.length === 0) return null;
  const firstOld = oldRows[0];

  const wrapper = document.createElement('tbody');
  wrapper.innerHTML = html.trim();
  const newRows = Array.from(wrapper.querySelectorAll('tr'));
  if (newRows.length === 0) return null;

  // Preserve non-editable info cells from the head row until the first editable cell
  const oldTds = Array.from(firstOld.children);
  const newTds = Array.from(newRows[0].children);
  const editableStart = newTds.findIndex((td) => td.classList && td.classList.contains('editable'));
  const keepCount = editableStart > 0 ? editableStart : 0;
  for (let i = 0; i < keepCount && i < oldTds.length && i < newTds.length; i++) {
    newTds[i].replaceWith(oldTds[i].cloneNode(true));
  }

  // Insert new rows before the first old row
  newRows.forEach((nr) => {
    tbody.insertBefore(nr, firstOld);
    if (typeof opts.formatRow === 'function') opts.formatRow(nr);
  });

  // Remove old rows
  oldRows.forEach((r) => r.remove());

  if (typeof opts.afterReplace === 'function') opts.afterReplace();

  return newRows;
}
