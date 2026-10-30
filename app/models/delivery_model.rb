class DeliveryModel < ActiveRecord::Base
  self.abstract_class = true
  DeliveryModel.establish_connection(:delivery)

end
