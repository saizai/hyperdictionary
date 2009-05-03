class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :title, :default => nil
      t.text :body, :default => nil, :null => false
      t.references :commentable, :polymorphic => true, :default => nil, :null => false
      t.references :user, :default => nil # No user = anonymous (or system?) comment
      t.references :comment_type, :default => nil, :null => false
      
      t.userstamps true
      t.timestamps
    end
    
    add_index :comments, [:user_id, :comment_type_id]
    add_index :comments, [:commentable_type, :commentable_id] # allows lookup by type or type + id; id alone is useless anyway
    add_index :comments, :comment_type_id
  end

  def self.down
    drop_table :comments
  end
end
