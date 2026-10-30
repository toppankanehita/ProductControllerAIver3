# == Schema Information
#
# Table name: CtpRequest.fnames
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  remark     :string(255)
#  created_at :datetime
#  updated_at :datetime
#  slip_id    :integer
#  position   :integer
#
class Fname < CtpModel
  belongs_to :slip

  def self.table_name_prefix
    "CtpRequest."
  end
end
