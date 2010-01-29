# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  acts_as_authorizable
  stampable
  has_many :roles_users, :dependent => :delete_all
  has_many :users, :through => :roles_users
  belongs_to :authorizable, :polymorphic => true
#  acts_as_paranoid
  
  named_scope :named, lambda{|name| {:conditions => {:name => name}}}
  
  def to_s
    "#{self.name} #{self.authorizable_type} #{self.authorizable_id}".strip
  end
  
  def before_save
    name.downcase!
  end
end
