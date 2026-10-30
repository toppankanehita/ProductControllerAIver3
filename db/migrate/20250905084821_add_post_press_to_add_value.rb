class AddPostPressToAddValue < ActiveRecord::Migration[6.1]
  def change
    add_column :add_values, :post_press, :string
    add_column :add_values, :before_yobi, :int
    add_column :add_values, :diff_before_weight, :decimal, precision: 6, scale: 2,default: 0.0
    add_column :add_values, :diff_before_price, :decimal, precision: 11, scale: 2,default: 0.0
    add_column :add_values, :paper_route, :string
  end
end
