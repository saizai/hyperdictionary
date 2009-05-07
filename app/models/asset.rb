class Asset < ActiveRecord::Base
  has_attachment  :storage => :file_system, 
                  :path_prefix => 'public/files/assets',
                  :max_size => 1.megabytes,
                  :thumbnails => { :thumb => '80x80>', :tiny => '40x40>' }

  validates_as_attachment
  belongs_to :attachable, :polymorphic => true
  
  named_scope :original, :conditions => {:parent_id => nil }
  
  # Adds a new temp_path to the array. This should take a string or a Tempfile. This class makes no
  # attempt to remove the files, so Tempfiles should be used. Tempfiles remove themselves when they go out of scope.
  # You can also use string paths for temporary files, such as those used for uploaded files in a web server.
  def temp_path=(value)
    temp_paths.unshift value
    temp_path
  end
end
