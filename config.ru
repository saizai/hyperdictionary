require "config/environment" 

use Rails::Rack::LogTailer 
use Rails::Rack::Debugger if options[:debugger] 
use Rails::Rack::Static 
run ActionController::Dispatcher.new 

