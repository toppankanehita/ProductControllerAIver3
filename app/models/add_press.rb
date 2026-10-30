# == Schema Information
#
# Table name: add_presses
#
#  id         :bigint           not null, primary key
#  position   :integer
#  press_num  :integer
#  men        :integer
#  jisu       :integer
#  machine    :string(255)
#  han        :string(255)
#  iro        :string(255)
#  dai        :integer
#  kake       :float(24)
#  daitanka   :decimal(11, 2)   default(0.0)
#  tanka      :decimal(11, 2)   default(0.0), unsigned
#  dai_price  :decimal(11, 2)   default(0.0)
#  job_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  zara       :integer
#  toku       :integer
#  kin        :integer
#  upo        :integer
#  iroa       :integer
#  irob       :integer
#  kake2      :float(24)
#  page       :integer
#  sasi       :integer          default(1)
#
class AddPress < ApplicationRecord
  belongs_to :job
end
