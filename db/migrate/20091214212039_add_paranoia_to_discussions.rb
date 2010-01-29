class AddParanoiaToDiscussions < ActiveRecord::Migration
  def self.up
    add_column :discussions, :lock_version, :integer, :default => 0, :nil => false
    add_column :discussions, :deleted_at, :datetime
    Discussion.create_versioned_table
  end

  def self.down
    drop_table :discussion_versions
    remove_column :discussions, :deleted_at
    remove_column :discussions, :lock_version
  end
end
