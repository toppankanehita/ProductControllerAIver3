class VisualizeModel < ActiveRecord::Base
  self.abstract_class = true
  VisualizeModel.establish_connection(:visualize)
end
