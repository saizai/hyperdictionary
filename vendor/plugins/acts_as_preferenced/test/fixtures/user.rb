class User < ActiveRecord::Base
  acts_as_preferenced
  validates_presence_of :login
end