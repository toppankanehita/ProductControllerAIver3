# == Schema Information
#
# Table name: cargos
#
#  id                  :bigint           not null, primary key
#  product_name        :string(255)
#  product_code        :string(255)
#  weight              :integer
#  destination         :string(255)
#  fee                 :decimal(10, )
#  press_date          :date
#  press_time          :time
#  name                :string(255)
#  job_id              :integer
#  truck_id            :integer
#  yamato_invoice_id   :integer
#  fukuyama_invoice_id :integer
#  jisya_invoice_id    :integer
#  created_at          :datetime
#  updated_at          :datetime
#
class Cargo < DeliveryModel
  belongs_to :job, optional: true


end
