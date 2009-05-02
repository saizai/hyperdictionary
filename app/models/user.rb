require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRolesWithOpenId
  
  has_many :comments
  has_one :profile
  
  acts_as_authorized_user
  acts_as_authorizable
  
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
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation
  attr_accessor :verified_email # temporary attribute
  
  def before_create
    self.build_profile :profile_type_id => ProfileType.find_or_create_by_name('person'), :url => self.identity_url, :name => self.name, :body => "I'm a new user. Say hello!"
  end
  
  def before_validate
    self.identity_url.sub!(/\/$/, '') # remove trailing slashes
  end
  
  # for use with RPX Now gem
  def self.find_or_initialize_with_rpx(token)
    data = {}
    RPXNow.user_data(token, :extended => true) { |raw| data = raw }
    profile = data['profile']
    
    return nil if data.blank? or profile["identifier"].blank?

    u = self.find(profile['primaryKey'].to_i) if profile['primaryKey'] # Get it from the mapping if we have that
    u ||= self.find_by_identity_url(profile["identifier"].sub(/\/$/, '')) # Or not...
    
    if u.nil?
      u = self.new
      u.identity_url = profile["identifier"] # Remove trailing slashes
      u.name = profile['displayName'] || "#{profile['name']['givenName']} #{profile['name']['familyName']}"
      u.name = nil if u.name.blank?
      u.login = profile['preferredUsername']
      u.email = profile['verifiedEmail'] || profile['email']
      u.verified_email = profile['verifiedEmail'] # bypasses activation
  #    u.gender = profile['gender']
  #    u.birth_date = profile['birthday']
  #    u.first_name = profile['givenName'] || profile['displayName']
  #    u.last_name = profile['familyName']
  #    u.country = profile['address']['country'] unless profile['address'].nil?
  #   profile['photo'] # url
    end

    return u
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
    
  protected
    def password_required?
      identity_url.blank? and (crypted_password.blank? or !password.blank?)
    end
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end
end
