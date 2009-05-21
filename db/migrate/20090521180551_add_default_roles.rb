class AddDefaultRoles < ActiveRecord::Migration
  def self.up
    Profile.find_each {|profile|
      profile.creator.has_role 'owner', profile if profile.creator
      profile.owner.has_role 'owner', profile if profile.owner
      AnonUser.has_role 'commenter', profile
    }
  end

  def self.down
  end
end
