class ToppanModel < ActiveRecord::Base
  self.abstract_class = true
  ToppanModel.establish_connection(:toppan)
end