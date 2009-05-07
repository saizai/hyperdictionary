class ApplicationController < ActionController::Base  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem
  include ExceptionLoggable
  include Userstamp
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :old_password
  
  # Hack to show what requests a process is handling in top (if it's in short mode)
  $PROC_NAME ||= "#{$0} #{$*.join(' ')}" # keep the original. Note that this isn't really what ps thinks it was to start; ruby's $0 isn't very smart, it seems
  
  before_filter :set_process_name_from_request
  def set_process_name_from_request
    $0 = request.path[0,16] + ' ' + $PROC_NAME
  end
  
  after_filter :unset_process_name_from_request
  def unset_process_name_from_request
    $0 = request.path[0,15] + "* " + $PROC_NAME
  end

  # This is a hack to get around cases (eg Flash) where we don't get the cookie per normal. 
  # Must be prepended to ensure it executes before anyone tries to access (and thus set) current_user
  # This is probably not the best way to do it, though; eg we ought to first check whether they log in from cookie, THEN try this
  prepend_before_filter :set_session_from_query
  def set_session_from_query
    # Refuse to set if we already have an active session
    self.session = ActiveRecord::SessionStore::Session.find_by_session_id(params[SESSION_KEY.to_sym]).data if params[SESSION_KEY.to_sym] and (session.nil? or session.empty?)
  end
end
