class Mailman < ActionMailer::Base
  
  def receive mail
    logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}-mail.log") 
    logger.info "Mailman: Receiving mail from #{mail.from.join(',')} to #{mail.to.join(',')}"
#    mail = TMail::Mail.parse raw_mail
#    mms = MMS2R::Media.new mail
    
    user = User.find_by_email mail.from.first
    if user
      domain = Regexp.new YAML.load_file("#{RAILS_ROOT}/config/mail.yml")[RAILS_ENV]['domain']
      
      ((mail.to || []) + (mail.cc || [])).select{|x| x=~domain}.map{|x| x.sub domain, ''}.map{|x| x.sub /@.*/, ''}.each do |addressee|
        case addressee
        when 'catchall', 'upload' then
          mail.attachments.each do |attachment|
#            if attachment.content_type.split('/').first == 'image' 
              if asset = Asset.create!(:uploaded_data => attachment, :creator => user, :updater => user)
                logger.info "Mailman: Asset created for #{user.login}: #{asset.filename}"
              else
                logger.info "Mailman: Asset failed to create for #{user.login}: #{attachment.original_filename}"          
              end
#            else
#                logger.info "Asset refused - unaccepted type #{attachment.content_type}, :user #{user.login}"          
#            end
          end # attachment
          
          logger.info "Mailman: No attachments found for #{user.login}." if mail.attachments.empty?
        else
          logger.info "Mailman: Not sent to us by #{user.login}. BCCed perhaps?"
        end # case
      end # addressees
    else
      # TODO: mail them back and say we don't know 'em
      logger.info "Mailman: Unknown email: #{mail.from.first}"
    end
  end

end
