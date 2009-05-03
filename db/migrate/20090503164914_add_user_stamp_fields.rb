class AddUserStampFields < ActiveRecord::Migration
  def self.up
    [:profiles, :tags, :users, :profile_types, :locales, :roles, :sessions, :four_oh_fours, :roles_users].each do |model|
      [:creator_id, :updater_id, :deleter_id].each do |column|
        add_column model, column, :integer
      end
    end
  end
  
  def self.down
    [:profiles, :tags, :users, :profile_types, :locales, :roles, :sessions, :four_oh_fours, :roles_users].each do |model|
      [:creator_id, :updater_id, :deleter_id].each do |column|
        remove_column model, column
      end
    end
  end
end
