class CommentMailer < ActionMailer::Base
  def new comment, user
    setup_email user, comment
    @subject        += "New comment posted"
    @body[:commentable_name] = commentable_name = comment.commentable.try(:name)
    @subject        += " on #{commentable_name}" if commentable_name
    
    @body[:url]     = polymorphic_url comment.commentable, :host => APP_HOST
  end
  
  def self.upload mail, contact, id = nil
    comment_text = mail.body.split('~~~')[0].strip
    if comment_text.split("\n").last =~ /^>/ # our signal got quoted
      while comment_text.split("\n").last =~ /^>/
        # nix everything at its quote level
        comment_text = comment_text.split("\n")[0..-2].join("\n")
      end
      # and the first line above that (e.g. "On foo date blah wrote:")
      comment_text = comment_text.split("\n")[0..-2].join("\n").strip
    end
    parent = Comment.find(id)  # require lookup in case it's broken
    @comment = Comment.new 
    @comment.comment_type ||= CommentType.find_or_create_by_name('comment')
    @comment.creator = @comment.updater = contact.user
    @comment.commentable = parent.commentable rescue nil
    @comment.body = comment_text
    
    if parent and @comment.save
      # because of how the nested set works (:-/) we have to move it to the child AFTER saving it. Kinda lame.
      @comment.move_to_child_of parent.id
      return true
    else
      CommentMailer.deliver_error mail, comment, contact, parent
    end
  end
  
  def error mail, comment, contact, parent
    subject     "Re: #{email.subject}"
    recipients  mail.from
    from        ADMIN_EMAIL
    sent_on     Time.now
    body        :comment => comment, :contact => contact, :parent => parent
  end
  
  protected
    def setup_email user, comment
      recipients    user.email
      from          "comments+#{comment.id}@#{EMAIL_DOMAIN}"
      subject       "#{APP_NAME}: "
      sent_on       Time.now
      body          :user => user, :comment => comment
    end
end
