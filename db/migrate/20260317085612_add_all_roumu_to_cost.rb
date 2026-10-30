class AddAllRoumuToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :all_paper_web, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_paper_sheet, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_press_web, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_press_sheet, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_roumu_product, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_roumu_create, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_roumu_design, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_assembly, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :costs, :all_outsourcing, :decimal, precision: 11, scale: 2,default: 0.0
  end
end
