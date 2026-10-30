class Twork < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["no","delivery_number","delivery_date","tinfo05","tinfo07","quote_number","quantity","unit_price","billing_amount","cost1","cost2","cost3","total_cost","profit","profit_margin","contractor1","contractor2","contractor3","customer_code","remarks","staff","den_code","outsourcing_cost","purchase_cost","work_time","work_cost"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
