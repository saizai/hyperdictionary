class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem
  include ExceptionLoggable
  
#  prepend_before_filter {|c| Footnotes::Filter.before c if Rails.env.development?}
#  after_filter {|c| Footnotes::Filter.after c if Rails.env.development?}

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :old_password
  
  # Hack to show what requests a process is handling in top (if it's in short mode)
  before_filter :set_process_name_from_request
  def set_process_name_from_request
    $0 = request.path[0,16] 
  end   
  
  after_filter :unset_process_name_from_request
  def unset_process_name_from_request
    $0 = request.path[0,15] + "*"
  end
end
