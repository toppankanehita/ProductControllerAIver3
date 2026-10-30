class AddDenCodeToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :den_code, :string
  end
end
