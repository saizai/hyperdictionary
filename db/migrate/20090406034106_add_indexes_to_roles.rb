class AddIndexesToRoles < ActiveRecord::Migration
  def self.up
    add_index :roles_users, :role_id
    add_index :roles_users, :user_id
    add_index :roles, :name
  end

  def self.down
  end
end
