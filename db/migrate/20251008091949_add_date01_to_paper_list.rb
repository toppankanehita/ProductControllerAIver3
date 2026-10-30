class AddDate01ToPaperList < ActiveRecord::Migration[6.1]
  def change
    add_column :paper_lists, :date01, :date
  end
end
