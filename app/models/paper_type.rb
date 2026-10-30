# == Schema Information
#
# Table name: paper_types
#
#  id         :bigint           not null, primary key
#  category   :string(255)
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PaperType < ApplicationRecord
  has_many :paper_lists
end
