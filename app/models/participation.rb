class Participation < ActiveRecord::Base
  belongs_to :discussion, :counter_cache => :participations_count
  belongs_to :user
  
  validates_uniqueness_of :user_id, :scope => :discussion_id, :allow_nil => true
  
  def mark_read! inbox = nil
    update_attribute :last_read, Time.now
    update_attribute :inbox, inbox if inbox
  end
end
