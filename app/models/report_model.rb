class ReportModel < ActiveRecord::Base
  self.abstract_class = true
  ReportModel.establish_connection(:printplan)

end
