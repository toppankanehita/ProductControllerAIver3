class CreatePressData < ActiveRecord::Migration[6.1]
  def change
    create_table :press_data do |t|
      t.string :den_code
      t.string :product_name
      t.string :paper_no
      t.datetime :start_time
      t.integer :work_time
      t.integer :n01
      t.integer :n02
      t.string :machine
      t.integer :job_id

      t.timestamps
    end
  end
end
