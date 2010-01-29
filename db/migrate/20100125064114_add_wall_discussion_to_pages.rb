class AddWallDiscussionToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :wall_discussion_id, :integer, :default => nil
    add_column :page_versions, :wall_discussion_id, :integer, :default => nil
  end
  
  def self.down
    remove_column :pages, :wall_discussion_id
    remove_column :page_versions, :wall_discussion_id
  end
end
