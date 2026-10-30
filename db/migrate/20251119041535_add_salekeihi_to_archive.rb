class AddSalekeihiToArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :sale_mitumori, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_keihi, :decimal, precision: 11, scale: 2,default: 0.0
  end
end
