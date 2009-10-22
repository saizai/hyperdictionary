class CreateContactTypes < ActiveRecord::Migration
  def self.up
    create_table :contact_types do |t|
      t.string :name, :meta_type, :default => nil
      t.boolean :verifiable, :default => false
      t.timestamps
    end
    
    add_index :contact_types, [:meta_type, :name], :unique => true
    
    ContactType.create :name => 'email', :verifiable => true
    %w(fax home cell work other).each do |x|
      ContactType.create :meta_type => 'phone', :name => x, :verifiable => false
    end
    ContactType.create :name => 'address', :verifiable => false
    %w(AIM Yahoo! Jabber ICQ MSN LiveJournal).each do |x|
      ContactType.create :meta_type => 'IM', :name => x, :verifiable => false
    end
    
  end

  def self.down
    drop_table :contact_types
  end
end
