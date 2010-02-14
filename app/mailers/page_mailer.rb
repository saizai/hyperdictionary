class PageMailer < ActionMailer::Base
  

  def update(page, user)
    setup_email(user)
    @subject        += "#{page.name}'s' page updated"
    
    @body[:url]     = page_url(page, :host => APP_HOST)
    @body[:page] = page
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