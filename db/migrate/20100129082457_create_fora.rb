class CreateFora < ActiveRecord::Migration
  def self.up
    drop_table :fora
    create_table :fora do |t|
      t.string :name, :default => nil, :null => false
      t.string :description, :default => nil
      t.references :parent, :last_discussion, :last_message, :default => nil
      t.references :context, :polymorphic => true # for now at least, fora only belong to a single context 
      t.boolean :has_discussions, :default => true, :null => false # if false then this is just a wrapper forum for subfora, with no discussions of its own
      t.integer :discussions_count, :messages_count, :default => 0, :null => false
      
      t.userstamps
      t.timestamps
    end
    
    add_index :fora, :parent_id
    add_index :fora, [:context_type, :context_id, :name], :unique => true
    add_index :fora, :name # for search. Might need to add a real full text search on this and description though
    
    Page.find_each do |page| 
      dd = page.discussions
      next if dd.blank? # don't create unpopulated fora
      f = page.fora.create(:name => page.name + ' forum')
      dd.map{|d| d.contexts << f; d.save}
    end
    
  end
  
  def self.down
    drop_table :fora
  end
end
