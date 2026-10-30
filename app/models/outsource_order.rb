# frozen_string_literal: true

class OutsourceOrder < VisualizeModel
  self.table_name = "visualize.outsource_orders"

  belongs_to :job, optional: true
  belongs_to :info, optional: true

  before_save :sync_effective_date

  scope :newest_first, -> {
    order(effective_date: :desc, issue_date: :desc, order_date: :desc, id: :desc)
  }

  # 指定した Job (または den_id) に紐づく外注依頼書履歴を日付の新しい順で全件取得
  def self.history_for_job(job_or_den_id)
    return none if job_or_den_id.blank?

    if job_or_den_id.is_a?(String)
      where(den_id: job_or_den_id.strip).newest_first
    else
      job_id = job_or_den_id.respond_to?(:id) ? job_or_den_id.id : job_or_den_id.to_i
      den_id = job_or_den_id.respond_to?(:den_id) ? job_or_den_id.den_id.to_s.strip : ""
      if den_id.present?
        where("job_id = ? OR den_id = ?", job_id, den_id).newest_first
      else
        where(job_id: job_id).newest_first
      end
    end
  end

  # 指定した Job (または den_id) に紐づく外注依頼書のうち、最も日付の新しい1件を取得
  def self.latest_for_job(job_or_den_id)
    history_for_job(job_or_den_id).first
  end

  def self.table_name_prefix
    "visualize."
  end

  private

  def sync_effective_date
    self.effective_date = [issue_date, order_date].compact.max
  end
end
