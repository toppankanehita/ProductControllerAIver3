class CtpModel < ActiveRecord::Base
  self.abstract_class = true
  CtpModel.establish_connection(:ctp)


end
