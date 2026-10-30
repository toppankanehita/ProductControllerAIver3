class AddAllPaperToCost < ActiveRecord::Migration[6.1]
  def change
    add_column :costs, :all_paper, :decimal
  end
end
