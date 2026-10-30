class AddPotitionToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :position, :integer
  end
end
