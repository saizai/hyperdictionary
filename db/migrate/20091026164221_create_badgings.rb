class CreateBadgings < ActiveRecord::Migration
  def self.up
    create_table :badgings do |t|
      t.references :user, :badge_set, :badge
      t.references :badgeable, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :badgings
  end
end
