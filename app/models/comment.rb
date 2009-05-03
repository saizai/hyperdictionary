class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  belongs_to :comment_type
  
  acts_as_authorizable
  acts_as_paranoid # never actually delete stuff
  acts_as_versioned :version_column => 'lock_version' # and save all copies too
  
  validates_presence_of :body
  # title optional
  validates_associated :user # but not its presence
  validates_associated :commentable
  validates_presence_of :commentable
  validates_associated :comment_type
  validates_presence_of :comment_type
  
  
end
