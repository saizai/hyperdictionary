class ContactMailer < ActionMailer::Base
  def verification(contact)
    setup_email(contact)
    @subject    += 'Please verify your contact info'  
    @body[:url]  = activate_user_contact_url(@user, contact, :activation_code => contact.activation_code, :host => APP_HOST )
  end
  
  protected
    def setup_email(contact)
      @recipients = "#{contact.data}"
      @from       = "#{ADMIN_EMAIL}"
      @subject    = "#{APP_NAME}: "
      @sent_on    = Time.now
      @body[:contact] = contact
      @user       = contact.user
    end
end
