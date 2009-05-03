class AddParanoia < ActiveRecord::Migration
  def self.up
    [:profiles, :tags, :profile_types, :locales, :roles, :sessions, :four_oh_fours, :roles_users].each do |model|
      add_column model, :deleted_at, :datetime
    end
  end

  def self.down
    [:profiles, :tags, :profile_types, :locales, :roles, :sessions, :four_oh_fours, :roles_users].each do |model|
      remove_column model, :deleted_at
    end
  end
end
