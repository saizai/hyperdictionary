class Profile < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  acts_as_versioned :version_column => 'lock_version', :extend => Ddb::Userstamp::Stampable::ClassMethods, :versioned_globs => :translations_glob
  has_friendly_id :name #, :use_slug => true
  stampable
  translates :body 
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id' # This is for *identity* only. Use proper roles for everything else.
  belongs_to :profile_type
  has_many :comments, :as => :commentable, :dependent => :destroy
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
  
  # Standard roles that moderators can set. These are mutually exclusive.
  ROLES = %w(reader commenter tagger editor member moderator owner)
  ROLE_VERBS = %w(read commented tagged edited member moderated owned)
  
  EXTRA_ROLES = %w(subscriber)
  
  def after_create
    creator.has_role 'owner', self if creator
    AnonUser.has_role 'commenter', self
  end
  
  def after_save
    (self.has_subscribers - [updater]).each {|subscriber| ProfileMailer.deliver_update self, subscriber }
  end
  
  # This is used by versioning; we don't want to version the translations table per se, just serialize it like this
  # The glob is only present on the db table, not the real one.
  def translations_glob
    self.globalize_translations.to_yaml
  end
  
  # TODO: somehow handle unpacking it again after a revert
  def translations_glob= glob
    logger.info "Tried to revert #{glob}"
  end
  
  
  # Permissions are hierarchical, not piecemeal, so here are some convenience accessors
  ROLE_VERBS.each_with_index do |verb, i| 
    # Whee metaprogramming
    define_method "#{verb}_by?".to_sym do |user|
      user ||= AnonUser
      user.has_role?('site_admin') or
      # & = set intersection; [i..-1] = 'this role or any higher one'
      !(user.roles_for(self).map(&:name) & ROLES[i..-1]).empty? or
      !(AnonUser.roles_for(self).map(&:name) & ROLES[i..-1]).empty? # Every user has at least the permissions of the anon user
    end
  end
  
end
