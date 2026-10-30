# == Schema Information
#
# Table name: CtpRequest.slips
#
#  id            :integer          not null, primary key
#  txtInfo01     :string(255)
#  txtInfo02     :string(255)
#  txtInfo03     :string(255)
#  txtInfo04     :string(255)
#  txtInfo05     :string(255)
#  txtInfo06     :string(255)
#  txtInfo07     :string(255)      default("依頼済")
#  txtInfo08     :string(255)
#  txtInfo09     :string(255)
#  txtInfo10     :string(255)
#  numInfo01     :integer
#  numInfo02     :integer
#  numInfo03     :integer
#  numInfo04     :integer
#  numInfo05     :integer
#  numInfo06     :integer
#  numInfo07     :integer
#  numInfo08     :integer
#  dateInfo01    :date
#  dateInfo02    :date
#  dateInfo03    :date
#  dateInfo04    :date
#  timeInfo01    :time
#  timeInfo02    :time
#  timeInfo03    :time
#  timeInfo04    :time
#  created_at    :datetime
#  updated_at    :datetime
#  job_id        :integer
#  info_id       :integer
#  den_id        :string(64)       default("000000-000")
#  jobrequest_id :integer
#  address       :string(64)
#  ext           :integer          default(0)
#  color_print   :integer          default(0)
#  mono_print    :integer          default(0)
#  sp_print      :integer          default(0)
#
class Slip < CtpModel
  belongs_to :job
  has_many :fnames
  has_many :impositions
  def self.table_name_prefix
    "CtpRequest."
  end
end
