class AddPaperNameToArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :archives, :post_press, :string
    add_column :archives, :paper_name, :string
    add_column :archives, :paper_route, :string
    add_column :archives, :ita, :integer
  end
end
