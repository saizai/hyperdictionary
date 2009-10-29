class AddNamespaceToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :namespace, :string, :default => '', :null => false
    add_column :profile_versions, :namespace, :string, :default => '', :null => false
    
    User.find_each {|user|
      profile = user.profile
      profile.namespace = 'User'
      profile.name = user.login
      profile.save
    }
  end
  
  def self.down
    remove_column :profiles, :namespace
    remove_column :profile_versions, :namespace
  end
end
