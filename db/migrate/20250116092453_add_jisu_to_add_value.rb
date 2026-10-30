class AddJisuToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :jisu, :integer
    add_column :add_values, :yobi, :integer
    add_column :add_values, :press_num, :integer
    add_column :add_values, :special, :integer
    add_column :add_values, :upo, :integer
    add_column :add_values, :gold, :integer
    add_column :add_values, :kaleid, :integer
    add_column :add_values, :other, :string
    add_column :add_values, :sasi, :integer
    add_column :add_values, :iroko, :integer
    add_column :add_values, :sale_price, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :add_values, :paper_price, :decimal, precision: 11, scale: 2,default: 0.0
  end
end
