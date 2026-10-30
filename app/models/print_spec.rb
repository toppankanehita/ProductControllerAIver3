# == Schema Information
#
# Table name: print_specs
#
#  id            :bigint           not null, primary key
#  t01           :string(255)
#  t02           :string(255)
#  n01           :integer          default(0)
#  n02           :integer          default(0)
#  n03           :integer          default(0)
#  n04           :integer          default(0)
#  n05           :integer          default(0)
#  n06           :integer          default(0)
#  price         :integer          default(0)
#  position      :integer          default(0)
#  lastest       :integer          default(1)
#  life          :integer          default(0)
#  uploadfile_id :integer
#  dai_tanka     :decimal(10, 2)   default(0.0)
#  tosi_tanka    :decimal(10, 2)   default(0.0)
#  kakeritu      :decimal(10, 2)   default(0.0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class PrintSpec < VisualizeModel
  belongs_to :uploadfile
end
