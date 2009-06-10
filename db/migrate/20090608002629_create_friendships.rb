class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.references  :from_user, :to_user, :from_identity, :to_identity
      t.string      :state
      
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
