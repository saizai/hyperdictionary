class Topic < ActiveRecord::Base
  has_many :replies, :dependent => :destroy, :order => 'replies.created_at DESC'
  belongs_to :project

  scope :mentions_activerecord, :conditions => ['topics.title LIKE ?', '%ActiveRecord%']
  
  scope :with_replies_starting_with, lambda { |text|
    { :conditions => "replies.content LIKE '#{text}%' ", :include  => :replies }
  }
end
