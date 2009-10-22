class Asset < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  stampable
  
  has_attachment  :storage => :file_system, 
                  :path_prefix => 'public/files/assets',
                  :max_size => 1.megabytes,
                  :thumbnails => { :thumb => '80x80>', :tiny => '40x40>', :icon => '16x16>' }

  validates_as_attachment
  belongs_to :attachable, :polymorphic => true
  
  validates_presence_of :creator_id
  validates_presence_of :updater_id
  
  named_scope :original, :conditions => {:parent_id => nil }
  named_scope :size, lambda { |size| { :conditions => [ "thumbnail = ?", size.to_s ] }  } # and filename LIKE "_#{size}.%"
  
  def before_validation
    self.updater_id ||= self.creator_id
    self.creator_id ||= self.parent.creator_id
    self.updater_id ||= self.parent.updater_id
  end
  
  def self.width size
    attachment_options[:thumbnails][size][/\d*/]
  end
  
end
