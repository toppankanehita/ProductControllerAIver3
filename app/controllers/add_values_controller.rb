class AddValuesController < ApplicationController
  protect_from_forgery with: :exception
  before_action :set_add_value, only: %i[edit destroy ]
  include AddValuesHelper
  include ApplicationHelper
  include ListMissionHelper
  include ActionView::Helpers::NumberHelper
  # ↑ ApplicationHelper を明示的にインクルードする

  # GET /add_values or /add_values.json
  def index
    session[:target_month] = Time.current.last_month.strftime("%Y%m") if session[:target_month].blank?

    if params["q"].present?
      sales_params = {}
      if params["q"]["sales_sale_day_gteq"].present?
        sales_params[:sale_day_gteq] = params["q"]["sales_sale_day_gteq"]
      end
      if params["q"]["sales_sale_day_lteq"].present?
        sales_params[:sale_day_lteq] = params["q"]["sales_sale_day_lteq"]
      end

      if sales_params.present?
        sale_q = Sale.ransack(sales_params)
        job_ids = sale_q.result.pluck(:job_id).compact.uniq
        params["q"]["id_in"] = job_ids.present? ? job_ids : [0]
      end

      session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
      session[:page] = 1
    end

    if session["q"].present?
      @q = Job.ransack(session["q"])
      params[:page] = session[:page] if params[:page].blank? && session[:page].present?
    else
      @q = Job.ransack(nil)
    end

    @q.build_grouping({ :life_eq => 1 })
    if @q.info_dateInfo03_lteq.present?
      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo03 desc')
    elsif @q.info_dateInfo05_lteq.present?
      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo05 desc')
    else
      @jobs = @q.result.page(params[:page]).per(15).order('id desc')
    end

    session[:show] = ""
    session[:page] = params[:page] if params[:page].present?
  end

  def list_mission
    session[:target_month] = Time.current.last_month.strftime("%Y%m") if session[:target_month].blank?

    if params["q"].present?
      # 検索条件はURLに残さず session に保存する
      sales_params = {}
      if params["q"]["sales_sale_day_gteq"].present?
        sales_params[:sale_day_gteq] = params["q"]["sales_sale_day_gteq"]
      end
      if params["q"]["sales_sale_day_lteq"].present?
        sales_params[:sale_day_lteq] = params["q"]["sales_sale_day_lteq"]
      end

      if sales_params.present?
        sale_q = Sale.ransack(sales_params)
        job_ids = sale_q.result.pluck(:job_id).compact.uniq

        if job_ids.present?
          params["q"]["id_in"] = job_ids
        else
          params["q"]["id_in"] = [0]
        end
      end

      session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
      session[:page] = 1
      redirect_to list_mission_add_values_path and return
    end

    if session["q"].present?
      @q = Job.ransack(session["q"])
      params[:page] = session[:page] if params[:page].blank? && session[:page].present?
    else
      @q = Job.ransack(nil)
    end

    @q.build_grouping({ :life_eq => 1 })
    if @q.info_dateInfo03_lteq.present?
      puts "--d2---"
      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo03 desc')
    elsif @q.info_dateInfo05_lteq.present?
      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo05 desc')
    else
      @jobs = @q.result.page(params[:page]).per(15).order('id desc')
    end



    session[:show] = ""
    session[:page] = params[:page] if params[:page].present?
    render layout: "list_mission"
  end
  def add_papers
    @q = AddValue.ransack(params[:q])
    session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
    @add_values =  @q.result.page(params[:page]).per(15).order('id desc')
    render layout: "add_papers"
  end
  def set_papers
    # 任意: パラメータで特定の den_code を指定したい場合
    target_den_code = params[:den_code].presence

    scope = AddValue.where(job_id: nil)
                    .where.not(den_code: [nil, ""])

    scope = scope.where(den_code: target_den_code) if target_den_code

    add_values = scope

    add_values.each do |value|
      job = Job.find_by("den_id = ?", value.den_code)
      if job.present?
        value.job_id = job.id
        value.save
      end
    end

    # 例2: ransack に条件を渡して add_papers にリダイレクト（den_code 指定時）
    if target_den_code
      redirect_to add_papers_add_values_path(q: { den_code_eq: target_den_code, job_id_null: true })
    else
      # den_code が「登録あり」を ransack だけで完全表現するのは難しいため、全件は直接渡すか別UIで対応
      redirect_to add_papers_add_values_path
    end

  end
  def set_target_month
    session[:target_month] = params[:target_month] if params[:target_month].present?
    redirect_to list_mission_add_values_path
  end
  def set_den_code
    # job_id があり、den_code が未設定（nil / 空文字）の AddValue を対象にする
    scope = AddValue.where.not(job_id: nil)
                    .where(den_code: [nil, ""])

    updated_count = 0
    skipped_count = 0

    # クロスDBでの一括トランザクションは避け、1件ずつ安全に更新
    scope.find_each(batch_size: 1000) do |av|
      job = Job.find_by(id: av.job_id) # Job は別DB接続（モデル側の establish_connection 等に依存）
      if job&.den_id.present?
        av.update_columns(den_code: job.den_id, updated_at: Time.current)
        updated_count += 1
      else
        skipped_count += 1
      end
    end

    redirect_to add_papers_add_values_path, notice: "den_code を #{updated_count}件更新しました（スキップ: #{skipped_count}件）。"
  end



  # GET /add_values/1 or /add_values/1.json
  def show
    @job = Job.find(params[:id])

  end

  def

  def out_csv_stop
    # 1) 検索条件を session[:q] から復元
    q_params = session[:q] || {}
    @q = Job.ransack(q_params)
    @q.build_grouping({ :life_eq => 1 })
    # 2) 並び順は index と同一ロジック
    ordering =
      if @q.info_dateInfo03_lteq.present?
        'infos.dateInfo03 DESC'
      elsif @q.info_dateInfo05_lteq.present?
        'infos.dateInfo05 DESC'
      else
        'id desc'
      end

    # 3) 全件取得（ページングなし）
    jobs = @q.result.order(ordering)

    # 4) ヘッダ（index の列と同じ順）
    headers = [
      'No', '種類', '受注No', '得意先名', '品名', '部数' , '見本', '見本2',
      '印刷日', '納品日', '売上日', 'サイズ','色表','色裏','色数','特色','ユポ','カレイド',
      '用紙', '納品枚数', '実数', '予備', '印刷枚数', '加工', 'P物', '面付','SM74','XL106',
      '連量', '差替数', 'k単価', '枚単価', '総重量','用紙見積','印刷見積','用紙原価','印刷','製版',
      'POD', '加工', '制作', '外注', 'アセンブリ', '配送', '営業管理費','用紙労務','印刷労務','製版労務',
      'POD労務', '加工労務', '制作労務', '外注労務', 'アセンブリ労務', '配送労務', '営業管理費',
      '合計原価', '売上金額', '粗利', '合算', '担当'
    ]

    # 5) 本文行の生成（index と同じヘルパ計算を使用）
    lines = []
    i = 1
    childs_counter = 0
    jobs.find_each do |job|
      info = job.info
      add_datum = AddDatum.find_by(job_id: job.id)

      # index と同じ付帯計算ヘルパを呼ぶ
      child_helper(job)
      child_plus_helper(job)
      childs_counter = childs_counter + @child_count.to_i
      value_total_sale = value_cal_price_helper(job, add_datum)
      sales = Sale.find_by(job_id: job.id)
      #puts "parent_csv_helper(add_datum) #{parent_csv_helper(add_datum)}"
      if parent_csv_helper(add_datum)
      # index と同じ表示値を作る
      row = [
        i - childs_counter,
        textInfo02_helper(info&.textInfo02),
        job.den_id,
        info&.textInfo05,
        info&.textInfo07,
        numformat1(info.numInfo01),
        numformat1(info.numInfo02),
        numformat1(info.numInfo03),
        hiduke4_helper(info&.dateInfo03),
        hiduke4_helper(info&.dateInfo05),
        (sales.present? ? sales.t03 : ""),
        info.textInfo20.blank? ? size_helper3_wrap(info.numInfo06,info.numInfo07) : info.textInfo20,
        info.numInfo04,
        info.numInfo05,
        color_count(info.numInfo04,info.numInfo05),
        @press_info[:special],
        @press_info[:upo],
        @press_info[:kaleido],
        info.textInfo11,
        numformat1(@papers[16]) ,
        numformat1(@papers[7]),
        numformat1(@papers[8]),
        numformat1(@papers[7].to_i + @papers[8].to_i),
        @press_info[:kako],
        @press_info[:booklet],
        numformat1(@papers[14]),
        @press_info[:sm74],
        @press_info[:xl106],
        @papers[11],
        numformat1(@papers[12]),
        numformat1(@papers[13]),
        numformat1(@papers[15]),
        @papers[9],
        numformat1(@papers[0]),
        numformat1(@pressArr[0]),
        numformat1(@tmp_array[0]),
        numformat1(@tmp_array[2]),
        numformat1(@tmp_array[1]),
        numformat1(@tmp_array[3]),
        numformat1(@tmp_array[4]),
        numformat1(@tmp_array[5]),
        numformat1(@tmp_array[6]),
        numformat1(@tmp_array[7]),
        numformat1(@tmp_array[8]),
        numformat1(@tmp_array[9]),
        numformat1(@roumu_array[0]),
        numformat1(@roumu_array[2]),
        numformat1(@roumu_array[1]),
        numformat1(@roumu_array[3]),
        numformat1(@roumu_array[4]),
        numformat1(@roumu_array[5]),
        numformat1(@roumu_array[6]),
        numformat1(@roumu_array[7]),
        numformat1(@roumu_array[8]),
        numformat1(@roumu_array[9]),
        numformat1(@tmp_hiyou_sum),
        numformat1(@sale_sum),
        numformat1(@sale_sum - @tmp_hiyou_sum),
        if @child_count > 0
          "合算" + @childs_den_id.uniq.join(", ") # コンマとスペースで連結
        else
          ""
        end,
        info&.salesname
      ]

      # TSVの1行へ
      # タブ・改行を含む可能性のある文字列は安全のため置換
      safe_row = row.map { |v| v.to_s.gsub(/\t/, ' ').gsub(/\r?\n/, ' ') }
      lines << safe_row.join("\t")
      end
      i += 1
    end

    # 6) 送信
    filename = "add_values_index_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.tsv"
    body = ([headers.join("\t")] + lines).join("\n")
    send_data body, filename: filename, type: 'text/tab-separated-values; charset=UTF-8'
  end

  def out_csv
    # 1) 検索条件を session[:q] から復元
    q_params = session[:q] || {}
    @q = Job.ransack(q_params)
    @q.build_grouping({ :life_eq => 1 })
    # 2) 並び順は index と同一ロジック
    ordering =
      if @q.info_dateInfo03_lteq.present?
        'infos.dateInfo03 DESC'
      elsif @q.info_dateInfo05_lteq.present?
        'infos.dateInfo05 DESC'
      else
        'id desc'
      end

    # 3) 全件取得（ページングなし）
    jobs = @q.result.order(ordering)

    # 4) ヘッダ（index の列と同じ順）
    headers = [
      'No', '種類', '種類','受注No', '得意先名', '品名', '部数' , '見本', '見本2',
      '印刷日', '納品日', '売上日', 'サイズ','色表','色裏','色数','特色','ユポ','カレイド',
      '用紙', '納品枚数', '実数', '予備', '印刷枚数', '加工', 'P物', '面付','SM74','XL106',
      '連量', '差替数', 'k単価', '枚単価', '総重量','用紙見積','印刷見積','用紙原価','印刷','製版',
      'POD', '加工', '制作', '外注', 'アセンブリ', '配送', '営業管理費',
      '合計原価', '売上金額', '粗利', '合算', '担当' , '備考', '請求額'
    ]

    # 5) 本文行の生成（index と同じヘルパ計算を使用）
    lines = []
    i = 1
    childs_counter = 0
    jobs.find_each do |job|
      info = job.info
      add_datum = AddDatum.find_by(job_id: job.id)

      # index と同じ付帯計算ヘルパを呼ぶ
      child_helper(job)
      child_plus_helper(job)
      childs_counter = childs_counter + @child_count.to_i
      value_total_sale = value_cal_price_helper(job, add_datum)
      sales = Sale.find_by(job_id: job.id)
      #puts "parent_csv_helper(add_datum) #{parent_csv_helper(add_datum)}"
      if parent_csv_helper(add_datum)
        # index と同じ表示値を作る
        row = [
          i - childs_counter,
          textInfo02_helper(info&.textInfo02),
          info&.textInfo03,
          job.den_id,
          info&.textInfo05,
          info&.textInfo07,
          numformat1(info.numInfo01),
          numformat1(info.numInfo02),
          numformat1(info.numInfo03),
          hiduke4_helper(info&.dateInfo03),
          hiduke4_helper(info&.dateInfo05),
          (sales.present? ? sales.t03 : ""),
          info.textInfo20.blank? ? size_helper3_wrap(info.numInfo06,info.numInfo07) : info.textInfo20,
          info.numInfo04,
          info.numInfo05,
          color_count(info.numInfo04,info.numInfo05),
          @press_info[:special],
          @press_info[:upo],
          @press_info[:kaleido],
          info.textInfo11,
          numformat1(@papers[16]) ,
          numformat1(@papers[7]),
          numformat1(@papers[8]),
          numformat1(@papers[7].to_i + @papers[8].to_i),
          @press_info[:kako],
          @press_info[:booklet],
          numformat1(@papers[14]),
          @press_info[:sm74],
          @press_info[:xl106],
          @papers[11],
          numformat1(@papers[12]),
          numformat1(@papers[13]),
          numformat1(@papers[15]),
          @papers[9],
          numformat1(@papers[0]),
          numformat1(@pressArr[0]),
          numformat1(@tmp_array[0]),
          numformat1(@tmp_array[2]),
          numformat1(@tmp_array[1]),
          numformat1(@tmp_array[3]),
          numformat1(@tmp_array[4]),
          numformat1(@tmp_array[5]),
          numformat1(@tmp_array[6]),
          numformat1(@tmp_array[7]),
          numformat1(@tmp_array[8]),
          numformat1(@tmp_array[9]),
          numformat1(@tmp_hiyou_sum),
          numformat1(@sale_sum),
          numformat1(@sale_sum - @tmp_hiyou_sum),
          if @child_count > 0
            "合算" + @childs_den_id.uniq.join(", ") # コンマとスペースで連結
          else
            ""
          end,
          info&.salesname,
          info&.textInfo28,
          numformat1(@mitumori_array[10])
        ]

        # TSVの1行へ
        # タブ・改行を含む可能性のある文字列は安全のため置換
        safe_row = row.map { |v| v.to_s.gsub(/\t/, ' ').gsub(/\r?\n/, ' ') }
        lines << safe_row.join("\t")
      end
      i += 1
    end

    # 6) 送信
    filename = "add_values_index_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.tsv"
    body = ([headers.join("\t")] + lines).join("\n")
    send_data body, filename: filename, type: 'text/tab-separated-values; charset=UTF-8'
  end

  def out_mission
    # 1) 検索条件を session[:q] から復元
    q_params = session[:q] || {}
    @q = Job.ransack(q_params)
    @q.build_grouping({ :life_eq => 1 })
    # 2) 並び順は index と同一ロジック
    ordering =
      if @q.info_dateInfo03_lteq.present?
        'infos.dateInfo03 DESC'
      elsif @q.info_dateInfo05_lteq.present?
        'infos.dateInfo05 DESC'
      else
        'id desc'
      end

    # 3) 全件取得（ページングなし）
    jobs = @q.result.order(ordering)

    # 4) ヘッダ（index の列と同じ順）
    headers = [
      'No','所属','種類', '受注No', '得意先名', '品名', '担当',
      '用紙','刷版','直接材料費','POD','直接外注費','直接仕入高',
      '製造労務時間','賃率','製造労務費','制作労務時間','賃率','制作労務費','デザイン労務時間','賃率','デザイン労務費',
      '直接作業時間合計','直接労務費計','アセンブリ労務時間','賃率','雑給計','材料費','労務費',
      '賞与','法定福利','水道光熱費','修繕費','租税公課',
      '保険料','消耗品費','車両費','通信費','減価償却費','雑費','間接費合計','運賃','合計原価','売上','粗利','粗利率' , '加工労務費' ,'顧客code','種類' , 'CTP労務費' ,
      'ロールカット労務費' , '自社配送労務費','印刷労務費' , 'POD労務費'
    ]

    lines = list_mission_sub(jobs , 0)
    # 6) 送信
    filename = "mission_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.tsv"
    body = ([headers.join("\t")] + lines).join("\n")
    send_data body, filename: filename, type: 'text/tab-separated-values; charset=UTF-8'
  end

  def list_mission_sub(jobs,flag)
    # flag == 1 (mission_data_set) の場合は MissionArchive の mission_archive_41(間接費合計)〜54 の列位置互換性を維持
    archive_mode = (flag == 1)
    # 5) 本文行の生成（index と同じヘルパ計算を使用）
    lines = []
    i = 1
    childs_counter = 0
    jobs.find_each do |job|
      info = job.info
      add_datum = AddDatum.find_by(job_id: job.id)

      @mission = true
      mission_child_helper(job)
      mission_child_plus_helper(job)
      childs_counter = childs_counter + @child_count.to_i
      value_total_sale = value_cal_price_helper(job, add_datum)
      sales = Sale.find_by(job_id: job.id)

      if parent_csv_helper(add_datum)
        indirect_cols = [
          numformat1(@mission_array[19]),
          numformat1(@mission_array[21]),
          numformat1(@mission_array[22]),
          numformat1(@mission_array[24]),
          numformat1(@mission_array[26]),
          numformat1(@mission_array[27]),
          numformat1(@mission_array[28]),
          numformat1(@mission_array[30]),
          numformat1(@mission_array[31]),
          numformat1(@mission_array[49]),
          numformat1(@mission_array[50]),
          numformat1(@mission_array[32]),
          numformat1(@mission_array[33])
        ]
        indirect_cols << "0" if archive_mode

        # index と同じ表示値を作る
        row = [
          i - childs_counter,
          @mission_array[40],
          textInfo02_helper(info&.textInfo02),
          job.den_id,
          info&.textInfo05,
          info&.textInfo07,
          info&.salesname,
          numformat1(@tmp_array[0]),
          numformat1(@tmp_array[1]),
          numformat1(@tmp_array[0] + @tmp_array[1]),
          numformat1(@tmp_array[3]),
          numformat1(@mission_array[15]),
          numformat1(@mission_array[16]),
          number_with_precision(@mission_array[3], precision: 2) ,
          numformat1(@unit_price.d27),
          numformat1(@mission_array[4]),
          number_with_precision(@mission_array[5], precision: 2) ,
          numformat1(@unit_price.d25),
          numformat1(@mission_array[6]),
          number_with_precision(@mission_array[7], precision: 2) ,
          numformat1(@unit_price.d26),
          numformat1(@mission_array[8]),
          number_with_precision(@mission_array[3] + @mission_array[5] + @mission_array[7], precision: 2) ,
          numformat1(@mission_array[4] + @mission_array[6] + @mission_array[8]),
          number_with_precision(@mission_array[9], precision: 2) ,
          numformat1(@unit_price.d29),
          numformat1(@mission_array[10]),
          *indirect_cols,
          numformat1(@mission_array[34]),
          numformat1(@mission_array[35]),
          numformat1(@mission_array[36]),
          numformat1(@mission_array[37]),
          numformat1(@mission_array[38]),
          number_with_precision(@mission_array[39], precision: 2) ,
          numformat1(@mission_array[41]),
          info&.textInfo04,
          info&.textInfo03,
          numformat1(@mission_array[42]),
          numformat1(@mission_array[43]),
          numformat1(@mission_array[44]),
          numformat1(@mission_array[45]),
          numformat1(@mission_array[46])
        ]

        # TSVの1行へ
        # タブ・改行を含む可能性のある文字列は安全のため置換
        safe_row = row.map { |v| v.to_s.gsub(/\t/, ' ').gsub(/\r?\n/, ' ') }
        lines << safe_row.join("\t")
      end
      i += 1
    end
    flag = 1
    if flag == 1
      tworks = Twork.where(target_month: session[:target_month],den_code: [nil, ""])
      tworks.each do |twork|
        if (twork.outsourcing_cost == 0 || twork.outsourcing_cost.nil? ) && (twork.purchase_cost == 0 || twork.purchase_cost.nil? )
          info02 = "デザイン"
        else
          info02 = "外注"
        end
        mission_twork_plus_helper(twork)
        twork_indirect_cols = [
          numformat1(@mission_array[19]),
          numformat1(@mission_array[21]),
          numformat1(@mission_array[22]),
          numformat1(@mission_array[24]),
          numformat1(@mission_array[26]),
          numformat1(@mission_array[27]),
          numformat1(@mission_array[28]),
          numformat1(@mission_array[30]),
          numformat1(@mission_array[31]),
          numformat1(@mission_array[49]),
          numformat1(@mission_array[50]),
          numformat1(@mission_array[32]),
          numformat1(@mission_array[33])
        ]
        twork_indirect_cols << "0" if archive_mode

        row = [
          i - childs_counter,
          "東京",
          info02,
          "",
          twork&.tinfo05,
          twork&.tinfo07,
          twork&.staff ,
          0,
          0,
          0,
          0,
          numformat1(@mission_array[15]),
          numformat1(@mission_array[16]),
          number_with_precision(@mission_array[3], precision: 2) ,
          numformat1(@unit_price.d27),
          numformat1(@mission_array[4]),
          number_with_precision(@mission_array[5], precision: 2) ,
          numformat1(@unit_price.d25),
          numformat1(@mission_array[6]),
          number_with_precision(@mission_array[7], precision: 2) ,
          numformat1(@unit_price.d26),
          numformat1(@mission_array[8]),
          number_with_precision(@mission_array[3] + @mission_array[5] + @mission_array[7], precision: 2) ,
          numformat1(@mission_array[4] + @mission_array[6] + @mission_array[8]),
          number_with_precision(@mission_array[9], precision: 2) ,
          numformat1(@unit_price.d29),
          numformat1(@mission_array[10]),
          *twork_indirect_cols,
          numformat1(@mission_array[34]),
          numformat1(@mission_array[35]),
          numformat1(@mission_array[36]),
          numformat1(@mission_array[37]),
          numformat1(@mission_array[38]),
          number_with_precision(@mission_array[39], precision: 2),
          ""
        ]
        # TSVの1行へ
        # タブ・改行を含む可能性のある文字列は安全のため置換
        safe_row = row.map { |v| v.to_s.gsub(/\t/, ' ').gsub(/\r?\n/, ' ') }
        lines << safe_row.join("\t")
        i += 1

      end
    end
    return lines
  end

  def mission_data_set
    # 1) 検索条件を session[:q] から復元
    q_params = session[:q] || {}
    @q = Job.ransack(q_params)
    @q.build_grouping({ :life_eq => 1 })
    # 2) 並び順は index と同一ロジック
    ordering =
      if @q.info_dateInfo03_lteq.present?
        'infos.dateInfo03 DESC'
      elsif @q.info_dateInfo05_lteq.present?
        'infos.dateInfo05 DESC'
      else
        'id desc'
      end

    #先にデータを削除
    MissionArchive.where(target_month: session[:target_month]).delete_all

    # 3) 全件取得（ページングなし）
    jobs = @q.result.order(ordering)

    lines = list_mission_sub(jobs , 1)

    lines.each do |line|
      archive = MissionArchive.new()
      columns = line.split("\t")
      columns.each_with_index do |val, i|
        column_number = format('%02d', i)
        method_name = "mission_archive_#{column_number}="
        if i > 6
          val = val.gsub(',', '')
        end
        if i == 3
          archive.job_id = Job.find_by(den_id: val)&.id
        end
        # archive.mission_archive_01 = val と同じ処理を実行
        if archive.respond_to?(method_name)
          archive.send(method_name, val)
        end
      end
      archive.target_month = session[:target_month]
      archive.save
    end
    redirect_to list_mission_add_values_path

  end
  def new

  end

  # GET /add_values/1/edit
  def edit
  end

  def create
    den_code = params[:den_code].to_s.strip
    if den_code.blank?
      return render_create_error('den_codeを入力してください。')
    end

    @job = Job.find_by(den_id: den_code)
    unless @job
      return render_create_error("den_code=#{den_code} に一致する受注が見つかりません。")
    end

    @info = @job.info
    if @info.textInfo02.index("オフ輪")
      sasi = (Reportitem.where(job_id: @job&.id).maximum(:sasikae) || 0)
      jisu,wari = web_jisu_value(@info)
      yobi = web_yobi_value(jisu, sasi)
    else
      sasi = 0
      jisu = 0
      yobi = 0
    end

    @value = AddValue.new(job: @job, den_code: den_code, jisu: jisu, yobi: yobi, press_num: jisu + yobi, sasi: sasi)
    @wari = wari
    # 必要なら初期値をここで設定
    # @value.ren = 0

    if @value.save
      respond_to do |format|
        # addPapers 側（dataType: 'script'）に対応
        format.js   # create.js.erb を返す（行を挿入）

        # jobs 側（dataType: 'json'）に対応
        format.json do
          #puts "create　ajax"
          if params[:all_rows].present?
            # 該当Jobの全AddValue行を返す
            rows_html = ''
            @job.add_values.order(:id).each_with_index do |val, i|
              rows_html << render_to_string(
                partial: 'add_values/row',
                formats: [:html],
                layout: false,
                locals: { value: val, job: @job, info: @info, idx: 0, offset: 0, idv: i, show_add_link: true, wari: wari }
              )
            end
            render json: { html: rows_html, job_id: @job.id }
          else
            # 単行返却（compact 指定で No/Job 情報の有無を切替）
            idv_local = params[:compact].present? ? 1 : 0
            html = render_to_string(
              partial: 'add_values/row',
              formats: [:html],
              layout: false,
              locals: { value: @value, job: @job, info: @info, idx: 0, offset: 0, idv: idv_local, show_add_link: true }
            )
            render json: { id: @value.id, job_id: @job.id, den_code: den_code, html: html }
          end
        end

        format.html { redirect_back fallback_location: add_papers_path, notice: '新規レコードを作成しました。' }
      end

    else
      render_create_error(@value.errors.full_messages.join(', '))
    end
  end

  def update
    @add_value = AddValue.find(params[:id])
    # 数値文字列の桁区切りカンマを除去してから更新
    cleaned = add_value_params.to_h

    int_fields    = %w[jisu yobi press_num sasi iroko sale_price paper_price tori dai men position job_id]
    decimal_fields = %w[ren ktanka mtanka weight]

    (int_fields + decimal_fields).each do |key|
      next unless cleaned.key?(key)

      v = cleaned[key]
      next if v.nil?

      s = v.to_s.strip
      s = s.delete(',') # 3桁区切りカンマ除去
      # 空文字は nil に（NOT NULL の場合はDB側で0等のdefaultに委ねる）
      cleaned[key] = (s == '' ? nil : s)
    end

    # 型を適切にキャスト
    int_fields.each do |key|
      next unless cleaned.key?(key)
      cleaned[key] = cleaned[key].nil? ? nil : cleaned[key].to_i
    end
    decimal_fields.each do |key|
      next unless cleaned.key?(key)
      cleaned[key] = cleaned[key].nil? ? nil : BigDecimal(cleaned[key])
    end

    if @add_value.update(cleaned)
      respond_to do |format|
        format.json { render json: { ok: true } }
        format.html { redirect_back fallback_location: add_values_path, notice: '更新しました' }
      end
    else
      respond_to do |format|
        format.json { render json: { ok: false, errors: @add_value.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: add_values_path, alert: '更新に失敗しました' }
      end
    end
  end

  # DELETE /add_values/1 or /add_values/1.json
  def destroy
    # 置換用に関連情報を保持
    job  = @add_value.job
    info = job&.info

    @add_value.destroy

    respond_to do |format|
      format.html { redirect_to add_values_url, notice: "Add value was successfully destroyed." }
      format.json do
        # 該当Jobに紐づく残存AddValueを全て描画し返す（0件なら未登録1行）
        rows_html = ''
        if job.present?
          remaining = job.add_values.order(:id).to_a
          if remaining.any?
            remaining.each_with_index do |val, i|
              rows_html << render_to_string(
                partial: 'add_values/row',
                formats: [:html],
                layout: false,
                locals: { value: val, job: job, info: info, idx: 0, offset: 0, idv: i, show_add_link: true }
              )
            end
          else
            placeholder = AddValue.new(job: job)
            rows_html << render_to_string(
              partial: 'add_values/row',
              formats: [:html],
              layout: false,
              locals: { value: placeholder, job: job, info: info, idx: 0, offset: 0, idv: 0, show_add_link: true }
            )
          end
        end

        render json: { html: rows_html, job_id: job&.id }
      end
      format.js   # destroy.js.erb を返す（既存のJS利用ケース向け）
    end
  end
  def add_values_search
    # 1) Job/Info 側の条件（例: params[:q_info]）で job_id を抽出
    job_ids = nil
    if params[:q_info].present?
      # Job 側は info にJOIN可能
      q_job = Job.joins(:info).ransack(params[:q_info])
      job_ids = q_job.result.distinct.pluck(:id)
      # 該当が0件なら、AddValueも0件に確定
      return render_results(AddValue.none.page(params[:page])) if job_ids.empty?
    end

    # 2) AddValue 側の条件（例: params[:q_add] or params[:q]）を適用
    q_add = params[:q_add].presence || params[:q]
    @q = AddValue.ransack(q_add)
    scope = @q.result

    # 3) Job/Info 条件があれば job_id で絞る
    scope = scope.where(job_id: job_ids) if job_ids

    @add_values = scope.page(params[:page]).per(20)
    render_results(@add_values)
  end

  def rows
    job = Job.find_by(id: params[:job_id])
    unless job
      return render json: { html: '', job_id: nil, error: 'Job not found' }, status: :not_found
    end
    ##ローカルLLMに問い合わせ
    # user_input = job.den_id
    #
    # @answer = begin
    #             AiService.ask_gemma(user_input)
    #           rescue AiService::AiUnavailableError => e
    #             Rails.logger.warn("AiService unavailable: #{e.message}")
    #             ""
    #           end


    info = job&.info
    rows_html = ''
    values = job.add_values.order(:id).to_a

    if values.any?
      values.each_with_index do |val, i|
        rows_html << render_to_string(
          partial: 'add_values/row',
          formats: [:html],
          layout: false,
          locals: { value: val, job: job, info: info, idx: 0, offset: 0, idv: i, show_add_link: true }
        )
      end
    else
      placeholder = AddValue.new(job: job)
      rows_html << render_to_string(
        partial: 'add_values/row',
        formats: [:html],
        layout: false,
        locals: { value: placeholder, job: job, info: info, idx: 0, offset: 0, idv: 0, show_add_link: true }
      )
    end

    header_html = render_to_string(
      partial: 'add_values/row_head',
      formats: [:html],
      layout: false
    )

    job_html = render_to_string(
      partial: 'calendar/job',
      formats: [:html],
      layout: false,
      locals: {value: placeholder, job: job, info: info}
    )

    render json: { html: rows_html, header_html: header_html,job_html: job_html, job_id: job.id }
  end

  def paper_inquiry
    service = PaperInquiryService.new(
      job_id: params[:job_id],
      den_id: params[:den_id] || params[:den_code],
      question: params[:question]
    )
    result = service.call
    if result[:ok]
      render json: result
    else
      render json: result, status: :unprocessable_entity
    end
  end

  private
    def render_results(scope)
      @add_values = scope
      render :add_papers, layout: "add_papers"
      # 例: 既存の一覧テンプレートに合わせる
    end

  # Use callbacks to share common setup or constraints between actions.
    def set_add_value
      @add_value = AddValue.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def add_value_params
      params.require(:add_value).permit(
        :paper_name, :me, :han, :ren, :ktanka, :mtanka, :job_id, :jisu, :yobi, :press_num,
        :special, :upo, :gold, :kaleid, :other, :sasi, :iroko, :sale_price, :paper_price, :id,
        :position, :ita, :tori, :dai, :men, :weight, :post_press, :paper_route
      )
    end

  def add_value_collection_params
    params
      .require(:form_add_value_collection)
      .permit(add_values_attributes: [:paper_name, :me, :han, :ren, :ktanka, :mtanka, :job_id, :jisu, :yobi, :press_num, :special, :upo, :gold, :kaleid, :other, :sasi, :iroko, :sale_price, :paper_price,:id ,:position, :ita, :tori, :dai, :men])
  end

  def render_create_error(message)
    respond_to do |format|
      format.js   { render js: "alert(#{message.to_json});" }
      format.json { render json: { errors: [message] }, status: :unprocessable_entity }
      format.html { redirect_back fallback_location: add_papers_path, alert: message }
    end
  end

end
