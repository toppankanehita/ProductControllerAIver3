# == Schema Information
#
# Table name: size_lists
#
#  id           :bigint           not null, primary key
#  weight       :decimal(6, 2)    default(0.0)
#  kind         :string(255)
#  han          :string(255)
#  weight_per_m :decimal(6, 2)    default(0.0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class SizeList < ApplicationRecord
end
