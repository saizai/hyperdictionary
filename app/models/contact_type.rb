class ContactType < ActiveRecord::Base
  has_many :contacts
  # meta_type
  
  acts_as_dropdown :order => "meta_type ASC, name ASC", :meta => :meta_type
  
  def email?
    name == 'email'
  end
end
