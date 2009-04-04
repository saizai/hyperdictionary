class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.column :preferrer_id,    :integer,               :null => false
      t.column :preferrer_type,  :string, :limit => 128, :null => false
      t.column :preferred_id,    :integer
      t.column :preferred_type,  :string,                :null => false
      t.column :name,            :string, :limit => 128, :null => false
      t.column :value,           :text
    end
  end

  def self.down
    drop_table :preferences
  end
end
