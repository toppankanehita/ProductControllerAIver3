class AddMenToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :men, :float, :default => 1.0
  end
end
