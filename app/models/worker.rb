# == Schema Information
#
# Table name: workers
#
#  id          :bigint           not null, primary key
#  worker_name :string(255)
#  worker_code :integer
#  bite_id     :integer
#  work_date   :date
#  status      :integer          default(0)
#  task_id     :integer
#  start_time  :datetime
#  stop_time   :datetime
#  work_time   :integer
#  num         :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Worker < AssemblyModel
  belongs_to :task, optional: true
end
