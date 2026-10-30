# == Schema Information
#
# Table name: WorkSlip.kinds
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  name       :string(255)
#  category   :string(255)
#  created_at :datetime
#  updated_at :datetime
#  sortkey    :integer
#
class Kind < WorkModel
  def self.table_name_prefix
    "WorkSlip."
  end
end
