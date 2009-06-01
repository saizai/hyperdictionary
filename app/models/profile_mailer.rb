class ProfileMailer < ActionMailer::Base
  

  def update(profile, user)
    setup_email(user)
    @subject        += "#{profile.name}'s' profile updated"
    
    @body[:url]     = profile_url(profile, :host => APP_HOST)
    @body[:profile] = profile
  end

  protected
    def setup_email(user)
      @recipients  = user.email
      @from        = ADMIN_EMAIL
      @subject     = "#{APP_NAME}: "
      @sent_on     = Time.now
      @body[:user] = user
    end
end