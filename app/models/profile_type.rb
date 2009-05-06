class ProfileType < ActiveRecord::Base
  acts_as_paranoid
  has_friendly_id :name
  
  has_many :profiles
  
  default_scope :order => 'name'
  
  acts_as_dropdown :text => "name"  
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
