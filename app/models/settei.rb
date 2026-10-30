# == Schema Information
#
# Table name: setteis
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  kind       :string(255)      default("i")
#  remarks    :string(255)
#  remarks_e  :string(255)
#  px         :integer
#  py         :integer
#  gx         :integer
#  gy         :integer
#  category   :integer          default(0)
#  position   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Settei < VisualizeModel
end
