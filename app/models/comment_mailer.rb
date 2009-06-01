class CommentMailer < ActionMailer::Base
  def new(comment, user)
    setup_email(user)
    @subject        += "New comment posted"
    @body[:commentable_name] = commentable_name = comment.commentable.try(:name)
    @subject        += " on #{commentable_name}" if commentable_name
    
    @body[:url]     = polymorphic_url comment.commentable, :host => APP_HOST
    @body[:comment] = comment
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
