class CuttingModel < ActiveRecord::Base
  self.abstract_class = true
  CuttingModel.establish_connection(:cutting)

end
