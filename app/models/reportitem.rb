# == Schema Information
#
# Table name: reportitems
#
#  id            :integer          not null, primary key
#  work_date     :date
#  position      :integer
#  report_id     :integer
#  job_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#  machine       :string(64)
#  den_id        :string(64)
#  numInfo01     :integer
#  numInfo04     :integer
#  numInfo05     :integer
#  textInfo05    :string(64)
#  textInfo07    :string(64)
#  textInfo11    :string(64)
#  textInfo20    :string(16)
#  textInfo29    :string(16)
#  dateInfo02    :date
#  dateInfo05    :date
#  ope01         :string(32)
#  ope02         :string(32)
#  ope03         :string(32)
#  ope04         :string(32)
#  finished      :string(16)
#  sonsi         :integer
#  sasikae       :integer
#  print_name    :string(64)
#  customer_code :string(64)
#
class Reportitem < ReportModel
  belongs_to :job
  belongs_to :report
end
