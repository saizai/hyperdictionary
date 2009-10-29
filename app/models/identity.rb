class Identity < ActiveRecord::Base
  acts_as_authorizable
#  acts_as_paranoid
  stampable
  
  has_many :relationships, :foreign_key => 'from_identity_id', :dependent => :destroy
  has_many :incoming_relationships, :foreign_key => 'to_identity_id', :dependent => :destroy, :class_name => 'Relationship'
  
  validates_associated :user
#  validates_presence_of :user # Causes error when creating a new user 
  validates_presence_of :url
  validates_uniqueness_of :url
  
  named_scope :public, :conditions => {:public => true}
  
  attr_accessor :new_friends, :ex_friends
  
  belongs_to :user
  
  def before_validation
    url.sub! /\/$/, ''
    url.sub! '//www.', '//'
    name = nil if name.blank?
  end
  
  def after_save
    # automatically add new friends
    new_friends.each do |friend|
      r = Relationship.find_or_initialize_by_from_identity_id_and_to_identity_id(self.id, friend.id)
      r.from_user_id, r.to_user_id = self.user.id, friend.user.id
      r.confirm! # will automatically touch the reciprocal
    end if new_friends
    # and suspend ex-friends
    ex_friends.each do |friend|
      r = Relationship.find_or_initialize_by_from_identity_id_and_to_identity_id(self.id, friend.id)
      r.from_user_id, r.to_user_id = self.user.id, friend.user.id
      r.suspend!
    end if ex_friends
    ex_friends, new_friends = nil, nil
    
    if self.email # TODO: first check if email is changed
      contact = user.contacts.find(:first, :conditions => {:contact_type_id => ContactType.find_by_name('email').id, :data => self.email}) ||
        user.contacts.build(:contact_type_id => ContactType.find_by_name('email').id, :data => self.email, :preverified => self.email_verified)
      contact.update_attribute :preverified, self.email_verified if !contact.preverified and self.email_verified
      contact.register! unless contact.active?
    end
  end
  
  # This is read only for now
  def data
    yaml = ActiveSupport::Gzip.decompress(Base64.decode64(data_blob)) rescue ActiveSupport::Gzip.decompress(data_blob) rescue data_blob # handles both compressed and not
    YAML.load yaml rescue {} # just in case we really can't get anything, otherwise yaml will barf
  end
  
  def self.find_or_initialize_with_rpx token
    rpx_data = {}
    RPXNow.user_data(token, :extended => true) { |raw| rpx_data = raw }
    profile = rpx_data['profile'] || {}
    return nil if profile["identifier"].blank?
    
    identity = self.find_or_initialize_by_url profile['identifier'].sub(/\/$/, '').sub('//www.', '//')
    identity ||= self.new
    identity.name = profile['displayName'] || profile['name']['formatted'] || "#{profile['name']['givenName']} #{profile['name']['familyName']}".trim
    identity.login = profile['preferredUsername']
    identity.email = profile['verifiedEmail'] || profile['email']
    identity.email_verified = !!(profile['verifiedEmail'])
    identity.gender = profile['gender']
    identity.birth_date = profile['birthday']
    identity.country = profile['address']['country'] unless profile['address'].nil?
    identity.photo = profile['photo'] # url - might well be a generic default one :-/
    identity.profile_url = profile['url']
    identity.provider = profile['providerName']
    case identity.provider
      when 'Facebook'
        identity.vendor_id = rpx_data['accessCredentials']['uid'].to_i
        identity.session_key = rpx_data['accessCredentials']['sessionKey']
        identity.session_key_expires_at = Time.at rpx_data['accessCredentials']['expires'].to_i # sent as unix time (seconds since epoch)
        
        # TODO: figure out a way to only look at the diff
        old_friend_ids = identity.data['friends'].map{|x| x[/\d+/].to_i } rescue []
        friend_ids = rpx_data['friends'].map{|x| x[/\d+/].to_i } rescue []
        identity.new_friends = Identity.find_all_by_vendor_id(friend_ids - old_friend_ids, :conditions => 'provider = "Facebook"', :include => :user)
        identity.ex_friends = Identity.find_all_by_vendor_id(old_friend_ids - friend_ids, :conditions => 'provider = "Facebook"', :include => :user)
    end
    
    identity.data_blob = Base64.encode64(ActiveSupport::Gzip.compress(rpx_data.to_yaml))
    
    return identity
  end
  
end
