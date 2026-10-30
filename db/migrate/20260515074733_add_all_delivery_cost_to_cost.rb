class AddAllDeliveryCostToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :all_delivery_cost, :decimal
  end
end
