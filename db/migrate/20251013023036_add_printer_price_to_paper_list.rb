class AddPrinterPriceToPaperList < ActiveRecord::Migration[6.1]
  def change
    add_column :paper_lists, :printer_price, :decimal,precision: 6, scale: 2,default: 0.0
  end
end
