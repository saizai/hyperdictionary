class Badging < ActiveRecord::Base
  belongs_to :user
  belongs_to :badge, :counter_cache => true
  belongs_to :badge_set
  belongs_to :badgeable, :polymorphic => true

  validates_uniqueness_of :badge_set_id, :scope => [:user_id, :badgeable_id]
  validates_presence_of :badge_set_id, :badge_id, :user_id  

  named_scope :with_badge_set, lambda {|badge_set|
    {:conditions => {:badge_set_id => badge_set} }
  }
  
  def level_up level = nil
    self.badge = level ? badge_set.badges.with_level(level).first : badge.next_level
  end
  
  def level_up! level = nil
    level_up level
    save
  end
end
