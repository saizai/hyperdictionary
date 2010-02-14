class PageType < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  stampable
  has_friendly_id :name
  
  has_many :pages
  
  default_scope order('name')
  
  acts_as_dropdown :text => "name"  
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
