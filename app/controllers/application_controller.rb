class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include AuthenticatedSystem
  include ExceptionLoggable
  
#  prepend_before_filter {|c| Footnotes::Filter.before c if Rails.env.development?}
#  after_filter {|c| Footnotes::Filter.after c if Rails.env.development?}

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :old_password


  
end
