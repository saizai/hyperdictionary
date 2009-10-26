class AddIdsToIdentities < ActiveRecord::Migration
  def self.up
    change_table :identities do |t|
      t.integer :vendor_id, :default => nil, :limit => 8 # 8 bytes = bigint
      t.string :session_key, :oauth_token, :oauth_secret, :default => nil
      t.datetime :session_key_expires_at, :default => nil
      t.boolean :public, :default => true, :null => false
    end
  end
  
  def self.down
    change_table :identities do |t|
      t.remove :vendor_id, :session_key, :oauth_token, :oauth_secret, :session_key_expires_at, :public
    end
  end
end
