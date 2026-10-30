# == Schema Information
#
# Table name: WorkSlip.kakos
#
#  id         :integer          unsigned, not null, primary key
#  kako_t01   :string(64)
#  kako_t02   :string(64)
#  kako_t03   :string(64)
#  kako_t04   :string(64)
#  kako_d01   :date
#  kako_d02   :date
#  job_id     :integer
#  info_id    :integer
#  position   :integer
#  lastest    :integer
#  dif_t01    :integer
#  dif_t02    :integer
#  dif_t03    :integer
#  dif_t04    :integer
#  dif_d01    :integer
#  dif_d02    :integer
#  created_at :datetime
#  updated_at :datetime
#
class Kako < WorkModel
  def self.table_name_prefix
    "WorkSlip."
  end
end
