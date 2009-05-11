class Identity < ActiveRecord::Base
  acts_as_authorizable
  acts_as_paranoid
  stampable
  
  belongs_to :user
  
  def before_validate 
    url.sub! /\/$/, ''
    name = nil if name.blank?
  end
  
  def data
    yaml = ActiveSupport::Gzip.decompress(data_blob) rescue data_blob # handles both compressed and not
    YAML.load yaml
  end
    
  def self.find_or_initialize_with_rpx token
    rpx_data = {}
    RPXNow.user_data(token, :extended => true) { |raw| rpx_data = raw }
    profile = rpx_data['profile'] || {}
    return nil if profile["identifier"].blank?
    
    identity = self.find_or_initialize_by_url profile['identifier'].sub(/\/$/, '')
    identity ||= self.new
    identity.data_blob = ActiveSupport::Gzip.compress(rpx_data.to_yaml)
    identity.name = profile['displayName'] || "#{profile['name']['givenName']} #{profile['name']['familyName']}"
    identity.login = profile['preferredUsername']
    identity.email = profile['verifiedEmail'] || profile['email']
    identity.email_verified = !!(profile['verifiedEmail'])
    identity.gender = profile['gender']
    identity.birth_date = profile['birthday']
    identity.country = profile['address']['country'] unless profile['address'].nil?
    identity.photo = profile['photo'] # url
    
    return identity
  end
  
end