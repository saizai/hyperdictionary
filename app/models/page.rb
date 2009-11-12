class Page < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  acts_as_taggable
  acts_as_versioned :version_column => 'lock_version', :extend => Ddb::Userstamp::Stampable::ClassMethods, :versioned_globs => :translations_glob
  has_friendly_id :name, :scope => :namespace #, :use_slug => true # if enabling slugs, run rake friendly_id:redo_slugs MODEL=Page
  stampable
  translates :body 
#  acts_as_cached
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id' # This is for *identity* only. Use proper roles for everything else.
  belongs_to :page_type
  has_many :messages, :as => :context, :dependent => :destroy
  has_many :assets, :as => :attachable
  
  # body # run through sanitization filter!
  # url # validate url-ness? existence on the net?
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :namespace, :case_sensitive => false
  validates_uniqueness_of :url, :allow_nil => true, :case_sensitive => false
  validates_presence_of :page_type
  validates_associated :page_type
  validates_associated :owner
  
  attr_accessible :name, :body, :url, :page_type_id, :tag_list # User must be set explicitly
  
  # Standard roles that moderators can set. These are mutually exclusive.
  ROLES = %w(reader commenter tagger editor member owner moderator)
  ROLE_VERBS = %w(read commented tagged edited member owned moderated)
  
  EXTRA_ROLES = %w(subscriber)
  
  # TODO: Come up with a clever way to handle multiple.
#  def self.find_one name_or_id, options
#    return super name_or_id, options if name_or_id.is_a?(Integer)
#    split_name = name_or_id.split(':')
#    raise "Invalid name" if split_name.size > 2
#    scope = split_name.size == 2 ? split_name[0] : ''
#    name = split_name.size == 2 ? split_name[1] : split_name[0]
#    super name, options.merge(:scope => scope)
#  end
  
  def after_create
    if creator
      creator.has_role 'owner', self
      creator.has_role 'subscriber', self
      Event.event! creator, 'create', self
    end
    AnonUser.has_role 'commenter', self
  end
  
#  after_destroy :expire_cache
  
  def after_save
#    expire_cache
    (self.has_subscribers - [updater]).each {|subscriber| PageMailer.deliver_update self, subscriber }
    Event.event! updater, 'edit', self if updater  
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
    return Page::ROLES[-1] if user.is_site_admin?
    roles = user.roles_for(self, Page::ROLES)
    roles += AnonUser.roles_for(self, Page::ROLES) unless user == AnonUser 
    max_role = roles.map{|role| Page::ROLES.index role.name }.max
    max_role ? Page::ROLES[max_role] : nil
  end
  
  # Permissions are hierarchical, not piecemeal, so here are some convenience accessors
  ROLE_VERBS.each_with_index do |verb, i| 
    # Whee metaprogramming
    define_method "#{verb}_by?".to_sym do |user|
      (Page::ROLES.index(highest_role_by(user)) || 0) >= i
    end
  end
  
  # Necessary to prevent spurious 'namespace is a private method' errors. Ironic.
  def namespace
    self.read_attribute :namespace
  end
end
