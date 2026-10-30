# == Schema Information
#
# Table name: planitems
#
#  id         :integer          not null, primary key
#  plan_id    :integer
#  machine    :string(255)
#  position   :integer
#  work_date  :date
#  job_id     :integer
#  print_time :string(32)
#  delivery   :string(32)
#  weight     :string(32)
#  memo       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
class Planitem < ReportModel
  belongs_to :job
end
