class CommentType < ActiveRecord::Base
  has_many :comments
  
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_paranoid
  acts_as_versioned :version_column => 'lock_version'  
end
