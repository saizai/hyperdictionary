class TranslateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profile_translations do |t|
      t.references :profile
      t.string :locale
      t.text :body
      
      t.integer :lock_version
      t.timestamps
      t.datetime :deleted_at
      t.userstamps true
    end
    
    add_index :profile_translations, [:profile_id, :locale]
    
    add_column :profile_versions, :translations_glob, :text
    
    I18n.locale = :en # Assume that everything so far has been written in English
    
    Profile::Version.delete_all # see below. Too much of a pain to move over.
    
    # find_each ensures we don't grab something huge
    Profile.find_each(:batch_size => 100, :include => :globalize_translations, :conditions => 'body IS NOT NULL') {|profile|
      # Globalize overwrote the .body= and .body accessors to hook to its table, above.
      # So we need to undercut it to read the real thing and set it, thus seeding the translations table
      # This should also set the versions table's glob for the newly set, most recent version.
      profile.body = profile.read_attribute :body
      profile.updated_at = Time.now # Force save so it propogates to the version
      profile.save
      # Unfortunately, updating old versions is kinda tricky.
      # To do this, one would need to ensure that Profile::Version also has the globalize hooks, and so the above for each of them, while disabling optimistic locking and versioning.
      # You can't just clone the one we just set, because then you'd be effectively blowing away your saved version of the body - it has to be done for every single version
      # Or you could detect whether the body was actually changed, only create if it's different, etc....
      # Basically too much of a pain in the ass to do really, unless there's a large base of stuff that has to be kept.
    }
    
    remove_column :profile_versions, :body 
    remove_column :profiles, :body # We no longer have a 'canonical' source, there's just the translations
  end
  
  def self.down
    add_column :profiles, :body, :text, :default => nil
    add_column :profile_versions, :body, :text, :default => nil
    
    Profile::Version.delete_all
    
    Profile.find_each(:batch_size => 100, :include => :globalize_translations) {|profile|
      profile.write_attribute :body, profile.body # write_attribute undercuts the accessor
      profile.save
    }
    
    drop_table :profile_translations    
    remove_column :profile_versions, :translations_glob
  end
end
