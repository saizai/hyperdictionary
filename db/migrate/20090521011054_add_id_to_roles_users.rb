class AddIdToRolesUsers < ActiveRecord::Migration
  def self.up
    add_column :roles_users, :id, :primary_key, :null => false
  end
  
  def self.down
    remove_column :roles_users, :id
  end
end
