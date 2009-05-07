class AddAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.references :attachable, :polymorphic => true, :default => nil
      
      t.column :size,         :integer  # file size in bytes
      t.column :content_type, :string   # mime type, ex: application/mp3
      t.column :filename,     :string   # sanitized filename
      # For images:
      t.column :height,       :integer  # in pixels
      t.column :width,        :integer  # in pixels
      # For thumbnails:
      t.column :parent_id,    :integer  # id of parent image (on the same table, a self-referencing foreign-key).
      t.column :thumbnail,    :string   # the 'type' of thumbnail this attachment record describes.
      t.column :db_file_id,   :integer  # id of the file in the database (foreign key)
      
      t.userstamps true
      t.timestamps
      t.column :deleted_at,   :datetime
    end
    
    add_index :assets, :content_type
    add_index :assets, :parent_id
  end

  def self.down
    drop_table :assets
  end
end
