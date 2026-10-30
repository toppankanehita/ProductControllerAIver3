class AddPressSiageSizeToArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :press_siage_size, :string
    add_column :archives, :press_siage_size1, :integer
    add_column :archives, :press_siage_size2, :integer
    add_column :archives, :press_tenkai_size, :string
    add_column :archives, :press_tenkai_size1, :integer
    add_column :archives, :press_tenkai_size2, :integer
  end
end
