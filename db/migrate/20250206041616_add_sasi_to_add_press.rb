class AddSasiToAddPress < ActiveRecord::Migration[6.1]
  def change
    add_column :add_presses, :sasi, :integer, :default => 0
  end
end
