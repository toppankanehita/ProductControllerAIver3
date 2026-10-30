class AddOutCostToAddDatum < ActiveRecord::Migration[6.1]
  def change
    add_column :add_data, :out_cost, :integer
    add_column :add_data, :assembly, :integer
    add_column :add_data, :delivery, :integer
  end
end
