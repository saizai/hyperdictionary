# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if ENV['RAILS_ENV'] == 'production'  # don't bother on dev
  ENV['GEM_PATH'] = '/home/kura2/.gem/ruby/1.8' #+ ':/usr/lib/ruby/gems/1.8'  # Need this or Passenger fails to start
#  require '/home/kura2/.gem/ruby/1.8/gems/RedCloth-4.1.9/lib/redcloth.rb'  # Need this for EACH LOCAL gem you want to use, otherwise it uses the ones in /usr/lib
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem 'rake'
  config.gem 'ruby-openid', :lib => 'openid'
  config.gem 'capistrano'
  config.gem 'mperham-memcache-client', :lib => 'memcache', :source => 'http://gems.github.com'
  config.gem 'rubaidh-google_analytics', :lib => 'rubaidh/google_analytics', :source => 'http://gems.github.com'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate'
  config.gem 'uuidtools'
  config.gem "grosser-rpx_now", :lib => "rpx_now", :source => "http://gems.github.com"
  config.gem 'lockfile'
  config.gem "friendly_id"
  config.gem 'chrislloyd-gravtastic', :lib => 'gravtastic', :version => '>= 2.1.0'
  config.gem 'sishen-rtranslate', :lib => 'rtranslate', :version => '>= 1.0'
#  config.gem 'tmtm-ruby-mysql', :lib => 'Mysql', :source => 'http://gems.github.com'
#  config.gem "sqlite3-ruby", :lib => "sqlite3"
#  config.gem 'rack'
#  config.gem 'test-spec', :version => '~> 0.9.0' # required for rack-rack-contrib (note: 0.10.0 is current)
#  config.gem 'rack-rack-contrib', :lib => 'rack/contrib',  :source => 'http://gems.github.com'

  # Not frozen because they cause conflicts and/or require native extensions
  config.gem 'rmagick', :lib => 'RMagick' # NOTE: installation for this is nontrivial. See its website (+ the DreamHost wiki, if on DH)
  config.gem 'mms2r'
  config.gem 'hpricot' # required by mms2r
  config.gem 'francois-piston', :lib => 'piston', :source => 'http://gems.github.com'
  config.gem 'ruby-debug'
  config.gem 'SystemTimer', :lib => 'system_timer' # makes memcache faster
#  config.gem 'RedCloth', :lib => 'redcloth'
  config.gem 'bluecloth' # lowercase is 2.x, camelcase is 1.x
  config.gem 'utf8proc'
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
