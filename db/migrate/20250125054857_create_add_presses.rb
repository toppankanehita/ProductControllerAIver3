class CreateAddPresses < ActiveRecord::Migration[6.1]
  def change
    create_table :add_presses do |t|
      t.integer :position
      t.integer :press_num
      t.integer :men
      t.integer :jisu
      t.string :machine
      t.string :han
      t.string :iro
      t.integer :dai
      t.float :kake
      t.decimal :daitanka, precision: 11, scale: 2,default: 0.0
      t.decimal :tanka, precision: 11, scale: 2,default: 0.0
      t.decimal :dai_price, precision: 11, scale: 2,default: 0.0
      t.integer :job_id

      t.timestamps
    end
  end
end
