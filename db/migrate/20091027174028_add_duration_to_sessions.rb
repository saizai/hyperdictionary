class AddDurationToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :duration, :integer, :default => 0, :null => false # in seconds
    add_column :users, :time_in_app, :integer, :default => 0, :null => false # in seconds
    add_column :user_versions, :time_in_app, :integer, :default => 0, :null => false # in seconds
  end
  
  def self.down
    remove_column :sessions, :duration
    remove_column :users, :time_in_app
    remove_column :user_versions, :time_in_app
  end
end
