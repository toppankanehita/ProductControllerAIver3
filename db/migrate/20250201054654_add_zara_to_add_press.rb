class AddZaraToAddPress < ActiveRecord::Migration[6.1]
  def change
    add_column :add_presses, :zara, :integer
    add_column :add_presses, :toku, :integer
    add_column :add_presses, :kin, :integer
    add_column :add_presses, :upo, :integer
  end
end
