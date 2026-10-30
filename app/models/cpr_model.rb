class CprModel < ActiveRecord::Base
  self.abstract_class = true
  CprModel.establish_connection(:cpr)
end