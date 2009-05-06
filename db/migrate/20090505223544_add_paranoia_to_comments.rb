class AddParanoiaToComments < ActiveRecord::Migration
  def self.up
    [:comments, :comment_versions, :comment_types, :comment_type_versions].each do |table|
      add_column table, :deleted_at, :datetime
    end
  end

  def self.down
    [:comments, :comment_versions, :comment_types, :comment_type_versions].each do |table|
      remove_column table, :comments, :deleted_at
    end
  end
end
