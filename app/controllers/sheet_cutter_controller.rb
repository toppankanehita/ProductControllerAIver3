class SheetCutterController < ApplicationController
  protect_from_forgery with: :exception
  def index


    base_date =
      if params[:week_start].present?
        begin
          Date.parse(params[:week_start])
        rescue ArgumentError
          Date.today
        end
      else
        Date.today
      end

    @start_date = base_date.beginning_of_week(:sunday)
    @end_date   = @start_date + 6.days

    @filters = {
      textInfo02: params[:info_textInfo02].to_s.strip,
      textInfo05: params[:info_textInfo05].to_s.strip,
      textInfo11: params[:info_textInfo11].to_s.strip
    }

    info_t = Info.arel_table
    av_t   = AddValue.arel_table

    # 1) AddValue 側（別DB）で「シートカッター」を含む行を抽出し、job_id を取得
    av_scope = AddValue.where(av_t[:paper_route].matches("%シートカッター%"))
                       .where.not(job_id: nil)

    job_ids = av_scope.distinct.pluck(:job_id)

    # 初期化：週内の日付 => AddValue 配列
    @values_by_date = (@start_date..@end_date).map { |d| [d, []] }.to_h
    @jobs_by_id = {}

    if job_ids.present?
      # 2) Job 側（別DB）で週内、かつ検索条件（info_textInfo02/05/11）で絞り込み
      job_scope = Job.includes(:info)
                     .joins(:info)
                     .where(id: job_ids)
                     .where(info_t[:dateInfo03].between(@start_date..@end_date))

      @filters.each do |col, val|
        next if val.blank?
        col_name = col.to_s
        next unless Info.column_names.include?(col_name)
        job_scope = job_scope.where(info_t[col_name].matches("%#{val}%"))
      end

      jobs = job_scope.to_a
      @jobs_by_id = jobs.index_by(&:id)
      allowed_ids = @jobs_by_id.keys

      # 3) 対象 Job に紐づく AddValue を取り出し、日付でグルーピング
      values = av_scope.where(job_id: allowed_ids).order(:id).to_a

      values.each do |value|
        job = @jobs_by_id[value.job_id]
        next unless job && job.info && job.info.dateInfo03
        d = job.info.dateInfo03.to_date
        next unless d && d >= @start_date && d <= @end_date
        @values_by_date[d] << value
      end
    end
  end
end

