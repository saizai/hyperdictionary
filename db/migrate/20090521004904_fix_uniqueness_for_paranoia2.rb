class FixUniquenessForParanoia2 < ActiveRecord::Migration
  def self.up
    remove_index :users, :login
    add_index :users, [:login, :deleted_at], :unique => true
  end

  def self.down
    remove_index :users, [:login, :deleted_at]
    add_index :users, :login, :unique => true
  end
end
