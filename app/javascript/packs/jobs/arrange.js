
function drawRectanglesOnCanvas(
    canvasId, canvasWidthMm, canvasHeightMm,
    rectWidthMm, rectHeightMm, cols, rows,
    baseHorizontalGapMm, baseVerticalGapMm,
    centerHorizontalGapMm, centerVerticalGapMm,
    evenPositionHorizontalGapMm, evenPositionVerticalGapMm,
    fixedPaddingBottomMm
) {
    const canvas = document.getElementById(canvasId);
    const totalSizeInfoDiv = document.getElementById('total-size-info'); // 合計サイズ表示用

    if (!canvas) {
        console.error(`Canvas element with ID '${canvasId}' not found.`);
        return;
    }

    // Canvasの論理的な描画サイズは入力値そのままに設定 (ミリメートル単位をそのままピクセルとして扱う)
    canvas.width = canvasWidthMm;
    canvas.height = canvasHeightMm;
    const ctx = canvas.getContext('2d');

    // Canvasをクリア
    ctx.clearRect(0, 0, canvasWidthMm, canvasHeightMm);

    let currentX = 0;
    let currentY = 0;

    const xPositions = [];
    const yPositions = [];

    const actualHorizontalGapsMm = [];
    const actualVerticalGapsMm = [];

    // 横方向の四角の位置と実際のアキを計算
    for (let c = 0; c < cols; c++) {
        xPositions.push(currentX);
        currentX += rectWidthMm;
        if (c < cols - 1) { // 最後の列の右にはアキを追加しない
            let currentGap = baseHorizontalGapMm;

            // グリッド全体の中心のアキを優先的に適用
            if (cols % 2 === 0 && c === (cols / 2) - 1) {
                currentGap = centerHorizontalGapMm;
            }
            // 列数が5以上の場合のみ、偶数位置のアキを適用
            else if (cols >= 5 && (c + 1) % 2 === 0 && !(cols % 2 === 0 && c === (cols / 2) - 1)) {
                currentGap = evenPositionHorizontalGapMm;
            }

            actualHorizontalGapsMm.push(currentGap);
            currentX += currentGap;
        }
    }

    // 縦方向の四角の位置と実際のアキを計算
    for (let r = 0; r < rows; r++) {
        yPositions.push(currentY);
        currentY += rectHeightMm;
        if (r < rows - 1) { // 最後の行の下にはアキを追加しない
            let currentGap = baseVerticalGapMm;

            // グリッド全体の中心のアキを優先
            if (rows % 2 === 0 && r === (rows / 2) - 1) {
                currentGap = centerVerticalGapMm;
            }
            // 行数が5以上の場合のみ、偶数位置のアキを適用
            else if (rows >= 5 && (r + 1) % 2 === 0 && !(rows % 2 === 0 && r === (rows / 2) - 1)) {
                currentGap = evenPositionVerticalGapMm;
            }

            actualVerticalGapsMm.push(currentGap);
            currentY += currentGap;
        }
    }

    const totalGridWidthMm = currentX;
    const totalGridHeightMm = currentY;

    // --- グリッドの配置オフセット計算 ---
    // 横方向は中央揃え
    const offsetX = (canvasWidthMm - totalGridWidthMm) / 2;

    // 縦方向はクワエを基準に計算
    let offsetY;

    // エラー判定はCanvasの論理サイズとグリッド全体のサイズで行われるため正確
    // クワエを含めた合計高さが外枠の高さを超える場合
    if (totalGridHeightMm + fixedPaddingBottomMm > canvasHeightMm) {
        offsetY = 0; // 最も上から描画を開始（クワエが無視される可能性あり）
    } else {
        offsetY = canvasHeightMm - totalGridHeightMm - fixedPaddingBottomMm;
    }

    // --- 四角の描画 ---
    for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
            const x = offsetX + xPositions[c];
            const y = offsetY + yPositions[r];

            if ((r + c) % 2 === 0) {
                ctx.fillStyle = '#ADD8E6';
            } else {
                ctx.fillStyle = '#90EE90';
            }

            ctx.fillRect(x, y, rectWidthMm, rectHeightMm);

            ctx.strokeStyle = 'black';
            ctx.lineWidth = 1;
            ctx.strokeRect(x, y, rectWidthMm, rectHeightMm);
        }
    }

    // --- アキ情報の表示 (単位表記はmm) ---
    ctx.fillStyle = 'blue';
    ctx.font = '18px Arial';
    ctx.textAlign = 'center';

    // 1. グリッド全体と外枠との間の余白 (パディング)
    const paddingLeftMm = offsetX;
    const paddingRightMm = canvasWidthMm - (offsetX + totalGridWidthMm);
    const paddingTopActualMm = offsetY; // 実際のグリッド上端までの距離
    const paddingBottomActualMm = canvasHeightMm - (offsetY + totalGridHeightMm); // 実際のグリッド下端までの距離

    // 表示位置はCanvasの論理サイズに合わせる
    ctx.fillText(`${paddingLeftMm.toFixed(1)}mm`, paddingLeftMm / 2 + 10, canvasHeightMm / 2);
    ctx.fillText(`${paddingRightMm.toFixed(1)}mm`, canvasWidthMm - paddingRightMm / 2 - 10, canvasHeightMm / 2);
    ctx.fillText(`${paddingTopActualMm.toFixed(1)}mm`, canvasWidthMm / 2, paddingTopActualMm / 2 + 10);
    ctx.fillText(`クワエ: ${paddingBottomActualMm.toFixed(1)}mm`, canvasWidthMm / 2, canvasHeightMm - paddingBottomActualMm / 2 + 10);

    // 2. 各四角間の実際のアキの値
    ctx.fillStyle = 'black';
    ctx.font = '12px Arial';
    ctx.textAlign = 'center';

    // 横方向のアキを表示
    for (let i = 0; i < actualHorizontalGapsMm.length; i++) {
        const gapValMm = actualHorizontalGapsMm[i];
        let textX = offsetX + xPositions[i] + rectWidthMm + (gapValMm / 2);
        let textY = offsetY + (totalGridHeightMm / 2); // グリッドの中央高さに表示
        // テキストが余白表示と重ならないように調整
        if (textY < paddingTopActualMm + 20 || textY > canvasHeightMm - paddingBottomActualMm - 20) {
            textY = offsetY + rectHeightMm / 2; // 上の四角の真ん中あたりに移動
        }
        ctx.fillText(`${gapValMm.toFixed(1)}mm`, textX, textY);
    }

    // 縦方向のアキを表示
    for (let i = 0; i < actualVerticalGapsMm.length; i++) {
        const gapValMm = actualVerticalGapsMm[i];
        let textX = offsetX + (totalGridWidthMm / 2); // グリッドの中央幅に表示
        let textY = offsetY + yPositions[i] + rectHeightMm + (gapValMm / 2) + 5; // テキストが四角に重ならないように少しオフセット
        // テキストが余白表示と重ならないように調整
        if (textX < paddingLeftMm + 20 || textX > canvasWidthMm - paddingRightMm - 20) {
            textX = offsetX + rectWidthMm / 2; // 左の四角の真ん中あたりに移動
        }
        ctx.fillText(`${gapValMm.toFixed(1)}mm`, textX, textY);
    }

    // 四角群の合計サイズを表示とサイズ超過判定
    let overflowMessage = "";
    const isWidthOverflow = totalGridWidthMm > canvasWidthMm;
    const isHeightOverflow = (totalGridHeightMm + fixedPaddingBottomMm) > canvasHeightMm;

    if (isWidthOverflow || isHeightOverflow) {
        overflowMessage = `<span class="overflow-message">サイズ超過</span>`;
    }
    totalSizeInfoDiv.innerHTML = `合計サイズ: ${totalGridWidthMm.toFixed(1)}mm (幅) x ${totalGridHeightMm.toFixed(1)}mm (高さ) ${overflowMessage}`;
}

