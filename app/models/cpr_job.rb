# == Schema Information
#
# Table name: cpr_jobs
#
#  id               :integer          not null, primary key
#  total_time       :integer
#  job_id           :integer
#  info_id          :integer
#  cpr_info_id      :integer
#  checkschedule_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  tci_id           :string(255)
#  require          :integer          default(1)
#
class CprJob < CprModel
  belongs_to :job
  has_many :cpr_times
end
