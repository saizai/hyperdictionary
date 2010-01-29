class AddInboxFlagToParticipations < ActiveRecord::Migration
  def self.up
    add_column :participations, :inbox, :boolean, :default => false, :null => false
  end
  
  def self.down
    remove_column :participations, :inbox
  end
end
