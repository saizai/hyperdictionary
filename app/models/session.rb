# Note: This class will NOT get autoreloaded in dev mode; you'll have to restart the server to see changes.
class Session < ActiveRecord::SessionStore::Session
  # Not using stampable here 'cause its injection method is a bit complicated for session usage
  attr_accessor :skip_setters
  
  before_save :set_ip
  before_save :set_user
  
  def set_user
    return true if self.skip_setters
    self.creator_id ||= self.data[:user_id] # First user on this session
    self.updater_id = self.data[:user_id] if self.data[:user_id] # Last user on this session
    if self.creator_id and self.updater_id and self.creator_id != self.updater_id
      # TODO: put this in the database somewhere; logged_exceptions perhaps?
      logger.error "MULTI LOGIN: User #{self.creator.login} and #{self.updater.login} from #{self.ip}"
      
      # Save a copy for later inspection
      backup = Session.new {|dup_session| 
        dup_session.attributes = self.attributes
        dup_session.session_id = ActiveSupport::SecureRandom.hex(16) # overwrite the session_id so we don't conflict with the current one & it can't be used to log in
        dup_session.skip_setters = true
      }
      backup.save
      
      # Set this session to be single user again. Updater is what the user looks for; creator is the one that's there to trigger this.
      self.creator_id = self.updater_id
    end
  end
  
  def set_ip
    return true if self.skip_setters
    self.ip = self.data[:ip] if self.data[:ip]
  end
  
  def logged_in?
    !! self.data[:user_id]
  end
end 