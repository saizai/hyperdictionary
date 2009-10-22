class Identity < ActiveRecord::Base
  acts_as_authorizable
#  acts_as_paranoid
  stampable
  
  validates_associated :user
#  validates_presence_of :user # Causes error when creating a new user 
  validates_presence_of :url
  validates_uniqueness_of :url
  
  belongs_to :user
  
  def before_validation
    url.sub! /\/$/, ''
    url.sub! '//www.', '//'
    name = nil if name.blank?
  end
  
  def after_save
    if self.email
      contact = user.contacts.find(:first, :conditions => {:contact_type_id => ContactType.find_by_name('email').id, :data => self.email}) ||
        user.contacts.build(:contact_type_id => ContactType.find_by_name('email').id, :data => self.email, :preverified => self.email_verified)
      contact.update_attribute :preverified, self.email_verified if !contact.preverified and self.email_verified
      contact.register! unless contact.active?
    end
  end
  
  # This is read only for now
  def data
    yaml = ActiveSupport::Gzip.decompress(Base64.decode64(data_blob)) rescue ActiveSupport::Gzip.decompress(data_blob) rescue data_blob # handles both compressed and not
    YAML.load yaml
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
    identity.data_blob = Base64.encode64(ActiveSupport::Gzip.compress(rpx_data.to_yaml))
    
    return identity
  end
  
end
