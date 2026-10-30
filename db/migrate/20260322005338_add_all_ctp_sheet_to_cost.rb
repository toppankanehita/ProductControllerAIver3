class AddAllCtpSheetToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :all_ctp_sheet, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_slip_sales, :decimal, precision: 11, scale: 2,default: 0.0
  end
end
