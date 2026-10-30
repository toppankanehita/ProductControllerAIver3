class AddAllTargerSalesToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :all_web_minus, :decimal
  end
end
