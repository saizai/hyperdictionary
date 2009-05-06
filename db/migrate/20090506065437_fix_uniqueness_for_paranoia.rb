class FixUniquenessForParanoia < ActiveRecord::Migration
  def self.up
    # This allows recreation of the same-named thing
    remove_index :profiles, :url
    remove_index :profiles, :name
    remove_index :comment_types, :name
    remove_index :four_oh_fours, [:url, :referer]
    remove_index :four_oh_fours, :url # was superflous
    remove_index :profile_types, :name
    add_index :profiles, [:url, :deleted_at], :unique => true
    add_index :profiles, [:name, :deleted_at], :unique => true
    add_index :comment_types, [:name, :deleted_at], :unique => true
    add_index :four_oh_fours, [:url, :referer, :deleted_at], :unique => true
    add_index :profile_types, [:name, :deleted_at], :unique => true
  end

  def self.down
    remove_index :profiles, [:url, :deleted_at]
    remove_index :profiles, [:name, :deleted_at]
    remove_index :comment_types, [:name, :deleted_at]
    remove_index :profile_types, [:name, :deleted_at]
    remove_index :four_oh_fours, [:url, :referer, :deleted_at]
    add_index :four_oh_fours, [:url, :referer], :unique => true
    add_index :four_oh_fours, :url
    add_index :profiles, :url, :unique => true
    add_index :profiles, :name, :unique => true
    add_index :comment_types, :name, :unique => true
    add_index :profile_types, :name, :unique => true
  end
end
