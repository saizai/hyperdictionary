class Comment < ActiveRecord::Base
  belongs_to :creator
  belongs_to :commentable, :polymorphic => true
  belongs_to :comment_type
  # Also parent, but acts_as_nested_set handles that
  
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  stampable
  acts_as_versioned :version_column => 'lock_version' # and save all copies too
  acts_as_nested_set :scope => [:commentable_type, :commentable_id]
  
  validates_presence_of :body
  # title optional
  validates_associated :creator # but not its presence
  validates_associated :updater
  validates_associated :deleter
  validates_associated :commentable
  validates_presence_of :commentable
  validates_associated :comment_type
  validates_presence_of :comment_type
  
  def visible_to? user
    user ||= AnonUser
    commentable.read_by?(user) and
      (!moderated or commentable.moderated_by? user) and
      (!private or commentable.member_by? user or (creator_id and user.id == creator_id))
  end
  
  def after_create
    # The fancy method_missing 'has_subscribers' fails on polymorphic associations for some reason
    (commentable.has_roles('subscriber') - [creator]).each {|subscriber| CommentMailer.deliver_new self, subscriber }
  end
    
  def children comments
    if comments
      comments.select{|x| x.parent_id == self.id}
    else
      super()
    end || []
  end
  
end
