class Profile < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  acts_as_versioned :version_column => 'lock_version', :extend => Ddb::Userstamp::Stampable::ClassMethods, :versioned_globs => :translations_glob
  has_friendly_id :name, :use_slug => true
  stampable
  translates :body 
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id' # This is for *identity* only. Use proper roles for everything else.
  belongs_to :profile_type
  has_many :comments, :as => :commentable
  has_many :assets, :as => :attachable
  
  # body # run through sanitization filter!
  # url # validate url-ness? existence on the net?
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :url, :allow_nil => true, :case_sensitive => false
  validates_presence_of :profile_type
  validates_associated :profile_type
  validates_associated :owner
  
  attr_accessible :name, :body, :url, :profile_type_id, :tag_list # User must be set explicitly
  
  # This is used by versioning; we don't want to version the translations table per se, just serialize it like this
  # The glob is only present on the db table, not the real one.
  def translations_glob
    self.globalize_translations.to_yaml
  end
  
  # TODO: somehow handle unpacking it again after a revert
  def translations_glob= glob
    logger.info "Tried to revert #{glob}"
  end
  
end
