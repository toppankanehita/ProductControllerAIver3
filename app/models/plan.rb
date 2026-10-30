# == Schema Information
#
# Table name: plans
#
#  id                :integer          not null, primary key
#  work_date         :date
#  order             :integer
#  machine           :string(255)
#  work_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#  job_count         :integer          default(10)
#  machine01_count   :integer          default(10)
#  machine02_count   :integer          default(10)
#  machine03_count   :integer          default(10)
#  machine04_count   :integer          default(10)
#  machine05_count   :integer          default(10)
#  machine06_count   :integer          default(10)
#  machine07_count   :integer          default(10)
#  machine08_count   :integer          default(10)
#  machine01_comment :string(64)       default("未登録です")
#  machine02_comment :string(64)       default("未登録です")
#  machine03_comment :string(64)       default("未登録です")
#  machine04_comment :string(64)       default("未登録です")
#  machine05_comment :string(64)       default("未登録です")
#  machine06_comment :string(64)       default("未登録です")
#  machine07_comment :string(64)       default("未登録です")
#  machine08_comment :string(64)       default("未登録です")
#  machine01_open    :integer          default(1)
#  machine02_open    :integer          default(0)
#  machine03_open    :integer          default(0)
#  machine04_open    :integer          default(0)
#  machine05_open    :integer          default(0)
#  machine06_open    :integer          default(0)
#  machine07_open    :integer          default(0)
#  machine08_open    :integer          default(0)
#
class Plan < ReportModel
  has_many :planitems
end
