class CreateProfileTypes < ActiveRecord::Migration
  def self.up
    create_table :profile_types do |t|
      t.string :name, :default => nil, :null => false

      t.timestamps
    end
    
    add_index :profile_types, :name, :unique => true
    
    # import syntax: [columns], [[record fields], [record], ...]
    ProfileType.import [:name], %w(person project group).map(&:to_a), :validate => false
  end

  def self.down
    drop_table :profile_types
  end
end
