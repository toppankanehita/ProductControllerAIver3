class AddDtoToAddDatum < ActiveRecord::Migration[6.1]
  def change
    add_column :add_data, :dtp, :integer
    add_column :add_data, :parent_code, :string
  end
end
