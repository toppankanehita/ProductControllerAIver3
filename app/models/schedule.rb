# == Schema Information
#
# Table name: WorkSlip.schedules
#
#  id          :integer          not null, primary key
#  work_date   :date
#  name        :string(255)
#  position    :integer
#  job_id      :integer
#  created_at  :datetime
#  updated_at  :datetime
#  lastest     :integer          default(2)
#  calendar_id :integer
#  info_id     :integer
#  diff        :integer
#
class Schedule < WorkModel
  belongs_to :calendar
  belongs_to :job
  belongs_to :info

  def self.table_name_prefix
    "WorkSlip."
  end
end
