class MissionArchivesController < ApplicationController
  before_action :set_mission_archive, only: %i[ show edit update destroy ]
  include ApplicationHelper
  # GET /mission_archives or /mission_archives.json
  def index
    @q = MissionArchive.ransack(params[:q])
    session["q"] = (params[:q] || params["q"]).respond_to?(:to_unsafe_h) ? (params[:q] || params["q"]).to_unsafe_h : (params[:q] || params["q"])
    #@q.result.page(params[:page]).per(15).order('id desc')
    @mission_archives = @q.result.page(params[:page]).per(50).order('id desc')
    @cost_sum = @mission_archives.sum(:mission_archive_43)
    @sales_sum = @mission_archives.sum(:mission_archive_44)

    @profit_sum = @mission_archives.sum(:mission_archive_45)
    @profit_par = ((@profit_sum.to_f / @sales_sum.to_f)) * 100
  end

  def data_set
    jobs = Job.joins(:info)
    if params[:month].present?
      jobs = jobs.where('infos.dateInfo05 >= ? AND life = ?', Date.today - params[:month].to_i.month , 1 ).order('infos.dateInfo05 ASC')
    else
      jobs = jobs.where('infos.dateInfo05 >= ? AND life = ?', Date.today - 2.month , 1 ).order('infos.dateInfo05 ASC')
    end

    i = 1
    childs_counter = 0
    @job_count = jobs.count
    jobs.find_each do |job|
      #data_set_sub(job)
      i += 1
    end
    @q = Archive.ransack(params[:q])
    #@q.result.page(params[:page]).per(15).order('id desc')
    @archives = @q.result.page(params[:page]).per(12).order('id desc')
    #redirect_to data_set_archives_path
  end
  def out_archive_mission
    # 1) 検索条件を session[:q] から復元
    q_params = session[:q] || {}
    @q = MissionArchive.ransack(q_params)
    lines = []
    i = 1
    # 3) 全件取得（ページングなし）
    mission_archives = @q.result

    # 4) ヘッダ（index の列と同じ順）
    headers = [
      'No','所属','種類', '受注No', '得意先名', '品名', '担当',
      '用紙','刷版','直接材料費','POD','直接外注費','直接仕入高',
      '製造労務時間','賃率','製造労務費','制作労務時間','賃率','制作労務費','デザイン労務時間','賃率','デザイン労務費',
      '直接作業時間合計','直接労務費計','アセンブリ労務時間','賃率','雑給計','材料費','労務費',
      '賞与','雑給','法定福利','福利厚生費','水道光熱費','修繕費','租税公課',
      '賃借料','保険料','消耗品費','減価償却費','雑費','間接費合計','運賃','合計原価','売上','粗利','粗利率'
    ]
    mission_archives.find_each do |mission_archive|
      row = [i]

      1.upto(46) do |index|
        column_name = "mission_archive_#{format('%02d', index)}"

        if mission_archive.respond_to?(column_name)
          if index < 7 || index == 13 || index == 16 || index == 19 || index == 22 || index == 24 || index == 46
            row << mission_archive.public_send(column_name)
          else
            row << numformat1(mission_archive.public_send(column_name))
          end

        end

      end

      # TSVの1行へ
      # タブ・改行を含む可能性のある文字列は安全のため置換
      safe_row = row.map { |v| v.to_s.gsub(/\t/, ' ').gsub(/\r?\n/, ' ') }
      lines << safe_row.join("\t")

      i += 1
    end

    # 6) 送信
    filename = "mission_archive_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.tsv"
    body = ([headers.join("\t")] + lines).join("\n")
    send_data body, filename: filename, type: 'text/tab-separated-values; charset=UTF-8'
  end

  # GET /mission_archives/1 or /mission_archives/1.json
  def show
  end

  # GET /mission_archives/new
  def new
    @mission_archive = MissionArchive.new
  end

  # GET /mission_archives/1/edit
  def edit
  end

  # POST /mission_archives or /mission_archives.json
  def create
    @mission_archive = MissionArchive.new(mission_archive_params)

    respond_to do |format|
      if @mission_archive.save
        format.html { redirect_to @mission_archive, notice: "Mission archive was successfully created." }
        format.json { render :show, status: :created, location: @mission_archive }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mission_archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mission_archives/1 or /mission_archives/1.json
  def update
    respond_to do |format|
      if @mission_archive.update(mission_archive_params)
        format.html { redirect_to @mission_archive, notice: "Mission archive was successfully updated." }
        format.json { render :show, status: :ok, location: @mission_archive }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mission_archive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mission_archives/1 or /mission_archives/1.json
  def destroy
    @mission_archive.destroy

    respond_to do |format|
      format.html { redirect_to mission_archives_path, status: :see_other, notice: "Mission archive was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission_archive
      @mission_archive = MissionArchive.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mission_archive_params
      params.require(:mission_archive).permit(:mission_archive_01, :mission_archive_02, :mission_archive_03, :mission_archive_04, :mission_archive_05, :mission_archive_06, :mission_archive_07, :mission_archive_08, :mission_archive_09, :mission_archive_10, :mission_archive_11, :mission_archive_12, :mission_archive_13, :mission_archive_14, :mission_archive_15, :mission_archive_16, :mission_archive_17, :mission_archive_18, :mission_archive_19, :mission_archive_20, :mission_archive_21, :mission_archive_22, :mission_archive_23, :mission_archive_24, :mission_archive_25, :mission_archive_26, :mission_archive_27, :mission_archive_28, :mission_archive_29, :mission_archive_30, :mission_archive_31, :mission_archive_32, :mission_archive_33, :mission_archive_34, :mission_archive_35, :mission_archive_36, :mission_archive_37, :mission_archive_38, :mission_archive_39, :mission_archive_40)
    end
end
