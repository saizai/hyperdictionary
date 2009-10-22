class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.references  :from_user, :to_user, :null => false, :default => nil
      t.references  :from_identity, :to_identity, :default => nil
      t.string      :state, :default => 'passive', :null => false
            
      t.userstamps 
      t.timestamps
    end
    
    add_index :friendships, :from_user_id
    add_index :friendships, :to_user_id
  end

  def self.down
    drop_table :friendships
  end
end
