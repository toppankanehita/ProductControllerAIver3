class WorkModel < ActiveRecord::Base
  self.abstract_class = true
  WorkModel.establish_connection(:work_slip)
end
