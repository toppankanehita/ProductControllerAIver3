class JobsController < ApplicationController
  protect_from_forgery with: :exception
  def index
    @q = Job.ransack(params[:q])
    session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
    @q.build_grouping({ :life_eq => 1 })
    @jobs =  @q.result.page(params[:page]).per(15).order('id desc')

    respond_to do |format|
      format.html { render layout: "job_index" }
      format.json { render json: { ok: true, count: @jobs.size } }
    end
  end
  def press_list
    t = DateTime.now
    @jobs = Job.joins(:info).where("infos.textInfo02 = ? AND infos.dateInfo05 <= ?", "002　オフセット", t ).limit(20).order("jobs.id desc")
  end

  def show
    @q = Job.ransack(session["q"])

    if params[:show] == "show"
      #puts "--111----"
      ii = params[:page].to_i
      p = (ii / 15).to_i
      if ii % 15 > 0
        p = p + 1
      end
      i = ii - ((p -1) * 15)
    else
      #puts "--222----"
      i = params[:i].to_i
      p = params[:p].to_i
      p = p == 0 ? 1 : p
      ii = ((p - 1) * 15) + (i % 15 == 0 ? 15 : i % 15)
    end
    session[:page] = p
    session[:i] = 1
    session[:show] = "show"
    #puts "--ii----"
    #puts "page:#{p} i:#{i} ii:#{ii}"
    if params[:job_id].present?
      @jobs = @q.result.page(ii).per(1).order('id desc').except(:i, :p)
      @job = Job.find(params[:job_id])
    elsif params[:id].present?
      @job = Job.find(params[:id])
    else
      @q.build_grouping({ :life_eq => 1 })
      if session["q"].present? && session["q"]["info_dateInfo03_lteq"].present?
        @jobs = @q.result.page(ii).per(1).order('id desc')
        #jobs = @q.result.page(ii).per(1).order('infos.dateInfo03 ASC')
        @job = @jobs[0]
      elsif session["q"].present? && session["q"]["info_dateInfo05_lteq"].present?
          @jobs = @q.result.page(ii).per(1).order('id desc')
          #jobs = @q.result.page(ii).per(1).order('infos.dateInfo03 ASC')
          @job = @jobs[0]
      else
        @jobs = @q.result.page(ii).per(1).order('id desc').except(:i, :p)
        #jobs = @q.result.page(ii).per(1).order('id desc')
        @job = @jobs[0]
      end
      @job = Job.find(params["job_id"])

    end

    @ii = ii
    @i = i
    @form = Form::AddPressCollection.new
    5.times.each do |i|
      add_press = AddPress.find_by(job_id: @job, position: i )
      if add_press.blank?
        add_press = AddPress.new(job_id: @job.id, position: i)
      end
      @form.add_presses[i] = add_press.present? ? add_press : AddPress.new(job_id: @job.id,position: i)
    end
    @value_form = Form::AddValueCollection.new
    5.times.each do |i|
      add_values = AddValue.find_by(job_id: @job, position: i ) || AddValue.new(job_id: @job, position: i)
      @value_form.add_values[i] = add_values.present? ? add_values : AddValue.new(job_id: @job.id,position: i)
    end
    @add_datum = AddDatum.find_by(job_id: @job) || AddDatum.new(job_id: @job)
    params[:show] = "show"
  end
  def show_org
    @job = Job.find(params[:id])
    @uploadfile = Uploadfile.find_by(job_id: @job)
    @print_plans = Planitem.where(job_id: @job.id)
    @print_reports = Reportitem.where(job_id: @job.id)
    @slips = Slip.where(job_id: @job)
    d = Date.strptime( @job.den_id , '%y%m%d')

    @unit_price = UnitPrice.find_by("date01 <= ?",d)

    @specs = Spec.where(uploadfile_id: @uploadfile)
    @print_specs = PrintSpec.where(uploadfile_id: @uploadfile)
    @press_datas = PressData.where(job_id: @job.id)
  end

  def arrange
    @job = Job.find(params[:id])
    @grid_setting = GridSetting.find_by(job_id: @job.id)

    if @grid_setting.nil?
      @grid_setting = GridSetting.new()
        @grid_setting.canvas_width = 939 # 例 = 外枠の幅
        @grid_setting.canvas_height = 636 # 例 = 外枠の高さ
        @grid_setting.rect_width = 100   # 例 = 四角の幅 (arrangeの子要素の幅から計算する、など)
        @grid_setting.rect_height = 150   # 例 = 四角の高さ
        @grid_setting.cols = 8           # 例 = 列数 (arrangeの子要素の数から計算する、など)
        @grid_setting.rows = 4          # 例 = 行数
        @grid_setting.base_horizontal_gap = 0
        @grid_setting.base_vertical_gap = 0
        @grid_setting.center_horizontal_gap = 6
        @grid_setting.center_vertical_gap = 6
        @grid_setting.even_position_horizontal_gap = 6
        @grid_setting.even_position_vertical_gap = 6
        @grid_setting.fixed_padding_bottom = 50
    end

    render layout: "simple"
  end
  def arrange_update
    #puts params[:job]
    grid_settings = GridSetting.all
    #puts grid_settings.count()
    #puts params[:job].class
    @grid_setting = GridSetting.find_by(job_id: params[:job])
    #puts "---0--"
    #puts params[:grid_setting]
    if @grid_setting.blank?
      @grid_setting = GridSetting.new(job_id: params[:job])
      #puts "---"
    end
    @grid_setting.canvas_width = params[:grid_setting][:canvas_width]
    @grid_setting.canvas_height = params[:grid_setting][:canvas_height]
    @grid_setting.rect_width = params[:grid_setting][:rect_width]
    @grid_setting.rect_height = params[:grid_setting][:rect_height]
    @grid_setting.cols = params[:grid_setting][:cols]
    @grid_setting.rows = params[:grid_setting][:rows]
    @grid_setting.base_horizontal_gap = params[:grid_setting][:base_horizontal_gap]
    @grid_setting.base_vertical_gap = params[:grid_setting][:base_vertical_gap]
    @grid_setting.center_horizontal_gap = params[:grid_setting][:center_horizontal_gap]
    @grid_setting.center_vertical_gap = params[:grid_setting][:center_vertical_gap]
    @grid_setting.even_position_horizontal_gap = params[:grid_setting][:even_position_horizontal_gap]
    @grid_setting.even_position_vertical_gap = params[:grid_setting][:even_position_vertical_gap]
    @grid_setting.fixed_padding_bottom = params[:grid_setting][:fixed_padding_bottom]
    @grid_setting.save
    #grid_setting = params[:grid_setting]

  end
  def download()
    #呼び出されたファイルを送信
    uploadfile = Uploadfile.find(params[:id])
    #send_data(@uploadfile.data,:filename=>@uploadfile.name)
    send_file(uploadfile.savepath,:filename => uploadfile.name)
  end
  def edit_paper
    @job = Job.find(params[:id])
    @info = @job.info
    #@q = session[:q]
    @grid_setting = GridSetting.first_or_initialize # 最初のレコードを取得、なければ新規作成

    @value_form = Form::AddValueCollection.new
    5.times.each do |i|
      add_values = AddValue.find_by(job_id: @job, position: i ) || AddValue.new(job_id: @job, position: i)
      @value_form.add_values[i] = add_values.present? ? add_values : AddValue.new(job_id: @job.id,position: i)
    end

    # arrange モデルからデータを取得し、@grid_setting の初期値に反映させる場合はここにロジックを追加
    # 例:
    # item = Item.find_by(id: params[:item_id]) # arrangeモデルの特定のレコード
    # if item
    #   @grid_setting.canvas_width = item.width_attribute if item.width_attribute.present?
    #   @grid_setting.rect_width = item.children.count * item.children.first.width_attribute if item.children.any?
    #   # ... など、arrangeの結果からグリッド設定の値を計算して@grid_settingに代入
    # end
    #
    # # JavaScriptに渡すためのハッシュ
    # @initial_grid_settings = {
    #   canvas_width: @grid_setting.canvas_width,
    #   canvas_height: @grid_setting.canvas_height,
    #   rect_width: @grid_setting.rect_width,
    #   rect_height: @grid_setting.rect_height,
    #   cols: @grid_setting.cols,
    #   rows: @grid_setting.rows,
    #   base_horizontal_gap: @grid_setting.base_horizontal_gap,
    #   base_vertical_gap: @grid_setting.base_vertical_gap,
    #   center_horizontal_gap: @grid_setting.center_horizontal_gap,
    #   center_vertical_gap: @grid_setting.center_vertical_gap,
    #   even_position_horizontal_gap: @grid_setting.even_position_horizontal_gap,
    #   even_position_vertical_gap: @grid_setting.even_position_vertical_gap,
    #   fixed_padding_bottom: @grid_setting.fixed_padding_bottom
    # }
    #
    # @grid_setting.canvas_width = params[:grid_setting][:canvas_width]
    # @grid_setting.canvas_height = params[:grid_setting][:canvas_height]
    # @grid_setting.rect_width = params[:grid_setting][:rect_width]
    # @grid_setting.rect_height = params[:grid_setting][:rect_height]
    # @grid_setting.cols = params[:grid_setting][:cols]
    # @grid_setting.rows = params[:grid_setting][:rows]
    # @grid_setting.base_horizontal_gap = params[:grid_setting][:base_horizontal_gap]
    # @grid_setting.base_vertical_gap = params[:grid_setting][:base_vertical_gap]
    # @grid_setting.center_horizontal_gap = params[:grid_setting][:center_horizontal_gap]
    # @grid_setting.center_vertical_gap = params[:grid_setting][:center_vertical_gap]
    # @grid_setting.even_position_horizontal_gap = params[:grid_setting][:even_position_horizontal_gap]
    # @grid_setting.even_position_vertical_gap = params[:grid_setting][:even_position_vertical_gap]
    # @grid_setting.fixed_padding_bottom = params[:grid_setting][:fixed_padding_bottom]
    #
    # puts "-------"
    # puts @grid_setting.base_horizontal_gap
    render layout: "simple"
  end
  private
  def add_press_collection_params
    params
      .require(:form_add_press_collection)
  end
  def set_grid_setting
    @grid_setting = GridSetting.find(params[:job])
  end
  def grid_setting_params
    params.require(:grid_setting).permit(:canvas_width, :canvas_height, :rect_width, :rect_height, :cols, :rows, :base_horizontal_gap, :base_vertical_gap, :center_horizontal_gap, :center_vertical_gap, :even_position_horizontal_gap, :even_position_vertical_gap)
  end
end
