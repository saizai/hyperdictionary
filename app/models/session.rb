# This class is mostly just a placeholder; it exposes sessions (which are in the DB anyway) to us as a normal-ish model.
# Note that the +data+ field is magic; behind the scenes its actually base 64 encoded marshalled data, but on access it's unpacked into the familiar session hash.
# Also note that this means we can do really hackish (but potentially useful?) things like directly editing a logged in user's session
#
# Note that data['flash'] is not a Hash, it's a ActionController::Flash::FlashHash; they are not interchangeable. 
# You must access it through the class methods (e.g. data['flash'][:notice] = 'Hello from the spooky admin!') or it will make the user's session crash.
#
# Another thing this allows is direct lookup of sessions, in case (for usually hackish reasons) we need to bind a session in an unusual way.
# Be careful about security (e.g. CSRF) when doing this! E.g. use :authenticity_token => form_authenticity_token + protect_from_forgery (on by default for non-GET requests).
#
# Note: This class will NOT get autoreloaded in dev mode; you'll have to restart the server to see changes.
class Session < ActiveRecord::SessionStore::Session
  acts_as_paranoid
  stampable
  
  # supposedly fixes 'can't dup NilClass' error introduced in rails 2.3.3 - see https://rails.lighthouseapp.com/projects/8994/tickets/2441-activerecordsessionstore-breaks-with-custom-model
  # also note https://rails.lighthouseapp.com/projects/8994/tickets/1339
  # unloadable
  
  named_scope :live, :conditions => ["updated_at > ?", 5.minutes.ago]
  named_scope :stale, :conditions => ["updated_at < ?", 1.week.ago]
  
  def before_destroy
    user = (updater || creator)
    user.update_attribute :time_in_app, user.time_in_app + self.duration if user 
  end
  
  # This just moves some fields from the session data to the session itself.
  # It lets us then do indexed lookups on the sessions.
  # e.g. Session.find_all_by_ip('1.2.3.4').map(&:updater_id).uniq gets us all the users from a particular IP :-)
  before_save :set_ip
  def set_ip
    self.ip = self.data[:last_ip] if self.data[:last_ip]
    self.creator_id ||= self.data[:last_user_id]
    self.updater_id = self.data[:last_user_id]
  end
  
  before_save :set_duration
  def set_duration
    self.duration += [5.minutes, Time.now - (updated_at || 1.minute.ago)].min.to_i
  end
  
end 