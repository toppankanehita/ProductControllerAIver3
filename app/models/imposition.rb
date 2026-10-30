# == Schema Information
#
# Table name: CtpRequest.impositions
#
#  id         :integer          unsigned, not null, primary key
#  den_id     :string(64)
#  job_id     :integer
#  slip_id    :integer
#  dai        :integer          default(0)
#  machine    :string(32)
#  num        :integer          default(0)
#  aki        :integer          default(0)
#  kuwae      :integer          default(0)
#  position   :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#
class Imposition < CtpModel
  belongs_to :slip

  def self.table_name_prefix
    "CtpRequest."
  end
end
