class AddItaToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :ita, :integer
  end
end
