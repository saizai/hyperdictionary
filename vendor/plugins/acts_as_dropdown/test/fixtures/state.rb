class State < ActiveRecord::Base
  acts_as_dropdown(:conditions => "id < 4")
end