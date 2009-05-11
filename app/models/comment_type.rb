class CommentType < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  acts_as_versioned :version_column => 'lock_version'  
  acts_as_taggable
  stampable
  has_friendly_id :name
  
  has_many :comments
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
