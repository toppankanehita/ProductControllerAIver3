# == Schema Information
#
# Table name: tasks
#
#  id            :bigint           not null, primary key
#  den_code      :string(255)
#  customer_code :string(255)
#  customer_name :string(255)
#  job_id        :integer
#  temp_id       :integer
#  job_name      :string(255)
#  position      :integer
#  posi          :float(24)
#  status        :integer          default(0)
#  comment       :string(255)
#  needed_people :integer
#  planned_date  :date
#  working_time  :time
#  start_time    :datetime
#  task_detail   :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  last_on       :datetime
#  plan_end_date :date
#
class Task < AssemblyModel
  belongs_to :job, optional: true
  has_many :workers
end
