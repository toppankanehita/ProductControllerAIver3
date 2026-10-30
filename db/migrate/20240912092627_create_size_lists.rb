class CreateSizeLists < ActiveRecord::Migration[6.1]
  def change
    create_table :size_lists do |t|
      t.decimal :weight, precision: 6, scale: 2,default: 0.0
      t.string :kind
      t.string :han
      t.decimal :weight_per_m, precision: 6, scale: 2,default: 0.0

      t.timestamps
    end
  end
end
