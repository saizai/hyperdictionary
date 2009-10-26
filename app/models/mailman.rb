class Mailman < ActionMailer::Base
  
  def receive mail
    logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}-mail.log") 
    logger.info "Mailman: Receiving mail from #{mail.from.join(',')} to #{mail.to.join(',')}"
#    mail = TMail::Mail.parse raw_mail
#    mms = MMS2R::Media.new mail
    
    if contact = Contact.find_by_data(mail.from, :conditions => {:state => 'active'}, :include => :user) # no need for .first, this'll get the first one
      user = contact.user
      domain = Regexp.new YAML.load_file("#{RAILS_ROOT}/config/mail.yml")[RAILS_ENV]['domain']
p "Got mail from #{user.login} to #{((mail.to || []) + (mail.cc || []))}"      
      case addressee = ((mail.to || []) + (mail.cc || [])).select{|x| x=~domain}.map{|x| x.sub domain, ''}.map{|x| x.sub /@.*/, ''}.first
      when /^upload/ then
        AssetMailer.upload mail, contact
      when /^comments/ then
        CommentMailer.upload mail, contact, addressee.split('+')[1]
        else
        return Mailman.deliver_unknown mail, contact
      end # case
    elsif contact = Contact.find_by_data(mail.from, :include => :user) # not active
      return Mailman.deliver_verification mail, contact
    else
      return Mailman.deliver_bounce mail
    end
  end
  
  def bounce mail
    setup_email mail
    body        :url => root_url(:host => APP_HOST), :email => mail.from.first
  end
  
  def unknown mail, contact
    setup_email mail
    body        :url => root_url(:host => APP_HOST), :contact => contact
  end
  
  def verification mail, contact
    setup_email mail
    body        :url => activate_user_contact_url(@user, contact, :activation_code => contact.activation_code, :host => APP_HOST ),
                :contact => contact, :user => contact.user
  end
  
  protected
    def setup_email mail
      subject     "Re: #{mail.subject}"
      recipients  mail.from
      from        ADMIN_EMAIL
      sent_on     Time.now
    end
end
