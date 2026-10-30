# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  work_date  :date
#  machine    :string(64)
#  writing01  :string(32)
#  writing02  :string(32)
#  remarks    :string(64)
#
class Report < ReportModel
  belongs_to :job
  has_many :reporttimes
  has_many :reportitems
end
