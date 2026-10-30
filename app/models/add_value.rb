# == Schema Information
#
# Table name: add_values
#
#  id          :bigint           not null, primary key
#  paper_name  :string(255)
#  han         :string(255)
#  me          :string(255)
#  ren         :decimal(10, 1)
#  ktanka      :decimal(6, 2)    default(0.0)
#  mtanka      :decimal(6, 2)    default(0.0)
#  job_id      :integer
#  jisu        :integer
#  yobi        :integer
#  press_num   :integer
#  special     :integer
#  upo         :integer
#  gold        :integer
#  kaleid      :integer
#  other       :string(255)
#  sasi        :integer
#  iroko       :integer
#  sale_price  :decimal(11, 2)   default(0.0)
#  paper_price :decimal(11, 2)   default(0.0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  position    :integer
#  ita         :integer
#  tori        :integer
#  dai         :integer
#  men         :float(24)        default(1.0)
#
class AddValue < ApplicationRecord
  include AddValueExtensions
  belongs_to :job
  attribute :sasi, :integer, default: 0
  def self.ransackable_attributes(auth_object = nil)
    ["before_yobi", "created_at", "dai", "diff_before_price", "diff_before_weight", "gold", "han", "id", "iroko", "ita", "jisu", "job_id", "kaleid", "ktanka", "me", "men", "mtanka", "other", "paper_name", "paper_price", "paper_route", "position", "post_press", "press_num", "ren", "sale_price", "sasi", "special", "tori", "updated_at", "upo", "yobi"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["job"]
  end
end
