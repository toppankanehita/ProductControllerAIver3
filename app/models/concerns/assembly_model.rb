class AssemblyModel < ActiveRecord::Base
  self.abstract_class = true
  AssemblyModel.establish_connection(:assembly)

end
