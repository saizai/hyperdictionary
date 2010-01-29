class CreateContextualizations < ActiveRecord::Migration
  def self.up
    create_table :contextualizations do |t|
      t.references :discussion
      t.references :context, :polymorphic => true
      
      t.timestamps
      t.userstamps
    end
    
    add_index :contextualizations, [:discussion_id, :context_type, :context_id], :unique => true, :name => 'by_all'
    add_index :contextualizations, [:context_type, :context_id]
    
    add_column :discussions, :contexts_count, :integer, :default => 0, :null => false
    add_column :discussions, :participations_count, :integer, :default => 0, :null => false
    add_column :discussion_versions, :contexts_count, :integer, :default => 0, :null => false
    add_column :discussion_versions, :participations_count, :integer, :default => 0, :null => false
    
    Discussion.find_each do |discussion|
      # import would be better if we actually had a lot, but we don't, so whatever
      # drop the User contexts, because those are now supplanted by participations
      Contextualization.create :discussion_id => discussion.id, :context_id => discussion.context_id, :context_type => discussion.context_type unless discussion.context_type == 'User'
    end
    
    remove_column :discussions, :context_id
    remove_column :discussions, :context_type
    remove_column :discussion_versions, :context_id
    remove_column :discussion_versions, :context_type
  end
  
  def self.down
    add_column :discussions, :context_id, :integer
    add_column :discussions, :context_type, :string
    remove_column :discussions, :contexts_count
    remove_column :discussions, :participations_count
    
    add_column :discussion_versions, :context_id, :integer
    add_column :discussion_versions, :context_type, :string
    remove_column :discussion_versions, :contexts_count
    remove_column :discussion_versions, :participations_count
    
    # lossy and inefficient. Oh well.
    Contextualization.find_each do |context|
      context.discussion.update_attribute :context_id, context.context_id
      context.discussion.update_attribute :context_type, context.context_type
    end
    
    drop_table :contexts
  end
end
