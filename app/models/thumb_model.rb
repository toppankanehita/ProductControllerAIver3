class ThumbModel < ActiveRecord::Base
  self.abstract_class = true
  ThumbModel.establish_connection(:thumb)
end
