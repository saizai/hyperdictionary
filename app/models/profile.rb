class Profile < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  acts_as_versioned :version_column => 'lock_version', :extend => Ddb::Userstamp::Stampable::ClassMethods, :versioned_globs => :translations_glob
  has_friendly_id :name #, :use_slug => true
  stampable
  translates :body 
  acts_as_cached
  
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
  ROLES = %w(reader commenter tagger editor member owner moderator)
  ROLE_VERBS = %w(read commented tagged edited member owned moderated)
  
  EXTRA_ROLES = %w(subscriber)
  
  def after_create
    if creator
      creator.has_role 'owner', self
      creator.has_role 'subscriber', self
    end
    
    AnonUser.has_role 'commenter', self
  end
  
  after_destroy :expire_cache
  
  def after_save
    expire_cache
    expire_fragment :controller => "profiles", :action => "show", :id => self.id #, :action_suffix => role
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
  
  def highest_role_by user
    user ||= AnonUser
    return Profile::ROLES[-1] if user.is_site_admin?
    roles = user.roles_for(self, Profile::ROLES)
    roles += AnonUser.roles_for(self, Profile::ROLES) unless user == AnonUser 
    max_role = roles.map{|role| Profile::ROLES.index role.name }.max
    max_role ? Profile::ROLES[max_role] : nil
  end
  
  # Permissions are hierarchical, not piecemeal, so here are some convenience accessors
  ROLE_VERBS.each_with_index do |verb, i| 
    # Whee metaprogramming
    define_method "#{verb}_by?".to_sym do |user|
      Profile::ROLES.index(highest_role_by(user)) >= i
    end
  end
end
