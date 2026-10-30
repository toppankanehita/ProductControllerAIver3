class AddIroaToAddPree < ActiveRecord::Migration[6.1]
  def change
    add_column :add_presses, :iroa, :integer
    add_column :add_presses, :irob, :integer
  end
end
