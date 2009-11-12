class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :event_types do |t|
      t.string :name, :default => nil, :null => false
      
      t.timestamps
      t.userstamps
    end
    
    add_index :event_types, :name, :unique => true
    
    create_table :events do |t|
      t.references :event_type, :default => nil, :null => false
      t.datetime :released_at, :default => nil, :null => false # when it's OK to publish this; normally identical to created_at
      
      t.timestamps
      t.userstamps
    end
    
    add_index :events, :event_type_id
    add_index :events, :released_at
    
    # e.g. event_type: edit, eventables: page foo (patient), user bar (agent)
    # then you can group over foo.events by e.g. same event_type & within x time of each other, and say:
    # foo was edited by bar, baz, and qux
    create_table :event_eventables do |t|
      t.references :event, :default => nil, :null => false
      t.references :event_type, :default => nil, :null => false # duplicate of event.event_type, but makes some queries faster
      t.references :eventable, :polymorphic => true, :default => nil, :null => false
      t.string :role, :default => 'agent', :null => false # what role this thing had in the event. Used as a variable in the template.
      # standard gramattical roles: agent patient instrument recipient etc
      t.integer :index, :default => nil, :null => false # this should be read-only, i.e. set only on create
      
      t.timestamps
      t.userstamps
    end
    
    add_index :event_eventables, [:event_id, :role]
    add_index :event_eventables, [:event_type_id, :role]
    add_index :event_eventables, [:eventable_type, :eventable_id]
  end
  
  def self.down
    drop_table :event_types
    drop_table :events
    drop_table :eventables
  end
end
