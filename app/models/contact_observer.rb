class ContactObserver < ActiveRecord::Observer
  def after_save(contact)
    ContactMailer.verification(contact).deliver if contact.recently_registered and contact.email?

    # TODO: verify phones
    # TODO: verify IMs
  end
end
