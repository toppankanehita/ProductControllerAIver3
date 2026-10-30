class AddKiriToPaperList < ActiveRecord::Migration[6.1]
  def change
    add_column :paper_lists, :kiri, :integer
    add_column :paper_lists, :ita, :integer
  end
end
