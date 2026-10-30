class AddPressNumToAddDatum < ActiveRecord::Migration[6.1]
  def change
    add_column :add_data, :press_num, :integer
    add_column :add_data, :sales_price, :integer
    add_column :add_data, :iroko_num, :integer
  end
end
