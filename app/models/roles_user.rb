# The table that links roles with users (generally named RoleUser.rb)
class RolesUser < ActiveRecord::Base
  acts_as_paranoid
  acts_as_authorizable
  stampable
  
  belongs_to :user
  belongs_to :role
end
