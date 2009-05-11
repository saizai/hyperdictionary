class MakeCommentsThreaded < ActiveRecord::Migration
  def self.up
    remove_column :comments, :user_id # This is redundant w/ creator_id anyway
    
    [:comments, :comment_versions].each do |t|
      [:parent_id, :lft, :rgt].each do |col|
        add_column t, col, :integer
      end
      add_index t, [:parent_id, :lft]
      add_index t, [:parent_id, :rgt]
    end
  end

  def self.down
    add_column :comments, :user_id
    
    [:comments, :comment_versions].each do |t|
      remove_index t, [:parent_id, :lft]
      remove_index t, [:parent_id, :rgt]
      [:parent_id, :lft, :rgt].each do |col|
        remove_column t, col, :integer
      end
    end
  end
end
