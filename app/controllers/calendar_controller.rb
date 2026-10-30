class CalendarController < ApplicationController
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
    job_t  = Job.arel_table

    scope = Job.includes(:info)
               .joins(:info)
               .where(info_t[:dateInfo03].between(@start_date..@end_date))

    @filters.each do |col, val|
      next if val.blank?
      col_name = col.to_s
      next unless Info.column_names.include?(col_name)
      scope = scope.where(info_t[col_name].matches("%#{val}%"))
    end

    @jobs_by_date = (@start_date..@end_date).map { |d| [d, []] }.to_h

    scope.order(info_t[:dateInfo03].asc, job_t[:id].desc).each do |job|
      d = job.info&.dateInfo03&.to_date
      next unless d
      @jobs_by_date[d] << job
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  # Return updated job item HTML for a given job_id (used to refresh calendar item after modal close)
  def job_item
    job_id = params[:job_id] || params[:id]
    @job = Job.includes(:info).find(job_id)
    info = @job.info
    html = render_to_string(partial: 'calendar/job_item', formats: [:html], locals: { job: @job, info: info })
    render json: { html: html, job_id: @job.id }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Job not found' }, status: :not_found
  end
end