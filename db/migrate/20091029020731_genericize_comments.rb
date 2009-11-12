class GenericizeComments < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.string :name, :default => nil
      t.integer :messages_count, :default => 0, :null => false
      t.integer :next_message, :default => 1, :null => false
      t.references :context, :polymorphic => true, :default => nil, :null => false # e.g. a Page, a Forum (if we have those), or a User
      # note: user pages are a special case, because they can have one discussion with messages across multiple user pages (a la wall-to-wall)
      t.boolean :locked, :default => false, :null => false # prohibit non-moderator posts (not the same as message.moderated, which *screens* it above the normal-user level)
      t.boolean :screened, :default => false, :null => false # force screen flag for all responses (but can be removed by context owner)
      t.boolean :sticky, :default => false, :null => false # floated to the top
      
      t.userstamps
      t.timestamps
    end
    
    add_index :discussions, [:context_type, :context_id, :sticky, :updated_at], :name => "recent_threads_index" # used for thread-bumping 
    
    create_table :message_interfaces do |t|
      t.string :name, :default => nil, :null => false
    end
    
    # maybe more in the future, but for now this is pretty simple... just a fancy enum really
    # the purpose of this is to help filter
    MessageInterface.import [:name], [["wall"], # typically short & chatty, displayed flat by default
                                      ["forum"], # longer, displayed threaded and treed
                                      ["email"], # longest, displayed as individual emails
                                      ["auto"]] # automatic stuff
    
    rename_table :comments, :messages
    rename_table :comment_versions, :message_versions
    Message.delete_all! # could make a migration, but not worth the bother since we have no important data
    Message::Version.delete_all
    drop_table :comment_types
    
    [:messages, :message_versions].each do |table| 
      change_table table do |t|
        t.references :discussion, :default => nil, :null => false
        t.string :index, :default => nil, :null => false # magic. When alpha-sorted, is the order this item comes when displaying the entire tree. Or can easily be pruned to show one level.
        t.references :split_discussion, :default => nil # only used for threadsplits. Lets us easily link to the new one.
        t.remove :title, :lft, :rgt, :comment_type_id # title is now in discussion; lft & rgt supplanted by index
        t.rename :commentable_type, :context_type
        t.rename :commentable_id, :context_id
        # like the discussion level one, but this one is just for this message. when toggled, set everything that descends from this too (thanks to index, that's cheap) 
        t.boolean :locked, :default => false, :null => false
        t.references :message_interface, :default => nil, :null => false
        t.integer :children_count, :default => 0, :null => false
        t.integer :next_child, :default => 1, :null => false
      end
    end
    
    rename_column :message_versions, :comment_id, :message_id
    
    add_index :messages, [:discussion_id, :index], :unique => true # index is only valid within a given discussion
    add_index :messages, :split_discussion_id # quick reverse lookup for a discussion to know its parent
    
    # Used for showing a recent-stuff ticker - e.g. "last 5 posts" in a forum. Really meant for created_at, but this is cheaper.
    # not updated_at 'cause we don't care all that much about edited messages.
    add_index :messages, [:context_type, :context_id, :id] 
  end
  
  def self.down
    drop_table :discussions
    
    [:messages, :message_versions].each do |table| 
      change_table table do |t|
        t.remove :discussion_id, :index, :split_discussion_id, :locked, :message_interface_id, :children_count, :next_child
        t.string :title
        t.integer :lft, :rgt, :comment_type_id
        t.rename :context_type, :commentable_type
        t.rename :context_id, :commentable_id
      end
    end
    
    rename_table :messages, :comments
    rename_table :message_versions, :comment_versions
    
#    create_table :comment_types do |t|
#      t.string :name
#      
#      t.userstamps true # true = include deleted_by, and we act as paranoid
#      t.timestamps
#    end
#    
#    add_index :comment_types, :name, :unique => true
  end
end
