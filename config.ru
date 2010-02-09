# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# use Rails::Rack::LogTailer 
# use Rails::Rack::Debugger if options[:debugger] 
# use Rails::Rack::Static 

run Hyperdictionary::Application
