class AddSaleCtpToArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :sale_ctp, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_pod, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_kako, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_seisaku, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_gaicyu, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_assembly, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :archives, :sale_haiso, :decimal, precision: 11, scale: 2,default: 0.0
  end
end
