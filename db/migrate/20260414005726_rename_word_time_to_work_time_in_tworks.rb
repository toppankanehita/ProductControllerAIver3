class RenameWordTimeToWorkTimeInTworks < ActiveRecord::Migration[6.1]
  def change
    rename_column :tworks, :word_time, :work_time
  end
end