// フォーム要素とボタンを取得
const canvasWidthInput = document.getElementById('canvasWidth');
const canvasHeightInput = document.getElementById('canvasHeight');
const rectWidthInput = document.getElementById('rectWidth');
const rectHeightInput = document.getElementById('rectHeight');
const colsInput = document.getElementById('cols');
const rowsInput = document.getElementById('rows');
const baseHorizontalGapInput = document.getElementById('baseHorizontalGap');
const baseVerticalGapInput = document.getElementById('baseVerticalGap');
const centerHorizontalGapInput = document.getElementById('centerHorizontalGap');
const centerVerticalGapInput = document.getElementById('centerVerticalGap');
const evenPositionHorizontalGapInput = document.getElementById('centerPreHorizontalGap');
const evenPositionVerticalGapInput = document.getElementById('centerPreVerticalGap');
const fixedPaddingBottomInput = document.getElementById('fixedPaddingBottom');
const drawButton = document.getElementById('drawButton');
const myCanvas = document.getElementById('myCanvas');
const totalSizeInfoDiv = document.getElementById('total-size-info'); // Canvasの下の合計サイズ表示エリア

// 偶数アキ設定のラッパー要素を取得
const evenGapSettingsDivs = document.querySelectorAll('.even-gap-settings');

// 偶数アキ設定の表示/非表示を制御する関数
function toggleEvenGapSettings() {
    const cols = parseInt(colsInput.value);
    const rows = parseInt(rowsInput.value);

    // 列数または行数が5以上の場合は表示、それ以外は非表示
    const isVisible = cols >= 5 || rows >= 5;

    // .even-gap-settingsはdisplay:contentsなので、個々の子要素にhiddenクラスを適用
    evenGapSettingsDivs.forEach(div => {
        const children = Array.from(div.children);
        children.forEach(child => {
            if (isVisible) {
                child.classList.remove('hidden');
            } else {
                child.classList.add('hidden');
            }
        });
    });
}



