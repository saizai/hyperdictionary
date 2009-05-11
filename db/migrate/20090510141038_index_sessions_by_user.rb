class IndexSessionsByUser < ActiveRecord::Migration
  def self.up
    add_index :sessions, :updater_id
    add_index :sessions, :creator_id
  end

  def self.down
    remove_index :sessions, :updater_id
    remove_index :sessions, :creator_id
  end
end
