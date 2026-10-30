class CreateTworks < ActiveRecord::Migration[6.1]
  def change
    create_table :tworks do |t|
      t.integer :no
      t.string :delivery_no
      t.date :delivery_date
      t.string :tinfo05
      t.string :tinfo07
      t.string :quote_no
      t.decimal :quantity, precision: 11, scale: 2,default: 0.0
      t.integer :unit_price
      t.integer :billing_amount
      t.decimal :cost1, precision: 11, scale: 2,default: 0.0
      t.decimal :cost2, precision: 11, scale: 2,default: 0.0
      t.decimal :cost3, precision: 11, scale: 2,default: 0.0
      t.decimal :total_cost, precision: 11, scale: 2,default: 0.0
      t.decimal :profit, precision: 11, scale: 2,default: 0.0
      t.float :profit_margin
      t.string :contractor1
      t.string :contractor2
      t.string :contractor3
      t.string :customer_code
      t.text :remarks
      t.string :staff
      t.string :den_code
      t.decimal :outsourcing_cost, precision: 11, scale: 2,default: 0.0
      t.decimal :purchase_cost, precision: 11, scale: 2,default: 0.0
      t.float :word_time
      t.decimal :work_cost, precision: 11, scale: 2,default: 0.0
      t.string :target_month

      t.timestamps
    end
  end
end
