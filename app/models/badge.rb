class Badge < ActiveRecord::Base
  has_many :badgings
  belongs_to :badge_set
  has_friendly_id :name
  
  validates_uniqueness_of :badge_set_id, :scope => :level
  
  default_scope :order => 'badges.badge_set_id, badges.level DESC'
  named_scope :with_level, lambda {|level| { :conditions => {:level => level}, :limit => 1 } }
  named_scope :public, :conditions => {:public => true}
  
  acts_as_dropdown :order => "badges.badge_set_id, badges.level DESC"
  
  def self.by_ids badge_set_id, level
    first :conditions => {:badge_set_id => badge_set_id, :level => level} 
  end
  
  def next_level
    Badge.first :conditions => {:badge_set_id => badge_set_id, :level => level + 1}
  end
  
  def level_name
    case level
    when 1
        'bronze'
    when 2
      'silver'
    when 3
      'gold'
    when 4
      'emerald'
    end
  end
end
