class AddFieldsToIdentities < ActiveRecord::Migration
  def self.up
    add_column :identities, :provider, :string
    add_column :identities, :profile_url, :string
    
    Identity.find_each{|identity|
      next unless identity.data['profile']
      identity.profile_url = identity.data['profile']['url']
      identity.provider = identity.data['profile']['providerName']
      identity.save
    }
  end
  
  def self.down
    remove_column :identities, :provider
    remove_column :identities, :profile_url
  end
end
