class Asset < ActiveRecord::Base
  has_attachment  :storage => :file_system, 
                  :path_prefix => 'public/files/assets',
                  :max_size => 1.megabytes,
                  :thumbnails => { :thumb => '80x80>', :tiny => '40x40>', :icon => '16x16>' }

  validates_as_attachment
  belongs_to :attachable, :polymorphic => true
  
  named_scope :original, :conditions => {:parent_id => nil }
  
end
