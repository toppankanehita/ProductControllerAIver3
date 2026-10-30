# == Schema Information
#
# Table name: press_data
#
#  id           :bigint           not null, primary key
#  den_code     :string(255)
#  product_name :string(255)
#  paper_no     :string(255)
#  start_time   :datetime
#  work_time    :integer
#  n01          :integer
#  n02          :integer
#  machine      :string(255)
#  job_id       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class PressData < ApplicationRecord
end
