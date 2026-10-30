class AddWeightToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :weight, :decimal,precision: 8, scale: 2,default: 0.0
  end
end
