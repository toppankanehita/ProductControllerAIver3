# == Schema Information
#
# Table name: thumbs
#
#  id           :bigint           not null, primary key
#  path         :string(255)
#  den_code     :string(255)
#  work_date    :string(255)
#  work_date_on :date
#  thumb_path   :string(255)
#  thumb_name   :string(255)
#  url          :string(255)
#  machine      :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sheet_path   :string(255)
#  sheet_name   :string(255)
#
class Thumb < ThumbModel
  self.table_name='thumbs'


end
