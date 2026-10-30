# == Schema Information
#
# Table name: CtpRequest.jobrequests
#
#  id         :integer          not null, primary key
#  den_id     :string(64)
#  textInfo01 :string(64)
#  textInfo02 :string(255)
#  textInfo03 :string(255)
#  textInfo05 :string(255)
#  textInfo07 :string(255)
#  textInfo10 :string(255)
#  textInfo11 :string(255)
#  textInfo20 :string(255)
#  salesname  :string(255)
#  numInfo04  :integer
#  numInfo05  :integer
#  numInfo06  :integer
#  numInfo07  :integer
#  dateInfo05 :date
#  timeInfo01 :time
#  slip_id    :integer
#  job_id     :integer
#  info_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
class Jobrequest < CtpModel
  belongs_to :job

  def self.table_name_prefix
    "CtpRequest."
  end
end
