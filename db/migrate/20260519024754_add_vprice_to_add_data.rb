class AddVpriceToAddData < ActiveRecord::Migration[6.1]
  def change
    add_column :add_data, :vprice, :decimal
  end
end
