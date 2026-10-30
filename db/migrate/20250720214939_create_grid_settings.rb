class CreateGridSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :grid_settings do |t|
      t.integer :canvas_width
      t.integer :canvas_height
      t.integer :rect_width
      t.integer :rect_height
      t.integer :cols
      t.integer :rows
      t.integer :base_horizontal_gap
      t.integer :base_vertical_gap
      t.integer :center_horizontal_gap
      t.integer :center_vertical_gap
      t.integer :even_position_horizontal_gap
      t.integer :even_position_vertical_gap
      t.integer :fixed_padding_bottom
      t.integer :job_id

      t.timestamps
    end
  end
end
