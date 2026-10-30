# == Schema Information
#
# Table name: ToppanM.employees
#
#  id           :integer          not null, primary key
#  emp_no       :integer
#  name         :string(255)
#  address      :string(255)
#  email        :string(64)
#  password     :string(32)
#  docpass      :string(64)
#  regulation   :integer          default(1)
#  sex          :integer
#  blood        :string(255)
#  birthday     :date
#  enterday     :date
#  busyo        :string(128)
#  sales_code   :integer
#  timer_div_id :integer
#  div_id       :integer
#  yaku_id      :integer
#  updated_at   :datetime
#  created_at   :datetime
#  sname        :string(64)
#
class Employee < ToppanModel

  def self.table_name_prefix
    "ToppanM."
  end
end
