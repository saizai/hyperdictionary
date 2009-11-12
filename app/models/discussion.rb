class Discussion < ActiveRecord::Base
  belongs_to :context, :polymorphic => true
  has_many :messages
  has_many :split_messages, :class_name => "Message", :conditions => "split_discussion_id IS NOT NULL"
  has_many :split_discussions, :through => :split_messages, :source => :split_discussion
  has_many :merged_messages, :class_name => "Message", :foreign_key => :split_discussion_id
  has_many :merged_discussions, :through => :merged_messages, :source => :discussion
  # locked, screened, sticky
  # messages_count, next_message
  # name
  
  
end