class AddToriToPaperList < ActiveRecord::Migration[6.1]
  def change
    add_column :paper_lists, :tori, :integer
    add_column :paper_lists, :mtanka, :decimal
    add_column :paper_lists, :ktanka, :decimal
    add_column :paper_lists, :area_size, :integer
  end
end
