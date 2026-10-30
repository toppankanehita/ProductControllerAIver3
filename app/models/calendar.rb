# == Schema Information
#
# Table name: WorkSlip.calendars
#
#  id             :integer          not null, primary key
#  change_date    :datetime
#  change_no      :integer
#  info_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  cal_startday   :date
#  lastest        :integer          default(2)
#  job_id         :integer
#  diff_start_day :integer
#
class Calendar < WorkModel
  has_many :schedules
  belongs_to :job
  belongs_to :info
  def self.table_name_prefix
    "WorkSlip."
  end
end
