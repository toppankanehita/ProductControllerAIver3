class GridsController < ApplicationController
  def show
    @job = Job.find(params[:id])
    #@q = session[:q]
    @grid_setting = GridSetting.first_or_initialize # 最初のレコードを取得、なければ新規作成
    # arrange モデルからデータを取得し、@grid_setting の初期値に反映させる場合はここにロジックを追加
    # 例:
    # item = Item.find_by(id: params[:item_id]) # arrangeモデルの特定のレコード
    # if item
    #   @grid_setting.canvas_width = item.width_attribute if item.width_attribute.present?
    #   @grid_setting.rect_width = item.children.count * item.children.first.width_attribute if item.children.any?
    #   # ... など、arrangeの結果からグリッド設定の値を計算して@grid_settingに代入
    # end

    # JavaScriptに渡すためのハッシュ
    @initial_grid_settings = {
      canvas_width: @grid_setting.canvas_width,
      canvas_height: @grid_setting.canvas_height,
      rect_width: @grid_setting.rect_width,
      rect_height: @grid_setting.rect_height,
      cols: @grid_setting.cols,
      rows: @grid_setting.rows,
      base_horizontal_gap: @grid_setting.base_horizontal_gap,
      base_vertical_gap: @grid_setting.base_vertical_gap,
      center_horizontal_gap: @grid_setting.center_horizontal_gap,
      center_vertical_gap: @grid_setting.center_vertical_gap,
      even_position_horizontal_gap: @grid_setting.even_position_horizontal_gap,
      even_position_vertical_gap: @grid_setting.even_position_vertical_gap,
      fixed_padding_bottom: @grid_setting.fixed_padding_bottom
    }
    render layout: "simple"
  end
end
