class AddKakoToArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :kako, :string
    add_column :archives, :booklet, :string
  end
end
