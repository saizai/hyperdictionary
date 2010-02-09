class Forum < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Forum'
  belongs_to :last_discussion, :class_name => 'Discussion'
  belongs_to :last_message, :class_name => 'Message'
  belongs_to :context, :polymorphic => true
  has_many :contextualizations, :as => :context
  has_many :discussions, :through => :contextualizations
  
  acts_as_authorizable
  acts_as_taggable
  stampable
  
  validates_presence_of :name, :discussions_count, :messages_count # not description
  # has_discussions
end
