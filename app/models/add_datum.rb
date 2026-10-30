# == Schema Information
#
# Table name: add_data
#
#  id          :bigint           not null, primary key
#  n01         :integer
#  n02         :integer
#  n03         :integer
#  n04         :integer
#  n05         :integer
#  dai         :integer
#  mentuke     :integer
#  sp          :integer
#  machine     :string(255)
#  job_id      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  press_num   :integer
#  sales_price :integer
#  iroko_num   :integer
#  out_cost    :integer
#  assembly    :integer
#  delivery    :integer
#  ctp         :integer
#  kako        :integer
#  pod         :integer
#  dtp         :integer
#  parent_code :string(255)
#
class AddDatum < ApplicationRecord
  belongs_to :job, optional: true

  def self.ransackable_attributes(auth_object = nil)
    ["assembly", "created_at", "ctp", "dai", "delivery", "dtp", "id", "iroko_num", "job_id", "kako", "machine", "mentuke", "n01", "n02", "n03", "n04", "n05", "out_cost", "parent_code", "pod", "press_num", "sales_price", "sp", "updated_at"]
  end
end
