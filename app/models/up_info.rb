# == Schema Information
#
# Table name: up_infos
#
#  id            :bigint           not null, primary key
#  infoItem      :string(255)
#  name          :string(255)
#  remarks       :string(255)
#  ftype         :string(255)
#  category      :integer
#  position      :integer
#  job_id        :integer
#  user_id       :integer
#  uploadfile_id :integer
#  settei_id     :integer
#  life          :integer          default(0)
#  change_no     :integer          default(0)
#  lastest       :integer          default(1)
#  created_at    :datetime
#  updated_at    :datetime
#
class UpInfo < VisualizeModel
  belongs_to :uploadfile
  belongs_to :settei
end
