class RemoveEmailFromUsers < ActiveRecord::Migration
  def self.up
    User.find_each do |user|
      contact = user.contacts.find(:first, :conditions => {:contact_type_id => ContactType.find_by_name('email').id, :data => user.email}) ||
        user.contacts.build(:contact_type_id => ContactType.find_by_name('email').id, :data => user.email, :state => user.state, :activation_code => user.activation_code)
      contact.register! unless user.active?
      
      user.identities.each {|identity|
        contact = user.contacts.find(:first, :conditions => {:contact_type_id => ContactType.find_by_name('email').id, :data => identity.email}) ||
          user.contacts.build(:contact_type_id => ContactType.find_by_name('email').id, :data => identity.email, :preverified => identity.email_verified)
        contact.register! unless contact.active?
      }
      
      user.save
    end
    
    remove_column :users, :email
    remove_column :users, :activation_code
    remove_column :users, :activated_at    
  end

  def self.down
    add_column :users, :email, :string, :limit => 100
    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :activated_at, :datetime 
  end
end
