class CreateAddValues < ActiveRecord::Migration[6.1]
  def change
    create_table :add_values do |t|
      t.string :paper_name
      t.string :me
      t.string :han
      t.decimal :ren, precision: 6, scale: 1,default: 0.0
      t.decimal :ktanka, precision: 6, scale: 2,default: 0.0
      t.decimal :mtanka, precision: 6, scale: 2,default: 0.0
      t.integer :job_id

      t.timestamps
    end
  end
end
