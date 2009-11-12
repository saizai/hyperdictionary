class MessageMailer < ActionMailer::Base
  def new message, user
    setup_email user, message
    @subject        += "New message posted"
    @body[:context_name] = context_name = message.context.try(:name)
    @subject        += " on #{context_name}" if context_name
    
    @body[:url]     = polymorphic_url message.context, :host => APP_HOST
  end
  
  def self.upload mail, contact, id = nil
    message_text = mail.body.split('~~~')[0].strip
    if message_text.split("\n").last =~ /^>/ # our signal got quoted
      while message_text.split("\n").last =~ /^>/
        # nix everything at its quote level
        message_text = message_text.split("\n")[0..-2].join("\n")
      end
      # and the first line above that (e.g. "On foo date blah wrote:")
      message_text = message_text.split("\n")[0..-2].join("\n").strip
    end
    parent = Message.find(id)  # require lookup in case it's broken
    @message = Message.new 
    @message.message_type ||= MessageType.find_or_create_by_name('message')
    @message.creator = @message.updater = contact.user
    @message.context = parent.context rescue nil
    @message.body = message_text
    
    if parent and @message.save
      # because of how the nested set works (:-/) we have to move it to the child AFTER saving it. Kinda lame.
      @message.move_to_child_of parent.id
      return true
    else
      MessageMailer.deliver_error mail, message, contact, parent
    end
  end
  
  def error mail, message, contact, parent
    subject     "Re: #{email.subject}"
    recipients  mail.from
    from        ADMIN_EMAIL
    sent_on     Time.now
    body        :message => message, :contact => contact, :parent => parent
  end
  
  protected
    def setup_email user, message
      recipients    user.contacts.emails.active.map(&:data)
# FIXME: what do we do if the user has no verified emails? 
      from          "messages+#{message.id}@#{EMAIL_DOMAIN}"
      subject       "#{APP_NAME}: "
      sent_on       Time.now
      body          :user => user, :message => message
    end
end
