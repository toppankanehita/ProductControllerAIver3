class ArchivesController < ApplicationController
  before_action :set_archive, only: %i[ show edit update destroy ]
  include AddValuesHelper
  include ListMissionHelper
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  # GET /archives or /archives.json
  def index
    @q = Archive.ransack(params[:q])
    session["q"] = (params[:q] || params["q"]).respond_to?(:to_unsafe_h) ? (params[:q] || params["q"]).to_unsafe_h : (params[:q] || params["q"])
    #@q.result.page(params[:page]).per(15).order('id desc')
    @archives = @q.result.page(params[:page]).per(10).order('id desc')
  end
  def out_csv
    q_params = session[:q] || {}
    q = Archive.ransack(q_params)
    # child_job が空(nil or "")のデータのみ抽出
    archives = q.result.where(child_job: [nil, '']).order('den_id desc')
    headers = [
      'No' , '種類' , '受注No' , '得意先名' , '品名' , '部数' , '見本' , '見本2' , '印刷日' , '納品日' , '売上日' , 'サイズ' ,
      '仕上サイズ' , '展開サイズ' , '色数' , '特色' , 'ユポ' , 'カレイド' , '用紙' , '板紙' , '納品枚数' , '実数' , '予備' , '印刷枚数' ,
      '加工' , 'P物' , '面付' , '連量' , '差替数' , 'k単価' , '枚単価' , '総重量' , '積算用紙' , '積算製版' , '積算印刷' , '積算POD' ,
      '積算加工' , '積算制作' , '積算外注' , '積算アセンブリ' , '積算配送' , '積算管理費' , '営業積算額' ,'費用用紙' , '費用製版' , '費用印刷' , '費用POD' , '費用加工' ,
      '費用制作' , '費用外注' , '費用アセンブリ' , '費用配送' , '営業管理費' , '合計原価' , '売上金額' , '粗利' , '合算' , '担当'
    ]
    lines = []
    i = 1
    archives.find_each do |archive|
      row = [
        i,
        archive.textInfo02,
        archive.den_id,
        archive.textInfo05,
        archive.textInfo07,
        numformat1(archive.numInfo01),
        numformat1(archive.numInfo02),
        numformat1(archive.numInfo03),
        hiduke4_helper(archive.press_date),
        hiduke4_helper(archive.finish_date),
        hiduke4_helper(archive.sale_date),
        archive.press_size,
        archive.press_siage_size,
        archive.press_tenkai_size,
        archive.press_color,
        archive.press_special,
        archive.press_upo,
        archive.press_kaleido,
        archive.textInfo11,
        archive.ita == 1 ? "板紙" : "",
        numformat1(archive.press_num),
        numformat1(archive.paper_jisu),
        numformat1(archive.paper_yobi),
        numformat1(archive.paper_jisu + archive.paper_yobi),
        archive.kako,
        archive.booklet,
        archive.paper_split,
        archive.paper_ren,
        archive.paper_sasi,
        archive.ktanka,
        archive.mtanka,
        archive.paper_weight,
        numformat1(archive.sale_paper),
        numformat1(archive.sale_ctp),
        numformat1(archive.sale_press),
        numformat1(archive.sale_pod),
        numformat1(archive.sale_kako),
        numformat1(archive.sale_seisaku),
        numformat1(archive.sale_gaicyu),
        numformat1(archive.sale_assembly),
        numformat1(archive.sale_haiso),
        numformat1(archive.sale_keihi),
        numformat1(archive.sale_mitumori),
        numformat1(archive.cost_paper),
        numformat1(archive.cost_ctp),
        numformat1(archive.cost_press),
        numformat1(archive.cost_pod),
        numformat1(archive.cost_kako),
        numformat1(archive.cost_seisaku),
        numformat1(archive.cost_gaicyu),
        numformat1(archive.cost_assembly),
        numformat1(archive.cost_haiso),
        numformat1(archive.cost_keihi),
        numformat1(archive.cost_sum),
        numformat1(archive.sale_sum),
        numformat1(archive.arari),
        archive.parent_job,
        archive.sales_name
      ]
      # TSVの1行へ
      # タブ・改行を含む可能性のある文字列は安全のため置換
      safe_row = row.map { |v| v.to_s.gsub(/\t/, ' ').gsub(/\r?\n/, ' ') }
      lines << safe_row.join("\t")

      i += 1
    end

    # 6) 送信
    filename = "archives_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.tsv"
    body = ([headers.join("\t")] + lines).join("\n")
    send_data body, filename: filename, type: 'text/tab-separated-values; charset=UTF-8'
  end
  def data_set
    jobs = Job.joins(:info)
    if params[:month].present?
      jobs = jobs.where('infos.dateInfo05 >= ? AND life = ?', Date.today - params[:month].to_i.week , 1 ).order('infos.dateInfo05 ASC')
    else
      jobs = jobs.where('infos.dateInfo05 >= ? AND life = ?', Date.today - 2.month , 1 ).order('infos.dateInfo05 ASC')
    end

    i = 1
    childs_counter = 0
    @job_count = jobs.count
    jobs.find_each do |job|
      data_set_sub(job)
      i += 1
    end
    @q = Archive.ransack(params[:q])
    #@q.result.page(params[:page]).per(15).order('id desc')
    @archives = @q.result.page(params[:page]).per(12).order('id desc')
    #redirect_to data_set_archives_path
  end
  def data_set_one
    job = Job.find(params[:id])
    data_set_sub(job)
    @archive = Archive.find_by(job_id: job.id)
    # index 側の per と整合させる（index は per(12)）
    @per_page = 12

    respond_to do |format|
      format.html { redirect_to archives_path(page: params[:page]) }
      format.js   { render :data_set_one }
    end
  end

  def data_set_sub(job)

    archive = Archive.find_by(job_id: job.id)
    archive = archive.present? ? archive : Archive.new(job_id: job.id)
    info = job.info
    add_datum = AddDatum.find_by(job_id: job.id)

    #child_helper(job)
    #child_plus_helper(job)
    @mission = true
    mission_child_helper(job)
    mission_child_plus_helper(job)

    sales = Sale.find_by(job_id: job.id)

    archive.textInfo02 = textInfo02_helper(info&.textInfo02)
    archive.den_id = job.den_id
    archive.textInfo05 = info&.textInfo05
    archive.textInfo07 = info&.textInfo07
    archive.numInfo01 = info.numInfo01.to_i
    archive.numInfo02 = info.numInfo02.to_i
    archive.numInfo03 = info.numInfo03.to_i
    archive.press_date = info&.dateInfo03
    archive.finish_date = info&.dateInfo05
    archive.sale_date = (sales.present? ? sales.t03 : "")
    archive.press_size = info.textInfo20
    archive.press_siage_size = size_helper3_wrap(info.numInfo06,info.numInfo07)
    archive.numInfo06 = info.numInfo06
    archive.numInfo07 = info.numInfo07
    archive.press_tenkai_size = size_helper3_wrap(info.numInfo14,info.numInfo15)
    archive.numInfo14 = info.numInfo14
    archive.numInfo15 = info.numInfo15
    archive.press_color = @press_info[:color]
    archive.press_special = @press_info[:special]
    archive.press_upo = @press_info[:upo]
    archive.press_kaleido = @press_info[:kaleido]
    archive.post_press = @press_info[:post_press]
    archive.paper_name = @press_info[:paper_name]
    archive.paper_route = @press_info[:paper_route]
    archive.ita = @press_info[:ita]
    archive.kako = @press_info[:kako]
    archive.booklet = @press_info[:booklet]
    archive.textInfo11 = info.textInfo11
    archive.press_num = @papers[16].to_i
    archive.paper_jisu = @papers[7].to_i
    archive.paper_yobi = @papers[8].to_i
    archive.paper_split = @papers[14].to_i
    archive.paper_ren = @papers[11].to_f
    archive.paper_sasi = @papers[12].to_f
    archive.ktanka = @papers[13].to_f
    archive.mtanka = @papers[15].to_f
    archive.paper_weight = @papers[9].to_f
    archive.sale_paper = @mitumori_array[0].to_i
    archive.sale_ctp = @mitumori_array[1].to_i
    archive.sale_press = @mitumori_array[2].to_i
    archive.sale_pod = @mitumori_array[3].to_i
    archive.sale_kako = @mitumori_array[4].to_i
    archive.sale_seisaku = @mitumori_array[5].to_i
    archive.sale_gaicyu = @mitumori_array[6].to_i
    archive.sale_assembly = @mitumori_array[7].to_i
    archive.sale_haiso = @mitumori_array[8].to_i
    archive.sale_keihi = @mitumori_array[9].to_i
    archive.sale_mitumori = @cal_sums[2].to_i
    archive.cost_paper = @tmp_array[0].to_i
    archive.cost_ctp = @tmp_array[1].to_i
    archive.cost_press = @tmp_array[2].to_i
    archive.cost_pod = @tmp_array[3].to_i
    archive.cost_kako = @tmp_array[4].to_i
    archive.cost_seisaku = @tmp_array[5].to_i
    archive.cost_gaicyu = @tmp_array[6].to_i
    archive.cost_assembly = @tmp_array[7].to_i
    archive.cost_haiso = @tmp_array[8].to_i
    archive.cost_keihi = @tmp_array[9].to_i

    if @mitumori_array.nil? || @mitumori_array[0].to_i == 0
      archive.cal_paper = 0
    else
      archive.cal_paper = (@tmp_array[0].to_f / @mitumori_array[0].to_i) * 100
    end
    if @mitumori_array.nil? || @mitumori_array[1].to_i == 0
      archive.cal_ctp = 0
    else
      archive.cal_ctp = (@tmp_array[1].to_f / @mitumori_array[1].to_i) * 100
    end
    if @mitumori_array.nil? || @mitumori_array[2].to_i == 0
      archive.cal_press = 0
    else
      archive.cal_press =  (@tmp_array[2].to_f / @mitumori_array[2].to_i) * 100
    end
    if @mitumori_array.nil? || @mitumori_array[3].to_i == 0
      archive.cal_pod = 0
    else
      archive.cal_pod = (@tmp_array[3].to_f / @mitumori_array[3].to_i) * 100
    end
    if @mitumori_array.nil? || @mitumori_array[4].to_i == 0
      archive.cal_kako = 0
    else
      archive.cal_kako = (@tmp_array[4].to_f / @mitumori_array[4].to_i) * 100
    end
    if @mitumori_array.nil? || @mitumori_array[5].to_i == 0
      archive.cal_seisaku = 0
    else
      archive.cal_seisaku = (@tmp_array[5].to_f / @mitumori_array[5].to_i) * 100
    end

    if @mitumori_array.nil? || @mitumori_array[6].to_i == 0
      archive.cal_gaicyu = 0
    else
      archive.cal_gaicyu = (@tmp_array[6].to_f / @mitumori_array[6].to_i) * 100
    end

    if @mitumori_array.nil? || @mitumori_array[7].to_i == 0
      archive.cal_assembly = 0
    else
      archive.cal_assembly = (@tmp_array[7].to_f / @mitumori_array[7].to_i) * 100
    end

    if @mitumori_array.nil? || @mitumori_array[8].to_i == 0
      archive.cal_haiso = 0
    else
      archive.cal_haiso = (@tmp_array[8].to_f / @mitumori_array[8].to_i) * 100
    end

    archive.cost_sum = @tmp_hiyou_sum.to_i
    archive.sale_sum = @mission_array[44].to_i #@sale_sum
    if @sale_sum > 0
      archive.arari = @sale_sum -@tmp_hiyou_sum
    else
      archive.arari = 0
    end
    if @child_count > 0
      archive.parent_job ="合算" + @childs_den_id.uniq.join(", ") # コンマとスペースで連結
    end

    archive.child_job = parent_archive_helper(add_datum)

    archive.sales_name = info&.salesname

    archive.mission_archive_01 = @mission_array[40]
    archive.mission_archive_02 = textInfo02_helper(info&.textInfo02)
    archive.mission_archive_03 = job.den_id
    archive.mission_archive_04 = info&.textInfo05
    archive.mission_archive_05 = info&.textInfo07
    archive.mission_archive_06 = info&.salesname
    archive.mission_archive_07 = @tmp_array[0]
    archive.mission_archive_08 = @tmp_array[1]
    archive.mission_archive_09 = @tmp_array[0] + @tmp_array[1]
    archive.mission_archive_10 = @tmp_array[3]
    archive.mission_archive_11 = @mission_array[15]
    archive.mission_archive_12 = @mission_array[16]
    archive.mission_archive_13 = @mission_array[3]
    archive.mission_archive_14 = @unit_price.d27
    archive.mission_archive_15 = @mission_array[4]
    archive.mission_archive_16 = @mission_array[5]
    archive.mission_archive_17 = @unit_price.d25
    archive.mission_archive_18 = @mission_array[6]
    archive.mission_archive_19 = @mission_array[7]
    archive.mission_archive_20 = @unit_price.d26
    archive.mission_archive_21 = @mission_array[8]
    archive.mission_archive_22 = @mission_array[3] + @mission_array[5] + @mission_array[7]
    archive.mission_archive_23 = @mission_array[4] + @mission_array[6] + @mission_array[8]
    archive.mission_archive_24 = @mission_array[9]
    archive.mission_archive_25 = @unit_price.d29
    archive.mission_archive_26 = @mission_array[10]
    archive.mission_archive_42 = @mission_array[35]
    archive.mission_archive_47 = @mission_array[41]
    archive.mission_archive_48 = info&.textInfo04
    archive.mission_archive_49 = info&.textInfo03
    archive.mission_archive_50 = @mission_array[42]
    archive.mission_archive_51 = @mission_array[43]
    archive.mission_archive_52 = @mission_array[44]
    archive.mission_archive_53 = @mission_array[45]
    archive.mission_archive_54 = @mission_array[46]
    #
    archive.save!
  end
  # GET /archives/1 or /archives/1.json
  def show
    @q = Archive.ransack(params[:q])
    @archives = @q.result.page(params[:page]).per(1).order('id desc')
    @archive = @archives[0]

  end

  # GET /archives/new
  def new
    @archive = Archive.new
  end

  # GET /archives/1/edit
  def edit
  end

  # POST /archives or /archives.json
  def create
    @archive = Archive.new(archive_params)

    respond_to do |format|
      if @archive.save
        format.html { redirect_to @archive, notice: "Archive was successfully created." }
        format.json { render :show, status: :created, location: @archive }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archives/1 or /archives/1.json
  def update
    respond_to do |format|
      if @archive.update(archive_params)
        format.html { redirect_to @archive, notice: "Archive was successfully updated." }
        format.json { render :show, status: :ok, location: @archive }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archives/1 or /archives/1.json
  def destroy
    @archive.destroy

    respond_to do |format|
      format.html { redirect_to archives_path, status: :see_other, notice: "Archive was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def archive_params
      params.require(:archive).permit(:textInfo02, :den_id, :textInfo05, :textInfo07, :numInfo01, :numInfo02, :numInfo03, :numInfo06, :numInfo07, :numInfo14, :numInfo15, :press_date, :finish_date, :sale_date, :press_size, :press_siage_size, :press_tenkai_size, :press_color, :press_special, :press_upo, :press_kaleido, :textInfo11, :ita, :kako, :booklet, :paper_route, :paper_name, :post_press, :press_num, :paper_jisu, :paper_yobi, :paper_split, :paper_ren, :paper_sasi, :ktanka, :mtanka, :paper_weight, :sale_paper, :sale_press, :cost_paper, :cost_ctp, :cost_press, :cost_pod, :cost_kako, :cost_seisaku, :cost_gaicyu, :cost_assembly, :cost_haiso, :cost_keihi, :cost_sum, :sale_sum, :arari, :parent_job, :child_job, :sales_name, :job_id, :sale_mitumori, :sale_keihi,  :mission_archive_00, :mission_archive_01, :mission_archive_02, :mission_archive_03, :mission_archive_04, :mission_archive_05, :mission_archive_06, :mission_archive_07, :mission_archive_08, :mission_archive_09, :mission_archive_10, :mission_archive_11, :mission_archive_12, :mission_archive_13, :mission_archive_14, :mission_archive_15, :mission_archive_16, :mission_archive_17, :mission_archive_18, :mission_archive_19, :mission_archive_20, :mission_archive_21, :mission_archive_22, :mission_archive_23, :mission_archive_24, :mission_archive_25, :mission_archive_26, :mission_archive_27, :mission_archive_28, :mission_archive_29, :mission_archive_30, :mission_archive_31, :mission_archive_32, :mission_archive_33, :mission_archive_34, :mission_archive_35, :mission_archive_36, :mission_archive_37, :mission_archive_38, :mission_archive_39, :mission_archive_40, :mission_archive_41, :mission_archive_42, :mission_archive_43, :mission_archive_44, :mission_archive_45, :mission_archive_46, :mission_archive_47, :mission_archive_48, :mission_archive_49, :mission_archive_50, :mission_archive_51, :mission_archive_52, :mission_archive_53, :mission_archive_54, :mission_archive_55, :mission_archive_56, :mission_archive_57, :mission_archive_58, :mission_archive_59, :mission_archive_60)
    end
end
