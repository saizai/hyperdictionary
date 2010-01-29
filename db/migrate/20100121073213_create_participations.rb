class CreateParticipations < ActiveRecord::Migration
  def self.up
    create_table :participations do |t|
      t.references :discussion, :user
      t.datetime :last_read, :default => nil
      
      t.timestamps
      t.userstamps
    end
    
    add_index :participations, [:discussion_id, :user_id], :unique => true
    add_index :participations, :user_id
  end

  def self.down
    drop_table :participations
  end
end
