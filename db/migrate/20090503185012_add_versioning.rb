class AddVersioning < ActiveRecord::Migration
  # For even more paranoia. Not only do we lie instead of deleting things, we save every version too.
  # While we're at it, we might as well get the benefit of doing automatic optimistic locking
  def self.up
    [:users, :profiles, :locales, :comments, :comment_types].each do |model|
      add_column model, :lock_version, :integer, :default => 0
      model.to_s.classify.constantize.create_versioned_table
    end
  end

  def self.down
    [:users, :profiles, :locales, :comments, :comment_types].each do |model|
      model.to_s.classify.constantize.drop_versioned_table
      remove_column model, :lock_version
    end
  end
end
