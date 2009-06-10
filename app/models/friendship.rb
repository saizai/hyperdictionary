class Friendship < ActiveRecord::Base
  belongs_to :to_user, :class_name => 'User'
  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_identity, :class_name => 'Identity'
  belongs_to :from_identity, :class_name => 'Identity'
  
  # aasm
  
end
