# == Schema Information
#
# Table name: cpr_times
#
#  id              :integer          not null, primary key
#  work_date       :date
#  work_time       :integer
#  cpr_job_id      :integer
#  sInfo05         :string(255)
#  sInfo07         :string(255)
#  cpr_schedule_id :integer
#  employee_id     :integer
#  cpr_info_id     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  name            :string(255)
#
class CprTime < CprModel
  belongs_to :employee
  belongs_to :cpr_job
end
