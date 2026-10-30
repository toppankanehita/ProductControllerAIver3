class AddCtoToAddDatum < ActiveRecord::Migration[6.1]
  def change
    add_column :add_data, :ctp, :integer
    add_column :add_data, :kako, :integer
    add_column :add_data, :pod, :integer
  end
end
