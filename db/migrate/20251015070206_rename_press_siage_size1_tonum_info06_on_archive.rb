class RenamePressSiageSize1TonumInfo06OnArchive < ActiveRecord::Migration[6.1]
  def change
    rename_column :archives, :press_siage_size1, :numInfo06
    rename_column :archives, :press_siage_size2, :numInfo07
    rename_column :archives, :press_tenkai_size1, :numInfo14
    rename_column :archives, :press_tenkai_size2, :numInfo15
  end
end
