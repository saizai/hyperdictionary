class AddIdsToIdentities < ActiveRecord::Migration
  def self.up
    raise "don't run me yet"
    
    add_column :identities, :vendor_id, :bigint, :default => nil
    add_column :identities, :session_key, :string, :default => nil
    add_column :identities, :session_key_expires, :int, :default => nil
    add_column :identities, :oauth_token, :string, :default => nil
    add_column :identities, :oauth_secret, :string, :default => nil
    add_column :identities, :public, :boolean, :default => false, :null => false
  end

  def self.down
  end
end
