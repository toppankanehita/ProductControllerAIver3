# == Schema Information
#
# Table name: grid_settings
#
#  id                           :bigint           not null, primary key
#  canvas_width                 :integer
#  canvas_height                :integer
#  rect_width                   :integer
#  rect_height                  :integer
#  cols                         :integer
#  rows                         :integer
#  base_horizontal_gap          :integer
#  base_vertical_gap            :integer
#  center_horizontal_gap        :integer
#  center_vertical_gap          :integer
#  even_position_horizontal_gap :integer
#  even_position_vertical_gap   :integer
#  fixed_padding_bottom         :integer
#  job_id                       :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class GridSetting < ApplicationRecord
  belongs_to :job
end
