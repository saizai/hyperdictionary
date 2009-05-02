class Status < ActiveRecord::Base
  acts_as_dropdown(:text => "status", :value => "abbreviation")
end