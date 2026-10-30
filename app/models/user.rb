# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  account         :string(64)
#  password        :string(64)
#  lastlogin       :datetime
#  email           :string(64)
#  name            :string(64)
#  employee_id     :integer
#  sales_code      :integer
#  work_slip       :integer
#  time_recorder   :integer
#  ctp_request     :integer
#  printing_plan   :integer
#  check_plan      :integer
#  customer_adm    :integer
#  planetImageView :integer
#  SozaiImageView  :integer
#  product_plan    :integer
#  mitumori        :integer
#  visualize       :integer
#  codo            :integer
#  salesManagement :integer
#  DivTimeAdmin    :integer
#  team_id         :integer
#  knowledge       :integer
#  remarks         :string(64)
#  created_at      :datetime
#  updated_at      :datetime
#
class User < ToppanModel
  #User.establish_connection("toppan")
  def after_find
    unless self.employee_id.blank? then
      employee = Employee.find(:first,:conditions => ["id = ?",self.employee_id])
      self.sales_code = employee.sales_code.blank? ? "" : employee.sales_code
    end
  end
end
