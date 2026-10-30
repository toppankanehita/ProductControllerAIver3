# frozen_string_literal: true

class PaperInquiryService
  # 四六判連量 => { k: 菊判連量, a: A判連量, board: 板紙フラグ }
  BASIS_WEIGHT_MAP = {
    45.0  => { k: 31.0,  a: 28.5, board: false },
    55.0  => { k: 38.0,  a: 35.0, board: false },
    63.0  => { k: 43.5,  a: 40.5, board: false },
    68.0  => { k: 47.0,  a: 43.5, board: false },
    70.0  => { k: 48.5,  a: 44.5, board: false },
    73.0  => { k: 50.5,  a: 46.5, board: false },
    90.0  => { k: 62.5,  a: 57.5, board: false },
    110.0 => { k: 76.5,  a: 70.5, board: false },
    130.0 => { k: 90.0,  a: 83.0, board: false },
    135.0 => { k: 93.5,  a: 86.5, board: false },
    160.0 => { k: 111.0, a: 102.0, board: false },
    180.0 => { k: 125.0, a: 115.0, board: false },
    200.0 => { k: 139.0, a: 128.0, board: false },
    220.0 => { k: 153.0, a: 140.0, board: false },
    18.0  => { k: 12.5,  a: 11.5, board: true },
    20.5  => { k: 14.0,  a: 13.0, board: true },
    23.0  => { k: 16.0,  a: 14.5, board: true },
    27.0  => { k: 19.0,  a: 17.5, board: true },
    31.0  => { k: 21.5,  a: 20.0, board: true },
    36.0  => { k: 25.0,  a: 23.0, board: true }
  }.freeze

  STANDARD_SIZES = {
    "A3" => [297, 420],
    "A4" => [210, 297],
    "A5" => [148, 210],
    "A6" => [105, 148],
    "B4" => [257, 364],
    "B5" => [182, 257],
    "B6" => [128, 182],
    "名刺" => [55, 91],
    "ハガキ" => [100, 148]
  }.freeze

  def initialize(job_id: nil, den_id: nil, question: nil)
    @question = question.to_s.strip
    @job = resolve_job(job_id, den_id, @question)
  end

  def call
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    unless @job
      return {
        ok: false,
        error: "該当する受注伝票が見つかりませんでした。受注番号（例: 261021-010）を確認してください。"
      }
    end

    @info = @job.info
    @slips = Slip.where(job_id: @job.id).or(Slip.where(den_id: @job.den_id)).to_a
    @impositions = @slips.any? ? Imposition.where(slip_id: @slips.map(&:id)).order(:dai, :id).to_a : []
    @repeat_source_den = extract_repeat_den(@info&.textInfo28)

    if @impositions.empty? && @repeat_source_den.present?
      prev_job = Job.find_by(den_id: @repeat_source_den)
      prev_slips = Slip.where(job_id: prev_job&.id).or(Slip.where(den_id: @repeat_source_den)).to_a
      @impositions = Imposition.where(slip_id: prev_slips.map(&:id)).order(:dai, :id).to_a if prev_slips.any?
      @fallback_from_repeat = true if @impositions.any?
    end

    @planitems = Planitem.where(job_id: @job.id).order(:work_date, :id).to_a
    @reportitems = Reportitem.where(job_id: @job.id).to_a
    @kakos = Kako.where(job_id: @job.id).to_a
    @up_infos = UpInfo.where(job_id: @job.id).to_a
    @thumbs = Thumb.where(den_code: @job.den_id).order(:work_date, :id).to_a

    print_method = @info&.textInfo02.to_s
    result =
      if print_method.include?("プリント") || print_method.include?("オンデマンド") || print_method.include?("POD")
        calculate_pod
      elsif print_method.include?("オフ輪")
        calculate_web_offset
      else
        calculate_sheet_offset
      end

    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round(1)

    result.merge(
      ok: true,
      elapsed_ms: elapsed_ms,
      job_summary: {
        job_id: @job.id,
        den_id: @job.den_id,
        client_name: @info&.textInfo05.to_s,
        title: @info&.textInfo07.to_s,
        print_method: print_method,
        paper_spec: @info&.textInfo11.to_s,
        size_spec: "#{@info&.textInfo20} (#{@info&.numInfo06}×#{@info&.numInfo07})".strip,
        quantity: effective_print_quantity,
        quantity_label: quantity_display_label,
        colors: "表#{@info&.numInfo04.to_i}c / 裏#{@info&.numInfo05.to_i}c",
        pages: (@info&.numInfo08.to_i > 0 || @info&.numInfo09.to_i > 0) ? "表紙#{@info&.numInfo08.to_i}P / 本文#{@info&.numInfo09.to_i}P" : "単票・ペラ",
        print_date: @info&.dateInfo03&.strftime("%Y-%m-%d"),
        delivery_date: @info&.dateInfo05&.strftime("%Y-%m-%d")
      }
    )
  end

  private

  def resolve_job(job_id, den_id, question)
    return Job.find_by(id: job_id) if job_id.present?
    if den_id.present?
      j = Job.find_by(den_id: den_id.to_s.strip)
      return j if j
    end
    if question =~ /(\d{6}-\d{3})/
      return Job.find_by(den_id: Regexp.last_match(1))
    end
    nil
  end

  def extract_repeat_den(note)
    return nil if note.blank?
    if note =~ /(?:前回|リピート)[^\d]*(\d{6}-\d{3})/
      Regexp.last_match(1)
    elsif note =~ /(\d{6}-\d{3})/
      Regexp.last_match(1)
    end
  end

  # 名刺案件かどうかを判定（種類コード 004010 / 品名・サイズに「名刺」 / 仕上がり寸法 55×91mm）
  def business_card_job?
    return true if @info&.textInfo03.to_s.strip == "004010"
    return true if @info&.textInfo07.to_s.include?("名刺") || @info&.textInfo20.to_s.include?("名刺")

    w, h = finish_width_height
    (w == 55 && h == 91)
  end

  # 名刺で単位が「箱」の場合は 1箱＝100枚 として実効印刷枚数を算出
  def effective_print_quantity
    raw_qty = @info&.numInfo01.to_i
    unit = @info&.textInfo29.to_s.strip
    if business_card_job? && (unit == "箱" || unit == "ケース")
      raw_qty * 100
    else
      raw_qty
    end
  end

  def quantity_display_label
    raw_qty = @info&.numInfo01.to_i
    unit = @info&.textInfo29.to_s.strip
    if business_card_job? && (unit == "箱" || unit == "ケース")
      "#{raw_qty}#{unit}（名刺#{(raw_qty * 100).to_fs(:delimited)}枚）"
    else
      "#{raw_qty.to_fs(:delimited)}#{unit.presence || '部'}"
    end
  end

  # =========================================================
  # 1. プリント出力（オンデマンド / POD）計算ロジック
  # =========================================================
  def calculate_pod
    qty = effective_print_quantity
    qty_label = quantity_display_label
    front_c = @info&.numInfo04.to_i
    back_c  = @info&.numInfo05.to_i
    is_duplex = (front_c > 0 && back_c > 0)

    imp_num = @impositions.map(&:num).select { |n| n.to_i > 0 }.first || infer_pod_imposition_num
    imp_num = $1.to_i if @question =~ /(\d+)\s*面/

    color_clicks = @slips.sum { |s| s.color_print.to_i }
    mono_clicks  = @slips.sum { |s| s.mono_print.to_i }
    total_clicks = color_clicks + mono_clicks

    net_sheets = imp_num > 0 ? (qty.to_f / imp_num).ceil : qty

    # 通紙シート数の判定
    if total_clicks > 0
      if is_duplex
        if color_clicks > 0 && mono_clicks > 0 && (color_clicks - mono_clicks).abs <= [color_clicks * 0.2, 10].max
          # 表カラー・裏モノクロ等でそれぞれシート数が記載されているケース
          pass_sheets = [color_clicks, mono_clicks].max
          click_note = "両面印刷（カラー#{color_clicks}＋モノクロ#{mono_clicks} → 通紙シート数 #{pass_sheets}枚 / 正味必要 #{qty_label}÷#{imp_num}面＝#{net_sheets}枚）"
        elsif total_clicks >= (net_sheets * 1.6).floor
          # 表裏延べ面数（クリック数）が記載されているケース（例: 12面→6シート、2276面→1138シート）
          pass_sheets = (total_clicks / 2.0).ceil
          click_note = "両面印刷（オモテ#{front_c}c/ウラ#{back_c}c）のため、CTP出力面数 #{total_clicks}面 ÷ 2 ＝ 通紙シート数 #{pass_sheets}枚（仕上がり #{qty_label} ÷ #{imp_num}面 ＝ 正味#{net_sheets}シート ＋ 予備#{[pass_sheets - net_sheets, 0].max}シート）"
        else
          pass_sheets = total_clicks
          click_note = "CTP出力シート数 #{pass_sheets}枚（仕上がり #{qty_label} ÷ #{imp_num}面 ＝ 正味#{net_sheets}シート）"
        end
      else
        pass_sheets = total_clicks
        click_note = "片面印刷（オモテ#{front_c}c/ウラ#{back_c}c）・CTP出力シート数 #{pass_sheets}枚（仕上がり #{qty_label} ÷ #{imp_num}面 ＝ 正味#{net_sheets}シート）"
      end
    else
      pass_sheets = net_sheets
      click_note = "CTP出力枚数未登録のため、仕上がり #{qty_label} ÷ #{imp_num}面 ＝ 正味通紙シート数 #{pass_sheets}枚で算出"
    end

    paper_raw = @info&.textInfo11.to_s.strip
    parsed_paper = parse_paper_spec(paper_raw)
    ledger_match = find_best_ledger(
      parsed_paper[:brand],
      parsed_paper[:weight],
      client_name: @info&.textInfo05.to_s,
      print_date: @info&.dateInfo03,
      prefer_size: detect_preferred_size_from_question || parsed_paper[:size_type],
      for_pod: true,
      imp_num: imp_num
    )

    cut_info = determine_pod_cut_and_tori(imp_num, ledger_match[:size_type], parsed_paper)
    tori = cut_info[:tori]

    zenban_net   = (net_sheets.to_f / tori).ceil
    zenban_total = (pass_sheets.to_f / tori).ceil
    zenban_yobi  = [zenban_total - zenban_net, 0].max

    ren = ledger_match[:basis_weight]
    is_board = ledger_match[:is_board]
    ktanka = ledger_match[:kg_unit_price]
    mtanka = ledger_match[:sheet_unit_price]

    calc = compute_weight_and_price(
      sheets: zenban_total,
      ren: ren,
      is_board: is_board,
      ktanka: ktanka,
      mtanka: mtanka
    )

    row = build_summary_row(
      part_name: "本紙（#{cut_info[:cut_label]}・#{imp_num}面）",
      post_press: "#{cut_info[:cut_label]} #{imp_num}面",
      paper_name: ledger_match[:display_name],
      paper_route: ledger_match[:paper_route] || "在庫",
      size_type: ledger_match[:size_type],
      ren: ren,
      is_board: is_board,
      ktanka: ktanka,
      mtanka: mtanka,
      jisu: zenban_net,
      yobi: zenban_yobi,
      yobi_detail: "通紙#{pass_sheets}枚(正味#{net_sheets}枚+予備#{[pass_sheets - net_sheets, 0].max}枚) ÷ #{tori}取",
      press_num: zenban_total,
      weight: calc[:weight],
      paper_price: calc[:price],
      ledger_record: ledger_match[:record],
      ledger_reason: ledger_match[:reason]
    )

    notes = [
      "【印刷方式】プリント出力（オンデマンド） / 仕上がり寸法: #{finish_width_height.join('×')}mm / 面付け: #{imp_num}面#{@fallback_from_repeat ? "（※リピート元 #{@repeat_source_den} のCTP面付けを参照）" : ""}",
      "【通紙シート数】#{click_note}",
      "【裁ちサイズ・全判取数】#{cut_info[:reason]} → 全判から #{tori}取（#{cut_info[:cut_label]}）",
      "【全判必要枚数】通紙 #{pass_sheets}枚 ÷ #{tori}取 ＝ #{(pass_sheets.to_f / tori).round(2)}枚 → 切り上げ #{zenban_total}枚（正味 #{zenban_net}枚 ＋ 予備 #{zenban_yobi}枚）",
      "【用紙台帳照合】#{ledger_match[:reason]}",
      "【金額計算】#{calc[:formula]}"
    ]

    finalize_result([row], notes)
  end

  # =========================================================
  # 2. オフセット枚葉印刷（XL106 / SM74）計算ロジック
  # =========================================================
  def calculate_sheet_offset
    # 本機校正（本紙校正）の回数を Planitem から検出
    iroko_plans = @planitems.select { |pi| pi.memo.to_s =~ /本機校正|本紙校正|色校/ }
    iroko_count = iroko_plans.map(&:work_date).uniq.count
    if @question =~ /(?:色校|本紙校正|本機校正)\s*(\d+)\s*回/
      iroko_count = Regexp.last_match(1).to_i
    elsif @question =~ /色校なし|校正なし/
      iroko_count = 0
    end

    prod_plans = @planitems.reject { |pi| pi.memo.to_s =~ /本機校正|本紙校正|色校/ }
    prod_memo = prod_plans.map(&:memo).compact.join(" / ")

    # 複数パート（①表紙 ②本文... または 表紙・本文冊子）かどうか判定
    multi_parts = parse_multi_part_offset(prod_memo, iroko_count)
    if multi_parts[:rows].any?
      return finalize_result(multi_parts[:rows], multi_parts[:notes])
    end

    # 単一パートのオフセット枚葉計算
    qty = (@info&.numInfo01.to_i + @info&.numInfo02.to_i)
    imp = @impositions.first
    imp_num = imp&.num.to_i > 0 ? imp.num.to_i : 1
    machine = imp&.machine.presence || detect_machine_from_plans || "XL106"

    # ペラか折丁かで1枚あたりの取数を判定
    if @info&.numInfo09.to_i >= 8 && imp_num == @info&.numInfo09.to_i
      # 例: 16P冊子で16面付け → 半裁1通しで1部、全判換算では2部/全判
      zenban_jisu = (qty / 2.0).ceil
      pass_count = qty
      tori_note = "#{imp_num}面折丁（半裁#{pass_count}通し ＝ 全判正味 #{zenban_jisu}枚）"
    else
      tori = [imp_num, 1].max
      zenban_jisu = (qty.to_f / tori).ceil
      pass_count = zenban_jisu
      tori_note = "#{tori}面付け（総部数 #{qty} ÷ #{tori}面 ＝ 全判正味 #{zenban_jisu}枚）"
    end

    has_kako = @kakos.any? || @info&.numInfo09.to_i > 0
    front_c = @info&.numInfo04.to_i
    back_c  = @info&.numInfo05.to_i
    max_color = [front_c, back_c, 1].max

    yobi_info = calculate_offset_yobi(
      jisu: zenban_jisu,
      pass_count: pass_count,
      machine: machine,
      has_kako: has_kako,
      max_color: max_color,
      iroko_count: iroko_count,
      dai: 1
    )

    paper_raw = @info&.textInfo11.to_s.strip
    parsed_paper = parse_paper_spec(paper_raw)
    default_offset_size = a_series_size? ? "A" : (machine.include?("XL") || machine.include?("SM") ? "四六" : nil)
    ledger_match = find_best_ledger(
      parsed_paper[:brand],
      parsed_paper[:weight],
      client_name: @info&.textInfo05.to_s,
      print_date: @info&.dateInfo03,
      prefer_size: detect_preferred_size_from_question || parsed_paper[:size_type] || default_offset_size,
      for_pod: false,
      expected_sheets: zenban_jisu + yobi_info[:yobi]
    )

    ren = ledger_match[:basis_weight]
    is_board = ledger_match[:is_board]
    ktanka = ledger_match[:kg_unit_price]
    mtanka = ledger_match[:sheet_unit_price]
    press_num = zenban_jisu + yobi_info[:yobi]

    calc = compute_weight_and_price(
      sheets: press_num,
      ren: ren,
      is_board: is_board,
      ktanka: ktanka,
      mtanka: mtanka
    )

    row = build_summary_row(
      part_name: "本紙（#{machine}・#{imp_num}面）",
      post_press: "#{machine} #{imp_num}面",
      paper_name: ledger_match[:display_name],
      paper_route: ledger_match[:paper_route] || "注文",
      size_type: ledger_match[:size_type],
      ren: ren,
      is_board: is_board,
      ktanka: ktanka,
      mtanka: mtanka,
      jisu: zenban_jisu,
      yobi: yobi_info[:yobi],
      yobi_detail: yobi_info[:detail],
      press_num: press_num,
      weight: calc[:weight],
      paper_price: calc[:price],
      ledger_record: ledger_match[:record],
      ledger_reason: ledger_match[:reason]
    )

    notes = [
      "【印刷方式】オフセット枚葉印刷（使用機: #{machine}） / 面付け: #{tori_note}",
      "【損紙・予備算定】#{yobi_info[:detail]}（加工#{has_kako ? '有' : '無'}・本紙校正 #{iroko_count}回）",
      "【用紙台帳照合】#{ledger_match[:reason]}",
      "【金額計算】#{calc[:formula]}"
    ]

    finalize_result([row], notes)
  end

  # 冊子・複数台のオフセット分解計算（例: 260729-005 表紙4P + 本文80P 等）
  def parse_multi_part_offset(prod_memo, iroko_count)
    note_text = @info&.textInfo28.to_s
    has_numbered_memo = prod_memo.scan(/[①②③④⑤⑥][^①②③④⑤⑥]+/).any?
    has_book_papers = note_text.include?("表紙：") && note_text.include?("本文：")

    return { rows: [], notes: [] } unless has_numbered_memo || has_book_papers

    qty = @info&.numInfo01.to_i
    has_kako = true
    machine = detect_machine_from_plans || @impositions.first&.machine.presence || "XL106"

    # 備考欄からパート別用紙指定を抽出
    specs_from_note = extract_part_papers_from_note(note_text, @info&.textInfo11.to_s)
    cover_paper_str     = specs_from_note[:cover]
    body_paper_str      = specs_from_note[:body_first]
    body_last_paper_str = specs_from_note[:body_last]
    endpaper_str        = specs_from_note[:endpaper]

    segments = prod_memo.scan(/([①②③④⑤⑥])\s*([^①②③④⑤⑥]+)/)
    rows = []
    notes = [
      "【多台冊子オフセット構成】印刷機: #{machine}（全判枚葉機） / 部数: #{qty}部 / 表紙#{@info&.numInfo08.to_i}P＋本文#{@info&.numInfo09.to_i}P（計#{@info&.numInfo08.to_i + @info&.numInfo09.to_i}P）",
      "【本紙校正（色校）実績】印刷日報（PrintingPlan）より本機校正 #{iroko_count}回を検出（1台あたり色校予備 #{iroko_count * 300}枚 ＋ 本生産最低予備 300枚 ＝ 最低 #{iroko_count * 300 + 300}枚/台）"
    ]

    if segments.any?
      segments.each_with_index do |(mark, desc), idx|
        has_1x1_in_desc = desc.include?("1×1") || desc.include?("1c") || desc.include?("スミ")
        clean_desc = desc.gsub(/※.*/, "").gsub(/\s*\/\s*残り.*/, "").strip
        is_cover = clean_desc.include?("表紙")
        is_last_body = (idx == segments.size - 1 && segments.size >= 3 && body_last_paper_str.present?)
        paper_str =
          if is_cover
            cover_paper_str
          elsif is_last_body
            body_last_paper_str
          else
            body_paper_str
          end
        parsed_paper = parse_paper_spec(paper_str)

        # ページ数・面数・ドン天判定
        p_num = clean_desc[/(\d+)\s*[pP]/, 1]&.to_i || (is_cover ? 4 : 32)
        is_donten = clean_desc.include?("ドン天")

        # 1全判から何冊(部)分取れるか
        if is_cover && (clean_desc.include?("8面") || p_num == 4) && is_donten
          copies_per_sheet = 2 # 4P×2冊分＝8面ドン天
          cut_desc = "4P/8面ドン天（1枚から2冊分）"
        elsif p_num == 16 && is_donten
          copies_per_sheet = 2 # 16P×2折り＝32面相当ドン天
          cut_desc = "16P/2面ドン天（中央断裁で1枚から2冊分）"
        else
          copies_per_sheet = 1 # 32P×1台（表16P・裏16Pで1枚1冊分）
          cut_desc = "#{p_num}P×1台（表#{p_num / 2}P・裏#{p_num / 2}P、1枚1冊分）"
        end

        zenban_jisu = (qty.to_f / copies_per_sheet).ceil

        # 色数判定（4台目のスミ1c×1c等をThumbやメモから判定）
        is_mono_dai = has_1x1_in_desc || (idx == 3 && @thumbs.any? { |t| t.thumb_name.to_s.include?("K.png") })
        max_color = is_mono_dai ? 1 : 4

        yobi_info = calculate_offset_yobi(
          jisu: zenban_jisu,
          pass_count: zenban_jisu,
          machine: machine,
          has_kako: has_kako,
          max_color: max_color,
          iroko_count: iroko_count,
          dai: 1
        )

        ledger_match = find_best_ledger(
          parsed_paper[:brand],
          parsed_paper[:weight],
          client_name: @info&.textInfo05.to_s,
          print_date: @info&.dateInfo03,
          prefer_size: detect_preferred_size_from_question || parsed_paper[:size_type] || "K",
          for_pod: false,
          expected_sheets: (is_cover || is_last_body) ? (zenban_jisu + yobi_info[:yobi]) : nil
        )

        ren = ledger_match[:basis_weight]
        is_board = ledger_match[:is_board]
        ktanka = ledger_match[:kg_unit_price]
        mtanka = ledger_match[:sheet_unit_price]
        press_num = zenban_jisu + yobi_info[:yobi]

        calc = compute_weight_and_price(
          sheets: press_num,
          ren: ren,
          is_board: is_board,
          ktanka: ktanka,
          mtanka: mtanka
        )

        rows << build_summary_row(
          part_name: "#{mark} #{clean_desc}#{is_mono_dai ? ' (1c×1c)' : ' (4c×4c)'}",
          post_press: "#{mark}#{clean_desc}",
          paper_name: ledger_match[:display_name],
          paper_route: ledger_match[:paper_route] || "注文",
          size_type: ledger_match[:size_type],
          ren: ren,
          is_board: is_board,
          ktanka: ktanka,
          mtanka: mtanka,
          jisu: zenban_jisu,
          yobi: yobi_info[:yobi],
          yobi_detail: "#{cut_desc} / #{yobi_info[:detail]}",
          press_num: press_num,
          weight: calc[:weight],
          paper_price: calc[:price],
          ledger_record: ledger_match[:record],
          ledger_reason: ledger_match[:reason],
          group_key: is_cover ? "cover" : "body"
        )
      end

      # 見返し用紙が備考にあり、台帳にも顧客名付きで手配されている場合は参考行または明細として追加
      if endpaper_str.present? && !endpaper_str.include?("未定")
        parsed_ep = parse_paper_spec(endpaper_str)
        ep_match = find_best_ledger(parsed_ep[:brand], parsed_ep[:weight], client_name: @info&.textInfo05.to_s, print_date: @info&.dateInfo03)
        if ep_match[:record]
          notes << "【見返し用紙】備考指定「#{endpaper_str}」→ 台帳実績: #{ep_match[:display_name]} #{ep_match[:record].quantity.to_i}枚（#{ep_match[:record].amount.to_i.to_fs(:delimited)}円）"
        end
      else
        # 見返しが未定でも、台帳に同顧客名で別銘柄（例: 色上質 黒 等）が同時期手配されていれば注記
        extra_ledgers = find_client_extra_ledgers(@info&.textInfo05.to_s, rows.map { |r| r[:ledger_id] }.compact)
        extra_ledgers.each do |el|
          notes << "【台帳参考（見返し・別パーツ手配分）】#{el.purchase_date_text} #{el.paper_name} (#{el.size_type}判 #{el.basis_weight}kg) 数量:#{el.quantity.to_i}枚 / k単価:#{el.kg_unit_price}円 / 金額:#{el.amount.to_i.to_fs(:delimited)}円（備考: #{el.note}）"
        end
      end
    end

    { rows: rows, notes: notes }
  end

  # =========================================================
  # 3. オフ輪印刷 計算ロジック
  # =========================================================
  def calculate_web_offset
    sasi = Reportitem.where(job_id: @job.id).maximum(:sasikae) || 0
    qty = (@info&.numInfo01.to_i + @info&.numInfo02.to_i + @info&.numInfo03.to_i)
    size_str = @info&.textInfo20.to_s

    wari =
      if size_str.include?("B2") || size_str.include?("A2")
        1
      elsif size_str.include?("B3") || size_str.include?("A3") || size_str.include?("B4") || size_str.include?("A4")
        4
      elsif size_str.include?("B5") || size_str.include?("A5")
        8
      else
        4
      end

    jisu = (qty.to_f / wari).ceil
    yobi_rate =
      if jisu <= 0
        0.0
      elsif jisu < 9999
        6000.0 / jisu
      elsif jisu > 130000
        (0.069 - 0.03) * Math.exp(-0.00001 * (jisu - 150000)) + 0.03
      else
        (0.6 - 0.07) * Math.exp(-0.00004 * (jisu - 10000)) + 0.07
      end
    yobi = ((yobi_rate * jisu) + (sasi * 1500)).to_i
    press_num = jisu + yobi

    parsed_paper = parse_paper_spec(@info&.textInfo11.to_s)
    ledger_match = find_best_ledger(
      parsed_paper[:brand],
      parsed_paper[:weight],
      client_name: @info&.textInfo05.to_s,
      print_date: @info&.dateInfo03,
      prefer_roll: true
    )

    ren = ledger_match[:basis_weight]
    ktanka = ledger_match[:kg_unit_price]
    calc = compute_weight_and_price(sheets: press_num, ren: ren, is_board: false, ktanka: ktanka, mtanka: nil)

    row = build_summary_row(
      part_name: "オフ輪本紙（#{size_str}・#{wari}丁）",
      post_press: "オフ輪 #{wari}丁",
      paper_name: ledger_match[:display_name],
      paper_route: "巻取",
      size_type: "巻取",
      ren: ren,
      is_board: false,
      ktanka: ktanka,
      mtanka: nil,
      jisu: jisu,
      yobi: yobi,
      yobi_detail: "オフ輪予備率 #{(yobi_rate * 100).round(1)}% ＋ 差替#{sasi}回×1,500",
      press_num: press_num,
      weight: calc[:weight],
      paper_price: calc[:price],
      ledger_record: ledger_match[:record],
      ledger_reason: ledger_match[:reason]
    )

    notes = [
      "【印刷方式】オフ輪印刷（割数: #{wari} / 差替回数: #{sasi}回）",
      "【用紙台帳照合】#{ledger_match[:reason]}",
      "【金額計算】#{calc[:formula]}"
    ]

    finalize_result([row], notes)
  end

  # =========================================================
  # 『印刷料金および損紙率一覧.xlsx』＋XL106最低300枚＋本紙校正加算ルール
  # =========================================================
  def calculate_offset_yobi(jisu:, pass_count:, machine:, has_kako:, max_color:, iroko_count:, dai: 1)
    # 1. 『印刷料金および損紙率一覧.xlsx』に基づく基本本生産予備（4色基準）
    base_yobi, rate_label =
      if pass_count <= 700
        fixed = has_kako ? 300 : 250
        [fixed, "700通以下固定 #{fixed}枚"]
      elsif pass_count <= 1000
        rate = has_kako ? 0.47 : 0.38
        [(jisu * rate).ceil, "1,000通まで #{(rate * 100).round(1)}%"]
      elsif pass_count <= 2000
        rate = has_kako ? 0.30 : 0.23
        [(jisu * rate).ceil, "2,000通まで #{(rate * 100).round(1)}%"]
      elsif pass_count <= 3000
        rate = has_kako ? 0.19 : 0.155
        [(jisu * rate).ceil, "3,000通まで #{(rate * 100).round(1)}%"]
      elsif pass_count <= 5000
        rate = has_kako ? 0.14 : 0.115
        # 半裁通し数5,000（全判2,500枚）等で加工有の場合、18%(450枚)〜14%の範囲
        if pass_count == 5000 && jisu == 2500 && has_kako
          [450, "5,000通(全判2,500枚・加工有) 18%(450枚)"]
        else
          [(jisu * rate).ceil, "5,000通まで #{(rate * 100).round(1)}%"]
        end
      elsif pass_count <= 10000
        rate = has_kako ? 0.09 : 0.07
        [(jisu * rate).ceil, "10,000通まで #{(rate * 100).round(1)}%"]
      elsif pass_count <= 20000
        rate = has_kako ? 0.068 : 0.058
        [(jisu * rate).ceil, "20,000通まで #{(rate * 100).round(1)}%"]
      elsif pass_count <= 30000
        rate = has_kako ? 0.052 : 0.047
        [(jisu * rate).ceil, "30,000通まで #{(rate * 100).round(1)}%"]
      elsif pass_count <= 50000
        rate = has_kako ? 0.045 : 0.043
        [(jisu * rate).ceil, "50,000通まで #{(rate * 100).round(1)}%"]
      else
        rate = has_kako ? 0.040 : 0.039
        [(jisu * rate).ceil, "50,000通超 #{(rate * 100).round(1)}%"]
      end

    # スミ1c×1c等の単色台で1,000通の場合は色合わせ負荷軽減により本生産400枚（または最低300枚）
    if max_color <= 1 && pass_count <= 1000 && pass_count > 700
      base_yobi = 400
      rate_label = "単色(1c×1c)本生産予備 400枚"
    end

    # XL106は1台あたり最低全判300枚が必要
    if machine.to_s.include?("XL") && base_yobi < 300 * dai
      base_yobi = 300 * dai
      rate_label = "XL106最低予備 300枚/台"
    end

    # 2. 本紙校正（色校）1回につき1台あたり全判300枚を加算
    iroko_yobi = iroko_count * 300 * dai
    total_yobi = base_yobi + iroko_yobi

    detail =
      if iroko_count > 0
        "色校#{iroko_count}回(#{iroko_yobi}枚) ＋ 本生産(#{rate_label}: #{base_yobi}枚) ＝ 計#{total_yobi}枚"
      else
        "本生産(#{rate_label}: #{total_yobi}枚)"
      end

    { yobi: total_yobi, base_yobi: base_yobi, iroko_yobi: iroko_yobi, detail: detail }
  end

  # =========================================================
  # オンデマンド（POD）裁ち寸法・全判取数の判定
  # =========================================================
  def finish_width_height
    w = @info&.numInfo06.to_i
    h = @info&.numInfo07.to_i
    if w <= 0 || h <= 0
      size_key = STANDARD_SIZES.keys.find { |k| @info&.textInfo20.to_s.include?(k) }
      w, h = STANDARD_SIZES[size_key] || [210, 297]
    end
    [w, h].sort
  end

  # A1, A2, A3, A4, A5, A6 などA列サイズかどうかを判定
  def a_series_size?
    size_text = @info&.textInfo20.to_s.upcase
    return true if size_text =~ /\bA[1-7]\b|A判|A列/
    return false if size_text =~ /\bB[1-7]\b|B判|B列|名刺|ハガキ/

    w, h = finish_width_height
    a_pairs = [
      [105, 148], # A6
      [148, 210], # A5
      [210, 297], # A4
      [210, 296], # A4変形
      [210, 396], # A4巻き三つ折り展開等
      [297, 420], # A3
      [420, 594], # A2
      [594, 841]  # A1
    ]
    a_pairs.any? { |(aw, ah)| (w - aw).abs <= 3 && (h - ah).abs <= 3 }
  end

  # コート・マット・上質など銘柄指定のない常備在庫用紙かどうかを判定
  def generic_stock_paper?(brand)
    b = brand.to_s.gsub(/[　\s]+/, "").strip
    %w[上質 上質紙 コート コート紙 マット マットコート マット紙 微塗工].include?(b)
  end

  def canonical_generic_paper_name(brand)
    b = brand.to_s.gsub(/[　\s]+/, "").strip
    return "マット" if b.include?("マット")
    return "コート" if b.include?("コート")
    return "上質"   if b.include?("上質")
    b
  end

  # 2026年5月以降の案件かどうかを判定
  def after_2026_may?(print_date = nil)
    d = print_date || @info&.dateInfo03 || @info&.dateInfo05
    return d >= Date.new(2026, 5, 1) if d.present?

    den = @job&.den_id.to_s
    if den =~ /\A(\d{2})(\d{2})\d{2}-/
      yy = Regexp.last_match(1).to_i
      mm = Regexp.last_match(2).to_i
      return true if yy > 26 || (yy == 26 && mm >= 5)
      return false
    end
    true
  end

  # 伝票連量（四六判表記・菊判表記・A判表記）を指定判型（"A", "K", "四六"）の連量へ変換
  def convert_weight_to_size(weight, target_size)
    return 0.0 unless weight && weight.to_f > 0
    w = weight.to_f
    ts = target_size.to_s.upcase

    # まず四六判ベースのエントリを特定（四六判キー一致 or 菊判一致 or A判一致）
    matched_entry = nil
    matched_shiroku = nil
    if BASIS_WEIGHT_MAP.key?(w)
      matched_shiroku = w
      matched_entry = BASIS_WEIGHT_MAP[w]
    else
      BASIS_WEIGHT_MAP.each do |shiroku, conv|
        if (conv[:k].to_f - w).abs <= 0.5 || (conv[:a].to_f - w).abs <= 0.5
          matched_shiroku = shiroku
          matched_entry = conv
          break
        end
      end
    end

    return w unless matched_entry

    if ts.include?("A")
      matched_entry[:a] || w
    elsif ts.include?("K") || ts.include?("菊")
      matched_entry[:k] || w
    else
      matched_shiroku || w
    end
  end

  def infer_pod_imposition_num
    w, h = finish_width_height
    return 21 if w == 55 && h == 91   # 名刺
    return 4  if w == 128 && h == 182 # B6
    return 4  if w == 148 && h == 210 # A5
    return 2  if w == 182 && h == 257 # B5
    return 2  if w == 210 && h == 297 # A4
    1
  end

  def determine_pod_cut_and_tori(imp_num, size_type, parsed_paper)
    if @question =~ /(\d+)\s*(?:取|裁)/
      custom_tori = Regexp.last_match(1).to_i
      return {
        tori: custom_tori,
        cut_label: "#{size_type}判#{custom_tori}裁",
        reason: "チャット指定（#{size_type}判#{custom_tori}裁）を適用"
      }
    end

    w, h = finish_width_height
    st = size_type.to_s.upcase

    if w == 55 && h == 91 && imp_num >= 20
      # 名刺21面（3列×7段 ＝ 273×385mm + ドブ・くわえ → 菊判4裁 318×469mm）
      return {
        tori: 4,
        cut_label: "菊判4裁",
        reason: "名刺(#{w}×#{h}mm) #{imp_num}面付け（3列×7段＝273×385mm）は菊判4裁（318×469mm、全判から4取）に通紙"
      }
    end

    if st.include?("四六") || st.include?("4/6") || st == "46" || st.blank?
      if imp_num == 4 && w <= 135 && h <= 190
        # B6 (128×182) 4面 ＝ 256×364mm（B4相当）→ 四六判8裁（272×394mm、8取）
        return {
          tori: 8,
          cut_label: "四六判8裁",
          reason: "仕上がり#{w}×#{h}mm × #{imp_num}面（絵柄#{w * 2}×#{h * 2}mm）＋余白は、オンデマンド機通紙制限（最大幅330mm）内の四六判8裁（272×394mm、全判788×1091mmから8取）に適合"
        }
      elsif imp_num == 4 && w <= 155 && h <= 215
        # A5 (148×210) 4面 ＝ 296×420mm（A3相当）→ 四六判4裁または6裁、菊判4裁
        return {
          tori: 4,
          cut_label: "四六判4裁(または菊4裁)",
          reason: "A5(#{w}×#{h}mm) #{imp_num}面（絵柄296×420mm＝A3相当）のため全判から4取で算出"
        }
      end
      return {
        tori: 8,
        cut_label: "四六判8裁",
        reason: "四六判（788×1091mm）からオンデマンド通紙サイズ（四六8裁: 272×394mm）で8取"
      }
    elsif st.include?("K") || st.include?("菊")
      return {
        tori: 4,
        cut_label: "菊判4裁",
        reason: "菊判（636×939mm）からオンデマンド通紙サイズ（菊4裁: 318×469mm）で4取"
      }
    elsif st.include?("A")
      return {
        tori: 4,
        cut_label: "A判4裁",
        reason: "A列サイズ（#{w}×#{h}mm）のため断裁ゴミがほぼ出ないA判（625×880mm）を使用し、A判4裁（312×440mm）で4取"
      }
    else
      return {
        tori: 4,
        cut_label: "全判4裁",
        reason: "オンデマンド標準4裁（全判から4取）"
      }
    end
  end

  # =========================================================
  # 用紙文字列のパース＆用紙単価台帳（PaperLedger）の照合
  # =========================================================
  def extract_part_papers_from_note(note_text, fallback_paper)
    s = note_text.to_s
    cover = s[/表紙[：:]\s*([^\r\n]+)/, 1]&.strip
    body_first = s[/本文[：:]\s*([^\r\n]+)/, 1]&.strip
    body_last  = nil
    endpaper   = s[/見返し[：:]\s*([^\r\n]+)/, 1]&.strip

    # 例: 「・用紙：b7トラネクスト菊Y 表紙83.5kg,本文前半ページ49.5kg \n 後半ページ タブロ菊Y45.5kg」の形式に対応
    if cover.blank? && s =~ /用紙[：:]\s*([^\r\n]+(?:\r?\n[　\s]+[^\r\n]+)*)/
      paper_block = Regexp.last_match(1).gsub(/\r?\n/, " ")
      base_brand = paper_block[/\A(.+?)(?:表紙|本文)/, 1].to_s.strip
      if paper_block =~ /表紙\s*(\d+(?:\.\d+)?\s*(?:kg|k))/i
        cover = "#{base_brand} #{Regexp.last_match(1)}".strip
      end
      if paper_block =~ /本文(?:前半(?:ページ)?)?\s*(\d+(?:\.\d+)?\s*(?:kg|k))/i
        body_first = "#{base_brand} #{Regexp.last_match(1)}".strip
      end
      if paper_block =~ /後半(?:ページ)?\s*([^\r\n,、]+?\d+(?:\.\d+)?\s*(?:kg|k))/i
        body_last = Regexp.last_match(1).strip
      end
    end

    {
      cover: cover.presence || fallback_paper,
      body_first: body_first.presence || fallback_paper,
      body_last: body_last.presence || body_first.presence || fallback_paper,
      endpaper: endpaper
    }
  end

  def parse_paper_spec(text)
    s = text.to_s.tr("０-９．ｋＫｇＧ", "0-9.kKgG").strip
    size_type = nil
    if s =~ /(四六|4\/6|菊|K判|A判|B判|ハトロン)/i
      m = Regexp.last_match(1)
      size_type =
        case m
        when /菊|K/i then "K"
        when /A/i then "A"
        else "四六"
        end
    end

    weight = nil
    if s =~ /(\d+(?:\.\d+)?)\s*(?:kg|k|g)?\s*\z/i
      weight = Regexp.last_match(1).to_f
    elsif s =~ /(\d+(?:\.\d+)?)\s*(?:kg|k)\b/i
      weight = Regexp.last_match(1).to_f
    end

    brand = s.sub(/(?:四六|4\/6|菊|K|A|B)(?:判|[YT縦横])?/i, "")
             .sub(/<\s*\d+(?:\.\d+)?\s*>/, "")
             .sub(/\d+(?:\.\d+)?\s*(?:kg|k|g)?\s*\z/i, "")
             .gsub(/[　\s]+/, "")
             .strip

    { raw: text, brand: brand, weight: weight, size_type: size_type }
  end

  def detect_preferred_size_from_question
    return "四六" if @question.include?("四六") || @question.include?("4/6")
    return "K"    if @question.include?("菊") || @question =~ /K判/i
    return "A"    if @question.include?("A判")
    nil
  end

  def detect_machine_from_plans
    machines = @planitems.map(&:machine).compact.uniq
    return "XL106" if machines.any? { |m| m.to_s.include?("XL") } || @impositions.any? { |i| i.machine.to_s.include?("XL") }
    return "SM74"  if machines.any? { |m| m.to_s.include?("SM") } || @impositions.any? { |i| i.machine.to_s.include?("SM") }
    machines.first.presence
  end

  def extract_client_keywords(client_name)
    cleaned = client_name.to_s
                         .gsub(/株式会社|有限会社|合同会社|一般社団法人|公益社団法人|独立行政法人|学校法人|医療法人|社会福祉法人|（株）|\(株\)|（有）|\(有\)|様|御中/, "")
                         .strip
    tokens = cleaned.split(/[　\s・]+/).reject { |t| t.length < 2 }
    no_dot = cleaned.delete("・　 ")
    extra = []
    extra << "酸ヶ湯" if cleaned.include?("酸ヶ湯")
    extra << "カネショウ" if cleaned.include?("カネショウ")
    extra << "エヌ・アンド・エー" if no_dot.include?("エヌアンドエー")
    extra << "エヌアンドエー" if no_dot.include?("エヌアンドエー")
    (extra + [no_dot] + tokens + [cleaned]).reject(&:blank?).uniq
  end

  def brand_search_keywords(brand)
    b = brand.to_s.strip
    return ["上質"] if b.blank?

    keywords = [b]
    keywords << "エルカード" if b.include?("エルカード")
    keywords << "ヴァンヌーボ" if b.include?("ヴァンヌーボ")
    keywords << "トラネクスト" if b.include?("トラネクスト")
    keywords << "タブロ" if b.include?("タブロ")
    keywords << "グラディア" if b.include?("グラディア")
    keywords << "MTA" if b.upcase.include?("MTA")
    keywords << "マット" if b.include?("マット")
    keywords << "コート" if b.include?("コート") && !b.include?("マット")
    keywords << "上質" if b.include?("上質")
    keywords << "サテン金藤" if b.include?("金藤")
    keywords << "アラベール" if b.include?("アラベール")
    keywords << "Mr.B" if b.include?("Mr") || b.include?("ミスター")
    keywords << "色上質" if b.include?("色上")
    keywords.uniq
  end

  def candidate_weights_for(weight)
    return [] unless weight && weight > 0
    w = weight.to_f
    list = [w]
    if BASIS_WEIGHT_MAP.key?(w)
      list << BASIS_WEIGHT_MAP[w][:k]
      list << BASIS_WEIGHT_MAP[w][:a]
    end
    # 逆引き（例: 70.5kg が渡された場合に 110kg / 76.5kg も候補に含める）
    BASIS_WEIGHT_MAP.each do |shiroku, conv|
      if conv[:k] == w || conv[:a] == w
        list << shiroku
        list << conv[:k]
        list << conv[:a]
      end
    end
    list.compact.uniq
  end

  def find_best_ledger(brand, weight, client_name:, print_date: nil, prefer_size: nil, for_pod: false, imp_num: nil, expected_sheets: nil, prefer_roll: false)
    # A1〜A6などのA列サイズの場合、断裁ゴミがほぼ出ないA判を優先採用（名刺21面等の菊4裁はK判を優先）
    effective_prefer_size = prefer_size.presence || (a_series_size? ? "A" : ((for_pod && imp_num.to_i >= 20) ? "K" : nil))

    # コート・マット・上質など銘柄指定のない一般紙は常備在庫（発注なし）、2026年5月以降は共通k単価 195円
    if !prefer_roll && generic_stock_paper?(brand)
      target_size = effective_prefer_size.presence || "四六"
      converted_bw = convert_weight_to_size(weight, target_size)
      generic_name = canonical_generic_paper_name(brand)
      size_suffix =
        case target_size
        when "A" then "A/Y"
        when "K", "菊" then "K/Y"
        else "四六/Y"
        end
      bw_str = (converted_bw == converted_bw.to_i) ? converted_bw.to_i.to_s : converted_bw.to_s
      display_name = "#{generic_name}#{bw_str}kg#{size_suffix}"
      unit_price = after_2026_may?(print_date) ? 195.0 : 187.0

      reasons = ["銘柄指定なし（#{generic_name}）のため常備在庫（個別発注なし）を使用"]
      if a_series_size? && target_size == "A"
        reasons << "A列サイズのため断裁ゴミがほぼ出ないA判（四六#{weight}kg相当 → A判#{converted_bw}kg）を選定"
      end
      reasons << "2026年5月以降の常備在庫共通単価（k単価 195円）を適用" if after_2026_may?(print_date)

      return {
        record: nil,
        display_name: display_name,
        size_type: target_size,
        basis_weight: converted_bw,
        is_board: false,
        kg_unit_price: unit_price,
        sheet_unit_price: nil,
        paper_route: "在庫",
        reason: reasons.join(" / ")
      }
    end

    b_keywords = brand_search_keywords(brand)
    c_keywords = extract_client_keywords(client_name)
    weights = candidate_weights_for(weight)
    prefer_size = effective_prefer_size

    scope = PaperLedger.all
    scope = scope.where(ledger_type: "roll") if prefer_roll

    # 銘柄キーワードで候補を取得（備考欄の「※b7トラネクストの代替」等もヒットするよう note も検索対象に含める）
    conds = b_keywords.map { "paper_name LIKE ? OR item_code LIKE ? OR category LIKE ? OR note LIKE ?" }.join(" OR ")
    binds = b_keywords.flat_map { |kw| ["%#{kw}%", "%#{kw}%", "%#{kw}%", "%#{kw}%"] }
    candidates = scope.where(conds, *binds).to_a

    # 連量で絞り込み（一致するものがあれば優先）
    if weights.any?
      weight_matched = candidates.select do |r|
        bw = r.basis_weight_num.to_f
        bw = r.basis_weight.to_s.to_f if bw <= 0
        weights.any? { |cw| (bw - cw).abs <= 0.6 }
      end
      candidates = weight_matched if weight_matched.any?
    end

    if candidates.empty?
      # フォールバック: デフォルト単価推定
      is_board = BASIS_WEIGHT_MAP[weight.to_f]&.dig(:board) || brand.to_s.include?("カード") || brand.to_s.include?("アイベスト")
      return {
        record: nil,
        display_name: "#{brand} #{weight}kg".strip,
        size_type: prefer_size || "四六",
        basis_weight: weight.to_f,
        is_board: is_board,
        kg_unit_price: 220.0,
        sheet_unit_price: nil,
        paper_route: "在庫",
        reason: "台帳に完全一致する銘柄が見つからないため標準単価で試算"
      }
    end

    # スコアリングして最適な台帳レコードを選定
    scored = candidates.map do |r|
      score = 0
      reasons = []
      note_and_client = "#{r.note} #{r.client_name}"
      bw = r.basis_weight_num.to_f > 0 ? r.basis_weight_num.to_f : r.basis_weight.to_s.to_f
      st = normalize_size_type(r.size_type, bw, weight)

      # 1. 顧客名一致（最優先ルール：備考欄に顧客名がある場合はその判型・ロットを最優先）
      if c_keywords.any? { |ck| ck.present? && note_and_client.include?(ck) }
        score += 500
        reasons << "台帳備考に顧客名「#{r.note.presence || r.client_name}」記載あり"
      end

      # 2. 手配枚数の近似一致（例: 2,950枚や2,150枚など案件特注手配ロット）
      if expected_sheets && r.quantity.to_i > 0
        diff_ratio = (r.quantity.to_f - expected_sheets).abs / [expected_sheets.to_f, 1.0].max
        if diff_ratio <= 0.05
          score += 250
          reasons << "手配数量(#{r.quantity.to_i}枚)が理論必要枚数(#{expected_sheets}枚)と一致"
        elsif diff_ratio <= 0.25
          score += 100
        end
      end

      # 3. 希望判型（質問指定または機械特性）との一致
      if prefer_size.present?
        if st == prefer_size
          score += 150
          reasons << "#{st}判指定に一致"
        end
      elsif for_pod && imp_num.to_i >= 20
        # 名刺21面等で菊判がある場合は菊判を優先
        if st == "K"
          score += 120
          reasons << "名刺21面（菊判4裁）に対応するK(菊)判連量(#{bw}kg)を採用"
        end
      end

      # 4. 作業伝票の連量表記との直接一致
      if weight && (bw - weight.to_f).abs <= 0.5
        score += 40
      elsif weight && BASIS_WEIGHT_MAP[weight.to_f] && (bw - BASIS_WEIGHT_MAP[weight.to_f][:k].to_f).abs <= 0.5
        score += 35
        reasons << "四六判#{weight}kg相当の菊判#{bw}kg"
      end

      # 5. 単価が入っており直近の日付であること
      score += 30 if r.kg_unit_price.to_f > 0 || r.sheet_unit_price.to_f > 0
      if r.purchase_date.present?
        score += 20
        if print_date.present? && (r.purchase_date - print_date).abs <= 30
          score += 80
          reasons << "印刷日(#{print_date.strftime('%m/%d')})直近の仕入ロット(#{r.purchase_date_text})"
        end
      end

      { record: r, score: score, size_type: st, bw: bw, reasons: reasons }
    end

    best = scored.sort_by { |x| [-x[:score], -(x[:record].purchase_date&.to_time&.to_i || 0), -x[:record].id.to_i] }.first
    rec = best[:record]
    is_board = !!rec.is_board || BASIS_WEIGHT_MAP[weight.to_f]&.dig(:board) || rec.paper_name.to_s.include?("カード")

    reason_str = "[#{rec.ledger_type_label}] #{rec.purchase_date_text} 仕入先:#{rec.supplier} 品名:「#{rec.paper_name}」(#{best[:size_type]}判 #{best[:bw]}kg) " \
                 "k単価:#{rec.kg_unit_price}円#{rec.sheet_unit_price.to_f > 0 ? " / 枚単価:#{rec.sheet_unit_price}円" : ""}" \
                 "#{rec.quantity.to_i > 0 ? " / 台帳数量:#{rec.quantity.to_i.to_fs(:delimited)}枚(#{rec.amount.to_i.to_fs(:delimited)}円)" : ""}" \
                 "#{best[:reasons].any? ? " 【選定理由: #{best[:reasons].join('・')}】" : ""}"

    {
      record: rec,
      display_name: rec.paper_name.to_s.strip,
      size_type: best[:size_type],
      basis_weight: best[:bw],
      is_board: is_board,
      kg_unit_price: rec.kg_unit_price&.to_f,
      sheet_unit_price: rec.sheet_unit_price&.to_f,
      paper_route: (rec.note.to_s.present? && c_keywords.any? { |ck| rec.note.to_s.include?(ck) }) ? "注文" : "在庫",
      reason: reason_str
    }
  end

  def find_client_extra_ledgers(client_name, exclude_ids)
    c_keywords = extract_client_keywords(client_name)
    return [] if c_keywords.empty?
    conds = c_keywords.map { "note LIKE ? OR client_name LIKE ?" }.join(" OR ")
    binds = c_keywords.flat_map { |ck| ["%#{ck}%", "%#{ck}%"] }
    PaperLedger.where(conds, *binds).where.not(id: exclude_ids).order(purchase_date: :desc, id: :desc).limit(3).to_a
  end

  def normalize_size_type(raw_size, bw, spec_weight)
    s = raw_size.to_s.strip.upcase
    return "四六" if s.include?("4/6") || s.include?("四六") || s == "46"
    return "K"    if s.include?("K") || s.include?("菊")
    return "A"    if s.include?("A")
    return "B"    if s.include?("B")
    if spec_weight && BASIS_WEIGHT_MAP[spec_weight.to_f]
      return "K" if (bw - BASIS_WEIGHT_MAP[spec_weight.to_f][:k].to_f).abs <= 0.5
      return "A" if (bw - BASIS_WEIGHT_MAP[spec_weight.to_f][:a].to_f).abs <= 0.5
    end
    "四六"
  end

  # =========================================================
  # 重量・金額計算（通常紙 vs 板紙 vs 枚単価優先）
  # =========================================================
  def compute_weight_and_price(sheets:, ren:, is_board:, ktanka:, mtanka:)
    s = sheets.to_i
    r = ren.to_f
    k = ktanka.to_f
    m = mtanka.to_f

    # 重量(kg)の表示値：板紙は100枚連量なので /100 すると実重量になるが、
    # 台帳・AddValueの慣例（板紙は (枚数/100)*連量 または (枚数/1000)*連量）に合わせ、
    # 金額計算は厳密に：板紙は (枚数 / 100.0) * 連量 * k単価、通常紙は (枚数 / 1000.0) * 連量 * k単価
    divisor = is_board ? 100.0 : 1000.0
    effective_weight = ((s / divisor) * r).round(2)

    if m > 0
      exact_price = (m * s).round(2)
      formula = "枚単価優先: #{m}円 × #{s.to_fs(:delimited)}枚 ＝ #{exact_price.to_fs(:delimited)}円"
    elsif k > 0 && r > 0
      exact_price = (effective_weight * k).round(2)
      unit_desc = is_board ? "板紙(100枚単位): (#{s.to_fs(:delimited)}枚 ÷ 100) × #{r}kg ＝ #{effective_weight}kg" : "通常紙(1,000枚単位): (#{s.to_fs(:delimited)}枚 ÷ 1,000) × #{r}kg ＝ #{effective_weight}kg"
      formula = "#{unit_desc} × k単価 #{k}円 ＝ #{exact_price.to_fs(:delimited)}円（四捨五入: #{exact_price.round.to_fs(:delimited)}円）"
    else
      exact_price = 0
      formula = "単価未設定"
    end

    {
      weight: effective_weight,
      exact_price: exact_price,
      price: exact_price.round,
      formula: formula
    }
  end

  def build_summary_row(part_name:, post_press:, paper_name:, paper_route:, size_type:, ren:, is_board:, ktanka:, mtanka:, jisu:, yobi:, yobi_detail:, press_num:, weight:, paper_price:, ledger_record:, ledger_reason:, group_key: "main")
    {
      part_name: part_name,
      post_press: post_press,
      paper_name: paper_name,
      paper_route: paper_route,
      size_type: size_type,
      ren: ren,
      is_board: is_board,
      ktanka: ktanka,
      mtanka: mtanka,
      jisu: jisu,
      sasi: 0,
      yobi: yobi,
      yobi_detail: yobi_detail,
      press_num: press_num,
      weight: weight,
      paper_price: paper_price,
      ledger_id: ledger_record&.id,
      ledger_qty: ledger_record&.quantity&.to_i,
      ledger_amount: ledger_record&.amount&.to_f&.round,
      ledger_date: ledger_record&.purchase_date_text,
      ledger_note: ledger_record&.note,
      ledger_reason: ledger_reason,
      group_key: group_key
    }
  end

  def finalize_result(rows, notes)
    # 同一台帳ロットを複数パート（例: 本文②③④の3台）で共有している場合の集計処理
    seen_ledger_ids = Set.new
    total_ledger_qty = 0
    total_ledger_amount = 0

    # チャット質問による数値オーバーライド（単価・予備・実数・台帳手配枚数適用）
    apply_question_overrides!(rows, notes)

    rows.each do |r|
      lid = r[:ledger_id]
      if lid && !seen_ledger_ids.include?(lid)
        seen_ledger_ids.add(lid)
        total_ledger_qty += r[:ledger_qty].to_i
        total_ledger_amount += r[:ledger_amount].to_i
      elsif lid && seen_ledger_ids.include?(lid)
        r[:ledger_shared] = true
      end
    end

    totals = {
      jisu: rows.sum { |r| r[:jisu].to_i },
      yobi: rows.sum { |r| r[:yobi].to_i },
      press_num: rows.sum { |r| r[:press_num].to_i },
      weight: rows.sum { |r| r[:weight].to_f }.round(2),
      paper_price: rows.sum { |r| r[:paper_price].to_i },
      ledger_qty: total_ledger_qty,
      ledger_amount: total_ledger_amount
    }

    bot_reply = build_bot_reply(rows, totals, notes)

    {
      bot_reply: bot_reply,
      summary_rows: rows,
      totals: totals,
      notes: notes,
      existing_add_values: @job.add_values.order(:id).map do |av|
        {
          id: av.id,
          post_press: av.post_press,
          paper_name: av.paper_name,
          paper_route: av.paper_route,
          ren: av.ren,
          ita: av.ita,
          jisu: av.jisu,
          sasi: av.sasi,
          yobi: av.yobi,
          ktanka: av.ktanka,
          mtanka: av.mtanka,
          press_num: av.press_num,
          weight: av.weight,
          paper_price: av.paper_price
        }
      end
    }
  end

  def apply_question_overrides!(rows, notes)
    return if @question.blank?

    q = @question.tr("０-９．", "0-9.")
    override_applied = []

    if q =~ /台帳(?:手配)?(?:枚数|数量|金額)で/
      rows.each do |r|
        next unless r[:ledger_qty].to_i > 0
        shared_rows = rows.select { |x| x[:ledger_id] == r[:ledger_id] }
        if shared_rows.size > 1
          # 共有ロットの場合は実数比率で按分、または先頭行に集約
          total_jisu = shared_rows.sum { |x| x[:jisu].to_i }
          ratio = total_jisu > 0 ? (r[:jisu].to_f / total_jisu) : (1.0 / shared_rows.size)
          alloc_total = (r[:ledger_qty].to_i * ratio).round
          r[:press_num] = alloc_total
          r[:yobi] = [alloc_total - r[:jisu].to_i, 0].max
        else
          r[:press_num] = r[:ledger_qty].to_i
          r[:yobi] = [r[:press_num] - r[:jisu].to_i, 0].max
        end
        c = compute_weight_and_price(sheets: r[:press_num], ren: r[:ren], is_board: r[:is_board], ktanka: r[:ktanka], mtanka: r[:mtanka])
        r[:weight] = c[:weight]
        r[:paper_price] = c[:price]
      end
      override_applied << "台帳の手配枚数を総枚数に適用"
    end

    if q =~ /(?:実数|通し(?:枚数)?)\s*(\d+)/
      new_jisu = Regexp.last_match(1).to_i
      rows.each do |r|
        r[:jisu] = new_jisu
        r[:press_num] = r[:jisu] + r[:yobi].to_i
        c = compute_weight_and_price(sheets: r[:press_num], ren: r[:ren], is_board: r[:is_board], ktanka: r[:ktanka], mtanka: r[:mtanka])
        r[:weight] = c[:weight]
        r[:paper_price] = c[:price]
      end
      override_applied << "実数(通し枚数)を #{new_jisu.to_fs(:delimited)}枚 に変更"
    end

    if q =~ /予備\s*(\d+)/
      new_yobi = Regexp.last_match(1).to_i
      rows.each do |r|
        r[:yobi] = new_yobi
        r[:press_num] = r[:jisu].to_i + r[:yobi]
        c = compute_weight_and_price(sheets: r[:press_num], ren: r[:ren], is_board: r[:is_board], ktanka: r[:ktanka], mtanka: r[:mtanka])
        r[:weight] = c[:weight]
        r[:paper_price] = c[:price]
      end
      override_applied << "予備枚数を #{new_yobi.to_fs(:delimited)}枚 に変更"
    end

    if q =~ /(?:k単価|ｋ単価|単価)\s*(\d+(?:\.\d+)?)/i && !q.include?("枚単価")
      new_ktanka = Regexp.last_match(1).to_f
      rows.each do |r|
        r[:ktanka] = new_ktanka
        r[:mtanka] = nil
        c = compute_weight_and_price(sheets: r[:press_num], ren: r[:ren], is_board: r[:is_board], ktanka: r[:ktanka], mtanka: nil)
        r[:weight] = c[:weight]
        r[:paper_price] = c[:price]
      end
      override_applied << "k単価を #{new_ktanka}円 に変更"
    elsif q =~ /枚単価\s*(\d+(?:\.\d+)?)/
      new_mtanka = Regexp.last_match(1).to_f
      rows.each do |r|
        r[:mtanka] = new_mtanka
        c = compute_weight_and_price(sheets: r[:press_num], ren: r[:ren], is_board: r[:is_board], ktanka: r[:ktanka], mtanka: r[:mtanka])
        r[:weight] = c[:weight]
        r[:paper_price] = c[:price]
      end
      override_applied << "枚単価を #{new_mtanka}円 に変更"
    end

    if q =~ /連量\s*(\d+(?:\.\d+)?)/
      new_ren = Regexp.last_match(1).to_f
      rows.each do |r|
        r[:ren] = new_ren
        c = compute_weight_and_price(sheets: r[:press_num], ren: r[:ren], is_board: r[:is_board], ktanka: r[:ktanka], mtanka: r[:mtanka])
        r[:weight] = c[:weight]
        r[:paper_price] = c[:price]
      end
      override_applied << "連量を #{new_ren}kg に変更"
    end

    notes << "【チャット指定反映】#{override_applied.join(' / ')}" if override_applied.any?
  end

  def build_bot_reply(rows, totals, notes)
    header = "受注番号 **#{@job.den_id}**（#{@info&.textInfo05} 様「#{@info&.textInfo07}」）の用紙選定・金額計算結果です。"
    if @question.present? && @question !~ /\A\d{6}-\d{3}\z/
      header = "ご質問「#{@question}」の条件を反映して **#{@job.den_id}** を再計算しました。"
    end

    summary_line = "理論必要総数 **#{totals[:press_num].to_fs(:delimited)}枚**（正味実数 #{totals[:jisu].to_fs(:delimited)}枚 ＋ 予備 #{totals[:yobi].to_fs(:delimited)}枚）、" \
                   "総重量 **#{totals[:weight]}kg**、理論用紙金額 **#{totals[:paper_price].to_fs(:delimited)}円**"
    if totals[:ledger_qty].to_i > 0
      summary_line += "（用紙台帳の該当ロット数量: #{totals[:ledger_qty].to_fs(:delimited)}枚 / 金額: #{totals[:ledger_amount].to_fs(:delimited)}円）"
    end

    "#{header}\n#{summary_line}となりました。下の「**3. 計算結果の総括比較**」表で各パートの内訳をご確認のうえ、上のテーブルの「**追加**」ボタンから手動で入力・登録してください。"
  end
end
