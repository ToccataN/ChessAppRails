class Turn < ApplicationRecord
  belongs_to :games
  #serialize :board, ActiveRecord::Coders::NestedHstore
end
