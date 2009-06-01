require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRolesWithOpenId
  
  has_many :comments, :foreign_key => 'creator_id'
  has_one :profile, :autosave => true, :dependent => :destroy
  has_many :assets, :foreign_key => 'creator_id'
  has_many :identities, :autosave => true, :dependent => :destroy
  has_many :sessions, :foreign_key => 'updater_id', :autosave => true
  has_many :multi_sessions, :foreign_key => 'updater_id', :conditions => 'sessions.updater_id != sessions.creator_id', :class_name => 'Session'
  has_many :multi_users, :through => :multi_sessions, :source =>  'creator', :class_name => 'User'
  
  acts_as_authorized_user
  acts_as_preferenced
  acts_as_tagger
  has_gravatar :secure => true, :filetype => :png, :rating => 'PG', :default => 'identicon'
  model_stamper
  
  acts_as_authorizable
  acts_as_paranoid
  acts_as_versioned :version_column => 'lock_version'
  has_friendly_id :login
  stampable
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100
  
  validates_presence_of     :email
  validates_uniqueness_of   :email
  validates_email_veracity_of :email # Actually checks if the server exists, the format is correct, etc
#  validates_length_of       :email,    :within => 6..100 #r@a.wk
#  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  
  named_scope :active, :conditions => ['activated_at IS NOT NULL AND state = "active"']
  default_scope :order => 'login'
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation
  
  def before_save
    # not before_create; this catches the case of a deleted profile
    unless self.profile
      self.build_profile :profile_type_id => ProfileType.find_or_create_by_name('person'), :url => self.identities.first.try(:url), :name => self.login, 
        :body => "Hi, my name is #{self.name}; I'm new here. Say hello!"
    end
  end
  
  def after_create
    # Profile wasn't able to set this itself, 'cause user didn't yet exist (ish)
    # TODO: could probably be made to work automatically w/ profile.after_create somehow...
    self.has_role 'owner', profile
    self.has_role 'subscriber', profile
  end
  
  def last_active
    sessions.last.updated_at
  end
  
  def ips
    sessions.find(:all, :select => 'DISTINCT ip').map(&:ip)
  end
  
  # Returns an array of User objects that have overlapped sessions w/ this user
  # WARNING: This is not a cheap query. Don't run it often.
  # TODO: make this a has_many association
  def multis
    return [] if self.new_record?
# NOTE: as is this completely ignores scoping (e.g. paranoia). That's bad. How can this be rewritten to play nice?
#    User.find_by_sql "SELECT DISTINCT users.* FROM users \
#                      INNER JOIN sessions \
#                        ON (sessions.updater_id = #{self.id} XOR sessions.creator_id = #{self.id}) AND \
#                           (sessions.updater_id = users.id XOR sessions.creator_id = users.id) \
#                      WHERE users.id !=  #{self.id}"
    # It's roughly equal to this; which is really more efficient?
    User.find(:all, :conditions => ['id in (?)', sessions.find(:all, :conditions => 'creator_id != updater_id', 
      :select => 'DISTINCT creator_id, updater_id').map{|x| [x.creator_id, x.updater_id]}.flatten.uniq - [self.id]])
  end
  
  # for use with RPX Now gem
  def self.find_or_initialize_with_rpx token
    identity = Identity.find_or_initialize_with_rpx token
    return nil unless identity
    user = identity.user
    if user.nil?
      user = User.new
      user.identities << identity
      user.name = identity.name
      user.login = identity.login
      user.email = identity.email
      # TODO: grab photo
    else
      identity.save if identity.changed?
    end
    
    return user
  end
  
  def email_verified_by_open_id?
    # Must use select here, not find, so it's compatible w/ new records
    identities.select{|id| id.email_verified}.map(&:email).include? email
  end
  
  def add_identity_with_rpx token
    data = {}
    RPXNow.user_data(token, :extended => true) { |raw| data = raw }
    profile = data['profile']
    
    return nil if data.blank? or profile["identifier"].blank?
    
#    if Rails.env.production? or Rails.env.development?
      RPXNow.map profile["identifier"].sub(/\/$/, ''), self.id
#    end
  end
  
  def avatar_asset size = :thumb
    # the self ensures we scope to this user's files
    self.assets.find :first, :conditions => ["thumbnail = '#{size}' and filename LIKE ?", self.login + "_#{size}.%"]
  end
  
  def identities_glob
    self.identities.to_yaml
  end
  
  # TODO: somehow handle unpacking it again after a revert
  def identities_glob= glob
    logger.info "Tried to revert #{glob}"
  end

  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def login=(value)
    write_attribute :login, (!value.blank? ? value.downcase : nil)
  end
  
  def email=(value)
    write_attribute :email, (!value.blank? ? value.downcase : nil)
  end
  
  # Not the same as active? - e.g. someone could be suspended, but still have activated their email
  # Or someone could be active, change their email, and not have activated it yet
  def activated?
    !self.activated_at.blank?
  end
    
  protected
    # Triggers validation on password & confirmation
    def password_required?
      identities.empty? and (crypted_password.blank? or !password.blank?)
    end
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end
end
