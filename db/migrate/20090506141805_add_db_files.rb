class AddDbFiles < ActiveRecord::Migration
  def self.up
    create_table :db_files do |t|
      t.column :data, :binary # binary file data, for use in database file storage
    end
  end

  def self.down
    drop_table :db_files
  end
end
