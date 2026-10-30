class AddCost21ToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :cost21, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :cost22, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :cost23, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :cost24, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :cost25, :decimal, precision: 11, scale: 2,default: 0.0

  end
end
