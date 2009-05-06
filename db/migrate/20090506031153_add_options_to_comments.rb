class AddOptionsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :private, :boolean
    add_column :comments, :moderated, :boolean
    add_column :comment_versions, :private, :boolean
    add_column :comment_versions, :moderated, :boolean
  end

  def self.down
    remove_column :comments, :private
    remove_column :comments, :moderated
    remove_column :comment_versions, :private
    remove_column :comment_versions, :moderated
  end
end
