class VisualizeModel < ActiveRecord::Base
  self.abstract_class = true
  VisualizeModel.establish_connection(:visualize)

  def self.table_name_prefix
    "visualize."
  end
end
