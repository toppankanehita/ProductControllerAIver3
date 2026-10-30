require 'nkf'
module ApplicationHelper

  # Webpacker -> Vite Rails 移行用の互換ヘルパー
  def javascript_pack_tag(*names, **options)
    tags = []
    if names.map(&:to_s).include?("application") && !@__jquery_loaded
      @__jquery_loaded = true
      tags << content_tag(:script, "", src: "/jquery.min.js")
    end
    clean_opts = options.except(:'data-turbolinks-track', "data-turbolinks-track")
    resolved_names = names.map do |n|
      s = n.to_s
      s.include?("/") && !s.start_with?("~/packs/", "packs/") ? "~/packs/#{s}" : s
    end
    tags << vite_javascript_tag(*resolved_names, **clean_opts)
    safe_join(tags, "\n")
  end

  def stylesheet_pack_tag(*names, **options)
    clean_opts = options.except(:'data-turbolinks-track', "data-turbolinks-track")
    scss_names = names.map { |n| n.to_s.end_with?(".css", ".scss") ? n.to_s : "#{n}.scss" }
    vite_stylesheet_tag(*scss_names, **clean_opts)
  end

  # Rails 8 互換: form_with(model: nil) が渡された場合に model: false として扱う
  def form_with(model: false, **options, &block)
    super(model: model.nil? ? false : model, **options, &block)
  end

  def safe_i(v)
    return 0 if v.nil?
    # 数値風文字列は to_s 経由で整数化
    if v.is_a?(String)
      s = v.strip
      return 0 if s.empty?
      # 3桁区切りなどを除去（必要なら）
      s = s.delete(',')
      # 数字先頭以外は to_i が0へフォールバックする
      return s.to_i
    end
    if v.is_a?(Float)
      return 0 if v.nan? || v.infinite?
      return v.to_i
    end
    # Integer など
    v.to_i
  rescue
    0
  end

  def select_size_web
    {
      'D4' => '4',
      'D/4' => '4',
      'B4' => '4',
      'B/4' => '4',
      'Ｂ4' => '4',
      'D3' => '2',
      'D/3' => '2',
      'B3' => '2',
      'B/3' => '2',
      'D2' => '1',
      'D/2' => '1',
      'B2' => '1',
      'B/2' => '1',
      'A3' => '4',
      'A/3' => '4',
      'A/4' => '5',
      'A4' => '5',
      'A/5' => '10',
      'A5' => '10',
      'B5' => '8'
    }
  end

  def select_size_sheet
    {
      'A1' => '508200',
      'A2' => '255600',
      'A3' => '129078',
      'A4' => '65448',
      'A5' => '33264',
      'A6' => '17094',
      'A7' => '8880',
      'A8' => '4640',
      'A9' => '2494',
      'A10' => '1376',
      'B0' => '1514632',
      'B1' => '760424',
      'B2' => '382414',
      'B3' => '192770',
      'B4' => '97310',
      'B5' => '49444',
      'B6' => '25192',
      'B7' => '12998',
      'B8' => '6790',
      'B9' => '3570'
    }
  end
  def paper_full_size
    {
      '四六' => 859708,
      '菊' => 597204,
      'A' => 550000,
      'B' => 830025,
      'K' => 601600,
      'KK' => 617500,
      'B3' => 215275
    }
  end
  def irokazu
    {
      '6x6' => '12' ,
      '5x5' => '10' ,
      '4x4' => '8' ,
      '3x3' => '6' ,
      '2x2' => '4' ,
      '1x1' => '2' ,
      '6x0' => '6' ,
      '5x0' => '5' ,
      '4x0' => '4' ,
      '3x0' => '3' ,
      '2x0' => '2' ,
      '1x0' => '1' ,
      '0x6' => '6' ,
      '0x5' => '5' ,
      '0x4' => '4' ,
      '0x3' => '3' ,
      '0x2' => '2' ,
      '0x1' => '1' ,
      '4x3' => '7' ,
      '4x2' => '6' ,
      '4x1' => '5' ,
      '3x2' => '5' ,
      '3x1' => '4' ,
      '2x1' => '3' ,
      '3x4' => '7' ,
      '2x4' => '6' ,
      '1x4' => '5' ,
      '2x3' => '5' ,
      '1x3' => '4' ,
      '1x2' => '3'
    }
  end

  def sheet_fact
    {
      '0x1' => 3.0 ,
      '0x2' => 2.4 ,
      '0x3' => 2.0 ,
      '0x4' => 1.3 ,
      '0x5' => 1.2 ,
      '1x0' => 3.0 ,
      '1x1' => 2.3 ,
      '1x2' => 1.8 ,
      '1x3' => 1.5 ,
      '1x4' => 1.25 ,
      '1x5' => 1.1 ,
      '2x0' => 2.4 ,
      '2x1' => 1.8 ,
      '2x2' => 1.4 ,
      '2x3' => 1.3 ,
      '2x4' => 1.2 ,
      '2x5' => 1.2 ,
      '3x0' => 2.0 ,
      '3x1' => 1.5 ,
      '3x2' => 1.4 ,
      '3x3' => 1.3 ,
      '3x4' => 1.1 ,
      '3x5' => 1.1 ,
      '4x0' => 1.3 ,
      '4x1' => 1.25 ,
      '4x2' => 1.2 ,
      '4x3' => 1.1 ,
      '4x4' => 1.0 ,
      '4x5' => 1.0 ,
      '5x0' => 1.2 ,
      '5x1' => 1.1 ,
      '5x2' => 1.1 ,
      '5x3' => 1.1 ,
      '5x4' => 1.0 ,
      '5x5' => 1.0 ,
      '6x4' => 1.0
    }
  end
  def arari_cal_wap(job)
    press_cost_cal(job)
  end
  def press_cost_cal(job)
    @job = job
    @info = @job.info
    sale_date = Sale.find_by("job_id = ?", job)&.t03
    sale_date = sale_date.present? ? sale_date[0,6] : nil
    @cost_data = Cost.find_by(target_month: sale_date)
    # @pageが0以上だとページもの
    @page = (@info&.numInfo08 || 0) + (@info&.numInfo09 || 0)

    if job.den_id.present?
      #d = Date.strptime( job.den_id , '%y%m%d')
      date_str = job.den_id[0, 6]
      issue_date = Date.strptime(date_str, '%y%m%d') # => Date.new(2025, 1, 1)
    end

    if date_str.blank?
      @unit_price = UnitPrice.all[-1]

    else
      #@unit_price = UnitPrice.order(date01: "desc").find_by("date01 <= ?",d)
      #
      @unit_price = UnitPrice.where('date01 <= ?', issue_date).order(date01: :desc).first
    end

    if @mission

      @unit_price.d16 = @unit_price.d116
      @unit_price.d17 = @unit_price.d117
      @unit_price.d18 = @unit_price.d118
      @unit_price.d36 = @unit_price.d136
      @unit_price.d37 = @unit_price.d137
      @unit_price.d39 = @unit_price.d139

    end

    #@mentuke = 0
    @sekisan_press_cost = 0
    @uploadfile = Uploadfile.find_by(job_id: @job)
    @print_plans = Planitem.where(job_id: @job.id)
    @print_reports = Reportitem.where(job_id: @job.id)
    @slips = Slip.where(job_id: @job)
    @specs = Array.new
    #@peper_hs = Hash.new
    @cuttings = Cutter.where(job_id: @job)
    @add_values = AddValue.where(job_id: job)
    @add_presies = AddPress.where(job_id: job)
    @add_datum = AddDatum.find_by(job_id: job) || AddDatum.new(job_id: job)
    @value_total_sale = value_cal_price_helper(job, @add_datum)
    sonsi_num = Reportitem.where(job_id: @job).sum(:sonsi)
    upinfos = UpInfo.where("lastest = ? AND job_id = ? ", 1,@job)

    @specs = Spec.where(uploadfile_id: @uploadfile)
    @print_specs = PrintSpec.where(uploadfile_id: @uploadfile)
    @press_datas = PressData.where(job_id: @job.id)
    @outsource_orders = OutsourceOrder.history_for_job(@job)
    @latest_outsource_order = @outsource_orders.first
    #各パート作成
    @ctpArr = search_ctp(@uploadfile,@job, @unit_price ,@add_datum, upinfos,@slips)
    @papers = search_yousi( @uploadfile , @specs ,@add_values, sonsi_num, upinfos,@slips,@add_datum)
    @pressArr = search_press(@uploadfile, @job, @unit_price, @print_price, @add_presies, upinfos,@add_datum)
    @podArr = serch_pod(@uploadfile, @job, @unit_price ,@add_datum, upinfos)
    @kakoArr = serch_kako(@uploadfile, @job, @unit_price, @cuttings,@add_datum, upinfos)
    @seisakuArr = search_seisaku(@uploadfile,@job,@unit_price,@add_datum, upinfos)
    @assemblyArr = search_assembly(@uploadfile,@job,@unit_price,@add_datum, upinfos)
    @hassoArr = search_hasso(@uploadfile,@job,@unit_price,@add_datum, upinfos)
    @gaicyuArr = search_gaicyu(@uploadfile,@job,@unit_price,@add_datum, upinfos)
    @keihiArr = search_keihi(@uploadfile,@job,@unit_price, upinfos)
    @cal_sums = search_sum(@uploadfile,@job,@unit_price,@add_datum, upinfos)

  end

  def web_press_num(sasikae_num ,sonsi_num)
    jisu = 0
    yobi = 0
    webMaxSize = 443898
    if @info.textInfo02.index("オフ輪")
      size = @info.textInfo20
      webSprit = select_size_web[size].to_i

      if webSprit == 0
        detaSize = @info.numInfo06.to_i * @info.numInfo07.to_i
        detaSize2 = @info.numInfo14.to_i * @info.numInfo15.to_i
        detaSize = detaSize < detaSize2 ? detaSize2 : detaSize
        webSprit = (webMaxSize / (detaSize * 1.1)).to_i
      end

      press_num = @info.numInfo01.to_i +  @info.numInfo02.to_i +  @info.numInfo03.to_i
      if webSprit > 0 && press_num > 0 then
        jisu = (press_num / webSprit).to_i
        if jisu == 0 then
          yobiRate = 6000
        elsif jisu < 9999 then
          yobiRate = 6000.0 / jisu
        elsif jisu > 130000 then
          yobiRate = (0.069 - 0.03) * Math.exp(-0.00001 * (jisu - 150000)) + 0.03
        else
          yobiRate = (0.6 - 0.07) * Math.exp(-0.00004 * (jisu - 10000)) + 0.07
        end

        yobi = ((yobiRate.to_f * jisu.to_i) + (sasikae_num.to_i * 1500)).floor
      end
    end
    return [jisu,yobi, webSprit ]
  end

  def web_press_weight(press_num, ren)
    mtanka = 0.0
    weight = 0.0
    price = 0
    if @info.textInfo02.index("オフ輪") && ren > 0
      #
      if @info.textInfo11&.include?("FJS用紙D巻") || @info.textInfo11.index("支給") || (@info.textInfo05 == "株式会社 JOETSU" && @info.textInfo07&.include?("ヤマダデンキ")  )
        ktanka = 0.0
      elsif @info.textInfo11&.include?("65.5")
        ktanka = @unit_price.d04
      elsif @info.textInfo11&.include?("アークス指定")
        ktanka = @unit_price.d05
      elsif @info.textInfo11&.include?("新黄更")
        ktanka = @unit_price.d06
      elsif @info.textInfo11&.include?("マットコート")
        ktanka = @unit_price.d02
      elsif @info.textInfo11&.include?("コート")
        ktanka = @unit_price.d01
      elsif @info.textInfo11&.include?("上質")
        ktanka = @unit_price.d03
      else
        tmp_paper = @info.textInfo11.to_s
        tmp_paper = NKF.nkf('-w -Z3', tmp_paper)
        tmp_paper = tmp_paper.delete("|() /")
        tmp_paper = tmp_paper.gsub("　", "")
        tmp_paper = tmp_paper.gsub(/(\d[.\d]*)K(?![gG])/i) { "#{$1}Kg" }
        if @job.den_id.present?
          #d = Date.strptime( job.den_id , '%y%m%d')
          date_str = @job.den_id[0, 6]
          issue_date = Date.strptime(date_str, '%y%m%d') # => Date.new(2025, 1, 1)
        end
        paper = PaperList.where('full_name = ? and date01 <= ? and paper_type_id = ?', tmp_paper, issue_date,3).order(date01: :desc).first
        puts "paper0 #{paper&.id}"
        #puts "tmp_paper #{tmp_paper}"
        if paper.present?
          ktanka = paper.ktanka
        else
          ktanka = @unit_price.d01
        end

      end
      weight = (press_num.to_f / 2000.0) * ren
      #puts "press_num #{press_num} weight #{weight} #{press_num / 2000} / #{ren}"
      price = weight * ktanka
      #puts "ktanka #{ktanka} weight = #{weight} , price = #{price}"
    end
    return [weight , price ,ktanka ,mtanka]
  end

  def web_sasikae_num(ctps,imps,job)
    press_num = Reportitem.where(job_id: job).maximum(:sasikae)
    dai_num = imps.map(&:dai).max
    if dai_num.present?
      dai_num = dai_num > 0 ? dai_num - 1 : dai_num
    else
      dai_num = 0
    end
    sasikae_num = dai_num.to_i < press_num.to_i ? press_num.to_i : dai_num.to_i
    return sasikae_num.to_i
  end
  def printer_paper_name(paper_name,type, ren)
    tmp_paper = paper_name.gsub(/|(|（|)|）|\//,"")
    tmp_paper = tmp_paper.gsub(/10面付け|【名刺台紙使用】|16丁付/,"")
    tmp_paper = tmp_paper.gsub(/（a台紙）|名刺台紙/,"")
    tmp_paper = tmp_paper.gsub(/刷り込み台紙/,"刷込台紙")
    tmp_paper = tmp_paper.tr("０-９", "0-9")
    tmp_paper = NKF.nkf('-w -Z3', tmp_paper)
    tmp_paper = tmp_paper.tr("/","")
    tmp_paper = tmp_paper.tr("　","")
    tmp_paper = tmp_paper.tr(" ","")
    tmp_paper = tmp_paper.gsub(/(\d[.\d]*)K(?![gG])/i, '\1Kg')
    # tmp_paper = paper_name.gsub(/10面付け|【名刺台紙使用】|16丁付|（台紙）|名刺台紙/, "")
    #                      .gsub(/刷り込み台紙/, "刷込台紙")
    # tmp_paper = NKF.nkf('-w -Z3', tmp_paper)
    # tmp_paper = tmp_paper.delete("|() /")
    # tmp_paper = tmp_paper.gsub(/(\d[.\d]*)K(?![gG])/i, '\kg')
    char_num = tmp_paper.length
    test1 = tmp_paper.slice(char_num - 1, 2)
    test = tmp_paper.slice(char_num - 2, 2)
    #ren = 0
    if test1.present?
      if test1 == "k"
        tmp2 = tmp_paper.slice(0..-2)
        tmp_paper = tmp2 + "Kg"
      end
      if test == "kg"
        tmp2 = tmp_paper.slice(0..-3)
        tmp_paper = tmp2 + "Kg"
      end
      if test1 == "K"
        tmp2 = tmp_paper.slice(0..-2)
        tmp_paper = tmp2 + "Kg"
      end
      if test1 == "㎏"
        tmp2 = tmp_paper.slice(0..-2)
        tmp_paper = tmp2 + "Kg"
      end
    end
    #名刺台紙なら健生、太陽地所、テレグ研、東奥信用金庫
    if paper_name&.include?("東奥信用金庫")
    elsif paper_name&.include?("健生")
    elsif paper_name&.include?("太陽地所")
    elsif paper_name&.include?("立替")
    elsif paper_name&.include?("支給")
    elsif paper_name&.include?("官製はがき") || paper_name&.include?("官製ハガキ") || paper_name&.include?("郵便はがき") || paper_name&.include?("郵便ハガキ")
      tmp_paper = "郵便はがき4面付け"
    end
    puts "tmp_paper #{tmp_paper}"
    date_str = @job.den_id[0, 6]
    issue_date = Date.strptime(date_str, '%y%m%d') # => Date.new(2025, 1, 1)
    if type == 2

      paper = PaperList.where('full_name = ? and date01 <= ? and (paper_type_id = ? or paper_type_id = ? )',  tmp_paper, issue_date,1,2).order(date01: :desc).first
      puts "paper2 #{paper&.id} tmp_paper #{tmp_paper}"
      text_to_convert = @info.textInfo11.to_s
      normalized_text = text_to_convert.tr('０-９．', '0-9.')
      # ren = normalized_text.scan(/\d{2,}\.\d+|\d{2,}/)
      # ren = ren.count > 0 ? ren[0] : normalized_text

      if paper.blank?
        tmps = tmp_paper.split(ren.to_s)
        tmp = tmps.count > 1 ? tmps[0] : tmp_paper

        if tmp.include?("四六判") || tmp.include?("四六")
          tmp_paper = tmp.gsub(/四六判|四六/,"")
        elsif tmp.include?("菊判") || tmp.include?("菊")
          tmp_paper = tmp.gsub(/菊判|菊/,"")
        elsif tmp.include?("A判")
          tmp_paper = tmp.gsub(/A判/,"")
        elsif tmp.include?("マットコート") || tmp == "マット"
          tmp_paper = "マットコート"
        elsif tmp.include?("色上質")
          #tmp_paper = "色上質"
        elsif tmp.include?("TOMカラ") || tmp.include?("トムカラ")
          tmp_paper = "トムカラー用紙"
        else
          tmp_paper = tmp
        end
        paper = PaperList.where('full_name = ? and date01 <= ? AND paper_type_id = ?', tmp_paper, issue_date, 2).order(date01: :desc).first
        if tmp_paper.include?("色上質") && paper.blank?
          paper = PaperList.where('full_name = ? and date01 <= ? AND paper_type_id = ?', "色上質", issue_date, 2).order(date01: :desc).first
        end
      end
    else
      paper = PaperList.where('full_name = ? and date01 <= ? AND paper_type_id = ?',  tmp_paper, issue_date,type).order(date01: :desc).first
    end
    puts "paper3 #{paper&.id}"
    return [tmp_paper,paper,ren.to_f]
  end
  def sheet_weight(men,ren,ita )
    weight = 0.0
    #ren = 57.5
    siroku = 859708
    if ita == 1
      base_waight = (ren / 100) # / siroku #1mmあたりの重量
    else
      base_waight = (ren / 1000) # / siroku #1mmあたりの重量
    end

    mm_weight = (base_waight / siroku)

    #作業伝票のデータから用紙枚数を算出
    size1 = (@info.numInfo14.to_i + 6) * (@info.numInfo15.to_i + 6)
    size2 = (@info.numInfo06.to_i + 6) * (@info.numInfo07.to_i + 6)
    tmp_size = @info.textInfo20
    tmp_size = tmp_size.gsub(/|(|（|)|）|\//,"")
    tmp_size = NKF.nkf('-w -Z3', tmp_size)
    size3 =  select_size_sheet[tmp_size].to_i
    size = [size1, size2, size3].max
    size = size.to_i * 1.15
    if size > 0
      weight = (size * men) * mm_weight.to_f
    end
    return weight
  end
  def printer_num(ctps, type, ren)
    jisu,mihon = meisi_num_helper(@info)
    weight = 0.0
    ktanka = 0.0
    mtanka = 0.0
    ita = 0

    #展開サイス
    tmp_paper,paper,ren = printer_paper_name(@info.textInfo11,type,ren)

    #CTPの面付け情報から用紙枚数を算出
    imps = Imposition.where("job_id = ? AND machine = ? AND machine IS NOT null", @job.id,"プリント")
    men1 = imps.map(&:num).max
    men1 = men1.to_i == 0 ? 1 : men1.to_i
    #名刺用紙DBから
    name = paper&.full_name
    men2 = 10
    if paper.present?
      men2 = paper.tori
      ita = paper.ita
    end
    #作業伝票の仕様から�から用紙枚数を算出
    if type == 1 #名刺なら
      men = men1.to_i < men2.to_i ? men2 : men1

    else
      men = men1.to_i
    end

    press_num = (jisu.to_i / men.to_i).to_i + ((jisu.to_i % men.to_i).to_f > 0 ? 1 : 0)
    mihon_num =  (mihon.to_i / men.to_i).to_i + ((mihon.to_i % men.to_i).to_f > 0 ? 1 : 0)
    print_count = count_chk(@info)

    #CTPのプリント数から用紙枚数を算出
    color_num = ctps.sum(:color_print)
    mono_num = ctps.sum(:mono_print)
    if color_num > 0 || mono_num > 0
      side_a = @info.numInfo04.to_i
      side_b = @info.numInfo05.to_i
      if side_a > 0 && side_b > 0 then
        pint_num = (color_num.to_i + mono_num.to_i) / 2
      elsif side_a == 0 || side_b == 0 then
        pint_num = (color_num.to_i + mono_num.to_i)
      elsif side_a == side_b then
        pint_num = (color_num.to_i + mono_num.to_i) / 2
      end
      #press_num = jisu.to_i
      #press_num = press_num - mihon_num
      pint_num = (pint_num.to_i / print_count).to_i
      mihon_num = pint_num.to_i - press_num
      mihon_num = mihon_num < 1 ? 1 : mihon_num
    end


    #press_num = (press_num / print_count).to_i
    mihon_num = (mihon_num / print_count).to_i

    if paper.blank?
      press_price = 0
      mtanka = 999.99
      ktanka = 0.0
    else
      mtanka = paper&.mtanka
      ktanka = paper&.ktanka

      if type == 1 #名刺なら

        press_price = ((press_num.to_i + mihon_num.to_i ) * men) * paper.unit_price
        if not @info.textInfo11&.include?("名刺台紙")
          press_price = press_price + 100#カット代
        end
        mi_weight = sheet_weight(men,ren,ita)#出力シート1枚の重量
        weight = (press_num.to_i + mihon_num.to_i ) * mi_weight

      else
        #案件の展開面積を取得

        printer_num = (press_num.to_i + mihon_num.to_i )
        mi_weight = sheet_weight(men,ren,ita)#出力シート1枚の重量
        if mi_weight > 0 && ktanka.to_f > 0
          weight = printer_num * mi_weight
          press_price = weight.to_f * ktanka.to_f + 100#カット代

        elsif mtanka.to_f > 0
          kiri = paper.kiri

          t = (printer_num / kiri.to_i).ceil

          press_price = t * mtanka.to_f + 100#カット代
        end
      end

    end
    return [ press_num, mihon_num, name, ktanka, mtanka, men,weight, press_price]
  end

  def search_yousi( uploadfile , specs ,add_values ,sonsi_num, upinfos, ctps ,add_datum)
    rArray = Array.new
    spec = specs.present? ? specs[0] : Spec.new
    @press_info = Hash.new
    add_value = AddValue.find_or_initialize_by(job_id: @job.id)

    ktanka = 0.0
    mtanka = 0.0
    webSprit = 0
    press_num = @info.numInfo01.to_i
    paper_weight = [0,0]
    weight = 0
    dai_num = 0
    sm74 = ""
    xl106 = ""

    #積算用紙代
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "用紙" && upinfo.category == 1
    end
    yousimitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算

    #営業積算原価
    upinfo = upinfos.find do |upinfo|
      upinfo.name == "用紙" && upinfo.category == 11
    end
    salesgenka = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    sasikae_num = web_sasikae_num(@ctps,@imps,@job)

    text_to_convert = @info.textInfo11.to_s
    normalized_text = text_to_convert.tr('０-９．', '0-9.')
    ren = normalized_text.scan(/\d{2,}\.\d+|\d{2,}/)
    color = ""
    special = ""

    #オフ輪転分が重量まで自動計算
    if @info.textInfo02&.include?("オフ輪")
      jisu,yobi,webSprit = web_press_num(sasikae_num ,sonsi_num)
      weight, yousigenka, ktanka, mtanka = web_press_weight(jisu + yobi ,ren[0].to_f)

      if @info.numInfo04.to_i > 0 || @info.numInfo05.to_i > 0
        color = "#{@info.numInfo04.to_i}x#{@info.numInfo05.to_i}"
        if @info.numInfo16.to_i == 0 && @info.numInfo04.to_i > 0
          special = "特色"
        end
        if @info.numInfo17.to_i == 0 && @info.numInfo05.to_i > 0
          special = "特色"
        end
      end

      #puts "jisu #{jisu} yobi #{yobi} ren #{ren[0].to_f} weight #{weight} yousigenka #{yousigenka}"
    elsif @info.textInfo02&.include?("オフセット")
      jisu = add_values.sum { |v| v.respond_to?(:jisu) ? v.jisu.to_i : 0 }
      yobi = add_values.sum { |v| v.respond_to?(:yobi) ? v.yobi.to_i : 0 }
      sasikae_num = @imps.map(&:dai).max
      webSprit = @imps.map(&:num).max#面付け
      sm74 = @imps.where(machine: 'SM74').exists? ? 1 : 0
      xl106 = @imps.where(machine: 'XL106').exists? ? 1 : 0

      if @info.numInfo04.to_i > 0 || @info.numInfo05.to_i > 0
        color = "#{@info.numInfo04.to_i}x#{@info.numInfo05.to_i}"
        if @info.numInfo16.to_i == 0 && @info.numInfo04.to_i > 0
          special = "特色"
        end
        if @info.numInfo17.to_i == 0 && @info.numInfo05.to_i > 0
          special = "特色"
        end
      end

    elsif @info.textInfo02&.include?("プリント") || @info.textInfo02&.include?("コピー")
      if @info.textInfo07&.include?("名刺") || @info.textInfo11&.include?("官製はがき") || @info.textInfo11&.include?("官製ハガキ") || @info.textInfo11&.include?("郵便はがき") || @info.textInfo11&.include?("郵便ハガキ") || @info.textInfo11&.include?("年賀はがき") || @info.textInfo11&.include?("年賀ハガキ")
        #puts "ren #{ren[0].to_f}}"
        jisu,yobi,paper_name,ktanka,mtanka,webSprit, weight,yousigenka = printer_num(ctps , 1, ren[0].to_f)

      else

        jisu,yobi,paper_name,ktanka,mtanka,webSprit,weight,yousigenka = printer_num(ctps , 2, ren[0].to_f)

      end
      #  [ jisu, mihon, name, paper.mtanka, men,press_price]
      sasikae_num = 0

    elsif @info.textInfo02 == "用紙"
      #jisu,yobi,paper_name,ktanka,mtanka,webSprit,weight,yousigenka = printer_num(ctps , 2, ren[0].to_f)
      tmp_paper,paper,rensu = printer_paper_name(@info.textInfo11,2, ren[0].to_f)
      size0 = select_size_sheet[@info.textInfo20]
      size1 = (@info.numInfo06.blank? ? 0 : @info.numInfo06) * (@info.numInfo07.blank? ? 0 : @info.numInfo07)
      size2 = (@info.numInfo14.blank? ? 0 : @info.numInfo14) * (@info.numInfo15.blank? ? 0 : @info.numInfo15)
      siage_size = size2 > 0 ? size2 : (size1 > 0 ? size1 : size0)
      if paper.present?
        full_size = paper_full_size[paper.han]
        mtanka = paper.mtanka
        ktanka = paper.ktanka
        if not full_size.to_i == 0 || siage_size.to_i == 0 then
          tori =(full_size.to_i / (siage_size * 1.1).to_i  ).to_i
        end
        jisu = @info.numInfo01.to_i.fdiv(tori.to_i).ceil
        if paper.ita == 1
          weight = jisu * (rensu / 100)
        else
          weight = jisu * (rensu / 1000)
        end
        if mtanka.present?
          yousigenka = jisu * mtanka
        else
          yousigenka = weight * ktanka
        end
      else
        ktanka = 999
      end
      #puts "tmp_paper #{tmp_paper} full_size #{full_size} siage_size #{siage_size} tori #{tori}"
    end



    @press_info.merge!({
      jisu: jisu,#1
      yobi: yobi,#2
      webSprit: webSprit,#3
      ren: ren[0].to_f,#4
      sasikae: sasikae_num,#5
      color: color,#6
      special: special,#7
      press_method: @info.textInfo02,#8
      upo: @info.textInfo11&.include?("ユポ") ? "ユポ" : "",#9
      kaleido: @info.textInfo28&.include?("カレイド") ? "カレイド" : "",#10
      ita: add_value.ita&.to_i,#11
      post_press: add_value.post_press,#12
      paper_name: add_value.paper_name,#13
      paper_route: add_value.paper_route,#14
      kako: kako_helper(@job),#15
      booklet: book_helper2( @info.numInfo08, @info.numInfo09),#16
      sm74: sm74,#17
      xl106: xl106,#18
      kin: (@info.textInfo28&.include?("赤金") || @info.textInfo28&.include?("青金") || @info.textInfo28&.include?("金刷") || @info.textInfo28&.include?("銀刷"))? "金" : "",#19
    })

    #藤田SV記入用紙原価
    value_genka = add_values.sum(&:paper_price)
    ren = ren[0].to_f
    roumu = 0.0
    if value_genka == 0.0
      if yousigenka.to_i == 0
        yousigenka = 0
      end
    else
      yousigenka = value_genka
      # max_by を使って nil セーフに取得（空なら nil）
      ktanka_record = add_values.max_by { |v| v.respond_to?(:ktanka) && v.ktanka ? v.ktanka : -Float::INFINITY }
      ktanka = ktanka_record&.ktanka.to_f

      mtanka_record = add_values.max_by { |v| v.respond_to?(:mtanka) && v.mtanka ? v.mtanka : -Float::INFINITY }
      mtanka = mtanka_record&.mtanka.to_f
      ren = add_values.max_by { |v| v.respond_to?(:ren) && v.ren ? v.ren : -Float::INFINITY }
      ren = ren&.ren.to_f

      jisu = add_values.sum { |v| v.respond_to?(:jisu) ? v.jisu.to_i : 0 }
      yobi = add_values.sum { |v| v.respond_to?(:yobi) ? v.yobi.to_i : 0 }
      tmp = 0.0
      add_values.each do |v|
        if v.ita == 1
          tmp = tmp + ((jisu + yobi) / 100.0) * v.ren.to_f
        else
          tmp = tmp +  ((jisu + yobi) / 1000.0) * v.ren.to_f
        end
      end
      weight = tmp
      add_values.each do |v|
        if v.paper_route == "ロールカッター" || v.paper_route == "シートカッター"
          roumu =+ ((jisu + yobi )/ 5400.0).to_f
          #puts "ロールカッター #{roumu}"
        end
      end
    end

    rArray.push(yousimitumori) #0 積算額
    rArray.push(yousigenka) # yousigenka)  #1 積算原価
    rArray.push(yousimitumori.to_i - yousigenka.to_i) #2 yousisagaku 粗利
    rArray.push(spec.t01) #3用紙名
    rArray.push(spec.f01) #4斤量
    rArray.push(spec.n05) #5取数
    rArray.push(spec.n06) #6台数
    rArray.push(jisu ||= 0 ) #spec.n01) #7実数
    rArray.push(yobi ||= 0 ) #spec.n02 - spec.n01) #8予備数
    rArray.push(weight ||= 0 )#spec.n02) #9総量
    rArray.push(salesgenka ) #10営業積算原価
    rArray.push(ren.to_f ) #11連
    rArray.push(sasikae_num ) #12差替数
    rArray.push(ktanka ) #13k単価
    rArray.push(webSprit ) #14webスプリット
    rArray.push(mtanka ) #15枚単価
    rArray.push(press_num ) #16印刷枚数
    rArray.push(roumu ) #17労務
    return rArray
  end

  def search_ctp(uploadfile,job,unit_price ,add_datum, upinfos, ctps)
    rArray = Array.new

    outnum = ctps.sum(:numInfo03)#出力数
    outtime = (outnum > 0 ? ((outnum / 8).to_i + 1) * 1200 + 1800 : 0)#出力時間

    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "刷版"
    end
    ctpmitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算

    ##################################################################
    ctp_all = 0
    ctpgenka = 0
    tanka = 0
    ctps.each do |slip|
      tmp_tanka = ctptanka(unit_price, slip.txtInfo04).to_i

      if tmp_tanka.present?
        ctp_all = ctp_all + slip.numInfo03.to_i
        ctpgenka = ctpgenka + (slip.numInfo03.to_i * tmp_tanka.to_i)
        tanka = tanka < tmp_tanka ? tmp_tanka : tanka
        puts "slip.numInfo03.to_i #{slip.numInfo03.to_i} tmp_tanka #{tmp_tanka}"
      end
    end
    ##################################################################
    #
    ctpsagaku = (ctpmitumori - ctpgenka)
    cost = ctpgenka
    ####追加情報取得################################################
    if add_datum.ctp.present?
      ctpgenka = ctpgenka + add_datum.ctp
    end
    ####労務情報################################################
    roumu = 0

    if outtime > 0
      roumu = (outtime.to_f / 3600)
    end
    ##############################################################
    @imps = Imposition.where("job_id = ? AND machine <> ? AND machine IS NOT null", job.id,"プリント")
    mentuke = 0
    dai = 0
    @imps.each do |imp|
      mentuke = imp.num
      dai = imp.dai
    end
    rArray.push(ctpmitumori)#0積算額
    rArray.push(ctpgenka)#1原価
    rArray.push(ctpsagaku)#2粗利
    rArray.push(outtime)#3作業時間
    rArray.push(tanka)#4 版単価
    rArray.push(ctps.sum(:numInfo04))#5ヤレ数
    rArray.push(ctps.sum(:numInfo05))#6版トレ
    rArray.push(ctps.sum(:numInfo06))#7カーブ変更
    rArray.push(ctp_all)#8全出力
    rArray.push(ctps[0].present? ? ctps[0].txtInfo04 : "")#9版種類
    rArray.push(mentuke)#10面付数
    rArray.push(dai)#11台数
    rArray.push(roumu)#12労務費
    rArray.push(cost)#13材料費
    return rArray
  end

  def search_press(uploadfile,job,unit_price,print_price,add_presies, upinfos,add_datum)
    pressArr = Array.new

    r = 0
    n = 0
    press = 0
    nin = 0
    sonsi = 0
    add_press_price = 0

    if @press_info[:jisu].present?
      if @info.textInfo02&.include?("オフ輪")
        #puts "press オフ輪"
        jisu = @press_info[:jisu].to_i
        yobi = @press_info[:yobi].to_i
        tusu = jisu + yobi
        if tusu < 10001 then
          pressRate = 70000.0 / tusu
        elsif tusu > 199999 then
          #pressRate = (2.0 - 0.95) * Math.exp(-0.000005 * (tusu - 140000)) + 0.95
          pressRate = (1.3 - 0.9) * Math.exp(-0.000005 * (tusu - 200000)) + 0.9
        else
          #pressRate = (6.6 - 1.8) * Math.exp(-0.000025 * (tusu - 10000)) + 1.8
          pressRate = (6.3 - 1.26) * Math.exp(-0.00003 * (tusu - 10000)) + 1.26
        end
        pressRate = pressRate / 8

        if @press_info[:special] == "特色"
          pressRate = pressRate * 1.5
        end

        iro_num = irokazu[@press_info[:color]].present? ? irokazu[@press_info[:color]].to_i : 8
        one_side = @press_info[:color]&.include?("0") ? 1 : 0

        if one_side == 1
          pressRate = pressRate * 1.5
        end

        if jisu.to_i > 0
          add_press_price = ((pressRate * iro_num) * jisu.to_i).to_i
        end

        if add_press_price < 48000
          add_press_price = 48000
        end
      elsif @info.textInfo02&.include?("オフセット")
        tusu = @press_info[:jisu].to_i + @press_info[:yobi].to_i
        if tusu > 0 then
          machine = @press_info[:sm74] == 1 ? "SM-74" : "XL106"
          optRate = 1
          color_set = color_set(@info.numInfo04,@info.numInfo05)
          iro_num = @info.numInfo04.to_i + @info.numInfo05.to_i
          sheetRate = sheet_fact[color_set]
          sheetRate = sheetRate.nil? ? 1 : sheetRate
          optRate = optRate * sheetRate

          if @press_info[:upo] == "ユポ"
            optRate = optRate * 1.5
          end
          if @press_info[:kaleido] == "カレイド"
            optRate = optRate * 1.5
          end
          if iro_num < 3
            if @press_info[:special] == "特色"
              optRate = optRate * 1.2
            end
          end
          if @press_info[:kin] == "金"
            optRate = optRate + 1.0
          end

          if machine == "SM-74"
            if tusu < 1501 then
              pressRate = 3600.0 / tusu
            elsif tusu > 10000 then
              pressRate = (1.1 - 0.6) * Math.exp(-0.00005 * (tusu - 10000)) + 0.6
            else
              pressRate = (2.2 - 1.058) * Math.exp(-0.0003 * (tusu - 1500)) + 1.05
            end
          elsif machine == "XL106"
            if tusu < 2001 then
              pressRate = 5000.0 / tusu
            elsif tusu > 15000 then
              pressRate = (1.23 - 0.65) * Math.exp(-0.00004 * (tusu - 15000)) + 0.65
            else
              pressRate = (2.55 - 1.2) * Math.exp(-0.00025 * (tusu - 2000)) + 1.2
            end
          end

          pressRate = pressRate.to_f * optRate.to_f

          add_press_price = ((pressRate.to_f * iro_num.to_i) * tusu.to_i).to_i

        else
          add_press_price = 0
        end

      end
    end

    ritems = Reportitem.where(job_id: job)
    roumu = 0.00
    ritems.each do |ritem|
      s = ritem.sonsi.blank? ? 0 : ritem.sonsi
      nin = (ritem.ope01.blank? ? 0 : 1) + (ritem.ope02.blank? ? 0 : 1) + (ritem.ope03.blank? ? 0 : 1) + (ritem.ope04.blank? ? 0 : 1)
      sonsi += s
      n += nin
    end
    rtimes = Reporttime.where(job_id: job)
    rtimes.each do |rtime|
      press = press + rtime.total_count
      r = r + rtime.total_count * nin
    end

    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "印刷"
    end
    insatumitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算

    insatusagaku = insatumitumori - add_press_price

    #時間
    if press > 0
      if n == 0
        n = 1
      end
      roumu = (r/3600.0).to_f
      #puts "r #{r} roumu #{roumu}"
    end

    rtime = rtimes.count > 0 ? rtimes[0] : Reporttime.new
    add_press_price = add_press_price.nil? ? 0 : add_press_price
    pressArr.push(insatumitumori)#0 積算額
    pressArr.push(add_press_price)#1 原価
    pressArr.push(insatusagaku)#2 粗利
    pressArr.push(rtime.work_date)#3 印刷日
    pressArr.push(rtime.report.present? ? rtime.report.machine : "")#4 機種
    pressArr.push(n)#5 担当者数
    pressArr.push(sonsi)#6 損紙
    pressArr.push(press)#7 印刷時間
    pressArr.push(roumu)#8労務
    return pressArr
  end

  def serch_pod(uploadfile,job,unit_price,add_datum, upinfos)
    rArray = Array.new
    color = 0
    mono = 0
    sp = 0
    print_count = count_chk(@info)
    chktimesPrint = Chktime.where("job_id = ? AND work_div = ? ",job,"プリント")
    r = chktimesPrint.sum(:work_time)

    slips = Slip.where(job_id: job, txtInfo03: "print")
    slips.each do |slip|
      color += slip.color_print.to_i
      mono += slip.mono_print.to_i
      sp += slip.sp_print.to_i
    end

    podgenka = color * unit_price.d16
    podgenka += mono * unit_price.d17
    podgenka += sp * unit_price.d18

    genka = podgenka.to_i

    #puts "podgenka #{podgenka} color #{unit_price.d16} mono #{unit_price.d17} sp #{unit_price.d18}"
    podgenka += (unit_price.d27 * (r / 60.0)).to_i
    if add_datum.pod.present?
      podgenka = podgenka + add_datum.pod
    end

    chktime = chktimesPrint.count > 0 ? chktimesPrint[0] : Chktime.new
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ?", 1, "POD",uploadfile )
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "POD"
    end
    podmitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算
    #podmitumori = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    ############労務情報############################################
    roumu = (r / 60.0).to_f
    ##############################################################
    podsagaku = (podmitumori - podgenka)
    rArray.push(podmitumori) #0 積算額
    rArray.push(podgenka) #1 原価
    rArray.push(podsagaku) #2 粗利
    rArray.push(chktime.work_date) #3 出力日
    rArray.push(r) #4 出力時間
    rArray.push(chktimesPrint.count) #5 担当者数
    rArray.push(color)#6 カラー出力
    rArray.push(mono) #7 mono
    rArray.push(sp) #8 sp
    rArray.push(roumu) #9 時間
    rArray.push(genka) #10 本当に原価

    return rArray
  end

  def color_count(info04,info05)
    r = info04.to_i > 0 ? 1 : 0
    r += info05.to_i > 0 ? 1 : 0
    return r
  end

  def color_set(info04,info05)
    return (info04.to_i).to_s + "x" + (info05.to_i).to_s
  end

  def serch_kako(uploadfile,job,unit_price,cutting,add_datum, upinfos)
    rArray = Array.new
    r = 0
    r2 = 0
    nin = 0
    nin2 = 0
    roumu = 0.0
    ktimes = Kakotime.where(job_id: job)
    ktimes.each do |ktime|
      #report =  ktime.kako_report
      kitem =  Kakoitem.find_by("report_id = ? AND job_id = ?",ktime.report_id ,job.id )
      if kitem.present?
        nin += (kitem.ope01.blank? ? 0 : 1) + (kitem.ope02.blank? ? 0 : 1) + (kitem.ope03.blank? ? 0 : 1) + (kitem.ope04.blank? ? 0 : 1)
      end
      r += ktime.total_count
    end
    r = r.present? ? r / 60 : 0
    cutting.each do |cut|
      nin2 += 1
      r2 += cut.work_time || 0
    end
    ktime = ktimes.count > 0 ? ktimes[0] : Kakoitem.new
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ?", 1, "加工",uploadfile )
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "加工"
    end
    kakomitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算
    #kakomitumori = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    roumu = ((r + r2) / 60.0).to_f
    kakogenka = (unit_price.d27 * ((r + r2) / 60.0) ).to_i <= 0 ? 0 : (unit_price.d27 * ((r + r2) / 60.0)).to_i
    #kakogenka += r2
    if add_datum.kako.present?
      kakogenka = kakogenka + add_datum.kako
    end

    kakosagaku = (kakomitumori - kakogenka)
    rArray.push(kakomitumori) #0 積算額
    rArray.push(kakogenka) #1 原価
    rArray.push(kakosagaku) #2 粗利
    rArray.push(ktime.work_date) #3 作業日
    rArray.push(nin) #4 作業者数
    rArray.push(r) #5 延べ時間
    rArray.push(nin2) #6 断裁作業者数
    rArray.push(r2) #7 断裁延べ時間
    rArray.push(r + r2) #8 合計時間
    rArray.push(roumu) #9 合計時間

    return rArray
  end

  def search_seisaku(uploadfile,job,unit_price,add_datum, upinfos)
    rArray = Array.new
    r = 0 #制作時間
    a = 0 #CPR時間
    rc = 0 #制作人数
    ac = 0 #cpr人数

    info = job.info
    tom_num = info.numInfo13
    tom_price = 0.00
    size1 = (info.numInfo06.blank? ? 0 : info.numInfo06) * (info.numInfo07.blank? ? 0 : info.numInfo07)
    size2 = (info.numInfo14.blank? ? 0 : info.numInfo14) * (info.numInfo15.blank? ? 0 : info.numInfo15)
    tmp = size2.to_i == 0 ? size1 : size2
    side = 0
    if info.numInfo04.to_i > 3
      side += 1
    end
    if info.numInfo05.to_i > 3
      side += 1
    end

    if @page > 2
      tmp_price = unit_price.d61
      # ページ物

      size = 0.5 # A1サイズ A4_8面
      tmp = tmp == 0 ? size : tmp
      if @specs.blank?
        dai = (size / tmp).to_i

        tom_price = (tmp_price * side) * dai
        if tom_num.to_i > 0
          tom_price = tom_price + (tom_price * tom_num)
        end

      else
        @specs.each do |spec|
          side = 0
          if spec.n07.to_i > 3
            side += 1
          end
          if spec.n08.to_i > 3
            side += 1
          end

          tom_price = tom_price + (tmp_price * side).to_i

          if tom_num.to_i > 0
            tom_price = tom_price + (tom_price * tom_num)
          end
        end
      end

    else
      tmp = (tmp.to_f / 1000000).to_f
      tom_price = tom_search(tmp, unit_price)
      tom_price = (tom_price * side).to_i
      if tom_num.to_i > 0
        tom_price = tom_price + (tom_price * tom_num)
      end
    end

    # 共通のベースクエリ
    base_query = Chktime.joins(:employee).where(job_id: job).where.not(work_div: "プリント")

    # 1. デザイン部門の条件（A OR B）
    design_condition = Employee.where(designer: 1)

    # 2. デザイン部門
    designers = base_query.merge(design_condition)

    # 3. 制作部門 (デザイン部門ではない全員)
    creators = base_query.where.not(id: designers.select(:id))
    # 共通のベースクエリ
    a = designers.sum(:work_time)
    ac = designers.count
    # 制作部門 (それ以外)
    r = creators.sum(:work_time)
    rc = creators.count

    total_time = CprTime.joins(:cpr_job).where(cpr_jobs: { job_id: job }).sum(:work_time)
    a += total_time

    seisakugenka = (unit_price.d25 * (r / 60.0)).to_i + (unit_price.d26 * (a / 60.0)).to_i + tom_price.to_i
    if add_datum.dtp.present?
      seisakugenka = seisakugenka + add_datum.dtp
    end
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ?", 1, "制作",uploadfile )
    # sel_upinfos = upinfos.select do |upinfo|
    #   (upinfo.name == "制作" && upinfo.category == "2") || (upinfo.name == "下版" && upinfo.category == "1")
    # end
    sel_upinfos = upinfos.select do |upinfo|
      (upinfo.name == "制作" && upinfo.category == 2) || (upinfo.name == "下版" && upinfo.category == 1)
    end
    seisakumitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算
    #upinfo2 = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ?", 1, "下版",uploadfile )
    # upinfo2 = upinfos.find do |upinfo|
    #   upinfo.name == "下版"
    # end
    # seisakumitumori = (upinfo.blank? ? 0 : upinfo.infoItem.to_i) + (upinfo2.blank? ? 0 : upinfo2.infoItem.to_i)
    # 労務
    roumu = 0.0
    if r > 0
      roumu = (r / 60.0).to_f
    end
    roumu2 = 0.0
    if a > 0
      roumu2 = (a / 60.0).to_f
    end
    seisakusagaku = (seisakumitumori - seisakugenka)

    rArray.push(seisakumitumori) #0 積算額
    rArray.push(seisakugenka) #1 原価
    rArray.push(seisakusagaku) #2 粗利
    rArray.push(rc) #3 制作担当数
    rArray.push(r) #4 制作担時間
    rArray.push(ac) #5 デザイン担当数
    rArray.push(a) #6 デザイン担当時間
    rArray.push(tom_price) #7 トムカラー金額
    rArray.push(roumu) #8 制作時間
    rArray.push(roumu2) #9 デザイナー時間

    return rArray
  end

  def search_gaicyu(uploadfile,job,unit_price,add_datum,upinfos)
    rArray = Array.new
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ? AND category = ?", 1, "外注",uploadfile , 2 )
    # if @uploadfile&.name&.start_with?("MV") || @uploadfile&.name&.start_with?("BIG")
    #   gaicyumitumori = 0
    #   gaicyugenka = 0
    # else
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "外注" && upinfo.category == 2
    end
    gaicyumitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算

    # gaicyumitumori = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ? AND category = ?", 1, "外注",uploadfile , 12)
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "外注" && upinfo.category == 12
    end
    gaicyugenka = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算
    # end

    # 積算書の登録忘れや記載漏れ（外注原価が0）の場合、下段の原価費用のみ外注依頼書履歴のうち日付が最も新しい発注金額から取得する
    # ※上段の見積額は積算書上の金額であり、外注依頼書の受注金額は案件全体の受注金額のため反映しない
    latest_outsource = (@job.present? && @job.id == job&.id && defined?(@latest_outsource_order)) ? @latest_outsource_order : OutsourceOrder.latest_for_job(job)
    outsource_source = gaicyugenka > 0 ? "積算書" : ""
    if gaicyugenka == 0 && latest_outsource.present?
      gaicyugenka = latest_outsource.order_amount.to_i
      outsource_source = "外注依頼書"
    end

    #Job.den_idの該当するSaleにポスティング料、折込料があれば外注費として計上する
    orikomi = Sale.where("job_id = ? AND (t07 like ? OR t07 like ? OR t07 like ?)",job&.id ,"%ポスティング料%","%折込料%","%折込み料%").sum(:d02)
    #puts "orikomi #{orikomi}"
    gaicyugenka  = gaicyugenka + orikomi + @hassoArr[10].to_i#西郵便局分
    puts "add_datum.out_cost #{add_datum.out_cost.to_i}"
    #gaicyugenka = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    if add_datum.out_cost.present?
      gaicyugenka = gaicyugenka + add_datum.out_cost
    end
    gaicyusagaku = (gaicyumitumori - gaicyugenka)
    puts "gaicyugenka #{gaicyugenka}"
    rArray.push(gaicyumitumori) #0 積算額
    rArray.push(gaicyugenka) #1 原価
    rArray.push(gaicyusagaku) #2 粗利
    rArray.push(outsource_source) #3 参照元（"積算書" or "外注依頼書"）
    rArray.push(latest_outsource) #4 最新外注依頼書レコード

    return rArray
  end

  def search_assembly(uploadfile,job,unit_price,add_datum,upinfos)
    tasks = job.tasks
    workers = Array.new
    r = 0
    tasks.each do |task|
      workers.push(task.workers)
      r = r + task.workers.sum(:work_time)
    end
    sannkanum = workers.count

    rArray = Array.new
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ? AND category = ?", 1, "アセンブリ",uploadfile,2 )
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "アセンブリ" && upinfo.category == 2
    end
    assemblymitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算
    ##労務#################
    roumu = (r / 60.0).to_f
    # assemblymitumori = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ? AND category = ?", 1, "アセンブリ",uploadfile,12 )
    #assemblygenka = upinfo.blank? ? (assemblymitumori * 0.9).to_i : upinfo.infoItem.to_i
    assemblygenka = (unit_price.d29 * (r / 60.0)).to_i
    if add_datum.assembly.present?
      assemblygenka = assemblygenka + add_datum.assembly
    end
    assemblysagaku = (assemblymitumori - assemblygenka)
    rArray.push(assemblymitumori) #0 積算額
    rArray.push(assemblygenka) #1 原価
    rArray.push(assemblysagaku) #2 粗利
    rArray.push(sannkanum) #3 参加人数
    rArray.push(r) #4 延べ時間
    rArray.push(roumu) #労務

    return rArray
  end

  def search_hasso(uploadfile,job,unit_price,add_datum,upinfos)
    cargos = job.cargos
    dist_hs = Hash.new
    dist_name = Array.new
    cargos.each do |cargo|
      if dist_hs[cargo.destination].present?

        tmp = dist_hs[cargo.destination]

        dist_hs[cargo.destination] = tmp + cargo.weight.to_i
      else
        dist_hs[cargo.destination] = cargo.weight.blank? ? 0 : cargo.weight
        dist_name.push(cargo)
      end

    end
    dist_name.uniq!
    rArray = Array.new
    #upinfo = UpInfo.find_by("lastest = ? AND name = ? AND uploadfile_id = ?", 1, "梱包・発送",uploadfile )
    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "梱包・発送"
    end
    hassomitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i # 整数に変換した値の配列を作成
    end.sum # その配列の合計を計算
    #hassomitumori = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    #hassogenka = (hassomitumori * 0.9).to_i
    roumu = 0.00
    #all_fee = cargos.sum(:fee)
    mail_cargos, other_cargos = cargos.partition { |c| c.name == "郵便" }
    mail_fee  = mail_cargos.sum(&:fee)
    all_fee = other_cargos.sum(&:fee)
    own_company_fee = cargos.where(name: "自社").sum(:fee)
    if own_company_fee > 0
      roumu = (own_company_fee / unit_price.d25)
    end
    hassogenka = all_fee + mail_fee

    #cost = (all_fee - own_company_fee) + add_datum.delivery.to_i
    #202604西郵便局分は外注費から発送費に変更
    cost = (all_fee + mail_fee - own_company_fee) + add_datum.delivery.to_i
    mail_fee = 0
    if add_datum.delivery.present?
      hassogenka = hassogenka + add_datum.delivery
    end
    hassosagaku = (hassomitumori - hassogenka)
    rArray.push(hassomitumori) #0 積算額
    rArray.push(hassogenka) #1 原価
    rArray.push(hassosagaku) #2 粗利

    rArray.push(delivery_helper(dist_hs,dist_name[0], "未登録") ) #3 配送先１
    rArray.push(delivery_helper(dist_hs,dist_name[1], "")) #4 配送先2
    rArray.push(delivery_helper(dist_hs,dist_name[2], "") ) #5 配送先3
    rArray.push(delivery_helper(dist_hs,dist_name[3], "") ) #6 配送先4
    rArray.push(delivery_helper(dist_hs,dist_name[4], "") ) #7 配送先5
    rArray.push(roumu) #8 自社配送労務
    rArray.push(cost) #9 間接費(直接)
    rArray.push(mail_fee) #10 郵便の発送碑 -> 外注費
    return rArray
  end

  def search_keihi(uploadfile, job, unit_price, upinfos)
    genkasum = @papers[1] + @ctpArr[1] + @pressArr[1] + @podArr[1] + @kakoArr[1] + @seisakuArr[1] + @assemblyArr[1] + @hassoArr[1] # + @gaicyuArr[1]

    rArray = Array.new

    upinfo = upinfos.find do |upinfo|
      upinfo.name == "営業経費%"
    end
    keihipar = upinfo.blank? ? 0 : upinfo.infoItem.to_i

    sel_upinfos = upinfos.select do |upinfo|
      upinfo.name == "営業経費"
    end
    keihimitumori = sel_upinfos.map do |upinfo|
      upinfo.infoItem.to_i #
    end.sum #
    #keihimitumori = upinfo.blank? ? 0 : upinfo.infoItem.to_i
    if keihimitumori == 0
      genka = genkasum * 0.05
      keihipar = unit_price.d31
      keihigenka = genka
    else
      keihigenka = keihimitumori
    end
    if @value_total_sale > 0
      tmp = (@value_total_sale - @gaicyuArr[1].to_i) * (@unit_price.d31 / 100)

      if @info.textInfo02&.include?("オフ輪")
        tmp = tmp.to_i < 4000 ? 4000 : tmp.to_i
      elsif @info.textInfo02&.include?("プリント出力")
        if @value_total_sale < 2000 || tmp < 300
          tmp = 300
        end

      elsif @value_total_sale < 5000 || tmp < 500
        tmp = 500
      end
      keihigenka = tmp.to_i
    end
    keihisagaku = (keihimitumori - keihigenka)
    rArray.push(keihimitumori) #0 積算額
    rArray.push(keihigenka) #1 原価
    rArray.push(keihisagaku) #2 粗利
    rArray.push(keihipar) #3 %

    return rArray
  end

  def search_sum(uploadfile,job,unit_price,add_datum,upinfos)
    @cal_sums = Array.new

    @cal_sums.push(@value_total_sale)
    #見積もり提出額 1
    sekisan = upinfos.find do |upinfo|
      upinfo.name == "提出金額"
    end
    @cal_sums.push( sekisan.present? ? sekisan.infoItem : 0 )
    #営業積算額 2
    sekisan = @papers[0] + @ctpArr[0] + @pressArr[0] + @podArr[0] + @gaicyuArr[0] + @kakoArr[0] + @seisakuArr[0] + @assemblyArr[0] + @hassoArr[0] + @keihiArr[0]
    @cal_sums.push(sekisan)
    #原価 3
    @genka = @papers[1] + @ctpArr[1] + @pressArr[1] + @podArr[1] + @gaicyuArr[1] + @kakoArr[1] + @seisakuArr[1] + @assemblyArr[1] + @hassoArr[1] + @keihiArr[1]
    @cal_sums.push(@genka)
    #差額
    @cal_sums.push(@value_total_sale - @genka)
  end


  def tom_search(size,unit_price)
    if size > 0.7348432
      return unit_price.d51
    elsif size > 0.48956292
      return unit_price.d61
    elsif size > 0.3674216
      return unit_price.d52
    elsif size > 0.244902
      return unit_price.d62
    elsif size > 0.1837108
      return unit_price.d53
    elsif size > 0.1222452
      return unit_price.d63
    elsif size > 0.09167704
      return unit_price.d54
    elsif size >  0.0611226
      return unit_price.d64
    elsif size > 0.04583852
      return unit_price.d55
    else
      return unit_price.d65
    end
  end

  def meisi_num_helper(info)
    jisu = 0
    yobi = 0
    if @info.textInfo07&.include?("名刺")
      if @info.textInfo29&.include?("箱") && @info.numInfo01.to_i > 0
        jisu = (@info.numInfo01 * 100).to_i
      else
        jisu = @info.numInfo01.to_i
      end

      if @info.textInfo30&.include?("箱") && @info.numInfo02.to_i > 0
        jisu = jisu + (@info.numInfo02 * 100).to_i
      else
        jisu = jisu + @info.numInfo02.to_i
      end

      if @info.textInfo31&.include?("箱") && @info.numInfo03.to_i > 0
        jisu = jisu + (@info.numInfo03 * 100).to_i
      else
        jisu = jisu + @info.numInfo03.to_i
      end
    else
      jisu = @info.numInfo01.to_i + @info.numInfo02.to_i + @info.numInfo03.to_i
    end
    yobi = (jisu / 100) * 7

    return [jisu,yobi]
  end

  def mihon(info)
    r = 0
    if info.numInfo02.present?
      r = r + info.numInfo02
    end
    if info.numInfo03.present?
      r = r + info.numInfo03
    end
    return r
  end

  def hiduke_helper(date)
    if date.blank? then
      return ""
    else
      y = date.year.to_s + "年"
      m = date.month.to_s + "月"
      d = date.day.to_s + "日"
      return y + m + d
    end
  end
  def hiduke2_helper(date)
    if date.blank? then
      return ""
    else
      m = date.month.to_s + "月"
      d = date.day.to_s + "日"
      return m + d
    end
  end
  def hiduke3_helper(date)
    if date.blank? then
      return ""
    else
      m = date.month.to_s
      d = date.day.to_s
      return m + "/" + d
    end
  end
  def hiduke4_helper(date)
    if date.blank? then
      return ""
    else
      y = date.year
      m = date.month
      d = date.day
      #puts "hiduke4_helper #{y} #{m} #{d}"
      return "#{y}/#{m}/#{d}"
    end
  end
  def hiduke5_helper(num)
    begin
      if num.length == 8
        y = num[0,3].to_s
        m = num[4,5].to_s
        d = num[6,7].to_s
        return ("#{num} #{y}-#{d}").to_date
        #return ("2025-10-20").to_date
      else
        return ""
      end
    rescue
      return ""
    end
  end
  def second_time(inseconds)
    outtext = ""
    outmihour = inseconds / 3600
    outminutes = (inseconds % 3600) / 60
    if outmihour == 0 then
      outtext = "0"
    elsif outmihour < 10 then
      outtext = outmihour.to_s
    else
      outtext = outmihour.to_s
    end
    outtext << ":"
    if outminutes == 0 then
      outtext << "00"
    elsif outminutes < 10 then
      outtext <<  "0" + outminutes.to_s
    else
      outtext << outminutes.to_s
    end

    return outtext
  end
  def time_int(i)
    if i.blank? || i ==  0 || i == "0" then
      return "0"
    else
      mainasu = i < 0 ? true : false
      i = i.abs
      h = (i / 60).to_s
      m = (i % 60) < 10 ? "0" +  (i % 60).to_s : (i % 60).to_s
      if mainasu then
        r = "-" + h + ":" + m
      else
        r = h + ":" + m
      end
      return r
    end
  end
  def print_time_int(i)
    if i.blank? || i ==  0 || i == "0" then
      return "0"
    else
      mainasu = i < 0 ? true : false
      i = i.abs
      i = i / 60
      h = (i / 60).to_s
      m = (i % 60) < 10 ? "0" +  (i % 60).to_s : (i % 60).to_s
      if mainasu then
        r = "-" + h + ":" + m
      else
        r = h + ":" + m
      end
      return r
    end
  end
  def numformat1(n)
    n = n.nil? ? 0 : n
    n = n.blank? ? 0 : n.to_i

    if n < 0
      mainus = "-"
      n =  n.to_i.abs.to_s
    else
      mainus = ""
      n =  n.to_i.to_s
    end

    size = n.size
    if size > 9
      return "#{mainus}#{n[ 0 , size - 9]},#{n[ size - 9 , 3]},#{n[ size -6, 3]},#{n[ size -3, 3]}"
    elsif size > 6
      return "#{mainus}#{n[ 0 , size - 6]},#{n[ size - 6, 3]},#{n[ size -3, 3]}"
    elsif size > 3
      return "#{mainus}#{n[ 0 , size - 3]},#{n[ size - 3, 3]}"
    else
      return "#{mainus}#{n}"
    end
  end
  def print_tanka(size,unit_price,job)
    info = job.info

    if(info.textInfo02.index("オフ輪"))
      return unit_price.d11
    elsif(info.textInfo02.index("オフセット"))
      if size <= 0.338 #K版
        return unit_price.d15
      elsif size <= 0.6016 #K全版
        return unit_price.d14
      else
        return unit_price.d13
      end
      #elsif (info.textInfo02.index("プリント"))
      else
      return 6 #1色
    end
  end
  def macnine_helper(sm74,xl106)
    if sm74 == 1
      return "SM74"
    elsif xl106 == 1
      return "XL106"
    end
  end
  def machine_name
    {
      'SM74' => 'SM74',
      '74' => 'SM74',
      '6C' => 'SM74',
      'XL106' => 'XL106',
      '106' => 'XL106',
      '5C' => 'XL106',
      'SM102' => 'SM102',
      '4C' => 'SM102',
      'GTO' => 'GTO'
    }
  end
  def delivery_helper(dist_hs, dist_name, txt)
    if dist_name.present?
      w = dist_hs[dist_name.destination]
      if w == 0
        return  dist_name.destination.present? ? "#{dist_name.destination}:#{dist_name.name} " : txt
      else
        return  dist_name.destination.present? ? "#{dist_name.destination}:#{dist_hs[dist_name.destination]} kg" : txt
      end
    end
  end
  def delivery_csv_helper(dist_hs, dist_name, txt)
    if dist_name.present?
      w = dist_hs[dist_name.destination]
      if w == 0
        return  dist_name.destination.present? ? [dist_name.destination,dist_name.name] : [txt , ""]
      else
        return  dist_name.destination.present? ? [dist_name.destination,dist_hs[dist_name.destination]] : [txt , ""]
      end
    end
  end
  def kikaku_saiz
    {
      'D4' =>    [ 406 , 273 ],
      'D/4' =>   [ 406 , 273 ],
      'B4' =>   [ 383 , 273 ],
      'B/4' =>   [ 383 , 273 ],
      'D3' =>  [ 546 , 406 ],
      'D/3' =>  [ 546 , 406 ],
      'B3' =>  [ 546 , 383 ],
      'B/3' =>   [ 546 , 383 ],
      'D2' =>  [ 813 , 546 ],
      'D/2' =>   [ 813 , 546 ],
      'B2' =>  [ 766 , 546 ],
      'B/2' =>  [ 766 , 546 ],
      'A3' =>  [ 420 , 297 ],
      'A/3' =>  [ 420 , 297 ],
      'A/4' =>   [ 210 , 297 ],
      'A4' =>  [ 210 , 297 ],
      'A/5' =>   [ 210 , 148 ],
      'A5' =>   [ 210 , 148 ]
    }
  end

  def size_helper_wrap(job)
    r = ""
    info = job.info
    kikaku = info.textInfo20
    tmp = size_helper3(info.numInfo06,info.numInfo06)
    if tmp.present? && kikaku.present?
      r = kikaku + " " + tmp
    elsif tmp.present?
      r = "仕上 " + tmp
    end
    tmp = size_helper3(info.numInfo14,info.numInfo15)
    if tmp.present?
      r = r + "<br>展開 " + tmp
    end
    if r.blank? && kikaku.present?
      r = "<span style='font-size: 120%'>#{kikaku}</span>"
    end
    return raw(r)
  end
  def size_helper3(size1,size2)
    if size1 || size2
      sa = size1.present? ? size1 : 0
      sb = size2.present? ? size2 : 0
      return "#{sa} x #{sb}"
    else
      return ""
    end

  end
  def size_helper2(sizes,size1,size2,men)
    sizes = sizes || [0,0]
    if size1 == 0 && size2 ==0
      size = sizes[0].to_i * sizes[1].to_i
    else
      size = size2 > size1 ? size2 : size1
    end
    size = size * men
    size = size.to_f / 1000000
    return size
  end
  def size_helper3_wrap(size1,size2)
    if size1 || size2
      sa = size1.present? ? size1 : 0
      sb = size2.present? ? size2 : 0
      return "#{sa} x #{sb}"
    else
      return ""
    end
  end
  def size_cal(info)
    return kikaku_saiz[info.textInfo20]
  end
  def color2_helper_wrap(job)
    info = job.info
    return color2_helper(info.numInfo16, info.numInfo17, info.numInfo04, info.numInfo05, info.textInfo02 )

  end
  def color2_helper(numInfo16, numInfo17, numInfo04, numInfo05 ,textInfo02)
    # if numInfo16 == 1 && numInfo17 == 1
    #   p = ""
    # else
    #   p = "<span class='sp'>特色<span>"
    # end
    unless textInfo02 == "プリント出力"
      if numInfo04.to_i > 0  && numInfo16.to_i < 1
        p = "<span class='sp'>特色<span>"
      end
      if numInfo05.to_i > 0  && numInfo17.to_i < 1
        p = "<span class='sp'>特色<span>"
      end
    else
      if numInfo04.to_i == 5 || numInfo05.to_i == 5
        p = "<span class='sp'>特色<span>"
      end
    end
    ca = numInfo04.present? ? numInfo04 : "0"
    cb = numInfo05.present? ? numInfo05 : "0"
    return raw("#{ca}<span> x </span>#{cb}#{p}")
  end
  def textInfo02_helper(data)
    if data == "002　オフセット"
      return "オフセット"
    elsif data == "003　オフ輪"
      return "オフ輪"
    elsif data == "005　その他"
      return "その他"
    else
      return data
    end

  end

  def mentuke(job)
    info = job.info
    if(info.textInfo02.index("オフ輪"))
      return select_size_web[info.textInfo20].to_i
    else
      return 1
    end
  end

  def ctptanka(tanka,machine)
    if machine == "オフ三菱"
      return tanka.d36
    elsif machine == "XL106"
      return tanka.d37
    elsif machine == "4色機"
      return tanka.d38
    elsif machine == "SM74"
      return tanka.d39
    elsif machine == "GTO"
      return tanka.d40
    else
      return ""
    end
  end
  #カレンダー対象日の日付の配列
  def date_array(created_at,num)
    a = Array.new
    sdate(created_at).upto(sdate(created_at) + num) do |d|
      a.push d
    end
    return a
  end
  def hash_by_date (tasks)
    h = Hash.new
    tasks.each{|c|
      h[c.work_date] = c

    }
    return h
  end
  def array_hash_by_position(in_cal,posi)
    jcals = Array.new
    cal = in_cal.blank? ? Calendar.new : in_cal##カレンダーが無い場合には新規で作成しています
    cal.cal_startday = cal.cal_startday.blank? ? Date.today + 1 : cal.cal_startday
    schedules = Schedule.where("calendar_id = ? AND position = ?", cal,posi)
    h = hash_by_date(schedules)
    cal.cal_startday = cal.cal_startday
    i = 0
    date_array = date_array(cal.cal_startday,48)
    date_array.each do |workdate |
      jcal = h[workdate]
      if jcal.blank?##taskが無い場合には新規で作成しています
        newcal = Schedule.new
        newcal.calendar_id = cal.id
        newcal.work_date = workdate
        jcals[i] = newcal
      else
        jcals[i] = jcal
      end
      i += 1
    end
    return jcals
  end

  def array_hash_by_schedule(schedules,cal)
    jcals = Array.new
    h = hash_by_date(schedules)
    i = 0
    for workdate in date_array(cal.cal_startday,48)
      jcal = h[workdate]
      if jcal.blank?##taskが無い場合には新規で作成しています
        newcal = Schedule.new
        newcal.calendar_id = cal.id
        newcal.work_date = workdate
        jcals[i] = newcal
      else
        jcals[i] = jcal
      end
      i += 1
    end
    return jcals
  end
  def sdate(created_at)
    created_at = created_at - created_at.wday
    Date.new(created_at.year, created_at.month,created_at.day )
  end
  def chk_holiday(d)
    holy = HolyDate.new
    hday = holy.national_holiday?(d)
    if hday then
      return " holiday"
    elsif d.wday == 0 then
      return " holiday"
    elsif d == Date.today then
      return " today"
    else
      return nil
    end
  end
  def date_helper_sale(t03)
    if t03.present?
      return "#{t03[0,4]}-#{t03[4,2]}-#{t03[5,2]}"
    else
      return ""
    end
  end
  def date_helper_short(date)
    if date.present?
      return date.strftime("%m/%d")
    else
      return ""
    end
  end
  def date_helper_short2(date,num)
    if num == 1 || date.day == 1
      return date.strftime("%m/%d")
    else
      return date.strftime("%d")
    end
  end
  def sum_add_value_paper_price(job)
    add_values = AddValue.where(job_id: job)
    add_yousigenka = 0
    add_values.each do |value|
      add_yousigenka = add_yousigenka + value.paper_price
    end
    return add_yousigenka
  end
  def out_csv_press(add_values,add_presses)
    @value_press = 0
    @value_press_num = 0
    @value_press_sasi = 0
    add_presses.each do |press|
      @value_press = @value_press + press.dai_price.to_i
      @value_press_num = @value_press_num + press.jisu.to_i
      @value_press_sasi = @value_press_sasi + (press.sasi.present? ? press.sasi.to_i - 1 : 0)
    end
    @value_paper = 0
    @value_paper_num = 0
    add_values.each do |value|
      @value_paper = @value_paper + value.paper_price.to_i
      @value_paper_num = @value_paper_num + value.jisu.to_i
    end
  end
  def total_helper()
    @total_paper = 0
    @total_ctp = 0
    @total_press = 0
    @total_pod = 0
    @total_kako = 0
    @total_seisaku = 0
    @total_gaicyu = 0
    @total_assembly = 0
    @total_hasso = 0
    @total_keihi = 0
    @total_sum = 0
  end
  def total_sum_helper()
    @total_paper = @total_paper + @papers[1].to_i
    @total_ctp = @total_ctp + @ctpArr[1].to_i
    @total_press = @total_press + @pressArr[1].to_i
    @total_pod = @total_pod + @podArr[1].to_i
    @total_kako = @total_kako + @kakoArr[1].to_i
    @total_seisaku = @total_seisaku + @seisakuArr[1].to_i
    @total_gaicyu = @total_gaicyu + @gaicyuArr[1].to_i
    @total_assembly = @total_assembly + @assemblyArr[1].to_i
    @total_hasso = @total_hasso  + @hassoArr[1].to_i
    @total_keihi = @total_keihi  + @keihiArr[1].to_i
    @total_sum = @total_sum + @cal_sums[3].to_i

  end
  def parent_helper(add_datum)
    if add_datum.present? && add_datum.parent_code.present?
      return raw(" style='display: none'")
    end
  end
  def parent_index_helper(job)
    if job.present?
      return raw(" style='display: none'")
    end
  end
  def parent_csv_helper(add_datum)
    if add_datum.present? && add_datum.parent_code.present?
      return false
    else
      return true
    end
  end
  def parent_archive_helper(add_datum)
    if add_datum.present? && add_datum.parent_code.present?
      return add_datum.parent_code
    end
  end

  # 用途: 親ジョブに紐づく子ジョブ（AddDatum.parent_code が親の den_id のもの）を集計します。
  # 引数:
  #   job: 親とみなす Job。job.den_id をキーに子ジョブを検索します。
  # 役割/副作用:
  #   - 各種コストの「原価合計」を @tmp_array[0..9] に加算します。
  #   - 各種コストの「見積合計」を @mitumori_array[0..9] に加算します。
  #   - 子件数 @child_count、子の伝票番号配列 @childs_den_id を設定します。
  #   - このメソッド単体では親ジョブ分は含めず、子ジョブ分のみを集計します。
  # 想定される呼び出し箇所:
  #   - AddValues の一覧/CSV で、親行に子ジョブの合算値を表示する前段処理。
  def child_helper(job)
    #合算するJobがあれば
    @mitumori_array = Array.new(11)
    @tmp_array = Array.new(11)
    @tmp_hiyou_sum = 0
    @mitumori_sum = 0
    @sale_sum = 0
    child_ids = AddDatum.where(parent_code: job.den_id)
    @child_count = 0
    @childs_den_id = []
    child_ids.each do |datum|
      arari_cal_wap(datum.job)
      @tmp_array[0] = @tmp_array[0].to_i + @papers[1].to_i
      @tmp_array[1] = @tmp_array[1].to_i + @ctpArr[1].to_i
      @tmp_array[2] = @tmp_array[2].to_i + @pressArr[1]
      @tmp_array[3] = @tmp_array[3].to_i + @podArr[1].to_i
      @tmp_array[4] = @tmp_array[4].to_i + @kakoArr[1].to_i
      @tmp_array[5] = @tmp_array[5].to_i + @seisakuArr[1].to_i
      @tmp_array[6] = @tmp_array[6].to_i + @gaicyuArr[1].to_i
      @tmp_array[7] = @tmp_array[7].to_i + @assemblyArr[1].to_i
      @tmp_array[8] = @tmp_array[8].to_i + @hassoArr[1].to_i
      @tmp_array[9] = @tmp_array[9].to_i + @keihiArr[1].to_i

      @mitumori_array[0] = @mitumori_array[0].to_i + @papers[0].to_i
      @mitumori_array[1] = @mitumori_array[1].to_i + @ctpArr[0].to_i
      @mitumori_array[2] = @mitumori_array[2].to_i + @pressArr[0]
      @mitumori_array[3] = @mitumori_array[3].to_i + @podArr[0].to_i
      @mitumori_array[4] = @mitumori_array[4].to_i + @kakoArr[0].to_i
      @mitumori_array[5] = @mitumori_array[5].to_i + @seisakuArr[0].to_i
      @mitumori_array[6] = @mitumori_array[6].to_i + @gaicyuArr[0].to_i
      @mitumori_array[7] = @mitumori_array[7].to_i + @assemblyArr[0].to_i
      @mitumori_array[8] = @mitumori_array[8].to_i + @hassoArr[0].to_i
      @mitumori_array[9] = @mitumori_array[9].to_i + @keihiArr[0].to_i
      @mitumori_array[10] = @mitumori_array[10].to_i + @cal_sums[1].to_i

      add_datum = AddDatum.find_by(job_id: datum.job)

      @sale_sum += value_cal_price_helper(datum.job,add_datum)

      @child_count += 1
      @childs_den_id.push(datum.job.den_id)
    end
  end

  # 用途: child_helper で集計した「子ジョブ分」に、親ジョブ（引数 job 自身）の値を加算し、合算トータルを求めます。
  # 引数:
  #   job: 合算のベースとなる親 Job。
  # 役割/副作用:
  #   - 親ジョブの原価を @tmp_array[0..9] に加算します。
  #   - 親ジョブの見積を @mitumori_array[0..9] に加算します。
  #   - @tmp_hiyou_sum（原価合計の総和）と @mitumori_sum（見積合計の総和）を算出します。
  #   - 事前に child_helper(job) を呼んでおくと、子+親の合算トータルが得られます。
  # 想定される呼び出し箇所:
  #   - AddValues の一覧/CSV で、表示用の合算原価・見積・粗利などを計算する直前。
  def child_plus_helper(job)
      #ベースになるJobの費用

      @tmp_array ||= Array.new(10)

      @child_count ||= 0
      arari_cal_wap(job)
      @tmp_array[0] = @tmp_array[0].to_i + safe_i(@papers[1])
      @tmp_array[1] = @tmp_array[1].to_i + safe_i(@ctpArr[1])
      @tmp_array[2] = @tmp_array[2].to_i + safe_i(@pressArr[1])
      @tmp_array[3] = @tmp_array[3].to_i + safe_i(@podArr[1])
      @tmp_array[4] = @tmp_array[4].to_i + safe_i(@kakoArr[1])
      @tmp_array[5] = @tmp_array[5].to_i + safe_i(@seisakuArr[1])
      @tmp_array[6] = @tmp_array[6].to_i + safe_i(@gaicyuArr[1])
      @tmp_array[7] = @tmp_array[7].to_i + safe_i(@assemblyArr[1])
      @tmp_array[8] = @tmp_array[8].to_i + @hassoArr[1].to_i
      @tmp_array[9] = @tmp_array[9].to_i + safe_i(@keihiArr[1])
      @mitumori_array[0] = @mitumori_array[0].to_i + @papers[0].to_i
      @mitumori_array[1] = @mitumori_array[1].to_i + @ctpArr[0].to_i
      @mitumori_array[2] = @mitumori_array[2].to_i + @pressArr[0]
      @mitumori_array[3] = @mitumori_array[3].to_i + @podArr[0].to_i
      @mitumori_array[4] = @mitumori_array[4].to_i + @kakoArr[0].to_i
      @mitumori_array[5] = @mitumori_array[5].to_i + @seisakuArr[0].to_i
      @mitumori_array[6] = @mitumori_array[6].to_i + @gaicyuArr[0].to_i
      @mitumori_array[7] = @mitumori_array[7].to_i + @assemblyArr[0].to_i
      @mitumori_array[8] = @mitumori_array[8].to_i + @hassoArr[0].to_i
      @mitumori_array[9] = @mitumori_array[9].to_i + @keihiArr[0].to_i
      @mitumori_array[10] = @mitumori_array[10].to_i + @cal_sums[1].to_i

      10.times do |i|
        @tmp_hiyou_sum = @tmp_hiyou_sum + @tmp_array[i].to_i
      end
      10.times do |i|
        @mitumori_sum = @mitumori_sum + @mitumori_array[i].to_i
      end

      add_datum = AddDatum.find_by(job_id: job.id)

      @sale_sum += value_cal_price_helper(job,add_datum)

  end

  def value_cal_price_helper(job,add_datum)
    sales = Sale.where("job_id = ?", job)
    rValue = 0
    sales.each do |sale|
      if sale.present?
        if add_datum.present?
          rValue = rValue.to_i + add_datum.sales_price.to_i
        end
        puts "rValue.to_i #{rValue.to_i} sale.d02　#{sale.d02} job#{job.id}"
        rValue = rValue.to_i + sale.d02
      end

    end
    return rValue
  end

  def list_mark_helper(info)
    unless info.blank? then
      unless info.job.blank? then
        unless info.job.update_at.blank? then
          if info.cansel == 1 then
            return raw("<div id='size' class='cansel'>&nbsp;</div>")
            return raw("<div id='size' class='hold'>&nbsp;</div>")
          elsif info.job.update_at > Time.now then
            return raw("<div id='size' class='new'>&nbsp;</div>")
          else
            works = info.job.works
            r = taisyou_helper_name(works)
            return r.blank? ? "" : raw(r.gsub(/全工程終了/,"全終了"))
          end
        end
      end
    end
  end
  def taisyou_helper_name(works)
    if works.blank? then
      return nil
    end
    outArray = []
    outtext = ""
    for work in works
      if work.status == "終了" then
        if work.name == "全工程" then
          return "<div id='task' class='e'>全工程終了</div>"
        else
          unless taisyo_name[work.name].blank? then
            if work.work_div == "制作" then
              outArray[0] = "<div id='task' class='" + taisyo_name[work.name] + "'>" + work.name + "</div>"
            elsif work.work_div == "製版" then
              outArray[1] = "<div id='task' class='" + taisyo_name[work.name] + "'>" + work.name + "</div>"
            elsif work.work_div == "印刷" then
              outArray[2] = "<div id='task' class='" + taisyo_name[work.name] + "'>" + work.name + "</div>"
            elsif work.work_div == "製本" then
              outArray[3] = "<div id='task' class='" + taisyo_name[work.name] + "'>" + work.name + "</div>"
            end
          end
        end
      end
    end
    4.times{|i|
      unless outArray[i].blank? then
        if outtext.blank? then
          outtext = outArray[i].to_s
        else
          outtext << outArray[i].to_s
        end
      end
    }
    return outtext
  end
  def taisyo_name
    {
      '校了' => 'a',
      'CTP' => 'b',
      '印刷' => 'c',
      '製本' => 'd',
      '全工程' => 'e'
    }
  end
  def cost_over_helper(par)
    if par > 100 then
      return "cal_red"
    elsif par > 80 then
      return "cal_orange"
    end
  end
  def cost_arari_helper(par)
    if par < 0 then
      return "cal_red"
    else
      return "cal_blue"
    end
  end

  def book_helper( h , c , t)
    r_txt = ""
    if h.present? && h != 0
      r_txt << "【表紙】#{h} <span>p</span>"
    end
    if c.present? && c != 0
      r_txt << "【本文】#{c} <span>p</span>"
    end
    if t.present?
      r_txt << "【綴じ】#{t}"
    end
    return raw(r_txt)
  end
  def book_helper2( h , c)
    r_txt = ""
    if h.present? && h != 0
      r_txt << "表紙:#{h}p "
    end
    if c.present? && c != 0
      r_txt << "本文:#{c}p "
    end
    return r_txt
  end
  def book_helper3( h , c)
    r_txt = 0
    if h.present? && h != 0
      r_txt = r_txt + h
    end
    if c.present? && c != 0
      r_txt = r_txt + c
    end
    return r_txt == 0 ? "" : raw(r_txt.to_s + "p")
  end
  def book_helper4( h , c)
    r_txt = ""
    r_num = 0
    if h.present? && h != 0
      r_txt << "表紙:#{h}p "
      r_num = r_num + h
    end
    if c.present? && c != 0
      unless r_txt == ""
        r_txt << "<br>"
      end
      r_txt << "本文:#{c}p "
      r_num = r_num + c
    end
    if r_num > 0
      unless r_txt == ""
        r_txt << "<br>"
      end
      r_txt << "合計:#{r_num}p "
    end
    return r_txt
  end
  def kako_list(job)
    kakos = Kako.where("job_id = ? AND lastest = ?",job , 1)
    rArray = Array.new
    kakos.each do |kako|
      if kako.kako_t01.present?
        rArray.push([kako.kako_t01 , kako.kako_t02.blank? ? "-" : kako.kako_t02 ])
      end
    end
    return rArray
  end
  def kako_helper(job)
    r = ""
    kakos = kako_list(job)
    kakos.each do |kako|
      if r.blank? then
        r << kako[0] + ":" + kako[1]
      else
        r << "," + kako[0] + ":" + kako[1]
      end
    end
    return r
  end
  def yousi_hepler(info)
    job = info.job
    yousi = UpInfo.find_by(job_id: job.id,life: 1,category: 1,position: 0)
    return yousi.blank? ? "" : yousi.infoItem.to_i
  end
  def count_chk(info)
    siage = info&.numInfo06.to_i > info&.numInfo07.to_i ? info&.numInfo06.to_i : info&.numInfo07.to_i
    tenkai = info&.numInfo14.to_i > info&.numInfo15.to_i ? info&.numInfo14.to_i : info&.numInfo15.to_i
    tmp = siage > tenkai ? siage : tenkai
    count = 1
    if tmp < 488 then
      count = 1
    elsif tmp < 841 then
      count = 2
    else
      count = 3
    end
    return count
  end

  def sales_code_helper(code)
    emp = Employee.find_by(sales_code: code)
    if emp.blank?
      user = User.find_by(sales_code: code)
      emp = Employee.find_by(user_id: user.id)
    end
    if emp.blank?
      return "ERR"
    else
      div = emp.div_id
      if emp.id == 665 then
        return "東京"
      elsif div == 1 || div == 20 || div == 101 then
        return "本社"
      elsif div == 10 then
        return "東京"
      elsif div == 11 then
        return "仙台"
      elsif div == 12 then
        return "青森"
      elsif div == 13 then
        return "八戸"
      else
        return "ERR"
      end
    end

  end
end





