class AddKake2ToAddPress < ActiveRecord::Migration[6.1]
  def change
    add_column :add_presses, :kake2, :float
  end
end
