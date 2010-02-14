class AssetMailer < ActionMailer::Base
  default :from => ADMIN_EMAIL, :sent_on => Time.now
  
  def self.upload mail, contact
    mail.attachments.each do |attachment|
      asset = Asset.new(:uploaded_data => attachment, :creator => contact.user, :updater => contact.user)
      if asset.save
        AssetMailer.deliver_confirm mail, asset, contact
      else
        AssetMailer.deliver_error mail, asset, contact    
      end
    end # attachment
    
    AssetMailer.deliver_empty mail, contact if mail.attachments.empty?
    return true
  end
  
  def confirm mail, asset, contact
    setup_email mail
    body        :asset => asset, :contact => contact
  end
  
  def error mail, asset, contact
    setup_email mail
    body        :asset => asset, :contact => contact
  end
  
  def empty mail, contact
    setup_email mail
    body        :asset => asset, :contact => contact
  end
  
  protected
    def setup_email mail
      subject     "Re: #{mail.subject}"
      recipients  mail.from
    end
end
