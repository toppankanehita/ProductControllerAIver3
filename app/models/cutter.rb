# == Schema Information
#
# Table name: workers
#
#  id          :bigint           not null, primary key
#  worker_name :string(255)
#  status      :integer          default(0)
#  work_date   :date
#  start_time  :datetime
#  stop_time   :datetime
#  work_time   :integer
#  num         :integer
#  task_id     :integer
#  job_id      :integer
#  employee_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  kind        :string(255)
#  category_id :integer
#
class Cutter < CuttingModel
  self.table_name = "workers"
end
