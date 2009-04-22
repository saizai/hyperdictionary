class AddPasswordResetCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reset_code, :string, :limit => 40
    add_index :users, :password_reset_code
  end

  def self.down
#    remove_index :users, :password_reset_code
    remove_column :users, :password_reset_code
  end
end
