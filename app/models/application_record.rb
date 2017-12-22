class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
   #serialize :board, ActiveRecord::Coders::NestedHstore
end
