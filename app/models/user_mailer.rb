class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Welcome!'
    @body[:url]  = "http://#{APP_HOST}/login"
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'You have requested to change your password.'
    @body[:url]  = "http://#{APP_HOST}/reset_password/#{user.password_reset_code}"
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset.'
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{ADMIN_EMAIL}"
      @subject     = "#{APP_NAME} "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
