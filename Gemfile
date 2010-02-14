# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
# path "/path/to/rails", :glob => "{*/,}*.gemspec"
git "git://github.com/rails/rack.git"
git "git://github.com/rails/arel.git"

# gem "rails", "3.0.0.beta"
gem "rails", :git => "git://github.com/rails/rails.git" # edge


source 'http://gemcutter.org'

gem 'aasm', '>= 2.1.5'


source 'http://gems.github.com'

gem 'rake'
# gem 'capistrano'
gem 'mperham-memcache-client', :require => 'memcache'
gem 'rubaidh-google_analytics', :require => 'rubaidh/google_analytics' # adds google analytics' code to all pages
gem 'will_paginate', '>= 2.3.11'  # the standard way to paginate things. We override it to use AJAX.
gem 'uuidtools'  # generates universally unique IDs (UUIDs) with good randomness, plus some associated utilities 
gem 'grosser-rpx_now', :require => 'rpx_now' # handles and normalizes OpenID/Facebook/Twitter/etc logins
gem 'lockfile'  # used by mail reader script, ensures only one copy is running at a time
gem 'friendly_id' # allows "nice" urls, e.g. /users/saizai instead of /users/1
gem 'chrislloyd-gravtastic', '>= 2.1.0', :require => 'gravtastic'
# gem 'sishen-rtranslate', '>= 1.0', :require => 'rtranslate'
gem 'ar-extensions', '>= 0.9.2' # adds more efficient bulk tools to ActiveRecord (e.g. import)
# gem 'bullet' # notifies dev of N+1 (aka eager loading) bugs
gem 'validation_reflection', '>= 0.3.5' # required by Validatious
gem 'validatious-on-rails' # hooks in Validatious client-side JS/AJAX validation
gem 'geoip'

# Not frozen because they cause conflicts and/or require native extensions
# gem 'rmagick', :require => 'RMagick' # NOTE: installation for this is nontrivial. See its website (+ the DreamHost wiki, if on DH)
gem 'mms2r'
gem 'hpricot'
gem 'francois-piston', :require => 'piston'
# gem 'SystemTimer', :require => 'system_timer' # makes memcache faster
gem 'bluecloth' # lowercase is 2.x, camelcase is 1.x
gem 'utf8proc'
