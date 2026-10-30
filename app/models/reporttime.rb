# == Schema Information
#
# Table name: reporttimes
#
#  id            :integer          not null, primary key
#  machine       :string(32)
#  work_date     :date
#  job_id        :integer
#  report_id     :integer
#  reportitem_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  start_count   :integer
#  stop_count    :integer
#  remove_count  :integer
#  total_count   :integer          default(0)
#
class Reporttime < ReportModel
  belongs_to :job
  belongs_to :report
end
