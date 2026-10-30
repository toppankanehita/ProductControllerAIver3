class AddPageToAddPress < ActiveRecord::Migration[6.1]
  def change
    add_column :add_presses, :page, :integer
  end
end
