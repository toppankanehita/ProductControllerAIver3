# == Schema Information
#
# Table name: paper_lists
#
#  id            :bigint           not null, primary key
#  full_name     :string(255)
#  name          :string(255)
#  opt1          :string(255)
#  opt2          :string(255)
#  han           :string(255)
#  line          :string(255)
#  ren           :decimal(6, 2)    default(0.0)
#  unit_price    :decimal(6, 2)    default(0.0)
#  paper_type_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class PaperList < ApplicationRecord
  belongs_to :paper_type
end
