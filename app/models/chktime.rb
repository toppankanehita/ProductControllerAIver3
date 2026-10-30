# == Schema Information
#
# Table name: chktimes
#
#  id               :integer          not null, primary key
#  name             :string(60)
#  work_date        :date
#  work_time        :integer
#  position         :integer
#  checkschedule_id :integer
#  status           :string(20)
#  work_div         :string(20)
#  job_id           :integer
#  customer_id      :integer
#  employee_id      :integer
#  app              :string(16)
#  created_at       :datetime
#  updated_at       :datetime
#  memo             :string(64)
#  address          :string(32)
#
class Chktime < WorkModel
  belongs_to :job
  belongs_to :checkschedule
  belongs_to :employee
end
