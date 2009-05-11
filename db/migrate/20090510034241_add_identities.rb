class AddIdentities < ActiveRecord::Migration
  def self.up
    create_table :identities do |t|
      t.references :user, :default => nil, :null => false
      t.string :url, :default => nil, :null => false
      t.text :data_blob, :default => nil
      t.string :name, :login, :email, :gender, :country, :photo, :default => nil
      t.date :birth_date, :default => nil
      t.boolean :email_verified, :default => false, :null => false
      
      t.timestamps
      t.datetime :deleted_at
      t.userstamps true
    end
    add_index :identities, :user_id # Not the same as creator; eg an admin might create an identity for a user
    add_index :identities, :url
    
    add_column :user_versions, :identities_glob, :text
    
    User::Version.delete_all
    
    User.find_each :conditions => 'identity_url IS NOT NULL' do |user|
      user.identities.build :url => user.identity_url
      user.save
    end
    
    remove_column :users, :identity_url
    remove_column :user_versions, :identity_url
  end
  
  def self.down
    add_column :users, :identity_url, :string
    add_column :user_versions, :identity_url, :string
    
    User::Version.delete_all
    
    User.find_each do |user|
      user.identity_url = user.identities.first.url
      user.save
    end
    
    drop_table :identities
    remove_column:user_versions, :identities_glob
  end
end
