class AddFieldsToFriendships < ActiveRecord::Migration
  def self.up
    change_table :friendships do |t|
      t.datetime  :activated_at, :denied_at, :suspended_at, :confirmation_requested_at, :default => nil
      t.boolean :friendships, :multi, :default => false
    end
    rename_table :friendships, :relationships
  end
  
  def self.down
    change_table :relationships do |t|
      t.remove :activated_at, :denied_at, :suspended_at, :confirmation_requested_at, :multi
    end
    rename_table :relationships, :friendships
  end
end
