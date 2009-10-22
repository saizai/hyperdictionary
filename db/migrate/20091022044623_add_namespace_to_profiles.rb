class AddNamespaceToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :namespace, :string, :default => '', :null => false
    add_column :profile_versions, :namespace, :string, :default => '', :null => false
    
    User.find_each {|user|
      page = user.page
      page.namespace = 'User'
      page.name = user.login
      page.save
    }
  end
  
  def self.down
    remove_column :profiles, :namespace
    remove_column :profile_versions, :namespace
  end
end
