class Profile < ActiveRecord::Base
  acts_as_paranoid
  acts_as_versioned :version_column => 'lock_version'
  
  belongs_to :user # This is for *identity* only. Use roles for everything else.
  belongs_to :profile_type
  
  # body # run through sanitization filter!
  # url # validate url-ness? existence on the net?
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_associated :user
  
  attr_accessible :name, :body, :url, :profile_type_id # User must be set explicitly
  
end
