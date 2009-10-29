class RenameProfilesToPages < ActiveRecord::Migration
  def self.up
    rename_column :profiles, :profile_type_id, :page_type_id
    rename_table :profiles, :pages
    rename_column :profile_versions, :profile_id, :page_id
    rename_column :profile_versions, :profile_type_id, :page_type_id
    rename_table :profile_versions, :page_versions
    rename_table :profile_types, :page_types
    rename_column :profile_translations, :profile_id, :page_id
    rename_table :profile_translations, :page_translations
    
    Comment.update_all('commentable_type = "Page"', 'commentable_type = "Profile"')
    Comment::Version.update_all('commentable_type = "Page"', 'commentable_type = "Profile"')
    Role.update_all('authorizable_type = "Page"', 'authorizable_type = "Profile"')
    Tagging.update_all('taggable_type = "Page"', 'taggable_type = "Profile"')
    Slug.destroy_all('sluggable_type = "Profile"')
  end
  
  def self.down
    rename_table :pages, :profiles
    rename_column :profiles, :page_type_id, :profile_type_id
    rename_table :page_verions, :profile_versions
    rename_column :profile_versions, :page_id, :profile_id
    rename_column :profile_versions, :page_type_id, :profile_type_id
    rename_table :page_types, :profile_types
    rename_table :page_translations, :profile_translations
    rename_column :profile_translations, :page_id, :profile_id 
    
    Comment.update_all('commentable_type = "Profile"', 'commentable_type = "Page"')
    Comment::Version.update_all('commentable_type = "Profile"', 'commentable_type = "Page"')
    Role.update_all('authorizable_type = "Profile"', 'authorizable_type = "Page"')
    Tagging.update_all('taggable_type = "Profile"', 'taggable_type = "Page"')
  end
end
