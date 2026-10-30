class KakoModel < ActiveRecord::Base
  self.abstract_class = true
  KakoModel.establish_connection(:postplan)
end