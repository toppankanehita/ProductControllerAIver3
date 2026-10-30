class CreateDebits < ActiveRecord::Migration[6.1]
  def change
    create_table :debits do |t|
      t.string :target_month
      t.string :den_code
      t.integer :job_id
      t.string :siwake
      t.string :name
      t.decimal :out_cost
      t.decimal :in_cost

      t.timestamps
    end
  end
end
