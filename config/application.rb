if ENV['Rails.env'] == 'production'  # don't bother on dev
  ENV['GEM_PATH'] = '/home/kura2/.gem/ruby/1.8' #+ ':/usr/lib/ruby/gems/1.8'  # Need this or Passenger fails to start
#  require '/home/kura2/.gem/ruby/1.8/gems/RedCloth-4.1.9/lib/redcloth.rb'  # Need this for EACH LOCAL gem you want to use, otherwise it uses the ones in /usr/lib
end

# Redirect logger to console if using it
if "irb" == $0
   Rails.logger = Logger.new(STDOUT)
end

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Hyperdictionary
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{Rails.root}/app/sweepers )
    
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    
    # Activate observers that should always be running
    config.active_record.observers = :user_observer, :contact_observer
    
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'UTC'
    ## config.active_record.default_timezone = :utc # only :utc and :local are valid
    
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
    
    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :old_password, :uploaded_data]
  end
end
