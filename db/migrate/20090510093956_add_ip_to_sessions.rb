class AddIpToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :ip, :string, :default => nil
  end

  def self.down
    remove_column :sessions, :ip
  end
end