// 描画処理を実行する共通関数
function executeDraw() {
    // 入力値は元のmm単位のまま取得
    const canvasW = parseInt(canvasWidthInput.value);
    const canvasH = parseInt(canvasHeightInput.value);
    const rectW = parseInt(rectWidthInput.value);
    const rectH = parseInt(rectHeightInput.value);
    const numCols = parseInt(colsInput.value);
    const numRows = parseInt(rowsInput.value);
    const baseHorGap = parseInt(baseHorizontalGapInput.value);
    const baseVerGap = parseInt(baseVerticalGapInput.value);
    const centerHorGap = parseInt(centerHorizontalGapInput.value);
    const centerVerGap = parseInt(centerVerticalGapInput.value);

    const evenPosHorGap = parseInt(evenPositionHorizontalGapInput.value);
    const evenPosVerGap = parseInt(evenPositionVerticalGapInput.value);

    const fixedPadBottom = parseInt(fixedPaddingBottomInput.value);

    // Canvasの論理サイズのみ設定。見た目はCSSで制御
    myCanvas.width = canvasW;
    myCanvas.height = canvasH;

    drawRectanglesOnCanvas(
        'myCanvas',
        canvasW,
        canvasH,
        rectW,
        rectH,
        numCols,
        numRows,
        baseHorGap,
        baseVerGap,
        centerHorGap,
        centerVerGap,
        evenPosHorGap,
        evenPosVerGap,
        fixedPadBottom
    );
}

// 初期描画（ページのロード時）
document.addEventListener('DOMContentLoaded', () => {
    toggleEvenGapSettings();
    executeDraw();
});

// 列数と行数の入力値が変更されたときに偶数アキ設定の表示を更新
colsInput.addEventListener('input', toggleEvenGapSettings);
rowsInput.addEventListener('input', toggleEvenGapSettings);

// 描画ボタンがクリックされた時の処理
drawButton.addEventListener('click', gridUpdate);

// Enterキーでも描画できるようにする (オプション)
document.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') {
        executeDraw();
    }
});
executeDraw();
// 全ての入力値が変更された際に描画を更新
canvasWidthInput.addEventListener('input', executeDraw);
canvasHeightInput.addEventListener('input', executeDraw);
rectWidthInput.addEventListener('input', executeDraw);
rectHeightInput.addEventListener('input', executeDraw);
baseHorizontalGapInput.addEventListener('input', executeDraw);
baseVerticalGapInput.addEventListener('input', executeDraw);
centerHorizontalGapInput.addEventListener('input', executeDraw);
centerVerticalGapInput.addEventListener('input', executeDraw);
evenPositionHorizontalGapInput.addEventListener('input', executeDraw);
evenPositionVerticalGapInput.addEventListener('input', executeDraw);
fixedPaddingBottomInput.addEventListener('input', executeDraw);
colsInput.addEventListener('input', executeDraw);
rowsInput.addEventListener('input', executeDraw);

function gridUpdate(){
    executeDraw();
    let id = $("#job_job_id").val();
    const canvasW = parseInt(document.getElementById('canvasWidth').value);
    const canvasH = parseInt(document.getElementById('canvasHeight').value);
    const rectW = parseInt(document.getElementById('rectWidth').value);
    const rectH = parseInt(document.getElementById('rectHeight').value);
    const numCols = parseInt(document.getElementById('cols').value);
    const numRows = parseInt(document.getElementById('rows').value);
    const baseHorGap = parseInt(document.getElementById('baseHorizontalGap').value);
    const baseVerGap = parseInt(document.getElementById('baseVerticalGap').value);
    const centerHorGap = parseInt(document.getElementById('centerHorizontalGap').value);
    const centerVerGap = parseInt(document.getElementById('centerVerticalGap').value);

    const evenPosHorGap = parseInt(document.getElementById('centerPreHorizontalGap').value);
    const evenPosVerGap = parseInt(document.getElementById('centerPreVerticalGap').value);
    const fixedPadBottom = parseInt(document.getElementById('fixedPaddingBottom').value);

    $.ajax({
        url:  "jobs/" + id +"/arrange_update",
        type: "GET",
        data: {job: id,
            grid_setting: {
                canvas_width: canvasW,
                canvas_height: canvasH,
                rect_width: rectW,
                rect_height: rectH,
                cols: numCols,
                rows: numRows,
                base_horizontal_gap: baseHorGap,
                base_vertical_gap: baseVerGap,
                center_horizontal_gap: centerHorGap,
                center_vertical_gap: centerVerGap,
                even_position_horizontal_gap: evenPosHorGap,
                even_position_vertical_gap: evenPosVerGap,
                fixed_padding_bottom: fixedPadBottom,
                job_id: id
            }
},
        dataType: "html",
        success: function(data) {
            let $modal = $('#modal');
            let $mask = $('#mask');
            const myId = id; // IDの文字列を変数に格納
            $(`#${myId}`).addClass('target'); // テンプレートリテラルでIDセレクタを構築
            $modal.html(data);
            $modal.removeClass('hidden');
            $mask.removeClass('hidden');
            console.log(id);
            $mask.click(function() {
                $modal.addClass('hidden');
                $mask.addClass('hidden');
                $(`#${myId}`).removeClass('target');
            });
        },
        error: function(data) {
            console.log("error");
        }
    });
}