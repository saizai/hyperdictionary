class Badging < ActiveRecord::Base
  belongs_to :user
  belongs_to :badge, :counter_cache => true
  belongs_to :badge_set
  belongs_to :badgeable, :polymorphic => true
  
  validates :badge_set_id, :uniqueness => {:scope => [:user_id, :badgeable_id]}, :presence => true
  validates :badge_id, :user_id, :presence => true
  
  scope :with_badge_set, lambda {|badge_set| where(:badge_set_id => badge_set) }
  
  def before_destroy
    User.decrement_counter("badge#{badge.level}_count", user_id)
  end
  
  def before_save
    if changed.include? 'badge_id'
      counters = {"badge#{Badge.find(changes['badge_id'][1]).level}_count" => 1}
      counters["badge#{Badge.find(changes['badge_id'][0]).level}_count"] = -1  unless new_record?
      User.update_counters  user_id, counters
    end
  end
  
  def level_up level = nil
    self.badge = level ? badge_set.badges.with_level(level).first : badge.next_level
  end
  
  def level_up! level = nil
    level_up level
    save
  end
end
