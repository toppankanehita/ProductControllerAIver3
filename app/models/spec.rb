# == Schema Information
#
# Table name: specs
#
#  id            :bigint           not null, primary key
#  positon       :integer
#  uploadfile_id :integer
#  life          :integer          default(0)
#  lastest       :integer          default(1)
#  t01           :string(255)
#  f01           :float(24)        default(0.0)
#  n01           :integer          default(0)
#  f02           :float(24)        default(0.0)
#  n02           :integer          default(0)
#  f03           :float(24)        default(0.0)
#  f04           :float(24)        default(0.0)
#  n03           :integer          default(0)
#  n04           :integer          default(0)
#  t02           :string(255)
#  t03           :string(255)
#  t04           :string(255)
#  t05           :string(255)
#  n05           :integer          default(0)
#  n06           :integer          default(0)
#  n07           :integer          default(0)
#  n08           :integer          default(0)
#  n09           :integer          default(0)
#  n10           :integer          default(0)
#  f05           :float(24)
#  f06           :float(24)
#  f07           :float(24)
#  f08           :float(24)
#  f09           :float(24)
#  f10           :float(24)
#  n11           :integer          default(0)
#  n12           :integer          default(0)
#  n13           :integer          default(0)
#  n14           :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Spec < VisualizeModel
  belongs_to :uploadfile
end
