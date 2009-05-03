class CreateCommentTypes < ActiveRecord::Migration
  def self.up
    create_table :comment_types do |t|
      t.string :name
      
      t.userstamps true # true = include deleted_by, and we act as paranoid
      t.timestamps
    end
    
    add_index :comment_types, :name, :unique => true
  end

  def self.down
    drop_table :comment_types
  end
end
