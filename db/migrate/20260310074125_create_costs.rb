class CreateCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :costs do |t|
      t.string :target_month
      t.decimal :cost01, precision: 11, scale: 2,default: 0.0
      t.decimal :cost02, precision: 11, scale: 2,default: 0.0
      t.decimal :cost03, precision: 11, scale: 2,default: 0.0
      t.decimal :cost04, precision: 11, scale: 2,default: 0.0
      t.decimal :cost05, precision: 11, scale: 2,default: 0.0
      t.decimal :cost06, precision: 11, scale: 2,default: 0.0
      t.decimal :cost07, precision: 11, scale: 2,default: 0.0
      t.decimal :cost08, precision: 11, scale: 2,default: 0.0
      t.decimal :cost09, precision: 11, scale: 2,default: 0.0
      t.decimal :cost10, precision: 11, scale: 2,default: 0.0
      t.decimal :cost11, precision: 11, scale: 2,default: 0.0
      t.decimal :cost12, precision: 11, scale: 2,default: 0.0
      t.decimal :cost13, precision: 11, scale: 2,default: 0.0
      t.decimal :cost14, precision: 11, scale: 2,default: 0.0
      t.decimal :cost15, precision: 11, scale: 2,default: 0.0
      t.decimal :cost16, precision: 11, scale: 2,default: 0.0
      t.decimal :cost17, precision: 11, scale: 2,default: 0.0
      t.decimal :cost18, precision: 11, scale: 2,default: 0.0
      t.decimal :cost19, precision: 11, scale: 2,default: 0.0
      t.decimal :cost20, precision: 11, scale: 2,default: 0.0
      t.decimal :all_cost, precision: 11, scale: 2,default: 0.0
      t.decimal :all_sales, precision: 11, scale: 2,default: 0.0
      t.decimal :sales_cost, precision: 11, scale: 2,default: 0.0

      t.timestamps
    end
  end
end
