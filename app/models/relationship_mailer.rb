class RelationshipMailer < ActionMailer::Base
  def confirmation_request(relationship)
    setup_email(relationship)
    @subject    += "#{relationship.from_user.login} added you as a friend."
    recipients  relationship.to_user.email
    
    body       :user => relationship.to_user, :from_user => relationship.from_user, :url => user_url(relationship.from_user, :host => APP_HOST)
  end
  
  def reciprocation_notice(relationship)
    setup_email(relationship)
    @subject    += "#{relationship.to_user.login} added you back."
    recipients  relationship.from_user.email
    
    body       :user => relationship.from_user, :from_user => relationship.to_user, :url => user_url(relationship.to_user, :host => APP_HOST)
  end
  
  protected
    def setup_email(relationship)
      from       "#{ADMIN_EMAIL}"
      subject    "#{APP_NAME}: "
      sent_on    Time.now
    end
end
