class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.references :user, :contact_type, :default => nil, :null => false
      t.string :data, :activation_code, :default => nil
      t.string :state, :null => false, :default => 'passive'
      t.boolean :public, :preverified, :default => false
      
      t.timestamps
      t.datetime :deleted_at, :activated_at
      t.userstamps true
    end
    
    add_index :contacts, [:user_id, :contact_type_id]
    add_index :contacts, [:contact_type_id, :data], :unique => true
  end

  def self.down
    drop_table :contacts
  end
end
