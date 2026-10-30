class CreatePaperLists < ActiveRecord::Migration[6.1]
  def change
    create_table :paper_lists do |t|
      t.string :full_name
      t.string :name
      t.string :opt1
      t.string :opt2
      t.string :han
      t.string  :line
      t.decimal :ren, precision: 6, scale: 2,default: 0.0
      t.decimal :unit_price, precision: 6, scale: 2,default: 0.0
      t.integer :paper_type_id

      t.timestamps
    end
  end
end
