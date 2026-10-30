class PressBoardModel < ActiveRecord::Base
  self.abstract_class = true
  PressBoardModel.establish_connection(:press_board)
end
