class AddLastMessageIdToDiscussions < ActiveRecord::Migration
  def self.up
    add_column :discussions, :last_message_id, :integer, :default => nil, :null => false
    add_column :discussion_versions, :last_message_id, :integer, :default => nil, :null => false
    
    Discussion.find_each {|discussion| discussion.update_attribute :last_message_id, discussion.messages.last.id }
  end

  def self.down
    remove_column :discussions, :last_message_id
    remove_column :discussion_versions, :last_message_id
  end
end
