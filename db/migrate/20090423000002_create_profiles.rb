class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.text :body, :default => nil
      t.references :profile_type, :default => nil, :null => false
      t.references :user, :default => nil
      t.string :url, :default => nil
      t.string :name, :default => nil, :null => false
      
      t.timestamps
    end
    
    add_index :profiles, :url, :unique => true
    add_index :profiles, :user_id # Only one profile per user, but not all profiles have users, so can't be unique (nil case)
    add_index :profiles, :name, :unique => true
    add_index :profiles, :profile_type_id
    
    # acts_as_paranoid (introduced in a later migration) breaks this
    # Profile.create :name => 'Kura', :profile_type_id => ProfileType.find_by_name('project').id, :url => 'http://dictionary.conlang.org', :body => "What you're lookin' at, bub."
    
    User.all.each do |user|
      user.before_create # invokes profile creation
      user.save
    end
  end

  def self.down
    drop_table :profiles
  end
end
