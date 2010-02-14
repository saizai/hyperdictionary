class Badge < ActiveRecord::Base
  has_many :badgings
  belongs_to :badge_set
  has_friendly_id :name
  
  validates :badge_set_id, :uniqueness => {:scope => :level}
  
  default_scope order('badges.badge_set_id, badges.level DESC')
  scope :with_level, lambda {|level| where(:level => level).limit(1) }
  scope :public, where(:public => true)
  
  acts_as_dropdown :order => "badges.badge_set_id, badges.level DESC"
  
  def self.by_ids badge_set_id, level
    where(:badge_set_id => badge_set_id, :level => level).first 
  end
  
  def next_level
    Badge.where(:badge_set_id => badge_set_id, :level => level + 1).first
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
