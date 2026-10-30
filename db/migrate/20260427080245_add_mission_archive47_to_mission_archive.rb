class AddMissionArchive47ToMissionArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :mission_archives, :mission_archive_47, :decimal
    add_column :mission_archives, :mission_archive_48, :decimal
    add_column :mission_archives, :mission_archive_49, :decimal
    add_column :mission_archives, :mission_archive_50, :decimal
  end
end
