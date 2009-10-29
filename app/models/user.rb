require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRolesWithOpenId
  
  has_many :comments, :foreign_key => 'creator_id', :dependent => :destroy
  has_one :page, :autosave => true, :dependent => :destroy
  
  # This is suboptimal. See http://stackoverflow.com/questions/958676/change-a-finder-method-w-parameters-to-an-association
  has_many :assets, :foreign_key => 'creator_id', :dependent => :destroy do
    def avatar size = :thumb
      find :first, :conditions => ["thumbnail = ? and filename LIKE ?", size.to_s, proxy_owner.login + "_#{size}.%"]
    end
  end
  
  has_many :badgings, :dependent => :destroy do
    def grant! badgeset_id, level, badgeable = nil
      b = self.with_badge_set(badgeset_id).first || 
         Badging.new(
            :badge_set_id => badgeset_id,
            :badge => Badge.by_ids(badgeset_id, level), 
            :badgeable => badgeable,
            :user => proxy_owner
         )
      b.level_up(level) unless b.new_record?
      b.save
    end
    def ungrant! badgeset_id, badgeable = nil
      Badging.destroy_all({:user_id => proxy_owner.id, :badge_set_id => badgeset_id,
        :badgeable_id => badgeable.try(:id), :badgeable_type => badgeable.try(:class)})
    end
  end
  has_many :badges, :through => :badgings, :uniq => true
  
  has_many :contacts, :autosave => true, :dependent => :destroy
  has_many :public_contacts, :class_name => "Contact", :conditions => {:state => 'active', :public => true}
  
  has_many :identities, :autosave => true, :dependent => :destroy
  
  has_many :sessions, :foreign_key => 'updater_id', :autosave => true
  has_many :multi_sessions, :foreign_key => 'updater_id', :conditions => 'sessions.updater_id != sessions.creator_id', :class_name => 'Session'
  has_many :multi_session_users, :through => :multi_sessions, :source =>  'creator', :class_name => 'User'
    
  has_many :relationships, :foreign_key => 'from_user_id', :dependent => :destroy
  has_many :incoming_relationships, :foreign_key => 'to_user_id', :dependent => :destroy, :class_name => 'Relationship'
  has_many :fans_of, :through => :relationships, :source => 'to_user', :order => "login", :conditions => "relationships.state IN ('pending', 'denied')" # denied is still a one-way friendship
  has_many :fans, :through => :incoming_relationships, :source => 'from_user', :order => "login", :conditions => "relationships.state IN ('pending', 'denied')" # denied is still a one-way friendship
  has_many :friends, :through => :relationships, :source => 'to_user', :order => "login", :conditions => "relationships.state = 'active'"
  has_many :friends_and_fans_of, :through => :relationships, :source => 'to_user', :order => "login", :conditions => "relationships.state IN ('pending', 'denied', 'active')"
  
  has_many :multis, :through => :relationships, :source => 'to_user', :conditions => "relationships.multi = 1"
  
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
  validates_exclusion_of    :login,    :in => %w( anonymous anonuser admin )
  
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100
  
  named_scope :active, :conditions => ['activated_at IS NOT NULL AND state = "active"']
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation
  attr_accessor :email # pseudo-attribute that's used to make contacts
  
  def before_validation
    login = login.downcase.trim if login
    login = nil if login.blank?
    email = email.downcase.trim if email
    email = nil if email.blank?
  end
  
  def before_save
    # not before_create; this catches the case of a deleted page
    unless self.page
      self.build_page :page_type_id => PageType.find_or_create_by_name('person'), :url => self.identities.first.try(:url), :name => self.login, 
        :body => "Hi, my name is #{self.name}; I'm new here. Say hello!", :namespace => 'User'
    end
    self.email ||= self.contacts.emails.active.first
  end
  
  def after_create
    # Page wasn't able to set this itself, 'cause user didn't yet exist (ish)
    # TODO: could probably be made to work automatically w/ page.after_create somehow...
    self.has_role 'owner', page
    self.has_role 'subscriber', page
    badgings.grant! 1, 3 # Grant alpha user status
  end
  
  def last_active
    sessions.last.updated_at
  end
  
  def ips
    sessions.find(:all, :select => 'DISTINCT ip').map(&:ip) - [nil]
  end
  
  def ips_with_names
    ips.map{|x| [x, Socket.getaddrinfo(x,  0, Socket::AF_UNSPEC, Socket::SOCK_STREAM, nil, Socket::AI_CANONNAME)[0][2]] }
  end
  
  def self.users_on_ip ips
    user_ids = Session.find(:all, :conditions => ["sessions.ip IN (?)", ips],
                                  :select => 'DISTINCT updater_id, creator_id').inject([]){
                                    |memo, sess| memo << sess.updater_id; memo << sess.creator_id }.uniq - [nil]
    User.find(user_ids)
  end
  
  # TODO: make this a has_many
  def users_on_same_ip
    User.users_on_ip(self.ips) - [self]
  end
  
  def total_time_in_app
    (sessions.last.try(:duration) || 0) + time_in_app
  end
  
  def update_time_in_app!
    old_time_in_app = time_in_app
    self.update_attribute :time_in_app, self.time_in_app + self.sessions.last(:offset => 1).duration rescue return
    case time_in_app
      when 0..20.hours
        # do nothing
      when 20.hours...60.hours
        badgings.grant 1, 0 if old_time_in_app < 20.hours
      when 60.hours..180.hours
        badgings.grant 1, 1 if old_time_in_app < 60.hours
      when 180.hours..540.hours
        badgings.grant 1, 2 if old_time_in_app < 180.hours
      else
        badgings.grant 1, 3 if old_time_in_app < 540.hours
    end
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
  
  def add_identity_with_rpx token
    data = {}
    RPXNow.user_data(token, :extended => true) { |raw| data = raw }
    profile = data['profile']
    
    return nil if data.blank? or profile["identifier"].blank?
    
#    if Rails.env.production? or Rails.env.development?
      RPXNow.map profile["identifier"].sub(/\/$/, ''), self.id
#    end
  end
  
  def identities_glob
    self.identities.to_yaml
  end
  
  # TODO: somehow handle unpacking it again after a revert
  def identities_glob= glob
    raise "Tried to revert #{glob}"
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
