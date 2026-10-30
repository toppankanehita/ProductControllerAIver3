class CreateAddData < ActiveRecord::Migration[6.1]
  def change
    create_table :add_data do |t|
      t.integer :n01
      t.integer :n02
      t.integer :n03
      t.integer :n04
      t.integer :n05
      t.integer :dai
      t.integer :mentuke
      t.integer :sp
      t.string :machine

      t.integer :job_id

      t.timestamps
    end
  end
end
