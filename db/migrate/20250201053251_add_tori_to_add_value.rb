class AddToriToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :tori, :integer
    add_column :add_values, :dai, :integer
  end
end
