class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :locales, [:name, :deleted_at], :unique => true
    add_index :locales, [:abbreviation, :deleted_at], :unique => true
    add_index :locales, :parent_id
    add_index :preferences, [:preferrer_id, :preferrer_type] # faster but less flexible than the reverse
    add_index :preferences, [:preferred_id, :preferred_type]
    add_index :preferences, :name # enables lookup of eg how many people did something
  end

  def self.down
    remove_index :locales, [:name, :deleted_at]
    remove_index :locales, [:abbreviation, :deleted_at]
    remove_index :locales, :parent_id
    remove_index :preferences, [:preferrer_id, :preferrer_type] # faster but less flexible than the reverse
    remove_index :preferences, [:preferred_id, :preferred_type]
    remove_index :preferences, :name
  end
end
